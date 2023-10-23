// ignore_for_file: must_be_immutable, no_logic_in_create_state, constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:dearim/core/imcore.dart';
import 'package:dearim/core/immessage.dart';
import 'package:dearim/core/log.dart';
import 'package:dearim/core/utils.dart';
import 'package:dearim/models/chat_message_model.dart';
import 'package:dearim/models/contact_model.dart';
import 'package:dearim/pages/chat_page.dart';
import 'package:dearim/pages/explorer_image.dart';
import 'package:dearim/pages/selector_page.dart';
import 'package:dearim/user/contacts.dart';
import 'package:dearim/user/user_manager.dart';
import 'package:dearim/utils/timer_utils.dart';
import 'package:dearim/views/color_utils.dart';
import 'package:dearim/views/head_view.dart';
import 'package:dearim/views/toast_show_utils.dart';
import 'package:dearim/widget/dialog_helper.dart';
import 'package:dearim/widget/emoji.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatView extends StatefulWidget {
  ChatPageState chatPageState;

  ChatMessageModel msgModel;
  ChatMessageModel? preMsgModel;
  ChatView(
    this.chatPageState , 
    this.msgModel, 
    {this.preMsgModel , Key? key}
  ) : super(key: key);

  @override
  _ChatViewState createState() => _ChatViewState(msgModel);
}

class _ChatViewState extends State<ChatView> {
  late ChatMessageModel msgModel;
  final double space = 8;
  final double innerSpace = 10;
  
  _ChatViewState(this.msgModel);

