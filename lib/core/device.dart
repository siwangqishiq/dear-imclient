

import 'package:dearim/core/log.dart';
import 'package:dearim/core/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

///
/// 获取设备唯一标识
///

class DeviceManager{
  // ignore: constant_identifier_names
  static const String _DeviceKey ="_device_key";
  static String? device;

  static Future<String> getDevice() async {
    if(Utils.isTextEmpty(device)){
      SharedPreferences prefs = await SharedPreferences.getInstance();
      device = prefs.getString(_DeviceKey);
    }

    if(Utils.isTextEmpty(device)){
      device = await genDeviceId();
    }
    
    LogUtil.log("device: $device");
    return device!;
  }

  static Future<String> genDeviceId() async{
    String result = "${Utils.getClientType()}_${Utils.genUnique()}";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_DeviceKey, result);
    return result;
  }

  //确保device生成的情况下 立即获取device
  static String getDeviceInstant(){
    return device!;
  }
}