// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'im_table.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: type=lint
class IMMessageDataData extends DataClass
    implements Insertable<IMMessageDataData> {
  final int? id;
  final int size;
  final String msgId;
  final int fromId;
  final int toId;
  final int createTime;
  final int updateTime;
  final int imMsgType;
  final int sessionType;
  final int msgState;
  final int readState;
  final int fromClient;
  final int toClient;
  final String? content;
  final String? url;
  final int attachState;
  final String? attachInfo;
  final String? localPath;
  final String? custom;
  final int isReceived;
  IMMessageDataData(
      {this.id,
      required this.size,
      required this.msgId,
      required this.fromId,
      required this.toId,
      required this.createTime,
      required this.updateTime,
      required this.imMsgType,
      required this.sessionType,
      required this.msgState,
      required this.readState,
      required this.fromClient,
      required this.toClient,
      this.content,
      this.url,
      required this.attachState,
      this.attachInfo,
      this.localPath,
      this.custom,
      required this.isReceived});
  factory IMMessageDataData.fromData(Map<String, dynamic> data,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return IMMessageDataData(
      id: const IntType().mapFromDatabaseResponse(data['${effectivePrefix}id']),
      size: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}size'])!,
      msgId: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}msg_id'])!,
      fromId: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}from_id'])!,
      toId: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}to_id'])!,
      createTime: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}create_time'])!,
      updateTime: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}update_time'])!,
      imMsgType: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}im_msg_type'])!,
      sessionType: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}session_type'])!,
      msgState: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}msg_state'])!,
      readState: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}read_state'])!,
      fromClient: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}from_client'])!,
      toClient: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}to_client'])!,
      content: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}content']),
      url: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}url']),
      attachState: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}attach_state'])!,
      attachInfo: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}attach_info']),
      localPath: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}local_path']),
      custom: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}custom']),
      isReceived: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}is_received'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int?>(id);
    }
    map['size'] = Variable<int>(size);
    map['msg_id'] = Variable<String>(msgId);
    map['from_id'] = Variable<int>(fromId);
    map['to_id'] = Variable<int>(toId);
    map['create_time'] = Variable<int>(createTime);
    map['update_time'] = Variable<int>(updateTime);
    map['im_msg_type'] = Variable<int>(imMsgType);
    map['session_type'] = Variable<int>(sessionType);
    map['msg_state'] = Variable<int>(msgState);
    map['read_state'] = Variable<int>(readState);
    map['from_client'] = Variable<int>(fromClient);
    map['to_client'] = Variable<int>(toClient);
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String?>(content);
    }
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String?>(url);
    }
    map['attach_state'] = Variable<int>(attachState);
    if (!nullToAbsent || attachInfo != null) {
      map['attach_info'] = Variable<String?>(attachInfo);
    }
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String?>(localPath);
    }
    if (!nullToAbsent || custom != null) {
      map['custom'] = Variable<String?>(custom);
    }
    map['is_received'] = Variable<int>(isReceived);
    return map;
  }

  IMMessageDataCompanion toCompanion(bool nullToAbsent) {
    return IMMessageDataCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      size: Value(size),
      msgId: Value(msgId),
      fromId: Value(fromId),
      toId: Value(toId),
      createTime: Value(createTime),
      updateTime: Value(updateTime),
      imMsgType: Value(imMsgType),
      sessionType: Value(sessionType),
      msgState: Value(msgState),
      readState: Value(readState),
      fromClient: Value(fromClient),
      toClient: Value(toClient),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      attachState: Value(attachState),
      attachInfo: attachInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(attachInfo),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      custom:
          custom == null && nullToAbsent ? const Value.absent() : Value(custom),
      isReceived: Value(isReceived),
    );
  }

  factory IMMessageDataData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IMMessageDataData(
      id: serializer.fromJson<int?>(json['id']),
      size: serializer.fromJson<int>(json['size']),
      msgId: serializer.fromJson<String>(json['msgId']),
      fromId: serializer.fromJson<int>(json['fromId']),
      toId: serializer.fromJson<int>(json['toId']),
      createTime: serializer.fromJson<int>(json['createTime']),
      updateTime: serializer.fromJson<int>(json['updateTime']),
      imMsgType: serializer.fromJson<int>(json['imMsgType']),
      sessionType: serializer.fromJson<int>(json['sessionType']),
      msgState: serializer.fromJson<int>(json['msgState']),
      readState: serializer.fromJson<int>(json['readState']),
      fromClient: serializer.fromJson<int>(json['fromClient']),
      toClient: serializer.fromJson<int>(json['toClient']),
      content: serializer.fromJson<String?>(json['content']),
      url: serializer.fromJson<String?>(json['url']),
      attachState: serializer.fromJson<int>(json['attachState']),
      attachInfo: serializer.fromJson<String?>(json['attachInfo']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      custom: serializer.fromJson<String?>(json['custom']),
      isReceived: serializer.fromJson<int>(json['isReceived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int?>(id),
      'size': serializer.toJson<int>(size),
      'msgId': serializer.toJson<String>(msgId),
      'fromId': serializer.toJson<int>(fromId),
      'toId': serializer.toJson<int>(toId),
      'createTime': serializer.toJson<int>(createTime),
      'updateTime': serializer.toJson<int>(updateTime),
      'imMsgType': serializer.toJson<int>(imMsgType),
      'sessionType': serializer.toJson<int>(sessionType),
      'msgState': serializer.toJson<int>(msgState),
      'readState': serializer.toJson<int>(readState),
      'fromClient': serializer.toJson<int>(fromClient),
      'toClient': serializer.toJson<int>(toClient),
      'content': serializer.toJson<String?>(content),
      'url': serializer.toJson<String?>(url),
      'attachState': serializer.toJson<int>(attachState),
      'attachInfo': serializer.toJson<String?>(attachInfo),
      'localPath': serializer.toJson<String?>(localPath),
      'custom': serializer.toJson<String?>(custom),
      'isReceived': serializer.toJson<int>(isReceived),
    };
  }

  IMMessageDataData copyWith(
          {int? id,
          int? size,
          String? msgId,
          int? fromId,
          int? toId,
          int? createTime,
          int? updateTime,
          int? imMsgType,
          int? sessionType,
          int? msgState,
          int? readState,
          int? fromClient,
          int? toClient,
          String? content,
          String? url,
          int? attachState,
          String? attachInfo,
          String? localPath,
          String? custom,
          int? isReceived}) =>
      IMMessageDataData(
        id: id ?? this.id,
        size: size ?? this.size,
        msgId: msgId ?? this.msgId,
        fromId: fromId ?? this.fromId,
        toId: toId ?? this.toId,
        createTime: createTime ?? this.createTime,
        updateTime: updateTime ?? this.updateTime,
        imMsgType: imMsgType ?? this.imMsgType,
        sessionType: sessionType ?? this.sessionType,
        msgState: msgState ?? this.msgState,
        readState: readState ?? this.readState,
        fromClient: fromClient ?? this.fromClient,
        toClient: toClient ?? this.toClient,
        content: content ?? this.content,
        url: url ?? this.url,
        attachState: attachState ?? this.attachState,
        attachInfo: attachInfo ?? this.attachInfo,
        localPath: localPath ?? this.localPath,
        custom: custom ?? this.custom,
        isReceived: isReceived ?? this.isReceived,
      );
  @override
  String toString() {
    return (StringBuffer('IMMessageDataData(')
          ..write('id: $id, ')
          ..write('size: $size, ')
          ..write('msgId: $msgId, ')
          ..write('fromId: $fromId, ')
          ..write('toId: $toId, ')
          ..write('createTime: $createTime, ')
          ..write('updateTime: $updateTime, ')
          ..write('imMsgType: $imMsgType, ')
          ..write('sessionType: $sessionType, ')
          ..write('msgState: $msgState, ')
          ..write('readState: $readState, ')
          ..write('fromClient: $fromClient, ')
          ..write('toClient: $toClient, ')
          ..write('content: $content, ')
          ..write('url: $url, ')
          ..write('attachState: $attachState, ')
          ..write('attachInfo: $attachInfo, ')
          ..write('localPath: $localPath, ')
          ..write('custom: $custom, ')
          ..write('isReceived: $isReceived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      size,
      msgId,
      fromId,
      toId,
      createTime,
      updateTime,
      imMsgType,
      sessionType,
      msgState,
      readState,
      fromClient,
      toClient,
      content,
      url,
      attachState,
      attachInfo,
      localPath,
      custom,
      isReceived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IMMessageDataData &&
          other.id == this.id &&
          other.size == this.size &&
          other.msgId == this.msgId &&
          other.fromId == this.fromId &&
          other.toId == this.toId &&
          other.createTime == this.createTime &&
          other.updateTime == this.updateTime &&
          other.imMsgType == this.imMsgType &&
          other.sessionType == this.sessionType &&
          other.msgState == this.msgState &&
          other.readState == this.readState &&
          other.fromClient == this.fromClient &&
          other.toClient == this.toClient &&
          other.content == this.content &&
          other.url == this.url &&
          other.attachState == this.attachState &&
          other.attachInfo == this.attachInfo &&
          other.localPath == this.localPath &&
          other.custom == this.custom &&
          other.isReceived == this.isReceived);
}

class IMMessageDataCompanion extends UpdateCompanion<IMMessageDataData> {
  final Value<int?> id;
  final Value<int> size;
  final Value<String> msgId;
  final Value<int> fromId;
  final Value<int> toId;
  final Value<int> createTime;
  final Value<int> updateTime;
  final Value<int> imMsgType;
  final Value<int> sessionType;
  final Value<int> msgState;
  final Value<int> readState;
  final Value<int> fromClient;
  final Value<int> toClient;
  final Value<String?> content;
  final Value<String?> url;
  final Value<int> attachState;
  final Value<String?> attachInfo;
  final Value<String?> localPath;
  final Value<String?> custom;
  final Value<int> isReceived;
  const IMMessageDataCompanion({
    this.id = const Value.absent(),
    this.size = const Value.absent(),
    this.msgId = const Value.absent(),
    this.fromId = const Value.absent(),
    this.toId = const Value.absent(),
    this.createTime = const Value.absent(),
    this.updateTime = const Value.absent(),
    this.imMsgType = const Value.absent(),
    this.sessionType = const Value.absent(),
    this.msgState = const Value.absent(),
    this.readState = const Value.absent(),
    this.fromClient = const Value.absent(),
    this.toClient = const Value.absent(),
    this.content = const Value.absent(),
    this.url = const Value.absent(),
    this.attachState = const Value.absent(),
    this.attachInfo = const Value.absent(),
    this.localPath = const Value.absent(),
    this.custom = const Value.absent(),
    this.isReceived = const Value.absent(),
  });
  IMMessageDataCompanion.insert({
    this.id = const Value.absent(),
    required int size,
    required String msgId,
    required int fromId,
    required int toId,
    required int createTime,
    required int updateTime,
    required int imMsgType,
    required int sessionType,
    required int msgState,
    required int readState,
    required int fromClient,
    required int toClient,
    this.content = const Value.absent(),
    this.url = const Value.absent(),
    required int attachState,
    this.attachInfo = const Value.absent(),
    this.localPath = const Value.absent(),
    this.custom = const Value.absent(),
    required int isReceived,
  })  : size = Value(size),
        msgId = Value(msgId),
        fromId = Value(fromId),
        toId = Value(toId),
        createTime = Value(createTime),
        updateTime = Value(updateTime),
        imMsgType = Value(imMsgType),
        sessionType = Value(sessionType),
        msgState = Value(msgState),
        readState = Value(readState),
        fromClient = Value(fromClient),
        toClient = Value(toClient),
        attachState = Value(attachState),
        isReceived = Value(isReceived);
  static Insertable<IMMessageDataData> createCustom({
    Expression<int?>? id,
    Expression<int>? size,
    Expression<String>? msgId,
    Expression<int>? fromId,
    Expression<int>? toId,
    Expression<int>? createTime,
    Expression<int>? updateTime,
    Expression<int>? imMsgType,
    Expression<int>? sessionType,
    Expression<int>? msgState,
    Expression<int>? readState,
    Expression<int>? fromClient,
    Expression<int>? toClient,
    Expression<String?>? content,
    Expression<String?>? url,
    Expression<int>? attachState,
    Expression<String?>? attachInfo,
    Expression<String?>? localPath,
    Expression<String?>? custom,
    Expression<int>? isReceived,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (size != null) 'size': size,
      if (msgId != null) 'msg_id': msgId,
      if (fromId != null) 'from_id': fromId,
      if (toId != null) 'to_id': toId,
      if (createTime != null) 'create_time': createTime,
      if (updateTime != null) 'update_time': updateTime,
      if (imMsgType != null) 'im_msg_type': imMsgType,
      if (sessionType != null) 'session_type': sessionType,
      if (msgState != null) 'msg_state': msgState,
      if (readState != null) 'read_state': readState,
      if (fromClient != null) 'from_client': fromClient,
      if (toClient != null) 'to_client': toClient,
      if (content != null) 'content': content,
      if (url != null) 'url': url,
      if (attachState != null) 'attach_state': attachState,
      if (attachInfo != null) 'attach_info': attachInfo,
      if (localPath != null) 'local_path': localPath,
      if (custom != null) 'custom': custom,
      if (isReceived != null) 'is_received': isReceived,
    });
  }

  IMMessageDataCompanion copyWith(
      {Value<int?>? id,
      Value<int>? size,
      Value<String>? msgId,
      Value<int>? fromId,
      Value<int>? toId,
      Value<int>? createTime,
      Value<int>? updateTime,
      Value<int>? imMsgType,
      Value<int>? sessionType,
      Value<int>? msgState,
      Value<int>? readState,
      Value<int>? fromClient,
      Value<int>? toClient,
      Value<String?>? content,
      Value<String?>? url,
      Value<int>? attachState,
      Value<String?>? attachInfo,
      Value<String?>? localPath,
      Value<String?>? custom,
      Value<int>? isReceived}) {
    return IMMessageDataCompanion(
      id: id ?? this.id,
      size: size ?? this.size,
      msgId: msgId ?? this.msgId,
      fromId: fromId ?? this.fromId,
      toId: toId ?? this.toId,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
      imMsgType: imMsgType ?? this.imMsgType,
      sessionType: sessionType ?? this.sessionType,
      msgState: msgState ?? this.msgState,
      readState: readState ?? this.readState,
      fromClient: fromClient ?? this.fromClient,
      toClient: toClient ?? this.toClient,
      content: content ?? this.content,
      url: url ?? this.url,
      attachState: attachState ?? this.attachState,
      attachInfo: attachInfo ?? this.attachInfo,
      localPath: localPath ?? this.localPath,
      custom: custom ?? this.custom,
      isReceived: isReceived ?? this.isReceived,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int?>(id.value);
    }
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    if (msgId.present) {
      map['msg_id'] = Variable<String>(msgId.value);
    }
    if (fromId.present) {
      map['from_id'] = Variable<int>(fromId.value);
    }
    if (toId.present) {
      map['to_id'] = Variable<int>(toId.value);
    }
    if (createTime.present) {
      map['create_time'] = Variable<int>(createTime.value);
    }
    if (updateTime.present) {
      map['update_time'] = Variable<int>(updateTime.value);
    }
    if (imMsgType.present) {
      map['im_msg_type'] = Variable<int>(imMsgType.value);
    }
    if (sessionType.present) {
      map['session_type'] = Variable<int>(sessionType.value);
    }
    if (msgState.present) {
      map['msg_state'] = Variable<int>(msgState.value);
    }
    if (readState.present) {
      map['read_state'] = Variable<int>(readState.value);
    }
    if (fromClient.present) {
      map['from_client'] = Variable<int>(fromClient.value);
    }
    if (toClient.present) {
      map['to_client'] = Variable<int>(toClient.value);
    }
    if (content.present) {
      map['content'] = Variable<String?>(content.value);
    }
    if (url.present) {
      map['url'] = Variable<String?>(url.value);
    }
    if (attachState.present) {
      map['attach_state'] = Variable<int>(attachState.value);
    }
    if (attachInfo.present) {
      map['attach_info'] = Variable<String?>(attachInfo.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String?>(localPath.value);
    }
    if (custom.present) {
      map['custom'] = Variable<String?>(custom.value);
    }
    if (isReceived.present) {
      map['is_received'] = Variable<int>(isReceived.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IMMessageDataCompanion(')
          ..write('id: $id, ')
          ..write('size: $size, ')
          ..write('msgId: $msgId, ')
          ..write('fromId: $fromId, ')
          ..write('toId: $toId, ')
          ..write('createTime: $createTime, ')
          ..write('updateTime: $updateTime, ')
          ..write('imMsgType: $imMsgType, ')
          ..write('sessionType: $sessionType, ')
          ..write('msgState: $msgState, ')
          ..write('readState: $readState, ')
          ..write('fromClient: $fromClient, ')
          ..write('toClient: $toClient, ')
          ..write('content: $content, ')
          ..write('url: $url, ')
          ..write('attachState: $attachState, ')
          ..write('attachInfo: $attachInfo, ')
          ..write('localPath: $localPath, ')
          ..write('custom: $custom, ')
          ..write('isReceived: $isReceived')
          ..write(')'))
        .toString();
  }
}

class $IMMessageDataTable extends IMMessageData
    with TableInfo<$IMMessageDataTable, IMMessageDataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IMMessageDataTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, true,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<int?> size = GeneratedColumn<int?>(
      'size', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _msgIdMeta = const VerificationMeta('msgId');
  @override
  late final GeneratedColumn<String?> msgId = GeneratedColumn<String?>(
      'msg_id', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _fromIdMeta = const VerificationMeta('fromId');
  @override
  late final GeneratedColumn<int?> fromId = GeneratedColumn<int?>(
      'from_id', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _toIdMeta = const VerificationMeta('toId');
  @override
  late final GeneratedColumn<int?> toId = GeneratedColumn<int?>(
      'to_id', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _createTimeMeta = const VerificationMeta('createTime');
  @override
  late final GeneratedColumn<int?> createTime = GeneratedColumn<int?>(
      'create_time', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _updateTimeMeta = const VerificationMeta('updateTime');
  @override
  late final GeneratedColumn<int?> updateTime = GeneratedColumn<int?>(
      'update_time', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _imMsgTypeMeta = const VerificationMeta('imMsgType');
  @override
  late final GeneratedColumn<int?> imMsgType = GeneratedColumn<int?>(
      'im_msg_type', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _sessionTypeMeta =
      const VerificationMeta('sessionType');
  @override
  late final GeneratedColumn<int?> sessionType = GeneratedColumn<int?>(
      'session_type', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _msgStateMeta = const VerificationMeta('msgState');
  @override
  late final GeneratedColumn<int?> msgState = GeneratedColumn<int?>(
      'msg_state', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _readStateMeta = const VerificationMeta('readState');
  @override
  late final GeneratedColumn<int?> readState = GeneratedColumn<int?>(
      'read_state', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _fromClientMeta = const VerificationMeta('fromClient');
  @override
  late final GeneratedColumn<int?> fromClient = GeneratedColumn<int?>(
      'from_client', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _toClientMeta = const VerificationMeta('toClient');
  @override
  late final GeneratedColumn<int?> toClient = GeneratedColumn<int?>(
      'to_client', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _contentMeta = const VerificationMeta('content');
  @override
  late final GeneratedColumn<String?> content = GeneratedColumn<String?>(
      'content', aliasedName, true,
      type: const StringType(), requiredDuringInsert: false);
  final VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String?> url = GeneratedColumn<String?>(
      'url', aliasedName, true,
      type: const StringType(), requiredDuringInsert: false);
  final VerificationMeta _attachStateMeta =
      const VerificationMeta('attachState');
  @override
  late final GeneratedColumn<int?> attachState = GeneratedColumn<int?>(
      'attach_state', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _attachInfoMeta = const VerificationMeta('attachInfo');
  @override
  late final GeneratedColumn<String?> attachInfo = GeneratedColumn<String?>(
      'attach_info', aliasedName, true,
      type: const StringType(), requiredDuringInsert: false);
  final VerificationMeta _localPathMeta = const VerificationMeta('localPath');
  @override
  late final GeneratedColumn<String?> localPath = GeneratedColumn<String?>(
      'local_path', aliasedName, true,
      type: const StringType(), requiredDuringInsert: false);
  final VerificationMeta _customMeta = const VerificationMeta('custom');
  @override
  late final GeneratedColumn<String?> custom = GeneratedColumn<String?>(
      'custom', aliasedName, true,
      type: const StringType(), requiredDuringInsert: false);
  final VerificationMeta _isReceivedMeta = const VerificationMeta('isReceived');
  @override
  late final GeneratedColumn<int?> isReceived = GeneratedColumn<int?>(
      'is_received', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        size,
        msgId,
        fromId,
        toId,
        createTime,
        updateTime,
        imMsgType,
        sessionType,
        msgState,
        readState,
        fromClient,
        toClient,
        content,
        url,
        attachState,
        attachInfo,
        localPath,
        custom,
        isReceived
      ];
  @override
  String get aliasedName => _alias ?? 'i_m_message_data';
  @override
  String get actualTableName => 'i_m_message_data';
  @override
  VerificationContext validateIntegrity(Insertable<IMMessageDataData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('size')) {
      context.handle(
          _sizeMeta, size.isAcceptableOrUnknown(data['size']!, _sizeMeta));
    } else if (isInserting) {
      context.missing(_sizeMeta);
    }
    if (data.containsKey('msg_id')) {
      context.handle(
          _msgIdMeta, msgId.isAcceptableOrUnknown(data['msg_id']!, _msgIdMeta));
    } else if (isInserting) {
      context.missing(_msgIdMeta);
    }
    if (data.containsKey('from_id')) {
      context.handle(_fromIdMeta,
          fromId.isAcceptableOrUnknown(data['from_id']!, _fromIdMeta));
    } else if (isInserting) {
      context.missing(_fromIdMeta);
    }
    if (data.containsKey('to_id')) {
      context.handle(
          _toIdMeta, toId.isAcceptableOrUnknown(data['to_id']!, _toIdMeta));
    } else if (isInserting) {
      context.missing(_toIdMeta);
    }
    if (data.containsKey('create_time')) {
      context.handle(
          _createTimeMeta,
          createTime.isAcceptableOrUnknown(
              data['create_time']!, _createTimeMeta));
    } else if (isInserting) {
      context.missing(_createTimeMeta);
    }
    if (data.containsKey('update_time')) {
      context.handle(
          _updateTimeMeta,
          updateTime.isAcceptableOrUnknown(
              data['update_time']!, _updateTimeMeta));
    } else if (isInserting) {
      context.missing(_updateTimeMeta);
    }
    if (data.containsKey('im_msg_type')) {
      context.handle(
          _imMsgTypeMeta,
          imMsgType.isAcceptableOrUnknown(
              data['im_msg_type']!, _imMsgTypeMeta));
    } else if (isInserting) {
      context.missing(_imMsgTypeMeta);
    }
    if (data.containsKey('session_type')) {
      context.handle(
          _sessionTypeMeta,
          sessionType.isAcceptableOrUnknown(
              data['session_type']!, _sessionTypeMeta));
    } else if (isInserting) {
      context.missing(_sessionTypeMeta);
    }
    if (data.containsKey('msg_state')) {
      context.handle(_msgStateMeta,
          msgState.isAcceptableOrUnknown(data['msg_state']!, _msgStateMeta));
    } else if (isInserting) {
      context.missing(_msgStateMeta);
    }
    if (data.containsKey('read_state')) {
      context.handle(_readStateMeta,
          readState.isAcceptableOrUnknown(data['read_state']!, _readStateMeta));
    } else if (isInserting) {
      context.missing(_readStateMeta);
    }
    if (data.containsKey('from_client')) {
      context.handle(
          _fromClientMeta,
          fromClient.isAcceptableOrUnknown(
              data['from_client']!, _fromClientMeta));
    } else if (isInserting) {
      context.missing(_fromClientMeta);
    }
    if (data.containsKey('to_client')) {
      context.handle(_toClientMeta,
          toClient.isAcceptableOrUnknown(data['to_client']!, _toClientMeta));
    } else if (isInserting) {
      context.missing(_toClientMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    }
    if (data.containsKey('attach_state')) {
      context.handle(
          _attachStateMeta,
          attachState.isAcceptableOrUnknown(
              data['attach_state']!, _attachStateMeta));
    } else if (isInserting) {
      context.missing(_attachStateMeta);
    }
    if (data.containsKey('attach_info')) {
      context.handle(
          _attachInfoMeta,
          attachInfo.isAcceptableOrUnknown(
              data['attach_info']!, _attachInfoMeta));
    }
    if (data.containsKey('local_path')) {
      context.handle(_localPathMeta,
          localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta));
    }
    if (data.containsKey('custom')) {
      context.handle(_customMeta,
          custom.isAcceptableOrUnknown(data['custom']!, _customMeta));
    }
    if (data.containsKey('is_received')) {
      context.handle(
          _isReceivedMeta,
          isReceived.isAcceptableOrUnknown(
              data['is_received']!, _isReceivedMeta));
    } else if (isInserting) {
      context.missing(_isReceivedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {msgId};
  @override
  IMMessageDataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    return IMMessageDataData.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $IMMessageDataTable createAlias(String alias) {
    return $IMMessageDataTable(attachedDatabase, alias);
  }
}

class SessionUnreadItemData extends DataClass
    implements Insertable<SessionUnreadItemData> {
  final int? id;
  final int sessionType;
  final int sessionId;
  final int unreadCount;
  final String? custom;
  SessionUnreadItemData(
      {this.id,
      required this.sessionType,
      required this.sessionId,
      required this.unreadCount,
      this.custom});
  factory SessionUnreadItemData.fromData(Map<String, dynamic> data,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return SessionUnreadItemData(
      id: const IntType().mapFromDatabaseResponse(data['${effectivePrefix}id']),
      sessionType: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}session_type'])!,
      sessionId: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}session_id'])!,
      unreadCount: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}unread_count'])!,
      custom: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}custom']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int?>(id);
    }
    map['session_type'] = Variable<int>(sessionType);
    map['session_id'] = Variable<int>(sessionId);
    map['unread_count'] = Variable<int>(unreadCount);
    if (!nullToAbsent || custom != null) {
      map['custom'] = Variable<String?>(custom);
    }
    return map;
  }

  SessionUnreadItemCompanion toCompanion(bool nullToAbsent) {
    return SessionUnreadItemCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      sessionType: Value(sessionType),
      sessionId: Value(sessionId),
      unreadCount: Value(unreadCount),
      custom:
          custom == null && nullToAbsent ? const Value.absent() : Value(custom),
    );
  }

  factory SessionUnreadItemData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionUnreadItemData(
      id: serializer.fromJson<int?>(json['id']),
      sessionType: serializer.fromJson<int>(json['sessionType']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      unreadCount: serializer.fromJson<int>(json['unreadCount']),
      custom: serializer.fromJson<String?>(json['custom']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int?>(id),
      'sessionType': serializer.toJson<int>(sessionType),
      'sessionId': serializer.toJson<int>(sessionId),
      'unreadCount': serializer.toJson<int>(unreadCount),
      'custom': serializer.toJson<String?>(custom),
    };
  }

  SessionUnreadItemData copyWith(
          {int? id,
          int? sessionType,
          int? sessionId,
          int? unreadCount,
          String? custom}) =>
      SessionUnreadItemData(
        id: id ?? this.id,
        sessionType: sessionType ?? this.sessionType,
        sessionId: sessionId ?? this.sessionId,
        unreadCount: unreadCount ?? this.unreadCount,
        custom: custom ?? this.custom,
      );
  @override
  String toString() {
    return (StringBuffer('SessionUnreadItemData(')
          ..write('id: $id, ')
          ..write('sessionType: $sessionType, ')
          ..write('sessionId: $sessionId, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('custom: $custom')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sessionType, sessionId, unreadCount, custom);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionUnreadItemData &&
          other.id == this.id &&
          other.sessionType == this.sessionType &&
          other.sessionId == this.sessionId &&
          other.unreadCount == this.unreadCount &&
          other.custom == this.custom);
}

class SessionUnreadItemCompanion
    extends UpdateCompanion<SessionUnreadItemData> {
  final Value<int?> id;
  final Value<int> sessionType;
  final Value<int> sessionId;
  final Value<int> unreadCount;
  final Value<String?> custom;
  const SessionUnreadItemCompanion({
    this.id = const Value.absent(),
    this.sessionType = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.custom = const Value.absent(),
  });
  SessionUnreadItemCompanion.insert({
    this.id = const Value.absent(),
    required int sessionType,
    required int sessionId,
    required int unreadCount,
    this.custom = const Value.absent(),
  })  : sessionType = Value(sessionType),
        sessionId = Value(sessionId),
        unreadCount = Value(unreadCount);
  static Insertable<SessionUnreadItemData> createCustom({
    Expression<int?>? id,
    Expression<int>? sessionType,
    Expression<int>? sessionId,
    Expression<int>? unreadCount,
    Expression<String?>? custom,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionType != null) 'session_type': sessionType,
      if (sessionId != null) 'session_id': sessionId,
      if (unreadCount != null) 'unread_count': unreadCount,
      if (custom != null) 'custom': custom,
    });
  }

  SessionUnreadItemCompanion copyWith(
      {Value<int?>? id,
      Value<int>? sessionType,
      Value<int>? sessionId,
      Value<int>? unreadCount,
      Value<String?>? custom}) {
    return SessionUnreadItemCompanion(
      id: id ?? this.id,
      sessionType: sessionType ?? this.sessionType,
      sessionId: sessionId ?? this.sessionId,
      unreadCount: unreadCount ?? this.unreadCount,
      custom: custom ?? this.custom,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int?>(id.value);
    }
    if (sessionType.present) {
      map['session_type'] = Variable<int>(sessionType.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (unreadCount.present) {
      map['unread_count'] = Variable<int>(unreadCount.value);
    }
    if (custom.present) {
      map['custom'] = Variable<String?>(custom.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionUnreadItemCompanion(')
          ..write('id: $id, ')
          ..write('sessionType: $sessionType, ')
          ..write('sessionId: $sessionId, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('custom: $custom')
          ..write(')'))
        .toString();
  }
}

class $SessionUnreadItemTable extends SessionUnreadItem
    with TableInfo<$SessionUnreadItemTable, SessionUnreadItemData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionUnreadItemTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, true,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _sessionTypeMeta =
      const VerificationMeta('sessionType');
  @override
  late final GeneratedColumn<int?> sessionType = GeneratedColumn<int?>(
      'session_type', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _sessionIdMeta = const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<int?> sessionId = GeneratedColumn<int?>(
      'session_id', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _unreadCountMeta =
      const VerificationMeta('unreadCount');
  @override
  late final GeneratedColumn<int?> unreadCount = GeneratedColumn<int?>(
      'unread_count', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _customMeta = const VerificationMeta('custom');
  @override
  late final GeneratedColumn<String?> custom = GeneratedColumn<String?>(
      'custom', aliasedName, true,
      type: const StringType(), requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, sessionType, sessionId, unreadCount, custom];
  @override
  String get aliasedName => _alias ?? 'session_unread_item';
  @override
  String get actualTableName => 'session_unread_item';
  @override
  VerificationContext validateIntegrity(
      Insertable<SessionUnreadItemData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_type')) {
      context.handle(
          _sessionTypeMeta,
          sessionType.isAcceptableOrUnknown(
              data['session_type']!, _sessionTypeMeta));
    } else if (isInserting) {
      context.missing(_sessionTypeMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('unread_count')) {
      context.handle(
          _unreadCountMeta,
          unreadCount.isAcceptableOrUnknown(
              data['unread_count']!, _unreadCountMeta));
    } else if (isInserting) {
      context.missing(_unreadCountMeta);
    }
    if (data.containsKey('custom')) {
      context.handle(_customMeta,
          custom.isAcceptableOrUnknown(data['custom']!, _customMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionType, sessionId};
  @override
  SessionUnreadItemData map(Map<String, dynamic> data, {String? tablePrefix}) {
    return SessionUnreadItemData.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $SessionUnreadItemTable createAlias(String alias) {
    return $SessionUnreadItemTable(attachedDatabase, alias);
  }
}

class RecentSessionItemData extends DataClass
    implements Insertable<RecentSessionItemData> {
  final int? id;
  final int sessionType;
  final int sessionId;
  final String? msgId;
  final String? custom;
  final int time;
  final int isReceived;
  RecentSessionItemData(
      {this.id,
      required this.sessionType,
      required this.sessionId,
      this.msgId,
      this.custom,
      required this.time,
      required this.isReceived});
  factory RecentSessionItemData.fromData(Map<String, dynamic> data,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return RecentSessionItemData(
      id: const IntType().mapFromDatabaseResponse(data['${effectivePrefix}id']),
      sessionType: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}session_type'])!,
      sessionId: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}session_id'])!,
      msgId: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}msg_id']),
      custom: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}custom']),
      time: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}time'])!,
      isReceived: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}is_received'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int?>(id);
    }
    map['session_type'] = Variable<int>(sessionType);
    map['session_id'] = Variable<int>(sessionId);
    if (!nullToAbsent || msgId != null) {
      map['msg_id'] = Variable<String?>(msgId);
    }
    if (!nullToAbsent || custom != null) {
      map['custom'] = Variable<String?>(custom);
    }
    map['time'] = Variable<int>(time);
    map['is_received'] = Variable<int>(isReceived);
    return map;
  }

  RecentSessionItemCompanion toCompanion(bool nullToAbsent) {
    return RecentSessionItemCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      sessionType: Value(sessionType),
      sessionId: Value(sessionId),
      msgId:
          msgId == null && nullToAbsent ? const Value.absent() : Value(msgId),
      custom:
          custom == null && nullToAbsent ? const Value.absent() : Value(custom),
      time: Value(time),
      isReceived: Value(isReceived),
    );
  }

  factory RecentSessionItemData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecentSessionItemData(
      id: serializer.fromJson<int?>(json['id']),
      sessionType: serializer.fromJson<int>(json['sessionType']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      msgId: serializer.fromJson<String?>(json['msgId']),
      custom: serializer.fromJson<String?>(json['custom']),
      time: serializer.fromJson<int>(json['time']),
      isReceived: serializer.fromJson<int>(json['isReceived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int?>(id),
      'sessionType': serializer.toJson<int>(sessionType),
      'sessionId': serializer.toJson<int>(sessionId),
      'msgId': serializer.toJson<String?>(msgId),
      'custom': serializer.toJson<String?>(custom),
      'time': serializer.toJson<int>(time),
      'isReceived': serializer.toJson<int>(isReceived),
    };
  }

  RecentSessionItemData copyWith(
          {int? id,
          int? sessionType,
          int? sessionId,
          String? msgId,
          String? custom,
          int? time,
          int? isReceived}) =>
      RecentSessionItemData(
        id: id ?? this.id,
        sessionType: sessionType ?? this.sessionType,
        sessionId: sessionId ?? this.sessionId,
        msgId: msgId ?? this.msgId,
        custom: custom ?? this.custom,
        time: time ?? this.time,
        isReceived: isReceived ?? this.isReceived,
      );
  @override
  String toString() {
    return (StringBuffer('RecentSessionItemData(')
          ..write('id: $id, ')
          ..write('sessionType: $sessionType, ')
          ..write('sessionId: $sessionId, ')
          ..write('msgId: $msgId, ')
          ..write('custom: $custom, ')
          ..write('time: $time, ')
          ..write('isReceived: $isReceived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sessionType, sessionId, msgId, custom, time, isReceived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecentSessionItemData &&
          other.id == this.id &&
          other.sessionType == this.sessionType &&
          other.sessionId == this.sessionId &&
          other.msgId == this.msgId &&
          other.custom == this.custom &&
          other.time == this.time &&
          other.isReceived == this.isReceived);
}

class RecentSessionItemCompanion
    extends UpdateCompanion<RecentSessionItemData> {
  final Value<int?> id;
  final Value<int> sessionType;
  final Value<int> sessionId;
  final Value<String?> msgId;
  final Value<String?> custom;
  final Value<int> time;
  final Value<int> isReceived;
  const RecentSessionItemCompanion({
    this.id = const Value.absent(),
    this.sessionType = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.msgId = const Value.absent(),
    this.custom = const Value.absent(),
    this.time = const Value.absent(),
    this.isReceived = const Value.absent(),
  });
  RecentSessionItemCompanion.insert({
    this.id = const Value.absent(),
    required int sessionType,
    required int sessionId,
    this.msgId = const Value.absent(),
    this.custom = const Value.absent(),
    required int time,
    required int isReceived,
  })  : sessionType = Value(sessionType),
        sessionId = Value(sessionId),
        time = Value(time),
        isReceived = Value(isReceived);
  static Insertable<RecentSessionItemData> createCustom({
    Expression<int?>? id,
    Expression<int>? sessionType,
    Expression<int>? sessionId,
    Expression<String?>? msgId,
    Expression<String?>? custom,
    Expression<int>? time,
    Expression<int>? isReceived,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionType != null) 'session_type': sessionType,
      if (sessionId != null) 'session_id': sessionId,
      if (msgId != null) 'msg_id': msgId,
      if (custom != null) 'custom': custom,
      if (time != null) 'time': time,
      if (isReceived != null) 'is_received': isReceived,
    });
  }

  RecentSessionItemCompanion copyWith(
      {Value<int?>? id,
      Value<int>? sessionType,
      Value<int>? sessionId,
      Value<String?>? msgId,
      Value<String?>? custom,
      Value<int>? time,
      Value<int>? isReceived}) {
    return RecentSessionItemCompanion(
      id: id ?? this.id,
      sessionType: sessionType ?? this.sessionType,
      sessionId: sessionId ?? this.sessionId,
      msgId: msgId ?? this.msgId,
      custom: custom ?? this.custom,
      time: time ?? this.time,
      isReceived: isReceived ?? this.isReceived,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int?>(id.value);
    }
    if (sessionType.present) {
      map['session_type'] = Variable<int>(sessionType.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (msgId.present) {
      map['msg_id'] = Variable<String?>(msgId.value);
    }
    if (custom.present) {
      map['custom'] = Variable<String?>(custom.value);
    }
    if (time.present) {
      map['time'] = Variable<int>(time.value);
    }
    if (isReceived.present) {
      map['is_received'] = Variable<int>(isReceived.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecentSessionItemCompanion(')
          ..write('id: $id, ')
          ..write('sessionType: $sessionType, ')
          ..write('sessionId: $sessionId, ')
          ..write('msgId: $msgId, ')
          ..write('custom: $custom, ')
          ..write('time: $time, ')
          ..write('isReceived: $isReceived')
          ..write(')'))
        .toString();
  }
}

class $RecentSessionItemTable extends RecentSessionItem
    with TableInfo<$RecentSessionItemTable, RecentSessionItemData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecentSessionItemTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, true,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _sessionTypeMeta =
      const VerificationMeta('sessionType');
  @override
  late final GeneratedColumn<int?> sessionType = GeneratedColumn<int?>(
      'session_type', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _sessionIdMeta = const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<int?> sessionId = GeneratedColumn<int?>(
      'session_id', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _msgIdMeta = const VerificationMeta('msgId');
  @override
  late final GeneratedColumn<String?> msgId = GeneratedColumn<String?>(
      'msg_id', aliasedName, true,
      type: const StringType(), requiredDuringInsert: false);
  final VerificationMeta _customMeta = const VerificationMeta('custom');
  @override
  late final GeneratedColumn<String?> custom = GeneratedColumn<String?>(
      'custom', aliasedName, true,
      type: const StringType(), requiredDuringInsert: false);
  final VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<int?> time = GeneratedColumn<int?>(
      'time', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _isReceivedMeta = const VerificationMeta('isReceived');
  @override
  late final GeneratedColumn<int?> isReceived = GeneratedColumn<int?>(
      'is_received', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, sessionType, sessionId, msgId, custom, time, isReceived];
  @override
  String get aliasedName => _alias ?? 'recent_session_item';
  @override
  String get actualTableName => 'recent_session_item';
  @override
  VerificationContext validateIntegrity(
      Insertable<RecentSessionItemData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_type')) {
      context.handle(
          _sessionTypeMeta,
          sessionType.isAcceptableOrUnknown(
              data['session_type']!, _sessionTypeMeta));
    } else if (isInserting) {
      context.missing(_sessionTypeMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('msg_id')) {
      context.handle(
          _msgIdMeta, msgId.isAcceptableOrUnknown(data['msg_id']!, _msgIdMeta));
    }
    if (data.containsKey('custom')) {
      context.handle(_customMeta,
          custom.isAcceptableOrUnknown(data['custom']!, _customMeta));
    }
    if (data.containsKey('time')) {
      context.handle(
          _timeMeta, time.isAcceptableOrUnknown(data['time']!, _timeMeta));
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    if (data.containsKey('is_received')) {
      context.handle(
          _isReceivedMeta,
          isReceived.isAcceptableOrUnknown(
              data['is_received']!, _isReceivedMeta));
    } else if (isInserting) {
      context.missing(_isReceivedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionType, sessionId};
  @override
  RecentSessionItemData map(Map<String, dynamic> data, {String? tablePrefix}) {
    return RecentSessionItemData.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $RecentSessionItemTable createAlias(String alias) {
    return $RecentSessionItemTable(attachedDatabase, alias);
  }
}

abstract class _$IMDatabase extends GeneratedDatabase {
  _$IMDatabase(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  late final $IMMessageDataTable iMMessageData = $IMMessageDataTable(this);
  late final $SessionUnreadItemTable sessionUnreadItem =
      $SessionUnreadItemTable(this);
  late final $RecentSessionItemTable recentSessionItem =
      $RecentSessionItemTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [iMMessageData, sessionUnreadItem, recentSessionItem];
}
