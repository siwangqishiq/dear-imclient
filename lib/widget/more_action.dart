// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:dearim/core/log.dart';
import 'package:dearim/pages/chat_page.dart';
import 'package:dearim/pages/explorer_image.dart';
import 'package:dearim/utils/device_utils.dart';
import 'package:dearim/utils/text_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screen_capturer/screen_capturer.dart';

///
/// 输入框 更多操作
///
class InputAction {
  final String name;
  final String icon;
  late int id = -1;

  InputAction(this.id, this.name, this.icon);

  void onClickAction(BuildContext context, InputPanelState inputPanel) {
    //base class do nothing
  }
}

class InputActionHelper {
  static const int PICK_IMAGE_ABLUM = 1;
  static const int PICK_VIDEO_RTC = 2;
  static const int CAPTURE_SCREEN = 3;

  //面板每页的数据项
  static const int PAGE_PER_SIZE = 8;

  static List<InputAction> findP2PSessionActions() {
    List<InputAction> actions = <InputAction>[];

    //选择图片发送
    actions.add(PickImageFromAblumAction());

    //截屏
    if (isDeskTop()) { //仅桌面端支持
      //增加截取屏幕
      actions.add(CaptureScreenAction());
    }

    //音视频通话
    actions.add(VideoRtcAction());

    return actions;
  }
}

///
/// 截屏操作  仅桌面端可用
///
class CaptureScreenAction extends InputAction {
  CaptureScreenAction()
      : super(InputActionHelper.CAPTURE_SCREEN, "截屏",
            "assets/ic_capture_screen.png");

  @override
  void onClickAction(BuildContext context, InputPanelState inputPanel) async {
    LogUtil.log("click $name");
    bool isAccessAllowed = await ScreenCapturer.instance.isAccessAllowed();
    LogUtil.log("isAccessAllowed = $isAccessAllowed");
    if (isAccessAllowed) {
      String? imagePath = await _beginCaptureScreen(context, inputPanel);
      if (TextUtils.isEmpty(imagePath)) {
        return;
      }
      var path = await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PreviewSendImage(imagePath!)));

      if (path == null) {
        return;
      }
      LogUtil.log("发送图片文件 $path");
      inputPanel.sendImageIMMessage(path);
    } else {
      if (Platform.isMacOS) {
        await ScreenCapturer.instance.requestAccess();
      }
      LogUtil.log("isAccessAllowed is false cancel capture");
    }
  }

  ///
  /// 开始截屏
  ///
  Future<String?> _beginCaptureScreen(
      BuildContext context, InputPanelState inputPanel) async {
    Directory dir = await getApplicationDocumentsDirectory();
    String imageName =
        "Screenshot_${DateTime.now().millisecondsSinceEpoch}.png";
    var sep = Platform.pathSeparator;
    String imagePath = "${dir.path}dearim${sep}Screenshots$sep$imageName";
    var lastCaptureData = await ScreenCapturer.instance
        .capture(imagePath: imagePath, silent: true);
    LogUtil.log(
        "lastCaptureData ${lastCaptureData?.imagePath} size : ${lastCaptureData?.imageWidth} x ${lastCaptureData?.imageHeight} ");
    if (lastCaptureData?.imageWidth == 0 || lastCaptureData?.imageHeight == 0) {
      return Future.value(null);
    }
    return Future.value(lastCaptureData?.imagePath);
  }
}

///
/// 音视频通话
///
class VideoRtcAction extends InputAction {
  VideoRtcAction()
      : super(
            InputActionHelper.PICK_VIDEO_RTC, "视频通话", "assets/video_chat.png");

  @override
  void onClickAction(BuildContext context, InputPanelState inputPanel) async {
    LogUtil.log("click $name");
    inputPanel.startAvChat();
  }
}

///
/// 从相册选择图片
///
class PickImageFromAblumAction extends InputAction {
  PickImageFromAblumAction()
      : super(InputActionHelper.PICK_IMAGE_ABLUM, "相册", "assets/album.png");

  @override
  void onClickAction(BuildContext context, InputPanelState inputPanel) async {
    LogUtil.log("click $name");
    FilePickerResult? pickerResult = await FilePicker.platform.pickFiles(
        type: FileType.image,);
    if (pickerResult != null) {
      LogUtil.log("用户选择文件 ${pickerResult.files.single.path}");
      String? path = pickerResult.files.single.path;

      if (path == null || path.isEmpty) {
        return;
      }
      
      _onSelectedImage(context, path, inputPanel);
    } else {
      LogUtil.log("用户选择取消");
    }
  }

  //选择图片后预览
  void _onSelectedImage(BuildContext context, String imagePath,
      InputPanelState inputPanel) async {
    var path = await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => PreviewSendImage(imagePath)));

    if (path == null) {
      return;
    }

    LogUtil.log("发送图片文件 $path");
    inputPanel.sendImageIMMessage(path);
  }
}
