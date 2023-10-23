///
/// flutter packages pub run build_runner build 自动生成
///

import 'dart:io';

import 'package:dearim/core/immessage.dart';
import 'package:dearim/core/session.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../log.dart';

part 'im_table.g.dart';

///
///
/// int size = 0; //消息总大小
  // String msgId = ""; //消息唯一标识
  // int fromId = 0; //发送人ID
  // int toId = 0; //接收人ID
  // int createTime = 0;
  // int updateTime = 0;

  // int imMsgType = 0; //消息类型
  // int sessionType = IMMessageSessionType.P2P;
  // int msgState = 0; //消息状态
  // int readState = 1; //已读状态 0已读  1未读
  // int fromClient = 0;
  // int toClient = 0;

  // String? content; //消息内容
  // String? url; //资源Url
  // int attachState = 0; //附件状态
  // String? attachInfo; //附件信息
  // String? localPath; //资源本地路径
  // String? custom; //自定义扩展字段

  // bool isReceived = false; //是否是接收消息 此字段不参与传输
///

//消息表 sqlite存储
class IMMessageData extends Table{
  IntColumn get id => integer().nullable().autoIncrement()();

  IntColumn get size => integer()();
  TextColumn get msgId => text()();
  IntColumn get fromId => integer()();
  IntColumn get toId => integer()();
  IntColumn get createTime => integer()();
  IntColumn get updateTime => integer()();

  IntColumn get imMsgType => integer()();
  IntColumn get sessionType => integer()();
  IntColumn get msgState => integer()();
  IntColumn get readState => integer()();
  IntColumn get fromClient => integer()();
  IntColumn get toClient => integer()();

  TextColumn get content => text().nullable()();
  TextColumn get url => text().nullable()();
  IntColumn get attachState => integer()();
  TextColumn get attachInfo => text().nullable()();
  TextColumn get localPath => text().nullable()();
  TextColumn get custom => text().nullable()();
  
  IntColumn get isReceived => integer()();

  @override
  Set<Column> get primaryKey => {msgId};
} 

//未读消息
class SessionUnreadItem extends Table{
  //主键
  IntColumn get id => integer().nullable().autoIncrement()();
  //会话类型
  IntColumn get sessionType => integer()();
  //会话Id 
  IntColumn get sessionId => integer()();
  //未读数量
  IntColumn get unreadCount => integer()();
  //附加信息
  TextColumn get custom => text().nullable()();

  @override
  Set<Column> get primaryKey => {sessionType , sessionId};
}


class RecentSessionItem extends Table {
  //主键
  IntColumn get id => integer().nullable().autoIncrement()();
  //会话类型
  IntColumn get sessionType => integer()();
  //会话Id 
  IntColumn get sessionId => integer()();
  //最近一条IM会话ID
  TextColumn get msgId => text().nullable()();
  //附加信息
  TextColumn get custom => text().nullable()();
  //更新时间
  IntColumn get time => integer()();
  //是否是接收方
  IntColumn get isReceived => integer()();

  @override
  Set<Column> get primaryKey => {sessionType , sessionId};
}

//打开数据库连接  按用户名分配
LazyDatabase openDataBaseConnection(int uid) {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();

    final file = File(p.join(dbFolder.path, "im$uid.db"));
    LogUtil.log("db路径: ${file.path}");
    return NativeDatabase(file);
  });
}

@DriftDatabase(tables:[IMMessageData , SessionUnreadItem , RecentSessionItem])
class IMDatabase extends _$IMDatabase{
  final int _uid;

  int get uid => _uid;

  IMDatabase(this._uid) : super(openDataBaseConnection(_uid));

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration{
    return MigrationStrategy(
      onUpgrade: (migrator, from , to)async{
        for(int i = from; i<= to ;i++){
          if(i < 5){
            await migrator.createTable(recentSessionItem);
          }
        }//end for i
      }
    );
  }

