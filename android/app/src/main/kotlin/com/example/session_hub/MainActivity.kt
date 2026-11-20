package com.example.session_hub

import android.content.Intent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "session_hub/apps")
            .setMethodCallHandler { call, result ->
                if (call.method != "launchPackage") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val packageName = call.argument<String>("packageName")?.trim()
                if (packageName.isNullOrEmpty()) {
                    result.error("invalid_package", "Package name is empty", null)
                    return@setMethodCallHandler
                }
                val intent: Intent? = packageManager.getLaunchIntentForPackage(packageName)
                if (intent == null) {
                    result.success(false)
                } else {
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    result.success(true)
                }
            }
    }
}
