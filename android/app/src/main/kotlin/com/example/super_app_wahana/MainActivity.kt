package com.example.super_app_wahana

import android.Manifest
import android.content.ContentValues
import android.content.pm.PackageManager
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    companion object {
        private const val DOWNLOAD_CHANNEL = "com.example.super_app_wahana/downloads"
        private const val DOWNLOAD_FOLDER = "Wahana SuperApp"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            DOWNLOAD_CHANNEL,
        ).setMethodCallHandler { call, result ->
            if (call.method != "saveFile") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            val fileName = call.argument<String>("fileName")
            val mimeType = call.argument<String>("mimeType") ?: "application/octet-stream"
            val bytes = call.argument<ByteArray>("bytes")

            if (fileName.isNullOrBlank() || bytes == null) {
                result.error("INVALID_DOWNLOAD", "Nama atau isi file tidak valid", null)
                return@setMethodCallHandler
            }

            try {
                result.success(saveToDownloads(fileName, mimeType, bytes))
            } catch (error: SecurityException) {
                result.error(
                    "STORAGE_PERMISSION_REQUIRED",
                    "Izin penyimpanan diperlukan untuk mengunduh file",
                    null,
                )
            } catch (error: Exception) {
                result.error("SAVE_FAILED", error.message ?: "File tidak dapat disimpan", null)
            }
        }
    }

    private fun saveToDownloads(fileName: String, mimeType: String, bytes: ByteArray): String {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val values = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
                put(
                    MediaStore.MediaColumns.RELATIVE_PATH,
                    "${Environment.DIRECTORY_DOWNLOADS}/$DOWNLOAD_FOLDER",
                )
                put(MediaStore.MediaColumns.IS_PENDING, 1)
            }

            val uri = contentResolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
                ?: throw IllegalStateException("Tidak dapat membuat file download")

            try {
                contentResolver.openOutputStream(uri)?.use { stream ->
                    stream.write(bytes)
                } ?: throw IllegalStateException("Tidak dapat membuka file download")

                values.clear()
                values.put(MediaStore.MediaColumns.IS_PENDING, 0)
                contentResolver.update(uri, values, null, null)
            } catch (error: Exception) {
                contentResolver.delete(uri, null, null)
                throw error
            }

            return "Download/$DOWNLOAD_FOLDER"
        }

        if (
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
            checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED
        ) {
            throw SecurityException("Storage permission is required")
        }

        @Suppress("DEPRECATION")
        val directory = File(
            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS),
            DOWNLOAD_FOLDER,
        )
        if (!directory.exists() && !directory.mkdirs()) {
            throw IllegalStateException("Folder download tidak dapat dibuat")
        }

        File(directory, fileName).writeBytes(bytes)
        return "Download/$DOWNLOAD_FOLDER"
    }
}
