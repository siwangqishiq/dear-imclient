// ignore_for_file: file_names

import 'dart:convert';

import 'package:dearim/core/utils.dart';
import 'package:dearim/models/contact_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/imcore.dart';
import 'contacts.dart';

class User {
  SharedPreferences? prefs;
  // ignore: constant_identifier_names
  static const String _user_key = "_user";

  int uid = 0;
  String name = "";
  String token = "";
  String avatar = "";
  String account = "";

  String imServer = "";
  int imPort = 0;
  //TCPParam tcpParam = TCPParam();

  ///
  /// 获取当前登录用户信息
  ///
  static ContactModel? getCurrentUser(){
    var uid = IMClient.getInstance().uid;
    ContactModel? info = ContactsDataCache.instance.getContact(uid);
    return info;
  }

  Future<int> save() async{
    if(uid <= 0 || Utils.isTextEmpty(token)){
      return Future.value(-1);
    }

    Map<String ,dynamic> json = <String,dynamic>{};
    json["uid"] = uid;
    json["name"] = name;
    json["token"] = token;
    json["avatar"] = avatar;
    json["imPort"] = imPort;
    json["imServer"] = imServer;

    String jsonValues = jsonEncode(json);
    prefs ??= await SharedPreferences.getInstance();
    print("jsonEncode: $jsonValues");

    prefs!.setString(_user_key, jsonValues);

    return Future.value(0);
  }

  Future<int> restore() async {
    prefs ??= await SharedPreferences.getInstance();
    String? userJson = prefs?.getString(_user_key);

    //print("userJson = $userJson");

    if(!Utils.isTextEmpty(userJson)){
      Map<String , dynamic> userMap = jsonDecode(userJson!);

      uid = userMap["uid"]??0;
      name= userMap["name"];
      token = userMap["token"];
      avatar = userMap["avatar"];

      imPort = userMap["imPort"]??0;
      imServer = userMap["imServer"];

      return Future.value(0);
    }

    return Future.value(-1);
  }

  //是否可以自动登录
  bool canAutoLogined(){
    return uid > 0 && !Utils.isTextEmpty(token);
  }

  Future<int> clear() async {
    prefs ??= await SharedPreferences.getInstance();
    prefs?.setString(_user_key, "");

    uid = 0;
    name = "";
    token = "";
    avatar = "";

    imPort = 0;
    imServer = "";

    return Future.value(0);
  }
}

class TCPParam {
  String imServer = "";
  int imPort = 0;
}
