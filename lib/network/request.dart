// ignore_for_file: file_names

import 'dart:developer';

import 'package:dearim/network/request_manager.dart';
import 'package:dearim/user/user_manager.dart';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';

typedef SuccessCallback = void Function(dynamic data);
typedef FailureCallback = void Function(
    int code, String errorStr, dynamic data);

class Callback {
  SuccessCallback? successCallback;
  FailureCallback? failureCallback;
  Callback({this.successCallback, this.failureCallback});
}

class Request {
  String host = RequestManager().hostName();

  static final Request _instance = Request._privateConstructor();
  Request._privateConstructor();

  factory Request() {
    return _instance;
  }

  void uploadRequest(String apiName, String filePath, Map<String, dynamic> map,
      Callback callback) async {
    Response response;
    Map<String, dynamic> param = <String, dynamic>{};
    param.addAll(map);
    param["file"] = await MultipartFile.fromFile(filePath, filename: filePath);
    FormData formData = FormData.fromMap(
        {"file": await MultipartFile.fromFile(filePath, filename: filePath)});
    try {
      response = await Dio().post(apiName, data: formData);
      Map<String, dynamic> responseMap = response.data;
      Logger().d(responseMap);
      int code = responseMap["code"];
      if (code != 200) {
        // 返回失败内容 给出回调
        if (callback.failureCallback != null) {
          callback.failureCallback!(
              responseMap["code"], responseMap["msg"], responseMap["data"]);
        }
        //TODO: wmy code 的处理
      } else {
        if (callback.successCallback != null) {
          dynamic data = responseMap["data"];
          callback.successCallback!(data);
          Logger().d(data);
        }
      }
    } catch (e) {
      Logger().d("catch e" + e.toString());
      if (callback.failureCallback != null) {
        callback.failureCallback!(500, "server failure", {});
      }
    }
  }

  void postRequest(
      String apiName, Map<String, dynamic> map, Callback callback) async {
    Response response;
    Map<String, dynamic> param = <String, dynamic>{};
    param.addAll(map);
    String? token = UserManager.getInstance()!.user!.token;

    if (token.isNotEmpty) {
      log(UserManager.getInstance()!.user!.token);
      param["token"] = UserManager.getInstance()!.user!.token;
    }
    try {
      FormData formData = FormData.fromMap(param);
      String address = host + apiName;
      Logger().d("address = " + address);
      Logger().i(map);
      Dio dio = Dio();
      dio.options.headers.addAll(systemParam());
      response = await dio.post(address, data: formData);

      Map<String, dynamic> responseMap = response.data;
      Logger().d(responseMap);
      int code = responseMap["code"];
      if (code != 200) {
        // 返回失败内容 给出回调
        if (callback.failureCallback != null) {
          callback.failureCallback!(
              responseMap["code"], responseMap["msg"], responseMap["data"]);
        }
      } else {
        if (callback.successCallback != null) {
          var data = responseMap["data"];
          callback.successCallback!(data);
          print(data);
        }
      }
    } catch (e) {
      Logger().d("catch e" + e.toString());
      if (callback.failureCallback != null) {
        callback.failureCallback!(500, "server failure", {});
      }
    }
    return null;
  }

  Map<String, dynamic> systemParam() {
    Map<String, dynamic> systemParam = <String, dynamic>{};
    systemParam["token"] = UserManager.getInstance()!.user!.token;
    return systemParam;
  }
}
