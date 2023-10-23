

import 'dart:io';

import 'package:dearim/core/file_upload.dart';
import 'package:dearim/core/log.dart';
import 'package:dearim/core/protocol/protocol.dart';
import 'package:dearim/core/utils.dart';
import 'package:dearim/models/contact_model.dart';
import 'package:dearim/network/request.dart';
import 'package:dearim/user/contacts.dart';
import 'package:dearim/views/head_view.dart';
import 'package:dearim/views/toast_show_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

///
/// 更新个人信息
///
class InfoUpdatePage extends StatefulWidget{
  late ContactModel info;

  InfoUpdatePage(this.info, {Key? key}) : super(key: key);

  @override
  State createState() {
    return InfoUpdateState();
  }
}

class InfoUpdateState extends State<InfoUpdatePage>{
  late TextEditingController nicknameController;
  String? avatar;
  String? nickname;

  late FileUploadManager fileUploadManager;

  @override
  void initState() {
    super.initState();
    fileUploadManager = DefaultFileUploadManager();

    nicknameController = TextEditingController();
    nicknameController.text = widget.info.name;

    avatar = widget.info.avatar;
    nickname = widget.info.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "更新信息",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body:SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10,),
                InkWell(
                  onTap: ()=>pickAvatar(),
                  child: HeadView(
                    avatar,
                    size: ImageSize.origin, 
                    width: 200, 
                    height:200 , 
                    circle: 100, 
                    key: UniqueKey(),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: nicknameController,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          hintText: "输入用户昵称",
                        ),
                        onChanged: (v){
                          setState(() {
                             nickname = v;
                          });
                        },
                      ) 
                    )
                  ],
                ),
                const SizedBox(height: 20,),
                ElevatedButton(
                  onPressed: submitPressed() ,
                  child: const Text("提交更新"),
                )
              ],
            ),
          )
        ),
      )
    );
  }

  void pickAvatar() async{
    FilePickerResult? pickerResult = await FilePicker.platform.pickFiles(type: FileType.image);

    if(pickerResult != null){
      LogUtil.log("用户选择文件 ${pickerResult.files.single.path}");
      String? path = pickerResult.files.single.path;

      // File file = File(path!);
      // var imageInfo = await decodeImageFromList(await file.readAsBytes());
      // LogUtil.log("图片大小 ${imageInfo.width} x ${imageInfo.height}");
      
      fileUploadManager.uploadFile(path!, UploadFileType.image, (result, url, attach){
        LogUtil.log("result = $result");
        if(result == Codes.success){
          LogUtil.log("url = $url");
          setState(() {
            avatar = url;
          });
        }
      });
    }else{
      LogUtil.log("用户选择取消");
    }
  }

  VoidCallback? submitPressed(){
    if(nickname != widget.info.name || avatar != widget.info.avatar){
      if(Utils.isTextEmpty(nickname)){
        return null;
      }

      return doSubmitUpdateInfo;
    }
    return null;
  }

  //提交更新
  void doSubmitUpdateInfo(){
    Map<String, dynamic> params = {};
    params["uid"] = widget.info.userId;
    params["nickname"] = nickname;
    params["avatar"] = avatar;
    params["description"] = null;

    Request().postRequest(
      "updateAccount",
      params,
      Callback(
        successCallback: (data) async {
          LogUtil.log("个人信息更新成功 $data");
          ToastShowUtils.show("更新成功", context);
          ContactsDataCache.instance.fetchContacts();
          
          Navigator.of(context).pop();
        }, 
        failureCallback: (code, errorStr, data) {
          LogUtil.log("注册接口错误 $data");
          ToastShowUtils.show("更新失败$errorStr", context);
        }
      )
    );
  }

}//end class


