package com.amarjith.budgetr

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.provider.Settings

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "com.amarjith.budgetr/settings"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "openNotificationListenerSettings") {
                val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
                startActivity(intent)
                // Instantly return success so Flutter doesn't hang waiting for an onActivityResult
                result.success(true) 
            } else {
                result.notImplemented()
            }
        }
    }
}