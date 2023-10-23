// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:dearim/core/log.dart';
import 'package:dearim/core/protocol/protocol.dart';
import 'package:dio/dio.dart';

import '../config.dart';
import 'imcore.dart';
import 'utils.dart';

///
/// 云存储 服务
///

//上传文件类型
enum UploadFileType{
  image,//图片
  video,//视频
  audio,//音频
  file,//普通文件
}

//文件上传结果回调
typedef UploadCallback = Function(int result , String? url , String? attach);

//文件上传基类 为不同的云存储服务统一方法
abstract class FileUploadManager{

  factory FileUploadManager.createDefault(){
    return DefaultFileUploadManager();
  }
  
  FileUploadManager();

  //文件上传 
  void uploadFile(String localPath , UploadFileType fileType , UploadCallback? callback);
}//end class 


//文件上传 默认实现
class DefaultFileUploadManager extends FileUploadManager{
  static const String UPLOAD_URL = "http://$HOST:9090/uploadfile";

  late Dio _dio;

  DefaultFileUploadManager(){
    _dio = Dio();
  }

  @override
  void uploadFile(String localPath, UploadFileType fileType, UploadCallback? callback) {
    File uploadFile = File(localPath);
    String fileName = uploadFile.path.split(Platform.pathSeparator).last;

    FormData formData = FormData.fromMap({"file" : MultipartFile.fromFileSync(localPath , filename: fileName)});
    _dio.post<String>(UPLOAD_URL , data:formData).then((resp){
      LogUtil.log("上传返回: $resp");
      if(Utils.isTextEmpty(resp.data)){
        callback?.call(Codes.error , null ,null);
      }else{
        var respData = jsonDecode(resp.data??"{}");
        var data = respData["data"];
        callback?.call(Codes.success , data["url"] ,null);
      }
    }).onError((error, stackTrace){
      LogUtil.log("上传文件发生异常");
      callback?.call(Codes.failed , null ,null);
    });
  }
}