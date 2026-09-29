package com.toxdes.cards;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.ClipboardManager;
import android.content.ClipData;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.os.SystemClock;
import android.text.Html;
import android.text.Spanned;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;

public class CardsForegroundService extends Service {

    private static final String CHANNEL_ID = "cards_default";
    private static final String CHANNEL_NAME = "Notifications for Cards";
    private static final String CHANNEL_DESC = "Notifications for cards app";
    public static final int NOTIFICATION_ID = 1;
    public static final String EXTRA_TITLE = "title";
    public static final String EXTRA_BODY = "body";
    private static final int COUNTDOWN_SECONDS = 60;
    private static final long COUNTDOWN_DURATION_MS = COUNTDOWN_SECONDS * 1000L;

    private final Handler handler = new Handler(Looper.getMainLooper());
    private long clipboardClearAt;
    private String notificationTitle = "Cards";
    private String notificationBody = "";
    private boolean foregroundStarted;

    private final Runnable countdownTick = new Runnable() {
        @Override
        public void run() {
            long remainingMs = clipboardClearAt - SystemClock.elapsedRealtime();
            if (remainingMs <= 0) {
                clearClipboard();
                stopForegroundAndRemoveNotification();
                stopSelf();
                return;
            }

            int remainingSeconds = (int) ((remainingMs + 999) / 1000);
            NotificationManagerCompat.from(CardsForegroundService.this)
                .notify(NOTIFICATION_ID, createNotification(remainingSeconds));
            handler.postDelayed(this, Math.min(1000L, remainingMs));
        }
    };

    @Override
    public void onCreate() {
        super.onCreate();
        createNotificationChannel();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (intent == null) {
            stopSelf(startId);
            return START_NOT_STICKY;
        }

        notificationTitle = intent.getStringExtra(EXTRA_TITLE);
        notificationBody = intent.getStringExtra(EXTRA_BODY);
        if (notificationTitle == null) notificationTitle = "Cards";
        if (notificationBody == null) notificationBody = "";

        handler.removeCallbacks(countdownTick);
        clipboardClearAt = SystemClock.elapsedRealtime() + COUNTDOWN_DURATION_MS;
        startForeground(NOTIFICATION_ID, createNotification(COUNTDOWN_SECONDS));
        foregroundStarted = true;
        handler.postDelayed(countdownTick, 1000L);

        return START_NOT_STICKY;
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onDestroy() {
        handler.removeCallbacks(countdownTick);
        if (foregroundStarted) {
            stopForegroundAndRemoveNotification();
        }
        super.onDestroy();
    }

    @SuppressWarnings("deprecation")
    private void stopForegroundAndRemoveNotification() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE);
        } else {
            stopForeground(true);
        }
    }

    private Notification createNotification(int remainingSeconds) {
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

        String countdown = "Clipboard clears in " + remainingSeconds + "s";
        String fullBody = countdown + "<br/>" + notificationBody;
        Spanned styledBody = Html.fromHtml(fullBody, Html.FROM_HTML_MODE_LEGACY);

        return new NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(notificationTitle)
            .setContentText(countdown)
            .setStyle(new NotificationCompat.BigTextStyle().bigText(styledBody))
            .setSmallIcon(R.mipmap.ic_launcher)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setOnlyAlertOnce(true)
            .setProgress(COUNTDOWN_SECONDS, COUNTDOWN_SECONDS - remainingSeconds, false)
            .setOngoing(true)
            .setContentIntent(tapPendingIntent)
            .addAction(
                R.mipmap.ic_launcher,
                "CLEAR",
                clearPendingIntent
            )
            .build();
    }

    private void clearClipboard() {
        ClipboardManager clipboardManager =
            (ClipboardManager) getSystemService(Context.CLIPBOARD_SERVICE);
        if (clipboardManager == null) return;

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            clipboardManager.clearPrimaryClip();
        } else {
            clipboardManager.setPrimaryClip(ClipData.newPlainText("", ""));
        }
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
