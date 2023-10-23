package com.example.dearim;

import android.app.Application;

public class MainApp extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        LogUtil.log("MainApp on Create");
    }
}
