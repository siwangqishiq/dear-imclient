import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:dearim/core/imcore.dart';
import 'package:dearim/core/immessage.dart';
import 'package:dearim/core/log.dart';
import 'package:dearim/core/protocol/trans.dart';
import 'package:dearim/core/session.dart';
import 'package:dearim/models/chat_message_model.dart';
import 'package:dearim/models/contact_model.dart';
import 'package:dearim/models/trans.dart';
import 'package:dearim/tcp/tcp_manager.dart';
import 'package:dearim/utils/timer_utils.dart';
import 'package:dearim/views/chat_view.dart';
import 'package:dearim/views/color_utils.dart';
import 'package:dearim/widget/emoji.dart';
import 'package:dearim/widget/more_action.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';

import 'avchat_page.dart';

///
/// P2P聊天页
///
class ChatPage extends StatefulWidget {
  final ContactModel model;

  final int sessionType = IMMessageSessionType.P2P;

  const ChatPage(this.model,
      {int sessionType = IMMessageSessionType.P2P, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  late List<ChatMessageModel> msgModels = [];
  final ScrollController _listViewController = ScrollController();
  String? receiveText = "";
  IMMessageIncomingCallback? _msgIncomingCallback;

  late InputPanelWidget inputPanelWidget;

  late ChatTitleWidget titleWidget;

  late GlobalKey inputKey;

  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();

    titleWidget = ChatTitleWidget(this);

    inputKey = GlobalKey();
    inputPanelWidget = InputPanelWidget(this, key: inputKey);

    initMessageList();
    
    _listViewController.addListener(() {
        if (_listViewController.position.pixels >=
          _listViewController.position.maxScrollExtent) {
        LogUtil.log("chat list scroll top");
        _loadMoreIMMessages();
      }
    });
  }

  ///
  /// 上滑 加载更多历史消息
  ///
  void _loadMoreIMMessages() async{
    if(isLoadingMore){
      return;
    }

    isLoadingMore = true;
    
    int lastMsgTime = msgModels.last.createTime;

    var imMsgList = await IMClient.getInstance()
          .queryIMMessageList(
            IMMessageSessionType.P2P, 
            widget.model.userId , 
            flagTime: lastMsgTime
          );
    List<ChatMessageModel> result = <ChatMessageModel>[];
    for(var imMsg in imMsgList){
      result.add(ChatMessageModel.fromIMMessage(imMsg));
    }
    isLoadingMore = false;
    msgModels.addAll(result);
    setState(() {
    });
  }

  //查询历史消息
  Future<List<ChatMessageModel>> queryHistoryMessage() async {
    List<ChatMessageModel> result = <ChatMessageModel>[];
    var imMsgList = await IMClient.getInstance()
        .queryIMMessageList(IMMessageSessionType.P2P, widget.model.userId);

    for(var imMsg in imMsgList){
      result.add(ChatMessageModel.fromIMMessage(imMsg));
    }
    // for (IMMessage imMsg in imMsgList) {
    //   result.insert(0, ChatMessageModel.fromIMMessage(imMsg));
    // } //end for each
    return result;
  }

  void initMessageList() async {
    var msgList = await queryHistoryMessage();
    setState(() {
      msgModels.addAll(msgList); //查询历史消息
    });

    _msgIncomingCallback = (incomingIMMessageList) {
      _handleOnReceivedIMMsg(incomingIMMessageList);
    };

    IMClient.getInstance().registerIMMessageIncomingObserver(_msgIncomingCallback!, true);
    // scrollToBottom();

    //清零未读
    IMClient.getInstance()
        .clearUnreadCountBySession(widget.sessionType, widget.model.userId);
  }

  void _handleOnReceivedIMMsg(List<IMMessage> incomingIMMessageList){
    IMMessage incomingMessage = incomingIMMessageList.last;
    if (incomingMessage.sessionId != widget.model.userId) {
      //不属于此会话的消息 不做处理
      return;
    }

    //
    IMClient.getInstance().clearUnreadCountBySession(
        incomingMessage.sessionType, incomingMessage.sessionId);

    setState(() {
      receiveText = incomingIMMessageList.last.content;
      LogUtil.log(receiveText!);
      ChatMessageModel incomingMsgModel =
          ChatMessageModel.fromIMMessage(incomingIMMessageList.last);
      msgModels.insert(0, incomingMsgModel);
    });
  }

  ///
  /// 删除IM消息
  ///
  void handleRemoveIMMesageSuccess(IMMessage delIMMessage){
    ChatMessageModel? delMsgModel;
    for(var model in msgModels){
      if(model.immessage?.msgId == delIMMessage.msgId){
        delMsgModel = model;
      }
    }//end for each

    if(delMsgModel == null){
      LogUtil.log("Not found msgModel");
      return;
    }

    setState(() {
      msgModels.remove(delMsgModel);
    });
  }

  ///
  /// 消息转发成功
  ///
  void handleForwardIMMessageSuccess(IMMessage msg , int toUid){
    if(toUid != widget.model.userId){
      LogUtil.log("not this page uerid ${widget.model.userId} toUid $toUid forward ignore");
      return;
    }

    LogUtil.log("handleForwardIMMessageSuccess refresh.");
    setState(() {
      msgModels.insert(0 , ChatMessageModel.fromIMMessage(msg));
    });
  }

  @override
  Widget build(BuildContext context) {
    // SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
    //   LogUtil.log("一帧渲染完成后回调 $timeStamp");
    //   //scrollToBottom();
    // });

    // LogUtil.log("ChatPageState build!!");

    // Future.delayed(const Duration(milliseconds: 1000),(){
    //   scrollToBottom();
    // });

    return Scaffold(
      appBar: AppBar(
        title: titleWidget,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: NotificationListener<ScrollUpdateNotification>(
                onNotification: (notification) {
                  // LogUtil.log("滑动 ${notification.scrollDelta}");
                  if (notification.scrollDelta!.abs() > 4.0) {
                    //向上滑动
                    (inputKey.currentState as InputPanelState)
                        .closeAllInputPanel();
                  }
                  return false;
                },
                child: Container(
                  color: ColorThemes.grayColor,
                  constraints:
                      BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: ListView.builder(
                        reverse: true,
                        shrinkWrap: true,
                        controller: _listViewController,
                        itemCount: msgModels.length,
                        itemBuilder: (BuildContext context, int index) {
                          ChatMessageModel msgModel = msgModels[index];
                          return ChatView(
                            this,
                            msgModel,
                            preMsgModel: index + 1 < msgModels.length
                                ? msgModels[index + 1]
                                : null,
                            key: UniqueKey(),
                          );
                        },
                      ),
                    ),
                  )
                ),
              )
            ),
            const SizedBox(
              height: 16,
            ),
            inputPanelWidget,
            const SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }

