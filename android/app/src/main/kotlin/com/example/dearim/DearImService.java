package com.example.dearim;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Color;
import android.graphics.PixelFormat;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.view.WindowManager;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;

import java.util.HashMap;

/**
 * 应用外接收消息通知
 *
 */
public class DearImService extends Service {
    public static final int NotificationId = 1001;
    public static final int MessageNotificationId = R.mipmap.ic_launcher;

    private static final String CHANNEL_ID = "DearImServiceChannelId";

    public static final String BROADCAST_INCOMING_IMMESSAGE = "broadcast_incoming_immessage";

    public static HashMap<String , String> params = new HashMap<String,String>();

    private OnMessageReceived mOnMessageReceived;

    private PendingIntent pendingIntent = null;

    private boolean isRuning = false;
    private static int count = 0;
    @Override
    public void onCreate() {
        super.onCreate();
        LogUtil.log("DearImService on create!");

        if(mOnMessageReceived != null){
            unregisterReceiver(mOnMessageReceived);
        }
        mOnMessageReceived = new OnMessageReceived();
        IntentFilter filter = new IntentFilter();
        filter.addAction(BROADCAST_INCOMING_IMMESSAGE);
        registerReceiver(mOnMessageReceived , filter);

        // keepServiceAlive();
        // debugLog();
    }

//    private void debugLog(){
//        isRuning = true;
//        new Thread(()->{
//            while(isRuning){
//                count++;
//                // LogUtil.log("DearImService task is ruinng... " + count);
//
//                try {
//                    Thread.sleep(2000);
//                } catch (InterruptedException e) {
//                    e.printStackTrace();
//                }
//            }//end while
//        }).start();
//    }

    public class OnMessageReceived extends BroadcastReceiver{
        @Override
        public void onReceive(Context context, Intent intent) {
            final String action = intent.getAction();
            if(TextUtils.equals(action , BROADCAST_INCOMING_IMMESSAGE)){
                onIncomingIMMessage();
            }
        }
    }

    /**
     *
     */
    private void onIncomingIMMessage(){
        final String name = params.get("name");
        final String content = params.get("content");
        LogUtil.log(name + " 来了一条Im 消息 " + content +" " + isAppForeground());

        //非前台的App才展示通知
        if(isAppForeground()){
            return;
        }

        final PendingIntent pendingIntent =  PendingIntent.getActivity(this, 0,
                new Intent(this, MainActivity.class), PendingIntent.FLAG_IMMUTABLE);

        NotificationCompat.Builder nBuilder = new NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentIntent(pendingIntent)
                .setContentTitle(name)
                .setContentText(content)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setAutoCancel(true);

        NotificationManagerCompat notificationManager = NotificationManagerCompat.from(this);
        notificationManager.notify(MessageNotificationId , nBuilder.build());
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        LogUtil.log("DearImService onStartCommand!");
        final Intent notificationIntent = new Intent(this, MainActivity.class);
        if(pendingIntent == null){
            pendingIntent =  PendingIntent.getActivity(this, 0, notificationIntent, PendingIntent.FLAG_IMMUTABLE);
        }

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            setNotificationChannel(CHANNEL_ID);

            Notification notification = new Notification.Builder(this, CHANNEL_ID)
                            .setContentTitle(getText(R.string.app_name))
                            .setContentText(getText(R.string.app_name))
                            .setSmallIcon(R.mipmap.ic_launcher)
                            .setContentIntent(pendingIntent)
                            .setTicker(getText(R.string.app_name))
                            .build();
            startForeground(NotificationId , notification);
        }
        return Service.START_STICKY;
    }

    private void updateForegroundService(String content){
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            setNotificationChannel(CHANNEL_ID);

            Notification notification = new Notification.Builder(this, CHANNEL_ID)
                    .setContentTitle(getText(R.string.app_name))
                    .setContentText(getText(R.string.app_name) + content)
                    .setSmallIcon(R.mipmap.ic_launcher)
                    .setContentIntent(pendingIntent)
                    .setTicker(getText(R.string.app_name))
                    .build();
            startForeground(NotificationId , notification);
        }
    }

    private void setNotificationChannel(String channelId) {
        final NotificationChannel channel;
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            channel = new NotificationChannel(channelId, channelId, NotificationManager.IMPORTANCE_HIGH);
            channel.setLightColor(Color.GREEN);
            channel.setLockscreenVisibility(Notification.DEFAULT_VIBRATE);
            NotificationManager mNotificationManager = (NotificationManager) this.getSystemService(Context.NOTIFICATION_SERVICE);
            mNotificationManager.createNotificationChannel(channel);
        }
    }

    @Override
    public void onDestroy() {
        if(mOnMessageReceived != null){
            unregisterReceiver(mOnMessageReceived);
        }
        super.onDestroy();
        LogUtil.log("DearImService onDestroy!");
        isRuning = false;
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    private void keepServiceAlive(){
        WindowManager winMgr = (WindowManager) this.getSystemService(Context.WINDOW_SERVICE);
//        TextView mLiveView = new TextView(this);
//        mLiveView.setText(" dear  hello alive ");

        View mLiveView = new View(this);
        mLiveView.setBackgroundColor(Color.TRANSPARENT);
        final WindowManager.LayoutParams params = new WindowManager.LayoutParams();
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            // 注意TYPE_SYSTEM_ALERT从Android8.0开始被舍弃了
            params.type = WindowManager.LayoutParams.TYPE_SYSTEM_ALERT;
        } else {
            // 从Android8.0开始悬浮窗要使用TYPE_APPLICATION_OVERLAY
            params.type = WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY;
        }

        //params.flags = WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL | WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE;
        params.flags =WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE|
                WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
                | WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN
                | WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL
                | WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED;


        params.gravity = Gravity.LEFT | Gravity.TOP;
        params.width = 10;
        params.height =10;
        params.y = 1;
        params.format = PixelFormat.TRANSPARENT;

        winMgr.addView(mLiveView, params);
        winMgr.updateViewLayout(mLiveView , params);
    }

    /**
     * 判断App是否在前台
     *
     * @return
     */
    private boolean isAppForeground(){
        return  MainActivity.isForeground();
    }
}
