package com.toxdes.cards;

import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.plugin.common.MethodChannel;

// We use FlutterFragmentActivity here because local_auth needs a FragmentActivity
// to be able to show system level device-auth popup
public class MainActivity extends FlutterFragmentActivity{

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
  }

  @Override
  public void configureFlutterEngine(io.flutter.embedding.engine.FlutterEngine flutterEngine) {
    super.configureFlutterEngine(flutterEngine);

    String packageName = getApplicationContext().getPackageName();

    new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), packageName)
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
