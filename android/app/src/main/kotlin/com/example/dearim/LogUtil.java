package com.example.dearim;

import android.util.Log;

public class LogUtil {
    public static void log(final String msg){
        if(BuildConfig.DEBUG){
            Log.i("logger" , msg);
        }
    }
}
