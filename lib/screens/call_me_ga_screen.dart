import 'package:flutter/material.dart';
import 'package:super_app_wahana/services/auth_service.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class CallMeGaScreen extends StatefulWidget {
  const CallMeGaScreen({super.key});

  @override
  State<CallMeGaScreen> createState() => _CallMeGAState();
}

class _CallMeGAState extends State<CallMeGaScreen> {
  WebViewController? _controller;
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
        Permission.photos,
        Permission.storage,
      ].request();

      debugPrint('Permission Camera: ${statuses[Permission.camera]}');
      debugPrint('Permission Photos: ${statuses[Permission.photos]}');
      debugPrint('Permission Storage: ${statuses[Permission.storage]}');
    } else if (Platform.isIOS) {
      await [
        Permission.camera,
        Permission.photos,
      ].request();
    }
  }

  Future<void> _initializeController() async {
    try {
      await _requestPermissions();
      final token = await AuthService.getToken() ?? '';

      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (url) {
              debugPrint('Page started: $url');
              setState(() => _isLoading = true);
            },
            onPageFinished: (url) {
              debugPrint('Page finished: $url');
              setState(() => _isLoading = false);
            },
          ),
        );

      // Setup file picker untuk Android
      if (Platform.isAndroid) {
        final androidController = _controller!.platform as AndroidWebViewController;
        await androidController.setOnShowFileSelector(_handleFilePicker);
        debugPrint('File selector handler registered');
      }

      await _controller!.loadRequest(
        Uri.parse('http://124.243.134.244/callme'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error initializing controller: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading page: $e')),
        );
      }
    }
  }

  Future<List<String>> _handleFilePicker(FileSelectorParams params) async {
    debugPrint('File selector triggered!');
    debugPrint('Accept types: ${params.acceptTypes}');
    debugPrint('Mode: ${params.mode}');
    debugPrint('Is capture: ${params.isCaptureEnabled}');

    try {
      final String? source = await showModalBottomSheet<String>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (BuildContext context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Select Image Source',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Color(0xFFB3282D)),
                  title: const Text('Take Photo'),
                  onTap: () => Navigator.pop(context, 'camera'),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Color(0xFFB3282D)),
                  title: const Text('Photo Library'),
                  onTap: () => Navigator.pop(context, 'gallery'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.cancel, color: Colors.grey),
                  title: const Text('Cancel'),
                  onTap: () => Navigator.pop(context, null),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      );

      debugPrint('User selected: $source');

      if (source == null) {
        debugPrint('User cancelled selection');
        return [];
      }

      XFile? file;
      if (source == 'camera') {
        debugPrint('Opening camera...');
        file = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
          maxWidth: 1920,
          maxHeight: 1920,
        );
      } else if (source == 'gallery') {
        debugPrint('Opening gallery...');
        file = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
          maxWidth: 1920,
          maxHeight: 1920,
        );
      }

      if (file != null) {
        debugPrint('File selected: ${file.path}');
        debugPrint('File exists: ${await File(file.path).exists()}');
        debugPrint('File size: ${await File(file.path).length()} bytes');

        // Convert file path to file:// URI
        final fileUri = Uri.file(file.path).toString();
        debugPrint('File URI: $fileUri');

        return [fileUri];
      } else {
        debugPrint('No file selected');
        return [];
      }
    } catch (e) {
      debugPrint('Error in file picker: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call Me GA'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: const Color(0xFFB3282D),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset(
              'assets/logo_wag_white.png',
              width: 36,
              height: 36,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            if (_controller != null) WebViewWidget(controller: _controller!),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFB3282D),
                ),
              ),
          ],
        ),
      ),
    );
  }
}