  void scrollToBottom() {
    // int microseconds = 1000;
    // Timer(Duration(microseconds: microseconds), () {
    //   _listViewController.jumpTo(_listViewController.position.maxScrollExtent);
    // });
    // _listViewController.jumpTo(_listViewController.position.maxScrollExtent);

    final double bottomOffset = _listViewController.position.maxScrollExtent;
    _listViewController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    if (_msgIncomingCallback != null) {
      TCPManager().unregistMessageCommingCallback(_msgIncomingCallback!);
    }
    super.dispose();
    LogUtil.log("chat page dispose");
  }
}

///
/// 头部标题
///
class ChatTitleWidget extends StatefulWidget {
  final ChatPageState chatContext;

  const ChatTitleWidget(this.chatContext, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ChatTitleState();
}

class ChatTitleState extends State<ChatTitleWidget> {
  late ContactModel contactModel;
  int sessionType = IMMessageSessionType.P2P;

  String? showTitle;
  bool isShowingInput = false;

  TransMessageIncomingCallback? _transMessageIncomingCallback;

  //未读消息改变观察者
  UnreadCountChangeCallback? _unreadMessageCountObserver;

  //其他会话未读消息数量
  int otherSessionUnreadCount = 0;

  @override
  void initState() {
    super.initState();
    contactModel = widget.chatContext.widget.model;
    sessionType = widget.chatContext.widget.sessionType;
    showTitle = _getChatTitleContent();
    otherSessionUnreadCount = _queryOtherSessionUnreadCount();

    _transMessageIncomingCallback = (transMessage) {
      handleTransMessage(transMessage);
    };

    IMClient.getInstance()
        .registerTransMessageObserver(_transMessageIncomingCallback!, true);

    _unreadMessageCountObserver = (int oldUnreadCunt, int currentUnreadCount) {
      if (currentUnreadCount > 0) {
        setState(() {
          showTitle = _getChatTitleContent();
          otherSessionUnreadCount = _queryOtherSessionUnreadCount();
        });
      }
    };
    IMClient.getInstance()
        .registerUnreadCountObserver(_unreadMessageCountObserver!, true);
  }

