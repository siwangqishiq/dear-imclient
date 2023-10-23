package com.example.dearim

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import com.example.dearim.DearImService.BROADCAST_INCOMING_IMMESSAGE
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.*


const val FLOAT_WINDOW_REQUEST_CODE = 101

class MainActivity: FlutterActivity() {
    companion object{
        @JvmStatic
        var isForeground : Boolean = false
    }


    private val METHOD_CHANNEL = "dearim_channel"

    private lateinit var mChannel: MethodChannel

    override fun onCreate(savedInstanceState: Bundle?){
        super.onCreate(savedInstanceState);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            window.statusBarColor = 0
        }

        //检查是否有浮动窗口权限
        // if(checkCanDrawOverlays()){
        //     startService()
        // }else{
        //     openCanDrawOverlaysSetting()
        // }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        LogUtil.log("configureFlutterEngine !")
        mChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
        mChannel.setMethodCallHandler{ call, result->
            LogUtil.log("flutter method call ${call.method}")
            if(call.method == "notifyIMMessage"){
                onReceiveIMMessage(call);
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if(requestCode == FLOAT_WINDOW_REQUEST_CODE && checkCanDrawOverlays()){
            startService()
        }
    }

    /**
     * 
     */
    private fun onReceiveIMMessage(call: MethodCall){
         LogUtil.log("onReceiveIMMessage method ${call.arguments}")

        DearImService.params.clear()
        var params = call.arguments as Map<String, String>
        for( k in params.keys){
            DearImService.params.put(k, params[k])
        }

        //send broadcast
        val it = Intent()
        it.action = BROADCAST_INCOMING_IMMESSAGE
        sendBroadcast(it)
    }

    /**
     *  start a service for background task
     */
    fun startService(){
        val intent = Intent(this, DearImService::class.java)
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            startForegroundService(intent)
        }else{
            startService(intent)
        }
    }

    /**
     * 覆写android平台 原有退出应用方法 保持IM后台服务 外部可接收消息
     */
    override fun popSystemNavigator():Boolean {
        moveTaskToBack(false)
        return true
    }

    override fun onResume() {
        super.onResume()
        isForeground = true
    }

    override fun onStop() {
        super.onStop()
        isForeground = false
    }

    /**
     * 是否有浮动窗口打开权限
     * @return
     */
    private fun checkCanDrawOverlays(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(this.getApplicationContext())
        } else {
            true
        } //
    }

    /**
     * 设置弹窗应用上层显示
     */
    private fun openCanDrawOverlaysSetting() {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                // 由于8.0对系统弹唱权限的限制，需要用户进去设置中找到对应应用设置弹窗权限
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && Build.VERSION.SDK_INT < Build.VERSION_CODES.P) {
                    //8.0
                    val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION)
                    this.startActivityForResult(intent, FLOAT_WINDOW_REQUEST_CODE)
                } else {
                    // 6.0、7.0、9.0
                    val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION)
                    intent.data = Uri.parse("package:" + this.getPackageName())
                    this.startActivityForResult(intent, FLOAT_WINDOW_REQUEST_CODE)
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
