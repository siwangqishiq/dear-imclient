// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';

import 'package:dearim/core/avchat.dart';
import 'package:dearim/core/imcore.dart';
import 'package:dearim/core/log.dart';
import 'package:dearim/core/protocol/trans.dart';
import 'package:dearim/models/contact_model.dart';
import 'package:dearim/models/trans.dart';
import 'package:dearim/views/toast_show_utils.dart';
import 'package:dearim/widget/avchat_userinfo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

const int AVCHAT_STATE_WAIT_ANSWER = 1; //等待对端响应 or 接收者 等待回答
const int AVCHAT_STATE_CONNECTING = 2; //连接建立中
const int AVCHAT_STATE_ESTABLISH = 4; //通话中
const int AVCHAT_STATE_CLOSED = 400; //关闭状态

// ignore: must_be_immutable
class AvChatPage extends StatefulWidget {
  ContactModel remoteModel;
  bool caller = true; //是否是发起者
  int avState = AVCHAT_STATE_WAIT_ANSWER;

  AvChatPage(this.remoteModel, {this.caller = true, Key? key})
      : super(key: key);

  @override
  AvChatPageState createState() => AvChatPageState();
}

class AvChatPageState extends State<AvChatPage> {
  late TransMessageIncomingCallback _transMessageIncomingCallback;

  MediaStream? _localStream;
  late RTCVideoRenderer _localVideoRender;

  MediaStream? _remoteStream;
  late RTCVideoRenderer _remoteVideoRender;

  final List<RTCIceCandidate> _candidateHolderList = [];
  RTCSessionDescription? _remoteDescription;

  @override
  void initState() {
    super.initState();
    _localVideoRender = RTCVideoRenderer();
    _localVideoRender.initialize();

    _remoteVideoRender = RTCVideoRenderer();
    _remoteVideoRender.initialize();

    _registerTranObserver();

    if (widget.caller) {
      AVChatManager.getInstance().startChat(widget.remoteModel.userId);
      _startLocalPreview();
    }
  }

