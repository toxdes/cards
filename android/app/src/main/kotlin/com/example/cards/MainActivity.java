package com.toxdes.cards;

import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "com.toxdes.cards/notifications";

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
  }

  @Override
  public void configureFlutterEngine(io.flutter.embedding.engine.FlutterEngine flutterEngine) {
    super.configureFlutterEngine(flutterEngine);
    
    new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
        .setMethodCallHandler((call, result) -> {
          if (call.method.equals("showNotificationWithAction")) {
            String title = call.argument("title");
            String body = call.argument("body");
            
            Intent serviceIntent = new Intent(getApplicationContext(), CardsForegroundService.class);
            serviceIntent.putExtra(CardsForegroundService.EXTRA_TITLE, title);
            serviceIntent.putExtra(CardsForegroundService.EXTRA_BODY, body);
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
              getApplicationContext().startForegroundService(serviceIntent);
            } else {
              getApplicationContext().startService(serviceIntent);
            }
            
            result.success(null);
          } else {
            result.notImplemented();
          }
        });
  }
}
