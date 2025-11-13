package com.toxdes.cards;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;
import android.text.Html;
import android.text.Spanned;
import androidx.core.app.NotificationCompat;

public class CardsForegroundService extends Service {

    private static final String CHANNEL_ID = "cards_default";
    private static final String CHANNEL_NAME = "Notifications for Cards";
    private static final String CHANNEL_DESC = "Notifications for cards app";
    public static final int NOTIFICATION_ID = 1;
    public static final String EXTRA_TITLE = "title";
    public static final String EXTRA_BODY = "body";

    @Override
    public void onCreate() {
        super.onCreate();
        createNotificationChannel();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        String title = "Cards";
        String body = "";
        
        if (intent != null) {
            title = intent.getStringExtra(EXTRA_TITLE);
            body = intent.getStringExtra(EXTRA_BODY);
            if (title == null) title = "Cards";
            if (body == null) body = "";
        }

        Notification notification = createNotification(title, body);
        startForeground(NOTIFICATION_ID, notification);

        return START_STICKY;
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    private Notification createNotification(String title, String body) {
        String packageName = getApplicationContext().getPackageName();
        String clearAction = packageName + ".action.CLEAR_CLIPBOARD";

        // Create clear action intent
        Intent clearIntent = new Intent(clearAction);
        clearIntent.setPackage(packageName);
        
        PendingIntent clearPendingIntent = PendingIntent.getBroadcast(
            this,
            0,
            clearIntent,
            PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT
        );

        // Create tap intent to open app
        Intent tapIntent = getPackageManager().getLaunchIntentForPackage(packageName);
        PendingIntent tapPendingIntent = PendingIntent.getActivity(
            this,
            0,
            tapIntent,
            PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT
        );

        // Parse HTML in body text
        Spanned styledBody;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            styledBody = Html.fromHtml(body, Html.FROM_HTML_MODE_LEGACY);
        } else {
            styledBody = Html.fromHtml(body);
        }

        return new NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(styledBody)
            .setStyle(new NotificationCompat.BigTextStyle().bigText(styledBody))
            .setSmallIcon(R.mipmap.ic_launcher)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setOngoing(true)
            .setContentIntent(tapPendingIntent)
            .addAction(
                R.mipmap.ic_launcher,
                "CLEAR",
                clearPendingIntent
            )
            .build();
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_HIGH
            );
            channel.setDescription(CHANNEL_DESC);
            
            NotificationManager notificationManager = getSystemService(NotificationManager.class);
            if (notificationManager != null) {
                notificationManager.createNotificationChannel(channel);
            }
        }
    }
}