  @override
  Widget build(BuildContext context) {
    late Widget showWidget;

    if (widget.avState == AVCHAT_STATE_CONNECTING) {
      showWidget = AvchatConnectingWidget(widget.remoteModel, this);
    } else if (widget.avState == AVCHAT_STATE_WAIT_ANSWER) {
      if (widget.caller) {
        showWidget = AvchatCallOutWaitPanel(widget.remoteModel, this);
      } else {
        showWidget = AvChatCallInWaitPanel(widget.remoteModel, this);
      }
    } else if (widget.avState == AVCHAT_STATE_ESTABLISH) {
      showWidget = AvchatEstablishPanel(widget.remoteModel, this);
    }

    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Stack(
          children: [
            Center(
                child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: RTCVideoView(
                _remoteVideoRender,
                mirror: true,
              ),
            )),
            Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                width: 100.0,
                height: 200.0,
                child: RTCVideoView(
                  _localVideoRender,
                  mirror: true,
                ),
              ),
            ),
            showWidget,
          ],
        ),
      ),
    );
  }

  void _startLocalPreview() async {
    //检测是否有摄像头 麦克风
    var deviceInfoList = await navigator.mediaDevices.enumerateDevices();
    bool enableAuido = false;
    bool enableVideo = false;
    for (var device in deviceInfoList) {
      LogUtil.log(
          "deviceInfo ${device.kind}: ${device.label} id = ${device.deviceId}");
      if (device.kind?.startsWith("videoinput") ?? false) {
        enableVideo = true;
      } else if (device.kind?.startsWith("audioinput") ?? false) {
        enableAuido = true;
      }
    }

    if (!enableAuido && !enableVideo) {
      LogUtil.log("not found audio or video device quit");
      _onLocalMediaError(null);
      return;
    }

    LogUtil.log("mediaConstraints audio: $enableAuido video: $enableVideo");
    final mediaConstraints = <String, dynamic>{
      'audio': enableAuido,
      'video': enableVideo
    };

    navigator.mediaDevices
        .getUserMedia(mediaConstraints)
        .then((stream) => _handleLocalStream(stream))
        .catchError((err) => _onLocalMediaError(err));
  }

  void _onLocalMediaError(Error? err) {
    LogUtil.log("start local preview error: $err");
    AVChatManager.getInstance().finishAVChat(needSendMessage: true);
    Navigator.of(context).pop();
  }

  void _handleLocalStream(MediaStream stream) {
    startCameraPreview(stream);
  }

  void startCameraPreview(MediaStream stream) async {
    LogUtil.log("startCameraPreview get stream");

    _localStream = stream;
    _localVideoRender.srcObject = _localStream;
    setState(() {});

    await AVChatManager.getInstance().buildPeerConnection();
    addPeerConnectionListener();

    if (!widget.caller) {
      //被叫方  修改状态为连接中 主叫方需要等待
      startRtcConnect();
      _setRemoteDesription();
    }

    //添加提前收取到的iceCandidate
    var pc = AVChatManager.getInstance().getPeerConnection();
    LogUtil.log("add ice holderlist size : ${_candidateHolderList.length}");
    if (_candidateHolderList.isNotEmpty) {
      for (var ice in _candidateHolderList) {
        LogUtil.log("add ice");
        pc?.addCandidate(ice);
      }
      _candidateHolderList.clear();
    }
  }

  void addPeerConnectionListener() {
    var pc = AVChatManager.getInstance().getPeerConnection();

    LogUtil.log("start addPeerConnectionListener");
    _localStream
        ?.getTracks()
        .forEach((track) => pc?.addTrack(track, _localStream!));

    pc?.onIceCandidate = (iceCandidate) {
      LogUtil.log(
          "add peerconnection on icecandidate: ${iceCandidate.candidate}");
      AVChatManager.getInstance().sendIceCandidate(iceCandidate);
    };

    pc?.onAddStream = (stream) {
      LogUtil.log("remote onAddStream");
      _remoteStream = stream;
      _remoteVideoRender.srcObject = _remoteStream;

      LogUtil.log("av chat connected successed!");
      setState(() {
        widget.avState = AVCHAT_STATE_ESTABLISH;
      });
    };

    // pc?.onTrack  = (track){
    // };
  }

  ///
  /// 开始webrtc连接
  ///
  void startRtcConnect() {
    LogUtil.log("start rtc connecting...");
    setState(() {
      widget.avState = AVCHAT_STATE_CONNECTING;
    });

    // create offer
    if (widget.caller) {
      //create offer
      var pc = AVChatManager.getInstance().getPeerConnection();
      pc?.createOffer().then((offer) {
        pc
            .setLocalDescription(RTCSessionDescription(offer.sdp, offer.type))
            .then((value) {
          LogUtil.log("setLocalDescription success");
          //send offer
          AVChatManager.getInstance().sendOffer(offer);
        }).onError((error, stackTrace) {
          LogUtil.log("setLocalDescription error $error");
        });
      }).onError((error, stackTrace) {
        LogUtil.log("create offer error: $error");
      });
    }
  }

  void _registerTranObserver() {
    _transMessageIncomingCallback =
        (transMessage) => _handleTransMessage(transMessage);
    IMClient.getInstance()
        .registerTransMessageObserver(_transMessageIncomingCallback, true);
  }

  void _handleTransMessage(TransMessage transMessage) {
    String? content = transMessage.content;
    if (content == null) {
      return;
    }

    // LogUtil.log("avchat onTransMessageIncoming content: $content");
    Map<String, dynamic> json = jsonDecode(content);
    int type = json[CustomTransTypes.KEY_TYPE];
    switch (type) {
      case CustomTransTypes.TYPE_AVCHAT_HANGUP:
        remoteHangUp(json[CustomTransTypes.KEY_CONTENT]);
        break;
      case CustomTransTypes.TYPE_AVCHAT_ACCEPT:
        remoteAcceptInvite(json[CustomTransTypes.KEY_CONTENT]);
        break;
      case CustomTransTypes.TYPE_AVCHAT_OFFER:
        remoteOffer(json[CustomTransTypes.KEY_CONTENT]);
        break;
      case CustomTransTypes.TYPE_AVCHAT_ANSWER:
        remoteAnswer(json[CustomTransTypes.KEY_CONTENT]);
        break;
      case CustomTransTypes.TYPE_AVCHAT_ICE_CANDIDATE:
        remoteGetIceCandidate(json[CustomTransTypes.KEY_CONTENT]);
        break;
    } //end switch
  }

  ///
  /// 获取IceCandidate
  ///
  void remoteGetIceCandidate(Map<String, dynamic> json) {
    LogUtil.log(
        "add ice remoteGetIceCandidate pc is null ${AVChatManager.getInstance().getPeerConnection() == null}");
    var result = AVChatManager.getInstance().checkMessageInSession(json);
    if (!result) {
      //not this session ignore
      LogUtil.log("remoteGetIceCandidate /not this session ignore !");
      return;
    }

    try {
      var map = json[AVChatManager.KEY_ICECANDIDATE];
      RTCIceCandidate iceCandidate = RTCIceCandidate(
          map['candidate'], map['sdpMid'], map['sdpMLineIndex']);

      var pc = AVChatManager.getInstance().getPeerConnection();
      LogUtil.log(
          "add ice ${iceCandidate.candidate}  pc is null ${pc == null}");
      if (pc == null) {
        _candidateHolderList.add(iceCandidate);
      } else {
        pc.addCandidate(iceCandidate);
      }
    } catch (e) {
      LogUtil.log(e.toString());
    }
  }

  ///
  /// 远端发送过来answer
  ///
  void remoteAnswer(Map<String, dynamic> json) {
    LogUtil.log("remoteAnswer");
    var result = AVChatManager.getInstance().checkMessageInSession(json);
    if (!result) {
      //not this session ignore
      return;
    }

    try {
      String type = json[AVChatManager.KEY_TYPE];
      String sdp = json[AVChatManager.KEY_SDP];

      var pc = AVChatManager.getInstance().getPeerConnection();
      pc
          ?.setRemoteDescription(RTCSessionDescription(sdp, type))
          .then((value) => LogUtil.log("setRemoteDescription success"))
          .onError((error, stackTrace) =>
              LogUtil.log("setRemoteDescription error $error"));
    } catch (e) {
      LogUtil.log(e.toString());
    }
  }

  ///
  /// 远端发送过来offer
  ///
  void remoteOffer(Map<String, dynamic> json) {
    LogUtil.log("remoteOffer");
    var result = AVChatManager.getInstance().checkMessageInSession(json);
    if (!result) {
      //not this session ignore
      return;
    }

    try {
      String type = json[AVChatManager.KEY_TYPE];
      String sdp = json[AVChatManager.KEY_SDP];

      _remoteDescription = RTCSessionDescription(sdp, type);
      var pc = AVChatManager.getInstance().getPeerConnection();
      if (pc == null) {
        LogUtil.log("remoteOffer but current peerconnection not created");
        return;
      }

      _setRemoteDesription();
    } catch (e) {
      LogUtil.log(e.toString());
    }
  }

  void _setRemoteDesription() {
    if (_remoteDescription == null) {
      return;
    }

    var pc = AVChatManager.getInstance().getPeerConnection();
    pc?.setRemoteDescription(_remoteDescription!).then((value) {
      pc.createAnswer().then((answer) {
        pc
            .setLocalDescription(RTCSessionDescription(answer.sdp, answer.type))
            .then((value) {
          //send answer;
          LogUtil.log("setLocalDescription success");
          AVChatManager.getInstance().sendAnswer(answer);
        }).onError((error, stackTrace) {
          LogUtil.log("setLocalDescription error $error");
        });
      }).onError((error, stackTrace) {
        LogUtil.log("remoteOffer set answer error: $error");
      });
    });
    _remoteDescription = null;
  }

  ///
  /// 远端接受邀请
  ///
  void remoteAcceptInvite(Map<String, dynamic> json) {
    LogUtil.log("remoteAcceptInvite");
    var result = AVChatManager.getInstance().checkMessageInSession(json);
    if (!result) {
      //not this session ignore
      return;
    }

    startRtcConnect();
  }

  void remoteHangUp(Map<String, dynamic> json) {
    var result = AVChatManager.getInstance().onReceivedHangupMessage(json);

    if (result) {
      if (widget.avState == AVCHAT_STATE_WAIT_ANSWER && widget.caller) {
        ToastShowUtils.show("对方拒绝接听", context);
      }
      Navigator.of(context).pop();
    }
  }

  void hangup({sendMessage = true}) {
    LogUtil.log("hangup av chat");
    var result =
        AVChatManager.getInstance().finishAVChat(needSendMessage: sendMessage);
    LogUtil.log("hangup $result");
    Navigator.of(context).pop();
  }

  void accept() {
    LogUtil.log("accept invite");
    if (AVChatManager.getInstance().acceptInvite()) {
      _startLocalPreview();
    }
  }

  void _closeLocalStream() {
    _localStream?.getTracks().forEach((track) {
      track.stop();
    });
    _localStream?.dispose();
    _localVideoRender.srcObject = null;
    _localVideoRender.dispose();
  }

  void _closeRemoteStream() {
    _remoteStream?.getTracks().forEach((track) {
      track.stop();
    });
    _remoteStream?.dispose();
    _remoteVideoRender.srcObject = null;
    _remoteVideoRender.dispose();
  }

  @override
  void dispose() {
    super.dispose();
    _closeLocalStream();
    _closeRemoteStream();

    AVChatManager.getInstance().close();

    IMClient.getInstance()
        .registerTransMessageObserver(_transMessageIncomingCallback, false);
  }
}

