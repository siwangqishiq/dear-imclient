
import 'dart:io';
import 'dart:typed_data';

import 'package:dearim/core/log.dart';
import 'package:dearim/views/image.dart';
import 'package:dearim/views/toast_show_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_save/image_save.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../config.dart';
import '../widget/dialog_helper.dart';

class PreviewSendImage extends StatelessWidget{
  final String imagePath;

  const PreviewSendImage(
    this.imagePath ,
    {Key? key}):super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "发送图片",
          style: TextStyle(color: Colors.white),
        ),
        actions:[
          InkWell(
            onTap: (){
              Navigator.of(context).pop(imagePath);
            },
            child:const Padding(
              padding: EdgeInsets.all(8),
              child: Center(
                child: Text("发送"),
              )
            ),
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,  
        color: Colors.black,
        child: ScanImageWidget(
          imagePath,
          type: ScanImageWidget.TYPE_FILE,
        ),
      ),
    );
  }
}


///
/// 图片游览
///
class ExplorerImagePage extends StatelessWidget{
  final String imageUrl;
  final String? heroId;
  final int? type;

  const ExplorerImagePage(
    this.imageUrl , 
    {Key? key , 
    this.heroId , this.type}):super(key: key);

  Widget buildBody(BuildContext context){
    return Container(
      width: double.infinity,
      height: double.infinity,  
      color: Colors.black,
      child: ScanImageWidget(
        imageUrl,
        heroId: heroId??imageUrl,
        type: type??ScanImageWidget.TYPE_HTTP,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "查看图片",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: buildBody(context),
    );
  }
}


///
/// 带有保存功能的图片游览
///
class ExplorerImagePageWithSaveAction extends ExplorerImagePage{
  const ExplorerImagePageWithSaveAction(String imageUrl , String? _heroId, {Key? key})
    :super(imageUrl ,  heroId: _heroId , key: key);
  
  @override
  Widget buildBody(BuildContext context) {
    var bodyWidget = super.buildBody(context);
    return GestureDetector(
      child: bodyWidget,
      onLongPress: () => _onLongPressImage(context),
    );
  }

  // 长按
  void _onLongPressImage(BuildContext context){
    final List<DialogItemAction> actions = <DialogItemAction>[];
    actions.add(DialogItemAction("保存图片" , onClickAction: (BuildContext ctx) => _saveImageAction(context)));
    DialogHelper.displayItemListDialog(context , actions);
  }

  //保存图片
  Future<bool> _saveImageAction(BuildContext ctx) async{
    // if(await Permission.storage.request().isGranted){
    // }else{
    //   return Future.value(false);
    // }


    LogUtil.log("保存图片 url: $imageUrl");
    Directory? dir;
    try{
      dir = await getApplicationDocumentsDirectory();
    }catch(e){
      LogUtil.log("error: " + e.toString());
      //ToastShowUtils.show("获取存储目录失败", ctx);
      return Future.value(false);
    }

    LogUtil.log("存储路径 ${dir.absolute}");

    if(Platform.isAndroid || Platform.isIOS){
      if (await Permission.storage.request().isGranted) {
        _doRealSaveImage(ctx, dir, imageUrl);
      }else{
        // ToastShowUtils.show("未授予存储权限", ctx);
        LogUtil.log("未授予存储权限");
      }
    }else{
      _doRealSaveImage(ctx , dir , imageUrl);
    }
    //权限检查
    return Future.value(true);
  }

  //实际保存图片
  void _doRealSaveImage(BuildContext context , Directory saveDir , String imageUrl) async{
     //1. download image
    String downloadFilePath = "${saveDir.path}/dearim/dearim_${DateTime.now().millisecondsSinceEpoch}.jpg";
    Response resp = await Dio().download(
      imageUrl, 
      downloadFilePath,
      onReceiveProgress:(int count, int total){
        //print("downloading $count / $total");
      },
    );

    //print("${resp.statusCode}");
    if(resp.statusCode == 200){
      File file = File(downloadFilePath);
      Uint8List rawData = await file.readAsBytes();

      //save image to ablum
      if(Platform.isAndroid || Platform.isIOS){
        bool? success = await ImageSave.saveImage(rawData, "jpg" , albumName: APP_NAME);
        if(success??false){
          ToastShowUtils.show("保存成功 保存路径${file.absolute}" , context);
        }else{
          ToastShowUtils.show("保存图片失败" , context);
        }
      }else{
        ToastShowUtils.show("保存成功 保存路径${file.absolute}" , context);
      }
    }else{
      ToastShowUtils.show("网络错误 保存图片失败" , context);
    }
  }

}//end class