  Future<int> saveIMMessage(IMMessage imMsg) async{
    return await into(iMMessageData).insert(
      IMMessageDataCompanion.insert(
        size: imMsg.size, 
        msgId: imMsg.msgId, 
        fromId: imMsg.fromId, 
        toId: imMsg.toId, 
        createTime: imMsg.createTime, 
        updateTime: imMsg.updateTime, 
        imMsgType: imMsg.imMsgType, 
        sessionType: imMsg.sessionType, 
        msgState: imMsg.msgState, 
        readState: imMsg.readState, 
        fromClient: imMsg.fromClient, 
        toClient: imMsg.toClient, 
        content: Value(imMsg.content),
        url: Value(imMsg.url),
        attachState: imMsg.attachState,
        attachInfo: Value(imMsg.attachInfo),
        localPath: Value(imMsg.localPath),
        custom: Value(imMsg.custom),
        isReceived: imMsg.isReceived?1:0
      )
    );
  }

  Future<List<IMMessage>> queryAllIMMessage() async{
    List<IMMessageDataData> queryResultSet = await select(iMMessageData).get();
    List<IMMessage> list = [];

    for(var query in queryResultSet){
      list.add(convertImQueryToImmessage(query));
    }//end for each
    return list;
  }

  Future<List<RecentSession>> queryRecentSessionList() async {
    List<RecentSession> list = [];
    var queryResultSet = await(
      select(recentSessionItem)
    ).get();
    for(var row in queryResultSet){
      RecentSession recent = convertToRecentSession(row);
      list.add(recent);
    }//end for each
    return list;
  }

  Future<List<String>> queryAllIMMessageIds() async{
    var queryResultSet = await(
      selectOnly(iMMessageData)
      ..addColumns([iMMessageData.msgId])
    ).get();
    List<String> list = [];
    for(var row in queryResultSet){
      list.add(row.read(iMMessageData.msgId)??"");
    }//end for each
    return list;
  }

  ///
  /// 根据会话  查询IM消息
  ///
  Future<List<IMMessage>> queryIMMessageListFromTypeAndSession(
    int sessionType,int sessionId , int flagTime , int limitSize
  ) async {
    if(flagTime <= 0){
      var queryResultSet = await(
      select(iMMessageData)
        ..where((tb) => tb.sessionType.equals(sessionType) & (tb.fromId.equals(sessionId) | tb.toId.equals(sessionId)))
        ..orderBy([(tb) => OrderingTerm(expression: tb.createTime,mode: OrderingMode.desc)])
        ..limit(limitSize)
      ).get();
      List<IMMessage> list = [];
      for(var row in queryResultSet){
        list.add(convertImQueryToImmessage(row));
      }//end for each
      return list;
    }else{
      var queryResultSet = await(
      select(iMMessageData)
        ..where((tb) => tb.createTime.isSmallerThanValue(flagTime) & tb.sessionType.equals(sessionType) & (tb.fromId.equals(sessionId) | tb.toId.equals(sessionId)))
        ..orderBy([(tb) => OrderingTerm(expression: tb.createTime,mode: OrderingMode.desc)])
        ..limit(limitSize)
      ).get();
      List<IMMessage> list = [];
      for(var row in queryResultSet){
        list.add(convertImQueryToImmessage(row));
      }//end for each
      return list;
    }
  }

  Future<List<IMMessage>> queryIMMessageByMsgIds(List<String> idList) async{
    var selectRun = select(iMMessageData);
    selectRun.where((u)=>u.msgId.isIn(idList));
    var queryResultSet = await selectRun.get();
    
    List<IMMessage> list = [];
    for(var query in queryResultSet){
      list.add(convertImQueryToImmessage(query));
    }//end for each
    return list;
  }

  RecentSession convertToRecentSession(RecentSessionItemData row){
    final RecentSession recentSession = RecentSession();
    recentSession.sessionId = row.sessionId;
    recentSession.sessionType = row.sessionType;
    recentSession.custom = row.custom;
    recentSession.msgId = row.msgId;
    return recentSession;
  }