// ignore: must_be_immutable
class AvChatCallInWaitPanel extends StatefulWidget {
  ContactModel remoteModel;
  AvChatPageState parentState;

  AvChatCallInWaitPanel(this.remoteModel, this.parentState, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => AvChatCallInWaitState();
}

class AvChatCallInWaitState extends State<AvChatCallInWaitPanel> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AvChatUserInfoWidget(widget.remoteModel),
        const Text(
          "请求通话",
          style: TextStyle(color: Colors.grey, fontSize: 16.0),
        ),
        const Spacer(),
        Row(
          children: [
            const SizedBox(width: 70.0),
            ElevatedButton(
              onPressed: () => widget.parentState.accept(),
              child: const Icon(
                Icons.phone,
                color: Colors.white,
                size: 36.0,
              ),
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
                backgroundColor: Colors.green, // <-- Button color
                foregroundColor: Colors.white, // <-- Splash color
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => widget.parentState.hangup(),
              child: const Icon(
                Icons.phone_disabled,
                color: Colors.white,
                size: 36.0,
              ),
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
                backgroundColor: Colors.red, // <-- Button color
                foregroundColor: Colors.white, // <-- Splash color
              ),
            ),
            const SizedBox(width: 70.0)
          ],
        ),
        const SizedBox(
          height: 14.0,
        )
      ],
    );
  }
}

