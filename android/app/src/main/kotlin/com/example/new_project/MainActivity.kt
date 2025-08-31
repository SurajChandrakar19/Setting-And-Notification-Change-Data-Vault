package com.example.new_project

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.core.app.NotificationCompat
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.io.IOException

class MainActivity : FlutterActivity() {
    private val CHANNEL = "mobile_download_service"
    private val NOTIFICATION_CHANNEL_ID = "file_downloads"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        createNotificationChannel()
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "saveToDownloads" -> {
                    val fileName = call.argument<String>("fileName")
                    val fileData = call.argument<ByteArray>("fileData")
                    
                    if (fileName != null && fileData != null) {
                        try {
                            val filePath = saveFileToDownloads(fileName, fileData)
                            if (filePath != null) {
                                showDownloadNotification(fileName, filePath)
                                result.success(filePath)
                            } else {
                                result.error("SAVE_FAILED", "Failed to save file to Downloads", null)
                            }
                        } catch (e: Exception) {
                            result.error("SAVE_EXCEPTION", "Exception while saving file: ${e.message}", null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENTS", "fileName and fileData are required", null)
                    }
                }
                "showDownloadNotification" -> {
                    val fileName = call.argument<String>("fileName")
                    val filePath = call.argument<String>("filePath")
                    
                    if (fileName != null && filePath != null) {
                        showDownloadNotification(fileName, filePath)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENTS", "fileName and filePath are required", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "File Downloads"
            val descriptionText = "Notifications for downloaded files"
            val importance = NotificationManager.IMPORTANCE_DEFAULT
            val channel = NotificationChannel(NOTIFICATION_CHANNEL_ID, name, importance).apply {
                description = descriptionText
            }
            
            val notificationManager: NotificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
    
    private fun showDownloadNotification(fileName: String, filePath: String) {
        val file = File(filePath)
        if (!file.exists()) return
        
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        
        // Create intent to open the file
        val intent = Intent(Intent.ACTION_VIEW)
        val uri = FileProvider.getUriForFile(
            this,
            "$packageName.fileprovider",
            file
        )
        intent.setDataAndType(uri, "text/csv")
        intent.flags = Intent.FLAG_GRANT_READ_URI_PERMISSION
        
        val pendingIntent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            android.app.PendingIntent.getActivity(
                this, 0, intent,
                android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
            )
        } else {
            android.app.PendingIntent.getActivity(
                this, 0, intent,
                android.app.PendingIntent.FLAG_UPDATE_CURRENT
            )
        }
        
        val notification = NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID)
            .setSmallIcon(android.R.drawable.stat_sys_download_done)
            .setContentTitle("Download Complete")
            .setContentText("$fileName has been downloaded")
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .build()
        
        notificationManager.notify(fileName.hashCode(), notification)
    }
    
    private fun saveFileToDownloads(fileName: String, fileData: ByteArray): String? {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                // Android 10+ (API 29+): Use MediaStore API
                saveFileWithMediaStore(fileName, fileData)
            } else {
                // Android 9 and below: Use legacy external storage
                saveFileToLegacyDownloads(fileName, fileData)
            }
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "Error saving file: ${e.message}", e)
            null
        }
    }
    
    private fun saveFileWithMediaStore(fileName: String, fileData: ByteArray): String? {
        val resolver = contentResolver
        val contentValues = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
            put(MediaStore.MediaColumns.MIME_TYPE, "text/csv")
            put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
        }
        
        val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, contentValues)
        return uri?.let {
            try {
                resolver.openOutputStream(it)?.use { outputStream ->
                    outputStream.write(fileData)
                    outputStream.flush()
                }
                // Get the actual file path for notification purposes
                getFilePathFromUri(it) ?: "${Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)}/$fileName"
            } catch (e: IOException) {
                android.util.Log.e("MainActivity", "Error writing file: ${e.message}", e)
                resolver.delete(it, null, null) // Clean up if write failed
                null
            }
        }
    }
    
    private fun saveFileToLegacyDownloads(fileName: String, fileData: ByteArray): String? {
        val downloadsDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
        if (!downloadsDir.exists()) {
            downloadsDir.mkdirs()
        }
        
        val file = File(downloadsDir, fileName)
        return try {
            FileOutputStream(file).use { outputStream ->
                outputStream.write(fileData)
                outputStream.flush()
            }
            file.absolutePath
        } catch (e: IOException) {
            android.util.Log.e("MainActivity", "Error writing file: ${e.message}", e)
            null
        }
    }
    
    private fun getFilePathFromUri(uri: Uri): String? {
        return try {
            val cursor = contentResolver.query(uri, arrayOf(MediaStore.MediaColumns.DATA), null, null, null)
            cursor?.use {
                if (it.moveToFirst()) {
                    val columnIndex = it.getColumnIndexOrThrow(MediaStore.MediaColumns.DATA)
                    it.getString(columnIndex)
                } else null
            }
        } catch (e: Exception) {
            android.util.Log.w("MainActivity", "Could not get file path from URI: ${e.message}")
            null
        }
    }
}
