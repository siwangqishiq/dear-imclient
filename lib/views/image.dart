// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

///
/// 图片游览
/// 
class ScanImageWidget extends StatelessWidget{
  static const int TYPE_HTTP = 1;//网络图片
  static const int TYPE_FILE = 2;//本地文件

  final String mImageUrl;
  final int type;
  final String? heroId;
  
  const ScanImageWidget(this.mImageUrl , {Key? key,this.heroId, this.type = TYPE_HTTP}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // LogUtil.log("heroID:$heroId  \n mImageUrl : $mImageUrl");
    return  GestureDetector(
      child: Center(
        child:Hero(
          tag: heroId??mImageUrl, 
          child: InteractiveViewer(
            child: type == TYPE_FILE ?Image.file(File(mImageUrl) , width: double.infinity) 
                  :ExtendedImage.network(mImageUrl , width: double.infinity),
            panEnabled: true, 
            boundaryMargin:const EdgeInsets.all(8),
            minScale: 0.5,
            maxScale: 4.5,
            clipBehavior: Clip.none
          )
        )
      )
    );
  }
}//end class