import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewDownloadService {
  WebViewDownloadService._();

  static const String _javaScriptChannelName = 'SuperAppDownload';
  static const MethodChannel _platformChannel = MethodChannel(
    'com.example.super_app_wahana/downloads',
  );

  static Future<void> register(
    WebViewController controller,
    BuildContext context,
  ) async {
    await controller.addJavaScriptChannel(
      _javaScriptChannelName,
      onMessageReceived: (message) => _handleMessage(context, message.message),
    );
  }

  static Future<void> injectInterceptor(WebViewController controller) async {
    await controller.runJavaScript(_downloadInterceptorScript);
  }

  static Future<void> _handleMessage(
    BuildContext context,
    String message,
  ) async {
    try {
      final payload = _DownloadPayload.fromMessage(message);
      final savedLocation = await _saveFile(payload);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${payload.fileName} tersimpan di $savedLocation'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download gagal: ${_friendlyError(error)}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static Future<String> _saveFile(_DownloadPayload payload) async {
    try {
      return await _invokeSave(payload);
    } on PlatformException catch (error) {
      if (error.code != 'STORAGE_PERMISSION_REQUIRED' || !Platform.isAndroid) {
        rethrow;
      }

      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw const FileSystemException('Izin penyimpanan ditolak');
      }

      return _invokeSave(payload);
    }
  }

  static Future<String> _invokeSave(_DownloadPayload payload) async {
    final result = await _platformChannel.invokeMethod<String>('saveFile', {
      'fileName': payload.fileName,
      'mimeType': payload.mimeType,
      'bytes': payload.bytes,
    });

    if (result == null || result.isEmpty) {
      throw const FileSystemException('Lokasi file tidak tersedia');
    }
    return result;
  }

  static String _friendlyError(Object error) {
    if (error is FormatException || error is ArgumentError) {
      return 'data file dari halaman tidak valid';
    }
    if (error is MissingPluginException) {
      return 'fitur ini belum tersedia pada perangkat';
    }
    if (error is PlatformException) {
      return error.message ?? 'file tidak dapat disimpan';
    }
    if (error is FileSystemException) {
      return error.message;
    }
    return error.toString();
  }

  static const String _downloadInterceptorScript = r'''
    (() => {
      if (window.__superAppDownloadInstalled) return;
      window.__superAppDownloadInstalled = true;

      const objectUrls = new Map();
      const originalCreateObjectURL = URL.createObjectURL.bind(URL);
      const originalRevokeObjectURL = URL.revokeObjectURL.bind(URL);

      URL.createObjectURL = (object) => {
        const url = originalCreateObjectURL(object);
        if (object instanceof Blob) objectUrls.set(url, object);
        return url;
      };

      URL.revokeObjectURL = (url) => {
        originalRevokeObjectURL(url);
        setTimeout(() => objectUrls.delete(url), 60000);
      };

      const sendBlob = (blob, fileName) => {
        const reader = new FileReader();
        reader.onloadend = () => {
          const dataUrl = String(reader.result || '');
          const comma = dataUrl.indexOf(',');
          if (comma < 0) throw new Error('File tidak dapat dibaca');

          SuperAppDownload.postMessage(JSON.stringify({
            fileName: fileName || 'download',
            mimeType: blob.type || 'application/octet-stream',
            base64: dataUrl.substring(comma + 1),
          }));
        };
        reader.readAsDataURL(blob);
      };

      document.addEventListener('click', async (event) => {
        const target = event.target;
        const anchor = target && target.closest ? target.closest('a') : null;
        if (!anchor) return;

        const href = anchor.href || '';
        const isDownload = anchor.hasAttribute('download');
        const isLocalFile = href.startsWith('blob:') || href.startsWith('data:');
        if (!isDownload && !isLocalFile) return;

        event.preventDefault();
        event.stopImmediatePropagation();

        try {
          const capturedBlob = objectUrls.get(href);
          if (capturedBlob) {
            sendBlob(capturedBlob, anchor.getAttribute('download') || 'download');
            return;
          }

          const response = await fetch(href, { credentials: 'include' });
          if (!response.ok) {
            throw new Error(`HTTP ${response.status}`);
          }
          const blob = await response.blob();
          let fileName = anchor.getAttribute('download') || '';
          if (!fileName) {
            const pathName = new URL(href, document.baseURI).pathname;
            fileName = pathName.split('/').pop() || 'download';
          }
          sendBlob(blob, fileName);
        } catch (error) {
          SuperAppDownload.postMessage(JSON.stringify({
            error: error && error.message ? error.message : String(error),
          }));
        }
      }, true);
    })();
  ''';
}

class _DownloadPayload {
  const _DownloadPayload({
    required this.fileName,
    required this.mimeType,
    required this.bytes,
  });

  factory _DownloadPayload.fromMessage(String message) {
    final decoded = jsonDecode(message);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Payload download bukan object');
    }

    final remoteError = decoded['error'];
    if (remoteError is String && remoteError.isNotEmpty) {
      throw FileSystemException(remoteError);
    }

    final encodedBytes = decoded['base64'];
    if (encodedBytes is! String || encodedBytes.isEmpty) {
      throw const FormatException('Isi file kosong');
    }

    final rawFileName = decoded['fileName'];
    final rawMimeType = decoded['mimeType'];
    return _DownloadPayload(
      fileName: _sanitizeFileName(
        rawFileName is String ? rawFileName : 'download',
      ),
      mimeType: rawMimeType is String && rawMimeType.isNotEmpty
          ? rawMimeType
          : 'application/octet-stream',
      bytes: Uint8List.fromList(base64Decode(encodedBytes)),
    );
  }

  final String fileName;
  final String mimeType;
  final Uint8List bytes;

  static String _sanitizeFileName(String value) {
    final sanitized = value
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'[\x00-\x1F]'), '')
        .trim();
    return sanitized.isEmpty ? 'download' : sanitized;
  }
}