  @override
  Widget build(BuildContext context) {
    
    bool isSendOutMsg = !msgModel.isReceived;
    
    int uid = msgModel.isReceived?(msgModel.sessionId):(UserManager.getInstance()?.user?.uid??0);
    final ContactModel contactModel = ContactsDataCache.instance.getContact(uid)??ContactModel("",0);
    final String avatar = contactModel.avatar;
    final String heroId = "$avatar?${Utils.genUnique()}";
    
    List<Widget> children = [
      createImmessageView(context),
      SizedBox(
        width: innerSpace,
      ),
      GestureDetector(
        onTap: () {
          //LogUtil.log("click $avatar");
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ExplorerImagePage(avatar , heroId: heroId))
          );
          // Navigator.of(context).push(
          //   PageRouteBuilder(
          //     pageBuilder: (BuildContext context, Animation<double> animation,
          //                   Animation<double> secondaryAnimation) {
          //       return ExplorerImagePage(avatar , heroId: heroId);
          //     },
          //   ),
          // );
        },
        child: Hero(
          tag: heroId,
          child: HeadView(avatar , circle: 8 , width: 38 , height: 38, size:ImageSize.small),
        ),
      ),
      SizedBox(
        width: space,
      ),
    ];

    if (!isSendOutMsg) {
      List<Widget> reverses = [];
      for (var i = children.length - 1; i >= 0; i--) {
        reverses.add(children[i]);
      }
      children = reverses;
    }

    String time = TimerUtils.getMessageFormatTime(msgModel.updateTime);
    return Column(
      children: [
        Visibility(
          visible: isTimeVisible(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Container(
                color: ColorThemes.unselectColor,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
                  child: Text(
                    time,
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ),
            ) ,
          )
        ),
        Column(
          children: [
            SizedBox(
              height: space,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment:!isSendOutMsg ? MainAxisAlignment.start : MainAxisAlignment.end,
              children: children
            )
          ],
        ),
        SizedBox(
          height: space,
        ),
      ],
    );
  }

  //根据时间差 判断时间控件是否显示
  bool isTimeVisible(){
    if(widget.preMsgModel == null){
      return true;
    }

    const int MSG_MAX_TIME_DURING_MILLS = 5 * 60 * 1000;

    ChatMessageModel preModel = widget.preMsgModel!;
    ChatMessageModel currentModel = widget.msgModel;
    
    if((preModel.updateTime - currentModel.updateTime).abs() < MSG_MAX_TIME_DURING_MILLS){
      return false;
    }
    return true;
  }

  //根据消息类型 创建消息视图
  Widget createImmessageView(BuildContext context){
    Widget? msgView;
    switch(msgModel.msgType){
      case MessageType.text:
        msgView = _textMsgView(context);
        break;
      case MessageType.picture:
        msgView = _imageMsgView(context);
        break;
      default:
        msgView = const Text("未知消息");
        break;
    }//end switch

    return InkWell(
      onLongPress: (){//长按 弹出消息操作选项
        final IMMessage msg = msgModel.immessage!;
        // LogUtil.log("long click ${msg.content}");
        _prepareMessageLongClickActions(msg);
      },
      child: msgView,
    );
  }

  ///
  /// 长按消息操作
  ///
  void _prepareMessageLongClickActions(IMMessage msg){
    final List<DialogItemAction> actions = <DialogItemAction>[];

    //add actions

    //拷贝
    prepareCopyAction(msg , actions);
    //删除
    prepareDeleteMsgAction(msg , actions);
    //转发
    prepareForwardMsgAction(msg, actions);

    //showGeneralDialog(context: context, pageBuilder: pageBuilder)
    // showDialog(context: context, builder: builder)
    if(actions.isEmpty){
      return;
    }

    DialogHelper.displayItemListDialog(context , actions);
  }

  ///
  /// 拷贝文本功能
  ///
  bool prepareCopyAction(IMMessage msg , List<DialogItemAction> actions){
    if(msg.imMsgType == IMMessageType.Text){
      actions.add(DialogItemAction("复制" , onClickAction: (BuildContext ctx) async {
        await Clipboard.setData(ClipboardData(text: msg.content??""));
        ToastShowUtils.show("消息文本复制成功", ctx);
      }));

      return true;
    }
    return false;
  }

  ///
  /// 删除IM消息
  ///
  bool prepareDeleteMsgAction(IMMessage msg , List<DialogItemAction> actions){
    actions.add(DialogItemAction("删除" , onClickAction: (BuildContext ctx) async {
      DialogHelper.showAlertDialog(
        "删除", 
        "确定删除此条消息吗?", 
        context, 
        () => _deleteIMMessage(msg), (){}
      );
    }));
    return true;
  }

  bool prepareForwardMsgAction(IMMessage msg , List<DialogItemAction> actions){
    actions.add(DialogItemAction(
        "转发" , 
        onClickAction: (BuildContext ctx) async {
          var selectedUids = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SelectorWidget()
            )
          );

          forwardIMMessage(ctx , msg ,selectedUids);
        }
      )
    );
    return true;
  }

  ///
  /// 转发IM消息
  ///
  bool forwardIMMessage(BuildContext ctx , IMMessage msg ,List<int>? uids){
    if(uids == null || uids.isEmpty){
      return false;
    }

    if(msg.reourceNeedUpload && msg.attachState != AttachState.UPLOADED){
      ToastShowUtils.show("消息附件尚未上传不能转发", ctx);
      return false;
    }

    for(var toUid in uids){
      doForwardIMMessage(ctx , msg , toUid);
    }//end for each
    return true;
  }

  ///
  /// 转发消息
  ///
  void doForwardIMMessage(BuildContext ctx , IMMessage msg , int toUid){
    IMMessage? forwardIMMessage = IMMessageBuilder.createForwardIMMessage(msg, toUid, IMMessageSessionType.P2P);
    if(forwardIMMessage == null){
      LogUtil.log("create forward im message failed!");
      return;
    }

    LogUtil.log("forward ${forwardIMMessage.msgId}: ${forwardIMMessage.url}");
    //send forward im message
    IMClient.getInstance().sendIMMessage(forwardIMMessage,
        callback: (imMessage, result) {
      LogUtil.log("forward ${imMessage.msgId}: ${result.code}");
      if(result.isSuccess()){
        //todo 本页面的更新
        widget.chatPageState.handleForwardIMMessageSuccess(msg, toUid);
        ToastShowUtils.show("转发消息成功", context);
      }
    });
  }


  ///
  /// 删除此条IM消息
  ///
  void _deleteIMMessage(IMMessage msg) async {
    LogUtil.log("删除消息 ${msg.msgId}");
    IMClient.getInstance().removeIMMessage(
      msg,
      cb:(msg, result){
        if(result.isSuccess()){
          _handleOnDeleteIMMessageSuccess(msg);
        }
      }, 
    );
  }

  void _handleOnDeleteIMMessageSuccess(IMMessage removeIMMessage){
    widget.chatPageState.handleRemoveIMMesageSuccess(removeIMMessage);
  }

  //文本消息
  Widget _textMsgView(BuildContext context){
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 200),
        color: msgModel.isReceived?ColorThemes.whiteColor:ColorThemes.themeColor,
        child: Padding(
          padding: EdgeInsets.all(innerSpace),
          // child: Platform.isLinux?
          //   Text(
          //     msgModel.content,
          //     style: TextStyle(
          //       color: msgModel.isReceived?Colors.black:Colors.white, 
          //       fontSize: 16,
          //       fontFamily: "cn"
          //     )
          //   ):
          //   EmojiText(
          //     msgModel.content,
          //     style: TextStyle(
          //       color: msgModel.isReceived?Colors.black:Colors.white, 
          //       fontSize: 16,
          //       fontFamily: "cn"
          //     ),
          //   ),
          child: EmojiText(
            msgModel.content,
            style: TextStyle(
              color: msgModel.isReceived?Colors.black:Colors.white, 
              fontSize: 16,
              fontFamily: "cn"
            ),
          ),
        ),
      )
    );
  }

  //图片消息
  Widget _imageMsgView(BuildContext context){
    final IMMessage msg = msgModel.immessage!;

    //计算实际显示宽高
    String attachInfo = msg.attachInfo??"{}";
    var info = jsonDecode(attachInfo);
    var width = info["w"];
    var height = info["h"];
    Size imageSize = _calulateImageSize(width , height);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Visibility(
          visible: !(msg.attachState == AttachState.UPLOADED),
          child: const Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 8, 4),
            child: SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                color: Colors.green,
                strokeWidth: 2.0,
              ),
            ) ,
          )
        ),
        GestureDetector(
          onTap: (){
            Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (BuildContext context, Animation<double> animation,Animation<double> secondaryAnimation) {
                  return ExplorerImagePageWithSaveAction(
                    msgModel.immessage!.url!, 
                    msgModel.immessage!.msgId,
                    key: UniqueKey(),
                  );
                },
              ),
            );
          },
          child: Hero(
            tag: msgModel.immessage!.msgId,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: imageSize.width,
                height: imageSize.height,
                color: Colors.white,
                child: msg.url == null
                ?Image.file(File(msg.localPath!) , fit: BoxFit.fitWidth)
                :ExtendedImage.network(
                  HeadView.urlByCurrentSize(
                    context, 
                    msg.url,
                    width,
                    height
                  ),
                  fit: BoxFit.fitWidth
                )
              )
            ),
          )
        )
      ],
    );
  }

  //计算image合适的显示大小
  Size _calulateImageSize(int width , int height){
    final double maxWidth = MediaQuery.of(context).size.width / 2.0;
    final double maxHeight = maxWidth * 1.5;
    final double ratio = width / height;//宽高比

    double newWidth = width.toDouble();
    double newHeight = height.toDouble();
    if(width >= height){//宽图
      newWidth = width >= maxWidth ?maxWidth:width.toDouble();
      newHeight = newWidth / ratio;
    }else{
      newHeight = height>= maxHeight?maxHeight:height.toDouble();
      newWidth = newHeight * ratio;
    }

    return Size(newWidth,newHeight);
  }
}