  IMMessage convertImQueryToImmessage(IMMessageDataData query){
    final IMMessage msg = IMMessage();
    
    msg.id = query.id??0;
    msg.size = query.size;
    msg.msgId = query.msgId;
    msg.fromId = query.fromId;
    msg.toId = query.toId;
    msg.createTime = query.createTime;
    msg.updateTime = query.updateTime;

    msg.imMsgType = query.imMsgType;
    msg.sessionType = query.sessionType;
    msg.msgState = query.msgState;
    msg.readState = query.readState;
    msg.fromClient = query.fromClient;
    msg.toClient = query.toClient;

    msg.content = query.content;
    msg.url = query.url;
    msg.attachState = query.attachState;
    msg.attachInfo = query.attachInfo;
    msg.localPath = query.localPath;
    msg.custom = query.custom;

    msg.isReceived = query.isReceived == 1;
    return msg;
  }

  ///
  /// 查询所有未读记录
  ///
  Future<List<UnreadSession>> queryAllUnreadSessionRecords() async{
    List<SessionUnreadItemData> queryResultSet = await select(sessionUnreadItem).get();
    List<UnreadSession> list = [];

    for(var query in queryResultSet){
      final UnreadSession record = UnreadSession();
      record.sessionId = query.sessionId;
      record.sessionType = query.sessionType;
      record.unreadCount = query.unreadCount;
      record.custom = query.custom;
      list.add(record);
    }//end for each
    return list;
  }


  ///
  /// 更新未读会话
  ///
  Future<int> updateUnreadCountSession(UnreadSession unreadRecord) async{
    // LogUtil.log("sessionType: ${unreadRecord.sessionType}   sessionId: ${unreadRecord.sessionId}");
    var statement = update(sessionUnreadItem);
    statement.where((tb) => tb.sessionId.equals(unreadRecord.sessionId) 
                    & tb.sessionType.equals(unreadRecord.sessionType));
    return await statement.write(SessionUnreadItemCompanion.insert(
        sessionId: unreadRecord.sessionId,
        sessionType: unreadRecord.sessionType,
        unreadCount: unreadRecord.unreadCount,
        custom: Value(unreadRecord.custom)
      )
    );
  }

  Future<int> insertUnreadCountSession(UnreadSession unreadRecord) async{
    return await into(sessionUnreadItem).insert(
      SessionUnreadItemCompanion.insert(
        sessionType: unreadRecord.sessionType, 
        sessionId: unreadRecord.sessionId, 
        unreadCount: unreadRecord.unreadCount,
        custom: Value(unreadRecord.custom)
      )
    );
  }

  Future<int> insertRecentSession(RecentSession recent) async{
    return await into(recentSessionItem).insert(
      RecentSessionItemCompanion.insert(
        sessionType: recent.sessionType,
        sessionId: recent.sessionId,
        msgId: Value(recent.imMessage?.msgId),
        custom: Value(recent.custom),
        time: recent.time,
        isReceived: -1
      )
    );
  }

  void batchInsertRecentSession(List<RecentSession> recentList) async{
    var list = <RecentSessionItemCompanion>[];
    for(RecentSession recent in recentList){
        list.add(RecentSessionItemCompanion.insert(
          sessionType: recent.sessionType,
          sessionId: recent.sessionId,
          msgId: Value(recent.imMessage?.msgId),
          custom: Value(recent.custom),
          time: recent.time,
          isReceived: -1
        )
      );
    }//end for each
    await batch((bat){
      bat.insertAll(recentSessionItem, list);
    });
  }

  Future<int> updateRecentSession(RecentSession recent) async{
    var statement = update(recentSessionItem);
    statement.where((tb) => tb.sessionId.equals(recent.sessionId) 
                    & tb.sessionType.equals(recent.sessionType));
    return await statement.write(RecentSessionItemCompanion.insert(
        sessionType: recent.sessionType,
        sessionId: recent.sessionId,
        msgId: Value(recent.imMessage?.msgId),
        custom: Value(recent.custom),
        time: recent.time,
        isReceived: -1
      )
    );
  }

  ///
  /// 删除IM消息 
  ///
  Future<int> removeIMMessage(String msgId) async{
    var statement = delete(iMMessageData);
    statement.where((tb) => tb.msgId.equals(msgId));
    return await statement.go();
  }
  
}