  ///
  /// 处理透传消息
  ///
  void handleTransMessage(TransMessage transMessage) {
    if (transMessage.from != contactModel.userId) {
      return;
    }

    String? content = transMessage.content;
    if (content != null) {
      Map<String, dynamic> json = jsonDecode(content);
      int type = json[CustomTransTypes.KEY_TYPE];

      if (type == CustomTransTypes.TYPE_INPUTTING) {
        displayInputtingTips();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Visibility(
            visible: otherSessionUnreadCount > 0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                    color: Colors.black12, shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      otherSessionUnreadCount.toString(),
                      style: const TextStyle(fontSize: 16, color: Colors.white54)
                    )
                  ),
                ),
            )
          ),
        Text(
          showTitle ?? "",
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  void displayInputtingTips() {
    if (isShowingInput) {
      return;
    }

    setState(() {
      isShowingInput = true;
      showTitle = "正在输入中...";
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        showTitle = _getChatTitleContent();
        isShowingInput = false;
      });
    });
  }

  String _getChatTitleContent() {
    // var count = IMClient.getInstance().querySessionUnreadCount(sessionType, contactModel.userId);
    // LogUtil.log("当前会话未读数量 : ${count}   sessionId = ${contactModel.userId}  TYPE: ${contactModel.sessionType}");

    //未读数量 需要减去当前会话的
    // final int unreadCountExceptCurrentSession =
    //     IMClient.getInstance().sessionUnreadCount -
    //         IMClient.getInstance()
    //             .querySessionUnreadCount(sessionType, contactModel.userId);
    // if (unreadCountExceptCurrentSession > 0) {
    //   return "($unreadCountExceptCurrentSession) ${contactModel.name}";
    // }
    return contactModel.name;
  }

  int _queryOtherSessionUnreadCount() {
    return IMClient.getInstance().sessionUnreadCount -
        IMClient.getInstance()
            .querySessionUnreadCount(sessionType, contactModel.userId);
  }

  @override
  void dispose() {
    if (_transMessageIncomingCallback != null) {
      IMClient.getInstance()
          .registerTransMessageObserver(_transMessageIncomingCallback!, false);
    }

    if (_unreadMessageCountObserver != null) {
      IMClient.getInstance()
          .registerUnreadCountObserver(_unreadMessageCountObserver!, false);
    }
    super.dispose();
  }
}

///
/// 输入面板
///
class InputPanelWidget extends StatefulWidget {
  final ChatPageState chatPageContext;

  const InputPanelWidget(this.chatPageContext, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return InputPanelState();
  }
}

///
/// 输入框控件
///
class InputPanelState extends State<InputPanelWidget> {
  final FocusNode _inputFocusNode = FocusNode();
  final TextEditingController _textFieldController = TextEditingController();

  GlobalKey inputKey = GlobalKey();

  String text = "";
  bool _sendBtnVisible = false;
  bool _showEmojiGridPanel = false;
  List<String> emojiNames = EmojiManager.instance.listAllEmoji();

  int lastTransMsgSendTime = 0;

  bool _showMoreActionsVisible = false;

  //输入更多操作
  List<InputAction> inputActions = InputActionHelper.findP2PSessionActions();

  //记录光标位置
  TextSelection? inputTextSelection;

  @override
  void initState() {
    super.initState();

    // _textFieldController.addListener(() {
    //   final String text = _textFieldController.text;
    //   _textFieldController.value = _textFieldController.value.copyWith(
    //     text: text,
    //     selection:
    //         TextSelection(baseOffset: text.length, extentOffset: text.length),
    //     composing: TextRange.empty,
    //   );
    // });
  }