// ignore: must_be_immutable
class AvchatConnectingWidget extends StatefulWidget {
  ContactModel remoteModel;
  AvChatPageState pageState;

  AvchatConnectingWidget(this.remoteModel, this.pageState, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => AvchatConnectingState();
}

///
/// 连接建立中
///
class AvchatConnectingState extends State<AvchatConnectingWidget> {
  int _dotCount = 0;
  Timer? _animatorTimer;

  @override
  void initState() {
    super.initState();
    _animatorTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _dotCount = (_dotCount + 1) % 4;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AvChatUserInfoWidget(widget.remoteModel),
        Text(
          "连接建立中." + ("." * _dotCount),
          style: const TextStyle(color: Colors.grey, fontSize: 16.0),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: () => widget.pageState.hangup(),
          child: const Icon(
            Icons.phone_disabled,
            color: Colors.white,
            size: 36.0,
          ),
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
            backgroundColor: Colors.red, // <-- Button color
            foregroundColor: Colors.white, // <-- Splash color
          ),
        ),
        const SizedBox(height: 20.0)
      ],
    );
  }

  @override
  void dispose() {
    _animatorTimer?.cancel();
    super.dispose();
  }
}

// ignore: must_be_immutable
class AvchatCallOutWaitPanel extends StatefulWidget {
  ContactModel remoteModel;
  AvChatPageState pageState;

  AvchatCallOutWaitPanel(this.remoteModel, this.pageState, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _AvChatCalloutWaitPanelState();
}

class _AvChatCalloutWaitPanelState extends State<AvchatCallOutWaitPanel> {
  int _dotCount = 0;
  Timer? _animatorTimer;

  @override
  void initState() {
    super.initState();
    _animatorTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // LogUtil.log("_dotCount update $_dotCount");
      setState(() {
        _dotCount = (_dotCount + 1) % 3;
      });
    });
  }

  @override
  void dispose() {
    _animatorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AvChatUserInfoWidget(widget.remoteModel),
        Text(
          "等待接听." + ("." * _dotCount),
          style: const TextStyle(color: Colors.grey, fontSize: 16.0),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: () => widget.pageState.hangup(),
          child: const Icon(
            Icons.phone_disabled,
            color: Colors.white,
            size: 36.0,
          ),
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
            backgroundColor: Colors.red, // <-- Button color
            foregroundColor: Colors.white, // <-- Splash color
          ),
        ),
        const SizedBox(
          height: 14.0,
        )
      ],
    );
  }
}

// 连接成功 开始通话
// ignore: must_be_immutable
class AvchatEstablishPanel extends StatefulWidget {
  ContactModel remoteModel;
  AvChatPageState pageState;

  AvchatEstablishPanel(this.remoteModel, this.pageState, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _AvChatEstablishPanelState();
}

class _AvChatEstablishPanelState extends State<AvchatEstablishPanel> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        ElevatedButton(
          onPressed: () => widget.pageState.hangup(),
          child: const Icon(
            Icons.phone_disabled,
            color: Colors.white,
            size: 36.0,
          ),
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
            backgroundColor: Colors.red, // <-- Button color
            foregroundColor: Colors.white, // <-- Splash color
          ),
        ),
        SizedBox(
          height: 14.0,
          width: MediaQuery.of(context).size.width,
        )
      ],
    );
  }
}
