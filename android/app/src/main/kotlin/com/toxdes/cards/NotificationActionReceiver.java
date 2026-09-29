package com.toxdes.cards;

import android.os.Build;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.ClipboardManager;
import android.content.ClipData;
import android.widget.Toast;
import android.util.Log;

public class NotificationActionReceiver extends BroadcastReceiver {
    private static final String TAG = "NotificationActionReceiver";
    @Override
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();
        String packageName = context.getPackageName();
        String expectedAction = packageName + ".action.CLEAR_CLIPBOARD";
        
        if (action != null && action.equals(expectedAction)) {
            clearClipboard(context);
            stopForegroundService(context);
        } else {
            Log.d(TAG, "Action did not match");
        }
    }

    private void clearClipboard(Context context) {
        ClipboardManager clipboardManager = (ClipboardManager) context.getSystemService(Context.CLIPBOARD_SERVICE);
        if(clipboardManager == null){
            Log.d(TAG, "could not get clipboard manager.");
            return;
        }
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.P){
            clipboardManager.clearPrimaryClip();
        }else{
            ClipData empty = ClipData.newPlainText("","");
            clipboardManager.setPrimaryClip(empty);
        }
        Toast.makeText(context, "Card number cleared from clipboard", Toast.LENGTH_SHORT).show();
    }

    private void stopForegroundService(Context context) {
        Intent serviceIntent = new Intent(context, CardsForegroundService.class);
        context.stopService(serviceIntent);
    }
}