  @override
  Widget build(BuildContext context) {
   
    return Column(
      children: [inputWidget(), emojiWidget(), moreActionsWidget()],
    );
  }

  int _inputActionsPageSize() {
    if (inputActions.length % InputActionHelper.PAGE_PER_SIZE == 0) {
      return inputActions.length ~/ InputActionHelper.PAGE_PER_SIZE;
    }
    return inputActions.length ~/ InputActionHelper.PAGE_PER_SIZE + 1;
  }

  Widget _moreActionPanelWidget(int index) {
    int offset = InputActionHelper.PAGE_PER_SIZE * index;
    int end = offset + InputActionHelper.PAGE_PER_SIZE >= inputActions.length
        ? inputActions.length
        : offset + InputActionHelper.PAGE_PER_SIZE;
    List<InputAction> subInputActions = inputActions.sublist(offset, end);

    // LogUtil.log("index : $index  subInputActions : ${subInputActions.length}");
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        childAspectRatio: 1,
      ),
      itemBuilder: (BuildContext context, int index) {
        final InputAction action = subInputActions[index];
        return InkWell(
          onTap: () => action.onClickAction(context, this),
          child: Center(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 60,
                  height: 60,
                  color: ColorThemes.grayBgColor,
                  child: Center(
                    child: SizedBox(
                      child: Image.asset(action.icon,
                          width: 32, height: 32, fit: BoxFit.fitWidth),
                    ),
                  )
                )
              ),
              const SizedBox(height: 8),
              Text(action.name,
                  style: const TextStyle(fontSize: 14, color: Colors.grey))
            ],
          )),
        );
      },
      itemCount: subInputActions.length,
    );
  }

  //更多操作
  Widget moreActionsWidget() {
    return Visibility(
        visible: _showMoreActionsVisible,
        child: SizedBox(
            height: 260,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                const Divider(
                  color: ColorThemes.grayBgDiv,
                  height: 1,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: PageView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _inputActionsPageSize(),
                        itemBuilder: (BuildContext context, int index) {
                          return _moreActionPanelWidget(index);
                        }),
                  ),
                )
              ],
            )));
  }

  void _toggleMoreActionsPanel() {
    _showMoreActionsVisible = !_showMoreActionsVisible;

    if (_showMoreActionsVisible) {
      _showEmojiGridPanel = false;
      _inputFocusNode.unfocus(); //关闭键盘
      Future.delayed(const Duration(milliseconds: 200), () {
        setState(() {});
      });
    } else {
      setState(() {});
    }
  }

  //插入文本
  void insertText(String insert, TextEditingController controller) {
    String text = controller.text;
    TextSelection textSelection = inputTextSelection ?? controller.selection;
    LogUtil.log(
        "text: $text , start : ${textSelection.start} end: ${textSelection.end}");
    String newText;
    int startPos;
    if (textSelection.start == -1 && textSelection.end == -1) {
      newText = insert;
      startPos = 0;
    } else {
      newText =
          text.replaceRange(textSelection.start, textSelection.end, insert);
      startPos = textSelection.start;
    }

    final int length = insert.length;
    controller.text = newText;
    controller.selection = textSelection.copyWith(
      baseOffset: startPos + length,
      extentOffset: startPos + length,
    );

    // int cursorPos = controller.selection.base.offset;
    // var selection = controller.selection;

    // LogUtil.log(
    //     "start : ${selection.start}   ${selection.end}  ${selection.toString()} ${selection.extentOffset}");

    // // controller.text = (controller.text + insert);

    // controller.selection =
    //     TextSelection.collapsed(offset: controller.text.length);

    // String newText = controller.text
    //     .replaceRange(max(cursorPos, 0), max(cursorPos, 0), insert);
    // controller.value = controller.value.copyWith(
    //     text: newText,
    //     selection: TextSelection.collapsed(offset: newText.length));

    // onInputTextChange(controller.text);
    // cursorPos = controller.selection.base.offset;
    // LogUtil.log("After cursorPos : $cursorPos");

    // EmojiInputTextState inputTextState =
    //     inputKey.currentState as EmojiInputTextState;
    //LogUtil.log("input globay key $type");
    // inputTextState.onChange(controller.text);

    onInputTextChange(controller.text);
  }

  Widget emojiWidget() {
    return Visibility(
        visible: _showEmojiGridPanel,
        child: SizedBox(
          height: 260,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: _emojiGridWidget(),
          ),
        ));
  }

  Widget _emojiGridWidget() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        childAspectRatio: 1,
      ),
      itemBuilder: (BuildContext context, int index) {
        final String emojiName = emojiNames[index];
        return InkWell(
          onTap: () => _onSelectEmoji(emojiName),
          child: Image.asset(EmojiManager.instance.emojiAssetPath(emojiName)),
        );
      },
      itemCount: emojiNames.length,
    );
  }

  //选中一个表情
  void _onSelectEmoji(String emojiName) {
    // LogUtil.log("emoji: $emojiName");
    // LogUtil.log(
    //     "${_textFieldController.selection.hashCode} text: $text , start : ${_textFieldController.selection.start} end: ${_textFieldController.selection.end}");
    insertText(emojiName, _textFieldController);
  }

  //打开 或 关闭 表情输入面板
  void _toggleEmojiInputGridPanel() {
    _showEmojiGridPanel = !_showEmojiGridPanel;

    if (_showEmojiGridPanel) {
      _showMoreActionsVisible = false;
      _inputFocusNode.unfocus(); //关闭键盘
      Future.delayed(const Duration(milliseconds: 200), () {
        setState(() {});
      });
    } else {
      setState(() {});
    }
  }

  ///
  /// linux使用系统自带的输入框
  ///
  Widget textFieldForLinux(){
    return TextField(
      key: inputKey,
      onSubmitted: (content) {
        sendTextIMMsg(content.trim());
      },
      onTap: () {
        _textFieldController.selection.copyWith();
        if (_showEmojiGridPanel || _showMoreActionsVisible) {
          setState(() {
            _showEmojiGridPanel = false;
            _showMoreActionsVisible = false;
          });
        }
      },
      showCursor: true,
      focusNode: _inputFocusNode,
      onChanged: (_text) => onInputTextChange(_text),
      controller: _textFieldController,
      maxLines: null,
      textInputAction: TextInputAction.send,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(10, 4, 10, 4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
        ),
      ),
    );
  }

  ///
  /// 文本输入框 支持表情emoji
  ///
  Widget textFieldCommon(){
    return ExtendedTextField(
      key: inputKey,
      onSubmitted: (content) {
        // LogUtil.log("on submit content : $content");
        // LogUtil.log("=================================");
        // LogUtil.log("on submit text : $text");
        // LogUtil.log("=================================");

        sendTextIMMsg(content.trim());
      },
      onTap: () {
        // LogUtil.log("input tap");
        _textFieldController.selection.copyWith();
        if (_showEmojiGridPanel || _showMoreActionsVisible) {
          setState(() {
            _showEmojiGridPanel = false;
            _showMoreActionsVisible = false;
          });
        }
        // _textFieldController.selection = TextSelection.collapsed(
        //     offset: _textFieldController.text.length);
      },
      specialTextSpanBuilder: CustomSpecialTextSpanBuilder(),
      showCursor: true,
      focusNode: _inputFocusNode,
      onChanged: (_text) => onInputTextChange(_text),
      controller: _textFieldController,
      maxLines: null,
      textInputAction: TextInputAction.send,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(10, 4, 10, 4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget inputWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 8,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child:textFieldCommon()
          ),
        ),
        Visibility(
          // visible: !Platform.isLinux,
          visible: true,
          child: GestureDetector(
            onTap: _toggleEmojiInputGridPanel,
            child: Container(
              width: 40,
              height: 40,
              child: const Icon(Icons.face_rounded, color: Colors.grey),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 2.0),
                borderRadius: const BorderRadius.all(Radius.circular(30)),
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: _toggleMoreActionsPanel,
              child: Container(
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.add,
                  color: Colors.grey,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2.0),
                  borderRadius: const BorderRadius.all(Radius.circular(30)),
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: _sendBtnVisible ? 60 : 0,
              height: _sendBtnVisible ? 40 : 0,
              child: ElevatedButton(
                onPressed: () => sendTextIMMsg(text),
                child: const Text("发送", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
        const SizedBox(
          width: 8,
        ),
      ],
    );
  }

  void onInputTextChange(String _text) {
    text = _text.trim();
    // String text2 = _textFieldController.text;
    // TextSelection textSelection = _textFieldController.selection;
    // LogUtil.log(
    //     "${_textFieldController.selection.hashCode} text: $text2 , start : ${textSelection.start} end: ${textSelection.end}");
    //_textFieldController.text = text;

    inputTextSelection = _textFieldController.selection;

    // _textFieldController.value = _textFieldController.value.copyWith(
    //     text: text, selection: TextSelection.collapsed(offset: text.length));

    setState(() {
      _sendBtnVisible = text.isNotEmpty;
    });

    sendInputCustomTransMsg();
  }

  //发送透传消息  告知对方 正在输入中...
  void sendInputCustomTransMsg() {
    int curTime = TimerUtils.getCurrentTimeStamp();

    //距离上一次发送间隔小于10s 不再发送
    if (curTime - lastTransMsgSendTime < 10 * 1000) {
      return;
    }

    TransMessage? msg = TransMessageBuilder.create(
        widget.chatPageContext.widget.model.userId,
        CustomTransBuilder.build(CustomTransTypes.TYPE_INPUTTING, null),
        null);

    IMClient.getInstance().sendTransMessage(msg!);
    lastTransMsgSendTime = curTime;
  }

  //添加新IM消息到消息列表中
  void _addIMMessageToList(IMMessage msg) {
    var msgList = widget.chatPageContext.msgModels;
    // msgList.add(ChatMessageModel.fromIMMessage(msg));
    msgList.insert(0, ChatMessageModel.fromIMMessage(msg));

    widget.chatPageContext.setState(() {});
    widget.chatPageContext.scrollToBottom();

    // Future.delayed(const Duration(milliseconds: 300), () {
    // });

    //LogUtil.log("总消息数量: ${msgList.length}");
  }

  //发送文本消息
  void sendTextIMMsg(String content) async {
    content = content.trim();

    var model = widget.chatPageContext.widget.model;

    if (_textFieldController.text.isEmpty) {
      _textFieldController.clear();
      _inputFocusNode.requestFocus();
      return;
    }

    var msg = await TCPManager().sendMessage(content, model.userId);
    if (msg == null) {
      return;
    }

    setState(() {
      _sendBtnVisible = false;
      _textFieldController.clear();
      inputTextSelection = _textFieldController.selection;
      //_textFieldController.text = "";

      //表情输入框 或 更多面板已经打开了 不需要再弹键盘
      if (_showEmojiGridPanel || _showMoreActionsVisible) {
        return;
      }

      //发送文本后保留焦点 以方便下次输入
      _inputFocusNode.requestFocus();
    });

    //refresh message list
    _addIMMessageToList(msg);
  }

  //发送图片消息
  void sendImageIMMessage(String path) async {
    ContactModel model = widget.chatPageContext.widget.model;
    IMMessage? imageMsg = await IMMessageBuilder.createImage(
        model.userId, IMMessageSessionType.P2P, path);
    if (imageMsg == null) {
      return;
    }

    _addIMMessageToList(imageMsg);

    //关闭更多操作面板
    setState(() {
      _showMoreActionsVisible = false;
    });

    //send image im message
    IMClient.getInstance().sendIMMessage(imageMsg,
        callback: (imMessage, result) {
      LogUtil.log("图片消息 发送成功! ${imMessage.url}");
      widget.chatPageContext.setState(() {});
    });
  }

  ///
  /// 关闭所有键盘 表情 输入
  ///
  void closeAllInputPanel() {
    // LogUtil.log("hello closeAllInputPanel");

    if (_showMoreActionsVisible ||
        _showEmojiGridPanel ||
        _inputFocusNode.hasFocus) {
      setState(() {
        _showMoreActionsVisible = false;
        _showEmojiGridPanel = false;
        _inputFocusNode.unfocus();
      });
    }
  }

  ///
  /// 开启音视频通话
  /// 
  ///
  void startAvChat(){
    var remoteModel = widget.chatPageContext.widget.model;
    Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => AvChatPage(remoteModel)));
  }
}//end class input_panel_state
