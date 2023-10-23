// ignore_for_file: file_names

import 'dart:ffi';

import 'package:dearim/core/log.dart';
import 'package:dearim/views/color_utils.dart';
import 'package:dearim/views/toast_show_utils.dart';
import 'package:dearim/network/request.dart';
import 'package:dearim/user/user_manager.dart';
import 'package:flutter/material.dart';
// import 'package:logger/logger.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //TODO: wmy test
  String username = "";
  String password = "";
  double space = 16.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "登录",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          padding: EdgeInsets.all(space),
          child: Column(
            children: [
              const SizedBox(
                height: 100,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: "请输入账号名"),
                onChanged: (String text) {
                  username = text;
                  // Logger().d(text);
                },
              ),
              SizedBox(
                height: space,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: "请输入密码"),
                obscureText: true,
                onChanged: (String text) {
                  password = text;
                  // Logger().d(text);
                },
              ),
              const SizedBox(
                height: 30,
              ),
              MaterialButton(
                  onPressed: () {
                    if (username.isEmpty || password.isEmpty) {
                      ToastShowUtils.show("用户名或密码为空", context);
                      return;
                    }
                    login();
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      width: 400,
                      height: 40,
                      color: ColorThemes.themeColor,
                      child: const Center(
                        child: Text(
                          "登录",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  )
              ),
              const SizedBox(
                height: 30,
              ),
              InkWell(
                child: const Text("注册新账号" , style: TextStyle(color: Colors.green),),
                onTap: () => toRegisterPage(),
              ),
            ],
          ),
        ),
      )
    );
  }

  void toRegisterPage(){
    LogUtil.log("跳转注册新账户");
    Navigator.of(context).pushNamed("/register");
  }

  void login() {
    UserManager.getInstance()!.login(
        username,
        password,
        Callback(successCallback: (data) {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed("/main");
          FocusManager.instance.primaryFocus!.unfocus();
        }, failureCallback: (code, errorStr, data) {
          ToastShowUtils.show(errorStr, context);
        }
      )
    );
  }
}
