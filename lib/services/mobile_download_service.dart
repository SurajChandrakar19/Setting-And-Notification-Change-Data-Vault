import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../services/permission_service.dart';

class MobileDownloadService {
  static const MethodChannel _channel = MethodChannel(
    'mobile_download_service',
  );

  // using
  /// Downloads a file to the Downloads folder on Android
  static Future<String> downloadFileToDownloads({
    required Uint8List bytes,
    required String fileName,
  }) async {
    if (!Platform.isAndroid) {
      throw UnsupportedError('This method is only supported on Android');
    }

    try {
      // Request storage permissions
      final hasPermission = await PermissionService.requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied. Cannot download file.');
      }

      // Use the native Android MediaStore API through method channel
      try {
        final filePath = await _channel.invokeMethod('saveToDownloads', {
          'fileName': fileName,
          'fileData': bytes,
        });

        if (filePath != null && filePath is String) {
          debugPrint('File successfully saved to Downloads: $filePath');
          return filePath;
        } else {
          throw Exception('Native save method returned null path');
        }
      } on PlatformException catch (e) {
        debugPrint('Platform exception during save: ${e.message}');
        throw Exception('Failed to save file: ${e.message}');
      }
    } catch (e) {
      debugPrint('Error in downloadFileToDownloads: $e');
      throw Exception('Failed to download file: $e');
    }
  }

  // using
  /// Gets a safe file name by removing invalid characters
  static String getSafeFileName(String fileName) {
    // Remove invalid characters for file names
    String safeFileName = fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');

    // Ensure it's not too long
    if (safeFileName.length > 100) {
      final extension = safeFileName.split('.').last;
      safeFileName = '${safeFileName.substring(0, 95)}.$extension';
    }

    return safeFileName;
  }
}
