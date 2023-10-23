// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import 'dart:convert' show utf8;
import 'dart:convert';
import 'package:crypto/crypto.dart';

class Utils {
  static Uuid uuid = const Uuid();
  static const double epsiod = 0.000001;

  static bool floatEqual(num d1, num d2) {
    if(Platform.isLinux){
      
    }
    return abs(d1 - d2) < epsiod;
  }

  static num abs(num v) {
    return v >= 0 ? v : -v;
  }

  //string to Uint8List
  static Uint8List convertStringToUint8List(String str) {
    final List<int> codeUnits = utf8.encode(str);;
    final Uint8List unit8List = Uint8List.fromList(codeUnits);
    return unit8List;
  }

  //Uint8List to string
  static String convertUint8ListToString(Uint8List uint8list) {
    return utf8.decode(uint8list);
    //return String.fromCharCodes(uint8list);
  }

  static String intToHex(int value){
    if(value >=0 && value <16){
      return "0" + value.toRadixString(16);
    }
    return value.toRadixString(16);
  }

  //检测list中是否包含重复元素
  static bool listContainObj(List<Object> list , Object obj){
    if(list.isEmpty){
      return false;
    }

    for(Object lObj in list){
      if(lObj == obj){
        return true;
      }
    }    
      
    return false;
  }

  //获取当前毫秒
  static int currentTime(){
    return DateTime.now().millisecondsSinceEpoch;
  }

  static bool isTextEmpty(String? text){
    return text == null || text == "";
  }

  //生成消息唯一标识码
  static String genUniqueMsgId() {
    return uuid.v1();
  }

  //生成随机字符串
  static String genUnique(){
    return uuid.v4();
  }

  //获取客户端类型
  static int getClientType(){
    if(Platform.isAndroid){
      return ClientType.Android;
    }else if(Platform.isIOS){
      return ClientType.Ios;
    }else if(Platform.isWindows){
      return ClientType.Windows;
    }else if(Platform.isLinux){
      return ClientType.Linux;
    }else if(Platform.isMacOS){
      return ClientType.Macos;
    }
    return ClientType.Web;
  }
}

class ClientType{
  static const int Windows = 1;
  static const int Macos = 2;
  static const int Linux = 3;
  static const int Web = 4;
  static const int Android = 5;
  static const int Ios = 6;
}

class MD5Utils{
  static const encoder = Utf8Encoder();

  static String genMd5(String data){
    var content = encoder.convert(data);
    var digest = md5.convert(content);
    return digest.toString();
  }
  
  //生成文件md5值
  static Future<String> genFileMd5(String path) async{
    var file = File(path);
    return md5.convert(await file.readAsBytes()).toString();
  }
}
