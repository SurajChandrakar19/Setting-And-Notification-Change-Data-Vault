import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // using
  static Future<bool> requestStoragePermission() async {
    if (kIsWeb || !Platform.isAndroid) {
      return true; // No permission needed for web or non-Android platforms
    }

    try {
      // Get Android SDK version
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      // Handle different Android versions
      if (sdkInt >= 33) {
        // Android 13+ (API 33+) - For downloads, we don't need media permissions
        // MediaStore.Downloads works without special permissions for writing to Downloads
        return true;
      } else if (sdkInt >= 30) {
        // Android 11-12 (API 30-32) - Try MANAGE_EXTERNAL_STORAGE first
        final manageStorageStatus =
            await Permission.manageExternalStorage.status;

        if (manageStorageStatus.isGranted) {
          return true;
        }

        // For Downloads folder with MediaStore API, we often don't need MANAGE_EXTERNAL_STORAGE
        // Let's check if regular storage permission is sufficient
        final storageStatus = await Permission.storage.request();
        if (storageStatus.isGranted) {
          return true;
        }

        // If storage permission is denied, try MANAGE_EXTERNAL_STORAGE as last resort
        if (manageStorageStatus.isDenied) {
          final result = await Permission.manageExternalStorage.request();
          return result.isGranted;
        }

        return false;
      } else {
        // Android 10 and below (API 29 and below)
        final storageStatus = await Permission.storage.request();
        return storageStatus.isGranted;
      }
    } catch (e) {
      debugPrint('Error requesting storage permission: $e');
      return false;
    }
  }

  // using
  static Future<bool> hasStoragePermission() async {
    if (kIsWeb || !Platform.isAndroid) {
      return true; // No permission needed for web or non-Android platforms
    }

    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        // Android 13+ - For downloads, no special permissions needed for MediaStore
        return true;
      } else if (sdkInt >= 30) {
        // Android 11-12 - Check MANAGE_EXTERNAL_STORAGE or storage
        final manageStorageStatus =
            await Permission.manageExternalStorage.status;
        if (manageStorageStatus.isGranted) {
          return true;
        }

        final storageStatus = await Permission.storage.status;
        return storageStatus.isGranted;
      } else {
        // Android 10 and below
        final storageStatus = await Permission.storage.status;
        return storageStatus.isGranted;
      }
    } catch (e) {
      debugPrint('Error checking storage permission: $e');
      return false;
    }
  }

  // using
  static Future<void> showPermissionDialog() async {
    // This can be used to show a custom dialog explaining why permission is needed
    // For now, we'll use the system dialog
    await openAppSettings();
  }
}
