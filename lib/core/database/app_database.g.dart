// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $FavoritesTableTable extends FavoritesTable
    with TableInfo<$FavoritesTableTable, FavoriteTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoritesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supabaseUserIdMeta = const VerificationMeta(
    'supabaseUserId',
  );
  @override
  late final GeneratedColumn<String> supabaseUserId = GeneratedColumn<String>(
    'supabase_user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _favoritedAtMeta = const VerificationMeta(
    'favoritedAt',
  );
  @override
  late final GeneratedColumn<DateTime> favoritedAt = GeneratedColumn<DateTime>(
    'favorited_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cardId,
    title,
    colorValue,
    supabaseUserId,
    favoritedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorites_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('supabase_user_id')) {
      context.handle(
        _supabaseUserIdMeta,
        supabaseUserId.isAcceptableOrUnknown(
          data['supabase_user_id']!,
          _supabaseUserIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_supabaseUserIdMeta);
    }
    if (data.containsKey('favorited_at')) {
      context.handle(
        _favoritedAtMeta,
        favoritedAt.isAcceptableOrUnknown(
          data['favorited_at']!,
          _favoritedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_favoritedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FavoriteTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      )!,
      supabaseUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supabase_user_id'],
      )!,
      favoritedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}favorited_at'],
      )!,
    );
  }

  @override
  $FavoritesTableTable createAlias(String alias) {
    return $FavoritesTableTable(attachedDatabase, alias);
  }
}

class FavoriteTableData extends DataClass
    implements Insertable<FavoriteTableData> {
  final int id;
  final String cardId;
  final String title;
  final int colorValue;
  final String supabaseUserId;
  final DateTime favoritedAt;
  const FavoriteTableData({
    required this.id,
    required this.cardId,
    required this.title,
    required this.colorValue,
    required this.supabaseUserId,
    required this.favoritedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['card_id'] = Variable<String>(cardId);
    map['title'] = Variable<String>(title);
    map['color_value'] = Variable<int>(colorValue);
    map['supabase_user_id'] = Variable<String>(supabaseUserId);
    map['favorited_at'] = Variable<DateTime>(favoritedAt);
    return map;
  }

  FavoritesTableCompanion toCompanion(bool nullToAbsent) {
    return FavoritesTableCompanion(
      id: Value(id),
      cardId: Value(cardId),
      title: Value(title),
      colorValue: Value(colorValue),
      supabaseUserId: Value(supabaseUserId),
      favoritedAt: Value(favoritedAt),
    );
  }

  factory FavoriteTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteTableData(
      id: serializer.fromJson<int>(json['id']),
      cardId: serializer.fromJson<String>(json['cardId']),
      title: serializer.fromJson<String>(json['title']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      supabaseUserId: serializer.fromJson<String>(json['supabaseUserId']),
      favoritedAt: serializer.fromJson<DateTime>(json['favoritedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cardId': serializer.toJson<String>(cardId),
      'title': serializer.toJson<String>(title),
      'colorValue': serializer.toJson<int>(colorValue),
      'supabaseUserId': serializer.toJson<String>(supabaseUserId),
      'favoritedAt': serializer.toJson<DateTime>(favoritedAt),
    };
  }

  FavoriteTableData copyWith({
    int? id,
    String? cardId,
    String? title,
    int? colorValue,
    String? supabaseUserId,
    DateTime? favoritedAt,
  }) => FavoriteTableData(
    id: id ?? this.id,
    cardId: cardId ?? this.cardId,
    title: title ?? this.title,
    colorValue: colorValue ?? this.colorValue,
    supabaseUserId: supabaseUserId ?? this.supabaseUserId,
    favoritedAt: favoritedAt ?? this.favoritedAt,
  );
  FavoriteTableData copyWithCompanion(FavoritesTableCompanion data) {
    return FavoriteTableData(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      title: data.title.present ? data.title.value : this.title,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      supabaseUserId: data.supabaseUserId.present
          ? data.supabaseUserId.value
          : this.supabaseUserId,
      favoritedAt: data.favoritedAt.present
          ? data.favoritedAt.value
          : this.favoritedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteTableData(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('title: $title, ')
          ..write('colorValue: $colorValue, ')
          ..write('supabaseUserId: $supabaseUserId, ')
          ..write('favoritedAt: $favoritedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, cardId, title, colorValue, supabaseUserId, favoritedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteTableData &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.title == this.title &&
          other.colorValue == this.colorValue &&
          other.supabaseUserId == this.supabaseUserId &&
          other.favoritedAt == this.favoritedAt);
}

class FavoritesTableCompanion extends UpdateCompanion<FavoriteTableData> {
  final Value<int> id;
  final Value<String> cardId;
  final Value<String> title;
  final Value<int> colorValue;
  final Value<String> supabaseUserId;
  final Value<DateTime> favoritedAt;
  const FavoritesTableCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.title = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.supabaseUserId = const Value.absent(),
    this.favoritedAt = const Value.absent(),
  });
  FavoritesTableCompanion.insert({
    this.id = const Value.absent(),
    required String cardId,
    required String title,
    required int colorValue,
    required String supabaseUserId,
    required DateTime favoritedAt,
  }) : cardId = Value(cardId),
       title = Value(title),
       colorValue = Value(colorValue),
       supabaseUserId = Value(supabaseUserId),
       favoritedAt = Value(favoritedAt);
  static Insertable<FavoriteTableData> custom({
    Expression<int>? id,
    Expression<String>? cardId,
    Expression<String>? title,
    Expression<int>? colorValue,
    Expression<String>? supabaseUserId,
    Expression<DateTime>? favoritedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (title != null) 'title': title,
      if (colorValue != null) 'color_value': colorValue,
      if (supabaseUserId != null) 'supabase_user_id': supabaseUserId,
      if (favoritedAt != null) 'favorited_at': favoritedAt,
    });
  }

  FavoritesTableCompanion copyWith({
    Value<int>? id,
    Value<String>? cardId,
    Value<String>? title,
    Value<int>? colorValue,
    Value<String>? supabaseUserId,
    Value<DateTime>? favoritedAt,
  }) {
    return FavoritesTableCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      title: title ?? this.title,
      colorValue: colorValue ?? this.colorValue,
      supabaseUserId: supabaseUserId ?? this.supabaseUserId,
      favoritedAt: favoritedAt ?? this.favoritedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (supabaseUserId.present) {
      map['supabase_user_id'] = Variable<String>(supabaseUserId.value);
    }
    if (favoritedAt.present) {
      map['favorited_at'] = Variable<DateTime>(favoritedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoritesTableCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('title: $title, ')
          ..write('colorValue: $colorValue, ')
          ..write('supabaseUserId: $supabaseUserId, ')
          ..write('favoritedAt: $favoritedAt')
          ..write(')'))
        .toString();
  }
}

class $OrdersTableTable extends OrdersTable
    with TableInfo<$OrdersTableTable, OrderTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrdersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _supabaseUserIdMeta = const VerificationMeta(
    'supabaseUserId',
  );
  @override
  late final GeneratedColumn<String> supabaseUserId = GeneratedColumn<String>(
    'supabase_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    remoteId,
    supabaseUserId,
    cardId,
    title,
    message,
    addedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'orders_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<OrderTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('supabase_user_id')) {
      context.handle(
        _supabaseUserIdMeta,
        supabaseUserId.isAcceptableOrUnknown(
          data['supabase_user_id']!,
          _supabaseUserIdMeta,
        ),
      );
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrderTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
      supabaseUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supabase_user_id'],
      ),
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $OrdersTableTable createAlias(String alias) {
    return $OrdersTableTable(attachedDatabase, alias);
  }
}

class OrderTableData extends DataClass implements Insertable<OrderTableData> {
  final int id;
  final String? remoteId;
  final String? supabaseUserId;
  final String cardId;
  final String title;
  final String message;
  final DateTime addedAt;
  const OrderTableData({
    required this.id,
    this.remoteId,
    this.supabaseUserId,
    required this.cardId,
    required this.title,
    required this.message,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    if (!nullToAbsent || supabaseUserId != null) {
      map['supabase_user_id'] = Variable<String>(supabaseUserId);
    }
    map['card_id'] = Variable<String>(cardId);
    map['title'] = Variable<String>(title);
    map['message'] = Variable<String>(message);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  OrdersTableCompanion toCompanion(bool nullToAbsent) {
    return OrdersTableCompanion(
      id: Value(id),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      supabaseUserId: supabaseUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(supabaseUserId),
      cardId: Value(cardId),
      title: Value(title),
      message: Value(message),
      addedAt: Value(addedAt),
    );
  }

  factory OrderTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderTableData(
      id: serializer.fromJson<int>(json['id']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      supabaseUserId: serializer.fromJson<String?>(json['supabaseUserId']),
      cardId: serializer.fromJson<String>(json['cardId']),
      title: serializer.fromJson<String>(json['title']),
      message: serializer.fromJson<String>(json['message']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'remoteId': serializer.toJson<String?>(remoteId),
      'supabaseUserId': serializer.toJson<String?>(supabaseUserId),
      'cardId': serializer.toJson<String>(cardId),
      'title': serializer.toJson<String>(title),
      'message': serializer.toJson<String>(message),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  OrderTableData copyWith({
    int? id,
    Value<String?> remoteId = const Value.absent(),
    Value<String?> supabaseUserId = const Value.absent(),
    String? cardId,
    String? title,
    String? message,
    DateTime? addedAt,
  }) => OrderTableData(
    id: id ?? this.id,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    supabaseUserId: supabaseUserId.present
        ? supabaseUserId.value
        : this.supabaseUserId,
    cardId: cardId ?? this.cardId,
    title: title ?? this.title,
    message: message ?? this.message,
    addedAt: addedAt ?? this.addedAt,
  );
  OrderTableData copyWithCompanion(OrdersTableCompanion data) {
    return OrderTableData(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      supabaseUserId: data.supabaseUserId.present
          ? data.supabaseUserId.value
          : this.supabaseUserId,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      title: data.title.present ? data.title.value : this.title,
      message: data.message.present ? data.message.value : this.message,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderTableData(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('supabaseUserId: $supabaseUserId, ')
          ..write('cardId: $cardId, ')
          ..write('title: $title, ')
          ..write('message: $message, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    remoteId,
    supabaseUserId,
    cardId,
    title,
    message,
    addedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderTableData &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.supabaseUserId == this.supabaseUserId &&
          other.cardId == this.cardId &&
          other.title == this.title &&
          other.message == this.message &&
          other.addedAt == this.addedAt);
}

class OrdersTableCompanion extends UpdateCompanion<OrderTableData> {
  final Value<int> id;
  final Value<String?> remoteId;
  final Value<String?> supabaseUserId;
  final Value<String> cardId;
  final Value<String> title;
  final Value<String> message;
  final Value<DateTime> addedAt;
  const OrdersTableCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.supabaseUserId = const Value.absent(),
    this.cardId = const Value.absent(),
    this.title = const Value.absent(),
    this.message = const Value.absent(),
    this.addedAt = const Value.absent(),
  });
  OrdersTableCompanion.insert({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.supabaseUserId = const Value.absent(),
    required String cardId,
    required String title,
    required String message,
    required DateTime addedAt,
  }) : cardId = Value(cardId),
       title = Value(title),
       message = Value(message),
       addedAt = Value(addedAt);
  static Insertable<OrderTableData> custom({
    Expression<int>? id,
    Expression<String>? remoteId,
    Expression<String>? supabaseUserId,
    Expression<String>? cardId,
    Expression<String>? title,
    Expression<String>? message,
    Expression<DateTime>? addedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (supabaseUserId != null) 'supabase_user_id': supabaseUserId,
      if (cardId != null) 'card_id': cardId,
      if (title != null) 'title': title,
      if (message != null) 'message': message,
      if (addedAt != null) 'added_at': addedAt,
    });
  }

  OrdersTableCompanion copyWith({
    Value<int>? id,
    Value<String?>? remoteId,
    Value<String?>? supabaseUserId,
    Value<String>? cardId,
    Value<String>? title,
    Value<String>? message,
    Value<DateTime>? addedAt,
  }) {
    return OrdersTableCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      supabaseUserId: supabaseUserId ?? this.supabaseUserId,
      cardId: cardId ?? this.cardId,
      title: title ?? this.title,
      message: message ?? this.message,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (supabaseUserId.present) {
      map['supabase_user_id'] = Variable<String>(supabaseUserId.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrdersTableCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('supabaseUserId: $supabaseUserId, ')
          ..write('cardId: $cardId, ')
          ..write('title: $title, ')
          ..write('message: $message, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }
}

class $EventsTableTable extends EventsTable
    with TableInfo<$EventsTableTable, EventTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _supabaseUserIdMeta = const VerificationMeta(
    'supabaseUserId',
  );
  @override
  late final GeneratedColumn<String> supabaseUserId = GeneratedColumn<String>(
    'supabase_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reminderMeta = const VerificationMeta(
    'reminder',
  );
  @override
  late final GeneratedColumn<String> reminder = GeneratedColumn<String>(
    'reminder',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCustomMeta = const VerificationMeta(
    'isCustom',
  );
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
    'is_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_custom" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    remoteId,
    supabaseUserId,
    title,
    date,
    reminder,
    isCustom,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<EventTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('supabase_user_id')) {
      context.handle(
        _supabaseUserIdMeta,
        supabaseUserId.isAcceptableOrUnknown(
          data['supabase_user_id']!,
          _supabaseUserIdMeta,
        ),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('reminder')) {
      context.handle(
        _reminderMeta,
        reminder.isAcceptableOrUnknown(data['reminder']!, _reminderMeta),
      );
    } else if (isInserting) {
      context.missing(_reminderMeta);
    }
    if (data.containsKey('is_custom')) {
      context.handle(
        _isCustomMeta,
        isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta),
      );
    } else if (isInserting) {
      context.missing(_isCustomMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EventTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
      supabaseUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supabase_user_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      reminder: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder'],
      )!,
      isCustom: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_custom'],
      )!,
    );
  }

  @override
  $EventsTableTable createAlias(String alias) {
    return $EventsTableTable(attachedDatabase, alias);
  }
}

class EventTableData extends DataClass implements Insertable<EventTableData> {
  final int id;
  final String? remoteId;
  final String? supabaseUserId;
  final String title;
  final DateTime date;
  final String reminder;
  final bool isCustom;
  const EventTableData({
    required this.id,
    this.remoteId,
    this.supabaseUserId,
    required this.title,
    required this.date,
    required this.reminder,
    required this.isCustom,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    if (!nullToAbsent || supabaseUserId != null) {
      map['supabase_user_id'] = Variable<String>(supabaseUserId);
    }
    map['title'] = Variable<String>(title);
    map['date'] = Variable<DateTime>(date);
    map['reminder'] = Variable<String>(reminder);
    map['is_custom'] = Variable<bool>(isCustom);
    return map;
  }

  EventsTableCompanion toCompanion(bool nullToAbsent) {
    return EventsTableCompanion(
      id: Value(id),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      supabaseUserId: supabaseUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(supabaseUserId),
      title: Value(title),
      date: Value(date),
      reminder: Value(reminder),
      isCustom: Value(isCustom),
    );
  }

  factory EventTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventTableData(
      id: serializer.fromJson<int>(json['id']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      supabaseUserId: serializer.fromJson<String?>(json['supabaseUserId']),
      title: serializer.fromJson<String>(json['title']),
      date: serializer.fromJson<DateTime>(json['date']),
      reminder: serializer.fromJson<String>(json['reminder']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'remoteId': serializer.toJson<String?>(remoteId),
      'supabaseUserId': serializer.toJson<String?>(supabaseUserId),
      'title': serializer.toJson<String>(title),
      'date': serializer.toJson<DateTime>(date),
      'reminder': serializer.toJson<String>(reminder),
      'isCustom': serializer.toJson<bool>(isCustom),
    };
  }

  EventTableData copyWith({
    int? id,
    Value<String?> remoteId = const Value.absent(),
    Value<String?> supabaseUserId = const Value.absent(),
    String? title,
    DateTime? date,
    String? reminder,
    bool? isCustom,
  }) => EventTableData(
    id: id ?? this.id,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    supabaseUserId: supabaseUserId.present
        ? supabaseUserId.value
        : this.supabaseUserId,
    title: title ?? this.title,
    date: date ?? this.date,
    reminder: reminder ?? this.reminder,
    isCustom: isCustom ?? this.isCustom,
  );
  EventTableData copyWithCompanion(EventsTableCompanion data) {
    return EventTableData(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      supabaseUserId: data.supabaseUserId.present
          ? data.supabaseUserId.value
          : this.supabaseUserId,
      title: data.title.present ? data.title.value : this.title,
      date: data.date.present ? data.date.value : this.date,
      reminder: data.reminder.present ? data.reminder.value : this.reminder,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventTableData(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('supabaseUserId: $supabaseUserId, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('reminder: $reminder, ')
          ..write('isCustom: $isCustom')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    remoteId,
    supabaseUserId,
    title,
    date,
    reminder,
    isCustom,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventTableData &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.supabaseUserId == this.supabaseUserId &&
          other.title == this.title &&
          other.date == this.date &&
          other.reminder == this.reminder &&
          other.isCustom == this.isCustom);
}

class EventsTableCompanion extends UpdateCompanion<EventTableData> {
  final Value<int> id;
  final Value<String?> remoteId;
  final Value<String?> supabaseUserId;
  final Value<String> title;
  final Value<DateTime> date;
  final Value<String> reminder;
  final Value<bool> isCustom;
  const EventsTableCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.supabaseUserId = const Value.absent(),
    this.title = const Value.absent(),
    this.date = const Value.absent(),
    this.reminder = const Value.absent(),
    this.isCustom = const Value.absent(),
  });
  EventsTableCompanion.insert({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.supabaseUserId = const Value.absent(),
    required String title,
    required DateTime date,
    required String reminder,
    required bool isCustom,
  }) : title = Value(title),
       date = Value(date),
       reminder = Value(reminder),
       isCustom = Value(isCustom);
  static Insertable<EventTableData> custom({
    Expression<int>? id,
    Expression<String>? remoteId,
    Expression<String>? supabaseUserId,
    Expression<String>? title,
    Expression<DateTime>? date,
    Expression<String>? reminder,
    Expression<bool>? isCustom,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (supabaseUserId != null) 'supabase_user_id': supabaseUserId,
      if (title != null) 'title': title,
      if (date != null) 'date': date,
      if (reminder != null) 'reminder': reminder,
      if (isCustom != null) 'is_custom': isCustom,
    });
  }

  EventsTableCompanion copyWith({
    Value<int>? id,
    Value<String?>? remoteId,
    Value<String?>? supabaseUserId,
    Value<String>? title,
    Value<DateTime>? date,
    Value<String>? reminder,
    Value<bool>? isCustom,
  }) {
    return EventsTableCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      supabaseUserId: supabaseUserId ?? this.supabaseUserId,
      title: title ?? this.title,
      date: date ?? this.date,
      reminder: reminder ?? this.reminder,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (supabaseUserId.present) {
      map['supabase_user_id'] = Variable<String>(supabaseUserId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (reminder.present) {
      map['reminder'] = Variable<String>(reminder.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsTableCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('supabaseUserId: $supabaseUserId, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('reminder: $reminder, ')
          ..write('isCustom: $isCustom')
          ..write(')'))
        .toString();
  }
}

class $DraftsTableTable extends DraftsTable
    with TableInfo<$DraftsTableTable, DraftTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DraftsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverTextMeta = const VerificationMeta(
    'coverText',
  );
  @override
  late final GeneratedColumn<String> coverText = GeneratedColumn<String>(
    'cover_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _insideMessageMeta = const VerificationMeta(
    'insideMessage',
  );
  @override
  late final GeneratedColumn<String> insideMessage = GeneratedColumn<String>(
    'inside_message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savedAtMeta = const VerificationMeta(
    'savedAt',
  );
  @override
  late final GeneratedColumn<DateTime> savedAt = GeneratedColumn<DateTime>(
    'saved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _draftNameMeta = const VerificationMeta(
    'draftName',
  );
  @override
  late final GeneratedColumn<String> draftName = GeneratedColumn<String>(
    'draft_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cardId,
    coverText,
    insideMessage,
    savedAt,
    draftName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'drafts_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<DraftTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('cover_text')) {
      context.handle(
        _coverTextMeta,
        coverText.isAcceptableOrUnknown(data['cover_text']!, _coverTextMeta),
      );
    } else if (isInserting) {
      context.missing(_coverTextMeta);
    }
    if (data.containsKey('inside_message')) {
      context.handle(
        _insideMessageMeta,
        insideMessage.isAcceptableOrUnknown(
          data['inside_message']!,
          _insideMessageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_insideMessageMeta);
    }
    if (data.containsKey('saved_at')) {
      context.handle(
        _savedAtMeta,
        savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_savedAtMeta);
    }
    if (data.containsKey('draft_name')) {
      context.handle(
        _draftNameMeta,
        draftName.isAcceptableOrUnknown(data['draft_name']!, _draftNameMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DraftTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DraftTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      coverText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_text'],
      )!,
      insideMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}inside_message'],
      )!,
      savedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}saved_at'],
      )!,
      draftName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}draft_name'],
      ),
    );
  }

  @override
  $DraftsTableTable createAlias(String alias) {
    return $DraftsTableTable(attachedDatabase, alias);
  }
}

class DraftTableData extends DataClass implements Insertable<DraftTableData> {
  final int id;
  final String cardId;
  final String coverText;
  final String insideMessage;
  final DateTime savedAt;
  final String? draftName;
  const DraftTableData({
    required this.id,
    required this.cardId,
    required this.coverText,
    required this.insideMessage,
    required this.savedAt,
    this.draftName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['card_id'] = Variable<String>(cardId);
    map['cover_text'] = Variable<String>(coverText);
    map['inside_message'] = Variable<String>(insideMessage);
    map['saved_at'] = Variable<DateTime>(savedAt);
    if (!nullToAbsent || draftName != null) {
      map['draft_name'] = Variable<String>(draftName);
    }
    return map;
  }

  DraftsTableCompanion toCompanion(bool nullToAbsent) {
    return DraftsTableCompanion(
      id: Value(id),
      cardId: Value(cardId),
      coverText: Value(coverText),
      insideMessage: Value(insideMessage),
      savedAt: Value(savedAt),
      draftName: draftName == null && nullToAbsent
          ? const Value.absent()
          : Value(draftName),
    );
  }

  factory DraftTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DraftTableData(
      id: serializer.fromJson<int>(json['id']),
      cardId: serializer.fromJson<String>(json['cardId']),
      coverText: serializer.fromJson<String>(json['coverText']),
      insideMessage: serializer.fromJson<String>(json['insideMessage']),
      savedAt: serializer.fromJson<DateTime>(json['savedAt']),
      draftName: serializer.fromJson<String?>(json['draftName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cardId': serializer.toJson<String>(cardId),
      'coverText': serializer.toJson<String>(coverText),
      'insideMessage': serializer.toJson<String>(insideMessage),
      'savedAt': serializer.toJson<DateTime>(savedAt),
      'draftName': serializer.toJson<String?>(draftName),
    };
  }

  DraftTableData copyWith({
    int? id,
    String? cardId,
    String? coverText,
    String? insideMessage,
    DateTime? savedAt,
    Value<String?> draftName = const Value.absent(),
  }) => DraftTableData(
    id: id ?? this.id,
    cardId: cardId ?? this.cardId,
    coverText: coverText ?? this.coverText,
    insideMessage: insideMessage ?? this.insideMessage,
    savedAt: savedAt ?? this.savedAt,
    draftName: draftName.present ? draftName.value : this.draftName,
  );
  DraftTableData copyWithCompanion(DraftsTableCompanion data) {
    return DraftTableData(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      coverText: data.coverText.present ? data.coverText.value : this.coverText,
      insideMessage: data.insideMessage.present
          ? data.insideMessage.value
          : this.insideMessage,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
      draftName: data.draftName.present ? data.draftName.value : this.draftName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DraftTableData(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('coverText: $coverText, ')
          ..write('insideMessage: $insideMessage, ')
          ..write('savedAt: $savedAt, ')
          ..write('draftName: $draftName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, cardId, coverText, insideMessage, savedAt, draftName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DraftTableData &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.coverText == this.coverText &&
          other.insideMessage == this.insideMessage &&
          other.savedAt == this.savedAt &&
          other.draftName == this.draftName);
}

class DraftsTableCompanion extends UpdateCompanion<DraftTableData> {
  final Value<int> id;
  final Value<String> cardId;
  final Value<String> coverText;
  final Value<String> insideMessage;
  final Value<DateTime> savedAt;
  final Value<String?> draftName;
  const DraftsTableCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.coverText = const Value.absent(),
    this.insideMessage = const Value.absent(),
    this.savedAt = const Value.absent(),
    this.draftName = const Value.absent(),
  });
  DraftsTableCompanion.insert({
    this.id = const Value.absent(),
    required String cardId,
    required String coverText,
    required String insideMessage,
    required DateTime savedAt,
    this.draftName = const Value.absent(),
  }) : cardId = Value(cardId),
       coverText = Value(coverText),
       insideMessage = Value(insideMessage),
       savedAt = Value(savedAt);
  static Insertable<DraftTableData> custom({
    Expression<int>? id,
    Expression<String>? cardId,
    Expression<String>? coverText,
    Expression<String>? insideMessage,
    Expression<DateTime>? savedAt,
    Expression<String>? draftName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (coverText != null) 'cover_text': coverText,
      if (insideMessage != null) 'inside_message': insideMessage,
      if (savedAt != null) 'saved_at': savedAt,
      if (draftName != null) 'draft_name': draftName,
    });
  }

  DraftsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? cardId,
    Value<String>? coverText,
    Value<String>? insideMessage,
    Value<DateTime>? savedAt,
    Value<String?>? draftName,
  }) {
    return DraftsTableCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      coverText: coverText ?? this.coverText,
      insideMessage: insideMessage ?? this.insideMessage,
      savedAt: savedAt ?? this.savedAt,
      draftName: draftName ?? this.draftName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (coverText.present) {
      map['cover_text'] = Variable<String>(coverText.value);
    }
    if (insideMessage.present) {
      map['inside_message'] = Variable<String>(insideMessage.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<DateTime>(savedAt.value);
    }
    if (draftName.present) {
      map['draft_name'] = Variable<String>(draftName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DraftsTableCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('coverText: $coverText, ')
          ..write('insideMessage: $insideMessage, ')
          ..write('savedAt: $savedAt, ')
          ..write('draftName: $draftName')
          ..write(')'))
        .toString();
  }
}

class $RemoteCategoriesTableTable extends RemoteCategoriesTable
    with TableInfo<$RemoteCategoriesTableTable, RemoteCategoryTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemoteCategoriesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconUrlMeta = const VerificationMeta(
    'iconUrl',
  );
  @override
  late final GeneratedColumn<String> iconUrl = GeneratedColumn<String>(
    'icon_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    iconUrl,
    sortOrder,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'remote_categories_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<RemoteCategoryTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_url')) {
      context.handle(
        _iconUrlMeta,
        iconUrl.isAcceptableOrUnknown(data['icon_url']!, _iconUrlMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RemoteCategoryTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RemoteCategoryTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      iconUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_url'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RemoteCategoriesTableTable createAlias(String alias) {
    return $RemoteCategoriesTableTable(attachedDatabase, alias);
  }
}

class RemoteCategoryTableData extends DataClass
    implements Insertable<RemoteCategoryTableData> {
  final String id;
  final String name;
  final String? iconUrl;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  const RemoteCategoryTableData({
    required this.id,
    required this.name,
    this.iconUrl,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || iconUrl != null) {
      map['icon_url'] = Variable<String>(iconUrl);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RemoteCategoriesTableCompanion toCompanion(bool nullToAbsent) {
    return RemoteCategoriesTableCompanion(
      id: Value(id),
      name: Value(name),
      iconUrl: iconUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(iconUrl),
      sortOrder: Value(sortOrder),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory RemoteCategoryTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RemoteCategoryTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      iconUrl: serializer.fromJson<String?>(json['iconUrl']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'iconUrl': serializer.toJson<String?>(iconUrl),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  RemoteCategoryTableData copyWith({
    String? id,
    String? name,
    Value<String?> iconUrl = const Value.absent(),
    int? sortOrder,
    bool? isActive,
    DateTime? createdAt,
  }) => RemoteCategoryTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    iconUrl: iconUrl.present ? iconUrl.value : this.iconUrl,
    sortOrder: sortOrder ?? this.sortOrder,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  RemoteCategoryTableData copyWithCompanion(
    RemoteCategoriesTableCompanion data,
  ) {
    return RemoteCategoryTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      iconUrl: data.iconUrl.present ? data.iconUrl.value : this.iconUrl,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RemoteCategoryTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconUrl: $iconUrl, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, iconUrl, sortOrder, isActive, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RemoteCategoryTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.iconUrl == this.iconUrl &&
          other.sortOrder == this.sortOrder &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class RemoteCategoriesTableCompanion
    extends UpdateCompanion<RemoteCategoryTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> iconUrl;
  final Value<int> sortOrder;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const RemoteCategoriesTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.iconUrl = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemoteCategoriesTableCompanion.insert({
    required String id,
    required String name,
    this.iconUrl = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<RemoteCategoryTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? iconUrl,
    Expression<int>? sortOrder,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (iconUrl != null) 'icon_url': iconUrl,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemoteCategoriesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? iconUrl,
    Value<int>? sortOrder,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return RemoteCategoriesTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      iconUrl: iconUrl ?? this.iconUrl,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconUrl.present) {
      map['icon_url'] = Variable<String>(iconUrl.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemoteCategoriesTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconUrl: $iconUrl, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemoteCardsTableTable extends RemoteCardsTable
    with TableInfo<$RemoteCardsTableTable, RemoteCardTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemoteCardsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES remote_categories_table (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverImageUrlMeta = const VerificationMeta(
    'coverImageUrl',
  );
  @override
  late final GeneratedColumn<String> coverImageUrl = GeneratedColumn<String>(
    'cover_image_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultFrontMessageMeta =
      const VerificationMeta('defaultFrontMessage');
  @override
  late final GeneratedColumn<String> defaultFrontMessage =
      GeneratedColumn<String>(
        'default_front_message',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _defaultInsideMessageMeta =
      const VerificationMeta('defaultInsideMessage');
  @override
  late final GeneratedColumn<String> defaultInsideMessage =
      GeneratedColumn<String>(
        'default_inside_message',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(5.99),
  );
  static const VerificationMeta _isFeaturedMeta = const VerificationMeta(
    'isFeatured',
  );
  @override
  late final GeneratedColumn<bool> isFeatured = GeneratedColumn<bool>(
    'is_featured',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_featured" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    categoryId,
    title,
    coverImageUrl,
    defaultFrontMessage,
    defaultInsideMessage,
    price,
    isFeatured,
    colorValue,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'remote_cards_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<RemoteCardTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('cover_image_url')) {
      context.handle(
        _coverImageUrlMeta,
        coverImageUrl.isAcceptableOrUnknown(
          data['cover_image_url']!,
          _coverImageUrlMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_coverImageUrlMeta);
    }
    if (data.containsKey('default_front_message')) {
      context.handle(
        _defaultFrontMessageMeta,
        defaultFrontMessage.isAcceptableOrUnknown(
          data['default_front_message']!,
          _defaultFrontMessageMeta,
        ),
      );
    }
    if (data.containsKey('default_inside_message')) {
      context.handle(
        _defaultInsideMessageMeta,
        defaultInsideMessage.isAcceptableOrUnknown(
          data['default_inside_message']!,
          _defaultInsideMessageMeta,
        ),
      );
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    }
    if (data.containsKey('is_featured')) {
      context.handle(
        _isFeaturedMeta,
        isFeatured.isAcceptableOrUnknown(data['is_featured']!, _isFeaturedMeta),
      );
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RemoteCardTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RemoteCardTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      coverImageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_image_url'],
      )!,
      defaultFrontMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_front_message'],
      ),
      defaultInsideMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_inside_message'],
      ),
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      isFeatured: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_featured'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RemoteCardsTableTable createAlias(String alias) {
    return $RemoteCardsTableTable(attachedDatabase, alias);
  }
}

class RemoteCardTableData extends DataClass
    implements Insertable<RemoteCardTableData> {
  final String id;
  final String categoryId;
  final String title;
  final String coverImageUrl;
  final String? defaultFrontMessage;
  final String? defaultInsideMessage;
  final double price;
  final bool isFeatured;
  final int? colorValue;
  final bool isActive;
  final DateTime createdAt;
  const RemoteCardTableData({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.coverImageUrl,
    this.defaultFrontMessage,
    this.defaultInsideMessage,
    required this.price,
    required this.isFeatured,
    this.colorValue,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category_id'] = Variable<String>(categoryId);
    map['title'] = Variable<String>(title);
    map['cover_image_url'] = Variable<String>(coverImageUrl);
    if (!nullToAbsent || defaultFrontMessage != null) {
      map['default_front_message'] = Variable<String>(defaultFrontMessage);
    }
    if (!nullToAbsent || defaultInsideMessage != null) {
      map['default_inside_message'] = Variable<String>(defaultInsideMessage);
    }
    map['price'] = Variable<double>(price);
    map['is_featured'] = Variable<bool>(isFeatured);
    if (!nullToAbsent || colorValue != null) {
      map['color_value'] = Variable<int>(colorValue);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RemoteCardsTableCompanion toCompanion(bool nullToAbsent) {
    return RemoteCardsTableCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      title: Value(title),
      coverImageUrl: Value(coverImageUrl),
      defaultFrontMessage: defaultFrontMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultFrontMessage),
      defaultInsideMessage: defaultInsideMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultInsideMessage),
      price: Value(price),
      isFeatured: Value(isFeatured),
      colorValue: colorValue == null && nullToAbsent
          ? const Value.absent()
          : Value(colorValue),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory RemoteCardTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RemoteCardTableData(
      id: serializer.fromJson<String>(json['id']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      title: serializer.fromJson<String>(json['title']),
      coverImageUrl: serializer.fromJson<String>(json['coverImageUrl']),
      defaultFrontMessage: serializer.fromJson<String?>(
        json['defaultFrontMessage'],
      ),
      defaultInsideMessage: serializer.fromJson<String?>(
        json['defaultInsideMessage'],
      ),
      price: serializer.fromJson<double>(json['price']),
      isFeatured: serializer.fromJson<bool>(json['isFeatured']),
      colorValue: serializer.fromJson<int?>(json['colorValue']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'categoryId': serializer.toJson<String>(categoryId),
      'title': serializer.toJson<String>(title),
      'coverImageUrl': serializer.toJson<String>(coverImageUrl),
      'defaultFrontMessage': serializer.toJson<String?>(defaultFrontMessage),
      'defaultInsideMessage': serializer.toJson<String?>(defaultInsideMessage),
      'price': serializer.toJson<double>(price),
      'isFeatured': serializer.toJson<bool>(isFeatured),
      'colorValue': serializer.toJson<int?>(colorValue),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  RemoteCardTableData copyWith({
    String? id,
    String? categoryId,
    String? title,
    String? coverImageUrl,
    Value<String?> defaultFrontMessage = const Value.absent(),
    Value<String?> defaultInsideMessage = const Value.absent(),
    double? price,
    bool? isFeatured,
    Value<int?> colorValue = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
  }) => RemoteCardTableData(
    id: id ?? this.id,
    categoryId: categoryId ?? this.categoryId,
    title: title ?? this.title,
    coverImageUrl: coverImageUrl ?? this.coverImageUrl,
    defaultFrontMessage: defaultFrontMessage.present
        ? defaultFrontMessage.value
        : this.defaultFrontMessage,
    defaultInsideMessage: defaultInsideMessage.present
        ? defaultInsideMessage.value
        : this.defaultInsideMessage,
    price: price ?? this.price,
    isFeatured: isFeatured ?? this.isFeatured,
    colorValue: colorValue.present ? colorValue.value : this.colorValue,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  RemoteCardTableData copyWithCompanion(RemoteCardsTableCompanion data) {
    return RemoteCardTableData(
      id: data.id.present ? data.id.value : this.id,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      title: data.title.present ? data.title.value : this.title,
      coverImageUrl: data.coverImageUrl.present
          ? data.coverImageUrl.value
          : this.coverImageUrl,
      defaultFrontMessage: data.defaultFrontMessage.present
          ? data.defaultFrontMessage.value
          : this.defaultFrontMessage,
      defaultInsideMessage: data.defaultInsideMessage.present
          ? data.defaultInsideMessage.value
          : this.defaultInsideMessage,
      price: data.price.present ? data.price.value : this.price,
      isFeatured: data.isFeatured.present
          ? data.isFeatured.value
          : this.isFeatured,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RemoteCardTableData(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('title: $title, ')
          ..write('coverImageUrl: $coverImageUrl, ')
          ..write('defaultFrontMessage: $defaultFrontMessage, ')
          ..write('defaultInsideMessage: $defaultInsideMessage, ')
          ..write('price: $price, ')
          ..write('isFeatured: $isFeatured, ')
          ..write('colorValue: $colorValue, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    categoryId,
    title,
    coverImageUrl,
    defaultFrontMessage,
    defaultInsideMessage,
    price,
    isFeatured,
    colorValue,
    isActive,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RemoteCardTableData &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.title == this.title &&
          other.coverImageUrl == this.coverImageUrl &&
          other.defaultFrontMessage == this.defaultFrontMessage &&
          other.defaultInsideMessage == this.defaultInsideMessage &&
          other.price == this.price &&
          other.isFeatured == this.isFeatured &&
          other.colorValue == this.colorValue &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class RemoteCardsTableCompanion extends UpdateCompanion<RemoteCardTableData> {
  final Value<String> id;
  final Value<String> categoryId;
  final Value<String> title;
  final Value<String> coverImageUrl;
  final Value<String?> defaultFrontMessage;
  final Value<String?> defaultInsideMessage;
  final Value<double> price;
  final Value<bool> isFeatured;
  final Value<int?> colorValue;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const RemoteCardsTableCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.title = const Value.absent(),
    this.coverImageUrl = const Value.absent(),
    this.defaultFrontMessage = const Value.absent(),
    this.defaultInsideMessage = const Value.absent(),
    this.price = const Value.absent(),
    this.isFeatured = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemoteCardsTableCompanion.insert({
    required String id,
    required String categoryId,
    required String title,
    required String coverImageUrl,
    this.defaultFrontMessage = const Value.absent(),
    this.defaultInsideMessage = const Value.absent(),
    this.price = const Value.absent(),
    this.isFeatured = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       categoryId = Value(categoryId),
       title = Value(title),
       coverImageUrl = Value(coverImageUrl),
       createdAt = Value(createdAt);
  static Insertable<RemoteCardTableData> custom({
    Expression<String>? id,
    Expression<String>? categoryId,
    Expression<String>? title,
    Expression<String>? coverImageUrl,
    Expression<String>? defaultFrontMessage,
    Expression<String>? defaultInsideMessage,
    Expression<double>? price,
    Expression<bool>? isFeatured,
    Expression<int>? colorValue,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (title != null) 'title': title,
      if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      if (defaultFrontMessage != null)
        'default_front_message': defaultFrontMessage,
      if (defaultInsideMessage != null)
        'default_inside_message': defaultInsideMessage,
      if (price != null) 'price': price,
      if (isFeatured != null) 'is_featured': isFeatured,
      if (colorValue != null) 'color_value': colorValue,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemoteCardsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? categoryId,
    Value<String>? title,
    Value<String>? coverImageUrl,
    Value<String?>? defaultFrontMessage,
    Value<String?>? defaultInsideMessage,
    Value<double>? price,
    Value<bool>? isFeatured,
    Value<int?>? colorValue,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return RemoteCardsTableCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      defaultFrontMessage: defaultFrontMessage ?? this.defaultFrontMessage,
      defaultInsideMessage: defaultInsideMessage ?? this.defaultInsideMessage,
      price: price ?? this.price,
      isFeatured: isFeatured ?? this.isFeatured,
      colorValue: colorValue ?? this.colorValue,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (coverImageUrl.present) {
      map['cover_image_url'] = Variable<String>(coverImageUrl.value);
    }
    if (defaultFrontMessage.present) {
      map['default_front_message'] = Variable<String>(
        defaultFrontMessage.value,
      );
    }
    if (defaultInsideMessage.present) {
      map['default_inside_message'] = Variable<String>(
        defaultInsideMessage.value,
      );
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (isFeatured.present) {
      map['is_featured'] = Variable<bool>(isFeatured.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemoteCardsTableCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('title: $title, ')
          ..write('coverImageUrl: $coverImageUrl, ')
          ..write('defaultFrontMessage: $defaultFrontMessage, ')
          ..write('defaultInsideMessage: $defaultInsideMessage, ')
          ..write('price: $price, ')
          ..write('isFeatured: $isFeatured, ')
          ..write('colorValue: $colorValue, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotificationsTableTable extends NotificationsTable
    with TableInfo<$NotificationsTableTable, NotificationTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    remoteId,
    title,
    description,
    createdAt,
    isRead,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notifications_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotificationTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotificationTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
    );
  }

  @override
  $NotificationsTableTable createAlias(String alias) {
    return $NotificationsTableTable(attachedDatabase, alias);
  }
}

class NotificationTableData extends DataClass
    implements Insertable<NotificationTableData> {
  final int id;
  final String? remoteId;
  final String title;
  final String description;
  final DateTime createdAt;
  final bool isRead;
  const NotificationTableData({
    required this.id,
    this.remoteId,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.isRead,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_read'] = Variable<bool>(isRead);
    return map;
  }

  NotificationsTableCompanion toCompanion(bool nullToAbsent) {
    return NotificationsTableCompanion(
      id: Value(id),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      title: Value(title),
      description: Value(description),
      createdAt: Value(createdAt),
      isRead: Value(isRead),
    );
  }

  factory NotificationTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationTableData(
      id: serializer.fromJson<int>(json['id']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isRead: serializer.fromJson<bool>(json['isRead']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'remoteId': serializer.toJson<String?>(remoteId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isRead': serializer.toJson<bool>(isRead),
    };
  }

  NotificationTableData copyWith({
    int? id,
    Value<String?> remoteId = const Value.absent(),
    String? title,
    String? description,
    DateTime? createdAt,
    bool? isRead,
  }) => NotificationTableData(
    id: id ?? this.id,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    title: title ?? this.title,
    description: description ?? this.description,
    createdAt: createdAt ?? this.createdAt,
    isRead: isRead ?? this.isRead,
  );
  NotificationTableData copyWithCompanion(NotificationsTableCompanion data) {
    return NotificationTableData(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationTableData(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('isRead: $isRead')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, remoteId, title, description, createdAt, isRead);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationTableData &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.title == this.title &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.isRead == this.isRead);
}

class NotificationsTableCompanion
    extends UpdateCompanion<NotificationTableData> {
  final Value<int> id;
  final Value<String?> remoteId;
  final Value<String> title;
  final Value<String> description;
  final Value<DateTime> createdAt;
  final Value<bool> isRead;
  const NotificationsTableCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isRead = const Value.absent(),
  });
  NotificationsTableCompanion.insert({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    required String title,
    required String description,
    required DateTime createdAt,
    this.isRead = const Value.absent(),
  }) : title = Value(title),
       description = Value(description),
       createdAt = Value(createdAt);
  static Insertable<NotificationTableData> custom({
    Expression<int>? id,
    Expression<String>? remoteId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<bool>? isRead,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (isRead != null) 'is_read': isRead,
    });
  }

  NotificationsTableCompanion copyWith({
    Value<int>? id,
    Value<String?>? remoteId,
    Value<String>? title,
    Value<String>? description,
    Value<DateTime>? createdAt,
    Value<bool>? isRead,
  }) {
    return NotificationsTableCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationsTableCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('isRead: $isRead')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FavoritesTableTable favoritesTable = $FavoritesTableTable(this);
  late final $OrdersTableTable ordersTable = $OrdersTableTable(this);
  late final $EventsTableTable eventsTable = $EventsTableTable(this);
  late final $DraftsTableTable draftsTable = $DraftsTableTable(this);
  late final $RemoteCategoriesTableTable remoteCategoriesTable =
      $RemoteCategoriesTableTable(this);
  late final $RemoteCardsTableTable remoteCardsTable = $RemoteCardsTableTable(
    this,
  );
  late final $NotificationsTableTable notificationsTable =
      $NotificationsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    favoritesTable,
    ordersTable,
    eventsTable,
    draftsTable,
    remoteCategoriesTable,
    remoteCardsTable,
    notificationsTable,
  ];
}

typedef $$FavoritesTableTableCreateCompanionBuilder =
    FavoritesTableCompanion Function({
      Value<int> id,
      required String cardId,
      required String title,
      required int colorValue,
      required String supabaseUserId,
      required DateTime favoritedAt,
    });
typedef $$FavoritesTableTableUpdateCompanionBuilder =
    FavoritesTableCompanion Function({
      Value<int> id,
      Value<String> cardId,
      Value<String> title,
      Value<int> colorValue,
      Value<String> supabaseUserId,
      Value<DateTime> favoritedAt,
    });

class $$FavoritesTableTableFilterComposer
    extends Composer<_$AppDatabase, $FavoritesTableTable> {
  $$FavoritesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supabaseUserId => $composableBuilder(
    column: $table.supabaseUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get favoritedAt => $composableBuilder(
    column: $table.favoritedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoritesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoritesTableTable> {
  $$FavoritesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supabaseUserId => $composableBuilder(
    column: $table.supabaseUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get favoritedAt => $composableBuilder(
    column: $table.favoritedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoritesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoritesTableTable> {
  $$FavoritesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get supabaseUserId => $composableBuilder(
    column: $table.supabaseUserId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get favoritedAt => $composableBuilder(
    column: $table.favoritedAt,
    builder: (column) => column,
  );
}

class $$FavoritesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoritesTableTable,
          FavoriteTableData,
          $$FavoritesTableTableFilterComposer,
          $$FavoritesTableTableOrderingComposer,
          $$FavoritesTableTableAnnotationComposer,
          $$FavoritesTableTableCreateCompanionBuilder,
          $$FavoritesTableTableUpdateCompanionBuilder,
          (
            FavoriteTableData,
            BaseReferences<
              _$AppDatabase,
              $FavoritesTableTable,
              FavoriteTableData
            >,
          ),
          FavoriteTableData,
          PrefetchHooks Function()
        > {
  $$FavoritesTableTableTableManager(
    _$AppDatabase db,
    $FavoritesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoritesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoritesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoritesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> cardId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> colorValue = const Value.absent(),
                Value<String> supabaseUserId = const Value.absent(),
                Value<DateTime> favoritedAt = const Value.absent(),
              }) => FavoritesTableCompanion(
                id: id,
                cardId: cardId,
                title: title,
                colorValue: colorValue,
                supabaseUserId: supabaseUserId,
                favoritedAt: favoritedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String cardId,
                required String title,
                required int colorValue,
                required String supabaseUserId,
                required DateTime favoritedAt,
              }) => FavoritesTableCompanion.insert(
                id: id,
                cardId: cardId,
                title: title,
                colorValue: colorValue,
                supabaseUserId: supabaseUserId,
                favoritedAt: favoritedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoritesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoritesTableTable,
      FavoriteTableData,
      $$FavoritesTableTableFilterComposer,
      $$FavoritesTableTableOrderingComposer,
      $$FavoritesTableTableAnnotationComposer,
      $$FavoritesTableTableCreateCompanionBuilder,
      $$FavoritesTableTableUpdateCompanionBuilder,
      (
        FavoriteTableData,
        BaseReferences<_$AppDatabase, $FavoritesTableTable, FavoriteTableData>,
      ),
      FavoriteTableData,
      PrefetchHooks Function()
    >;
typedef $$OrdersTableTableCreateCompanionBuilder =
    OrdersTableCompanion Function({
      Value<int> id,
      Value<String?> remoteId,
      Value<String?> supabaseUserId,
      required String cardId,
      required String title,
      required String message,
      required DateTime addedAt,
    });
typedef $$OrdersTableTableUpdateCompanionBuilder =
    OrdersTableCompanion Function({
      Value<int> id,
      Value<String?> remoteId,
      Value<String?> supabaseUserId,
      Value<String> cardId,
      Value<String> title,
      Value<String> message,
      Value<DateTime> addedAt,
    });

class $$OrdersTableTableFilterComposer
    extends Composer<_$AppDatabase, $OrdersTableTable> {
  $$OrdersTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supabaseUserId => $composableBuilder(
    column: $table.supabaseUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OrdersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $OrdersTableTable> {
  $$OrdersTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supabaseUserId => $composableBuilder(
    column: $table.supabaseUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OrdersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrdersTableTable> {
  $$OrdersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get supabaseUserId => $composableBuilder(
    column: $table.supabaseUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $$OrdersTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrdersTableTable,
          OrderTableData,
          $$OrdersTableTableFilterComposer,
          $$OrdersTableTableOrderingComposer,
          $$OrdersTableTableAnnotationComposer,
          $$OrdersTableTableCreateCompanionBuilder,
          $$OrdersTableTableUpdateCompanionBuilder,
          (
            OrderTableData,
            BaseReferences<_$AppDatabase, $OrdersTableTable, OrderTableData>,
          ),
          OrderTableData,
          PrefetchHooks Function()
        > {
  $$OrdersTableTableTableManager(_$AppDatabase db, $OrdersTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrdersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrdersTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrdersTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<String?> supabaseUserId = const Value.absent(),
                Value<String> cardId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
              }) => OrdersTableCompanion(
                id: id,
                remoteId: remoteId,
                supabaseUserId: supabaseUserId,
                cardId: cardId,
                title: title,
                message: message,
                addedAt: addedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<String?> supabaseUserId = const Value.absent(),
                required String cardId,
                required String title,
                required String message,
                required DateTime addedAt,
              }) => OrdersTableCompanion.insert(
                id: id,
                remoteId: remoteId,
                supabaseUserId: supabaseUserId,
                cardId: cardId,
                title: title,
                message: message,
                addedAt: addedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OrdersTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrdersTableTable,
      OrderTableData,
      $$OrdersTableTableFilterComposer,
      $$OrdersTableTableOrderingComposer,
      $$OrdersTableTableAnnotationComposer,
      $$OrdersTableTableCreateCompanionBuilder,
      $$OrdersTableTableUpdateCompanionBuilder,
      (
        OrderTableData,
        BaseReferences<_$AppDatabase, $OrdersTableTable, OrderTableData>,
      ),
      OrderTableData,
      PrefetchHooks Function()
    >;
typedef $$EventsTableTableCreateCompanionBuilder =
    EventsTableCompanion Function({
      Value<int> id,
      Value<String?> remoteId,
      Value<String?> supabaseUserId,
      required String title,
      required DateTime date,
      required String reminder,
      required bool isCustom,
    });
typedef $$EventsTableTableUpdateCompanionBuilder =
    EventsTableCompanion Function({
      Value<int> id,
      Value<String?> remoteId,
      Value<String?> supabaseUserId,
      Value<String> title,
      Value<DateTime> date,
      Value<String> reminder,
      Value<bool> isCustom,
    });

class $$EventsTableTableFilterComposer
    extends Composer<_$AppDatabase, $EventsTableTable> {
  $$EventsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supabaseUserId => $composableBuilder(
    column: $table.supabaseUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminder => $composableBuilder(
    column: $table.reminder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EventsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $EventsTableTable> {
  $$EventsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supabaseUserId => $composableBuilder(
    column: $table.supabaseUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminder => $composableBuilder(
    column: $table.reminder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EventsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventsTableTable> {
  $$EventsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get supabaseUserId => $composableBuilder(
    column: $table.supabaseUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get reminder =>
      $composableBuilder(column: $table.reminder, builder: (column) => column);

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);
}

class $$EventsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventsTableTable,
          EventTableData,
          $$EventsTableTableFilterComposer,
          $$EventsTableTableOrderingComposer,
          $$EventsTableTableAnnotationComposer,
          $$EventsTableTableCreateCompanionBuilder,
          $$EventsTableTableUpdateCompanionBuilder,
          (
            EventTableData,
            BaseReferences<_$AppDatabase, $EventsTableTable, EventTableData>,
          ),
          EventTableData,
          PrefetchHooks Function()
        > {
  $$EventsTableTableTableManager(_$AppDatabase db, $EventsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<String?> supabaseUserId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> reminder = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
              }) => EventsTableCompanion(
                id: id,
                remoteId: remoteId,
                supabaseUserId: supabaseUserId,
                title: title,
                date: date,
                reminder: reminder,
                isCustom: isCustom,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<String?> supabaseUserId = const Value.absent(),
                required String title,
                required DateTime date,
                required String reminder,
                required bool isCustom,
              }) => EventsTableCompanion.insert(
                id: id,
                remoteId: remoteId,
                supabaseUserId: supabaseUserId,
                title: title,
                date: date,
                reminder: reminder,
                isCustom: isCustom,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EventsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventsTableTable,
      EventTableData,
      $$EventsTableTableFilterComposer,
      $$EventsTableTableOrderingComposer,
      $$EventsTableTableAnnotationComposer,
      $$EventsTableTableCreateCompanionBuilder,
      $$EventsTableTableUpdateCompanionBuilder,
      (
        EventTableData,
        BaseReferences<_$AppDatabase, $EventsTableTable, EventTableData>,
      ),
      EventTableData,
      PrefetchHooks Function()
    >;
typedef $$DraftsTableTableCreateCompanionBuilder =
    DraftsTableCompanion Function({
      Value<int> id,
      required String cardId,
      required String coverText,
      required String insideMessage,
      required DateTime savedAt,
      Value<String?> draftName,
    });
typedef $$DraftsTableTableUpdateCompanionBuilder =
    DraftsTableCompanion Function({
      Value<int> id,
      Value<String> cardId,
      Value<String> coverText,
      Value<String> insideMessage,
      Value<DateTime> savedAt,
      Value<String?> draftName,
    });

class $$DraftsTableTableFilterComposer
    extends Composer<_$AppDatabase, $DraftsTableTable> {
  $$DraftsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverText => $composableBuilder(
    column: $table.coverText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get insideMessage => $composableBuilder(
    column: $table.insideMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get draftName => $composableBuilder(
    column: $table.draftName,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DraftsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DraftsTableTable> {
  $$DraftsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverText => $composableBuilder(
    column: $table.coverText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get insideMessage => $composableBuilder(
    column: $table.insideMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get draftName => $composableBuilder(
    column: $table.draftName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DraftsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DraftsTableTable> {
  $$DraftsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<String> get coverText =>
      $composableBuilder(column: $table.coverText, builder: (column) => column);

  GeneratedColumn<String> get insideMessage => $composableBuilder(
    column: $table.insideMessage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);

  GeneratedColumn<String> get draftName =>
      $composableBuilder(column: $table.draftName, builder: (column) => column);
}

class $$DraftsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DraftsTableTable,
          DraftTableData,
          $$DraftsTableTableFilterComposer,
          $$DraftsTableTableOrderingComposer,
          $$DraftsTableTableAnnotationComposer,
          $$DraftsTableTableCreateCompanionBuilder,
          $$DraftsTableTableUpdateCompanionBuilder,
          (
            DraftTableData,
            BaseReferences<_$AppDatabase, $DraftsTableTable, DraftTableData>,
          ),
          DraftTableData,
          PrefetchHooks Function()
        > {
  $$DraftsTableTableTableManager(_$AppDatabase db, $DraftsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DraftsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DraftsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DraftsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> cardId = const Value.absent(),
                Value<String> coverText = const Value.absent(),
                Value<String> insideMessage = const Value.absent(),
                Value<DateTime> savedAt = const Value.absent(),
                Value<String?> draftName = const Value.absent(),
              }) => DraftsTableCompanion(
                id: id,
                cardId: cardId,
                coverText: coverText,
                insideMessage: insideMessage,
                savedAt: savedAt,
                draftName: draftName,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String cardId,
                required String coverText,
                required String insideMessage,
                required DateTime savedAt,
                Value<String?> draftName = const Value.absent(),
              }) => DraftsTableCompanion.insert(
                id: id,
                cardId: cardId,
                coverText: coverText,
                insideMessage: insideMessage,
                savedAt: savedAt,
                draftName: draftName,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DraftsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DraftsTableTable,
      DraftTableData,
      $$DraftsTableTableFilterComposer,
      $$DraftsTableTableOrderingComposer,
      $$DraftsTableTableAnnotationComposer,
      $$DraftsTableTableCreateCompanionBuilder,
      $$DraftsTableTableUpdateCompanionBuilder,
      (
        DraftTableData,
        BaseReferences<_$AppDatabase, $DraftsTableTable, DraftTableData>,
      ),
      DraftTableData,
      PrefetchHooks Function()
    >;
typedef $$RemoteCategoriesTableTableCreateCompanionBuilder =
    RemoteCategoriesTableCompanion Function({
      required String id,
      required String name,
      Value<String?> iconUrl,
      Value<int> sortOrder,
      Value<bool> isActive,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$RemoteCategoriesTableTableUpdateCompanionBuilder =
    RemoteCategoriesTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> iconUrl,
      Value<int> sortOrder,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$RemoteCategoriesTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RemoteCategoriesTableTable,
          RemoteCategoryTableData
        > {
  $$RemoteCategoriesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$RemoteCardsTableTable, List<RemoteCardTableData>>
  _remoteCardsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.remoteCardsTable,
    aliasName: 'remote_categories_table__id__remote_cards_table__category_id',
  );

  $$RemoteCardsTableTableProcessedTableManager get remoteCardsTableRefs {
    final manager = $$RemoteCardsTableTableTableManager(
      $_db,
      $_db.remoteCardsTable,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _remoteCardsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RemoteCategoriesTableTableFilterComposer
    extends Composer<_$AppDatabase, $RemoteCategoriesTableTable> {
  $$RemoteCategoriesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconUrl => $composableBuilder(
    column: $table.iconUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> remoteCardsTableRefs(
    Expression<bool> Function($$RemoteCardsTableTableFilterComposer f) f,
  ) {
    final $$RemoteCardsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.remoteCardsTable,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemoteCardsTableTableFilterComposer(
            $db: $db,
            $table: $db.remoteCardsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RemoteCategoriesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $RemoteCategoriesTableTable> {
  $$RemoteCategoriesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconUrl => $composableBuilder(
    column: $table.iconUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RemoteCategoriesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemoteCategoriesTableTable> {
  $$RemoteCategoriesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get iconUrl =>
      $composableBuilder(column: $table.iconUrl, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> remoteCardsTableRefs<T extends Object>(
    Expression<T> Function($$RemoteCardsTableTableAnnotationComposer a) f,
  ) {
    final $$RemoteCardsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.remoteCardsTable,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemoteCardsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.remoteCardsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RemoteCategoriesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemoteCategoriesTableTable,
          RemoteCategoryTableData,
          $$RemoteCategoriesTableTableFilterComposer,
          $$RemoteCategoriesTableTableOrderingComposer,
          $$RemoteCategoriesTableTableAnnotationComposer,
          $$RemoteCategoriesTableTableCreateCompanionBuilder,
          $$RemoteCategoriesTableTableUpdateCompanionBuilder,
          (RemoteCategoryTableData, $$RemoteCategoriesTableTableReferences),
          RemoteCategoryTableData,
          PrefetchHooks Function({bool remoteCardsTableRefs})
        > {
  $$RemoteCategoriesTableTableTableManager(
    _$AppDatabase db,
    $RemoteCategoriesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemoteCategoriesTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$RemoteCategoriesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RemoteCategoriesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> iconUrl = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemoteCategoriesTableCompanion(
                id: id,
                name: name,
                iconUrl: iconUrl,
                sortOrder: sortOrder,
                isActive: isActive,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> iconUrl = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => RemoteCategoriesTableCompanion.insert(
                id: id,
                name: name,
                iconUrl: iconUrl,
                sortOrder: sortOrder,
                isActive: isActive,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RemoteCategoriesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({remoteCardsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (remoteCardsTableRefs) db.remoteCardsTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (remoteCardsTableRefs)
                    await $_getPrefetchedData<
                      RemoteCategoryTableData,
                      $RemoteCategoriesTableTable,
                      RemoteCardTableData
                    >(
                      currentTable: table,
                      referencedTable: $$RemoteCategoriesTableTableReferences
                          ._remoteCardsTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$RemoteCategoriesTableTableReferences(
                            db,
                            table,
                            p0,
                          ).remoteCardsTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RemoteCategoriesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemoteCategoriesTableTable,
      RemoteCategoryTableData,
      $$RemoteCategoriesTableTableFilterComposer,
      $$RemoteCategoriesTableTableOrderingComposer,
      $$RemoteCategoriesTableTableAnnotationComposer,
      $$RemoteCategoriesTableTableCreateCompanionBuilder,
      $$RemoteCategoriesTableTableUpdateCompanionBuilder,
      (RemoteCategoryTableData, $$RemoteCategoriesTableTableReferences),
      RemoteCategoryTableData,
      PrefetchHooks Function({bool remoteCardsTableRefs})
    >;
typedef $$RemoteCardsTableTableCreateCompanionBuilder =
    RemoteCardsTableCompanion Function({
      required String id,
      required String categoryId,
      required String title,
      required String coverImageUrl,
      Value<String?> defaultFrontMessage,
      Value<String?> defaultInsideMessage,
      Value<double> price,
      Value<bool> isFeatured,
      Value<int?> colorValue,
      Value<bool> isActive,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$RemoteCardsTableTableUpdateCompanionBuilder =
    RemoteCardsTableCompanion Function({
      Value<String> id,
      Value<String> categoryId,
      Value<String> title,
      Value<String> coverImageUrl,
      Value<String?> defaultFrontMessage,
      Value<String?> defaultInsideMessage,
      Value<double> price,
      Value<bool> isFeatured,
      Value<int?> colorValue,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$RemoteCardsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RemoteCardsTableTable,
          RemoteCardTableData
        > {
  $$RemoteCardsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RemoteCategoriesTableTable _categoryIdTable(_$AppDatabase db) =>
      db.remoteCategoriesTable.createAlias(
        'remote_cards_table__category_id__remote_categories_table__id',
      );

  $$RemoteCategoriesTableTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$RemoteCategoriesTableTableTableManager(
      $_db,
      $_db.remoteCategoriesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RemoteCardsTableTableFilterComposer
    extends Composer<_$AppDatabase, $RemoteCardsTableTable> {
  $$RemoteCardsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverImageUrl => $composableBuilder(
    column: $table.coverImageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultFrontMessage => $composableBuilder(
    column: $table.defaultFrontMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultInsideMessage => $composableBuilder(
    column: $table.defaultInsideMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFeatured => $composableBuilder(
    column: $table.isFeatured,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$RemoteCategoriesTableTableFilterComposer get categoryId {
    final $$RemoteCategoriesTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.categoryId,
          referencedTable: $db.remoteCategoriesTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RemoteCategoriesTableTableFilterComposer(
                $db: $db,
                $table: $db.remoteCategoriesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$RemoteCardsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $RemoteCardsTableTable> {
  $$RemoteCardsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverImageUrl => $composableBuilder(
    column: $table.coverImageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultFrontMessage => $composableBuilder(
    column: $table.defaultFrontMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultInsideMessage => $composableBuilder(
    column: $table.defaultInsideMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFeatured => $composableBuilder(
    column: $table.isFeatured,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$RemoteCategoriesTableTableOrderingComposer get categoryId {
    final $$RemoteCategoriesTableTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.categoryId,
          referencedTable: $db.remoteCategoriesTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RemoteCategoriesTableTableOrderingComposer(
                $db: $db,
                $table: $db.remoteCategoriesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$RemoteCardsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemoteCardsTableTable> {
  $$RemoteCardsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get coverImageUrl => $composableBuilder(
    column: $table.coverImageUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultFrontMessage => $composableBuilder(
    column: $table.defaultFrontMessage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultInsideMessage => $composableBuilder(
    column: $table.defaultInsideMessage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<bool> get isFeatured => $composableBuilder(
    column: $table.isFeatured,
    builder: (column) => column,
  );

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$RemoteCategoriesTableTableAnnotationComposer get categoryId {
    final $$RemoteCategoriesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.categoryId,
          referencedTable: $db.remoteCategoriesTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RemoteCategoriesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.remoteCategoriesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$RemoteCardsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemoteCardsTableTable,
          RemoteCardTableData,
          $$RemoteCardsTableTableFilterComposer,
          $$RemoteCardsTableTableOrderingComposer,
          $$RemoteCardsTableTableAnnotationComposer,
          $$RemoteCardsTableTableCreateCompanionBuilder,
          $$RemoteCardsTableTableUpdateCompanionBuilder,
          (RemoteCardTableData, $$RemoteCardsTableTableReferences),
          RemoteCardTableData,
          PrefetchHooks Function({bool categoryId})
        > {
  $$RemoteCardsTableTableTableManager(
    _$AppDatabase db,
    $RemoteCardsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemoteCardsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemoteCardsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemoteCardsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> coverImageUrl = const Value.absent(),
                Value<String?> defaultFrontMessage = const Value.absent(),
                Value<String?> defaultInsideMessage = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<bool> isFeatured = const Value.absent(),
                Value<int?> colorValue = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemoteCardsTableCompanion(
                id: id,
                categoryId: categoryId,
                title: title,
                coverImageUrl: coverImageUrl,
                defaultFrontMessage: defaultFrontMessage,
                defaultInsideMessage: defaultInsideMessage,
                price: price,
                isFeatured: isFeatured,
                colorValue: colorValue,
                isActive: isActive,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String categoryId,
                required String title,
                required String coverImageUrl,
                Value<String?> defaultFrontMessage = const Value.absent(),
                Value<String?> defaultInsideMessage = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<bool> isFeatured = const Value.absent(),
                Value<int?> colorValue = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => RemoteCardsTableCompanion.insert(
                id: id,
                categoryId: categoryId,
                title: title,
                coverImageUrl: coverImageUrl,
                defaultFrontMessage: defaultFrontMessage,
                defaultInsideMessage: defaultInsideMessage,
                price: price,
                isFeatured: isFeatured,
                colorValue: colorValue,
                isActive: isActive,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RemoteCardsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable:
                                    $$RemoteCardsTableTableReferences
                                        ._categoryIdTable(db),
                                referencedColumn:
                                    $$RemoteCardsTableTableReferences
                                        ._categoryIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RemoteCardsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemoteCardsTableTable,
      RemoteCardTableData,
      $$RemoteCardsTableTableFilterComposer,
      $$RemoteCardsTableTableOrderingComposer,
      $$RemoteCardsTableTableAnnotationComposer,
      $$RemoteCardsTableTableCreateCompanionBuilder,
      $$RemoteCardsTableTableUpdateCompanionBuilder,
      (RemoteCardTableData, $$RemoteCardsTableTableReferences),
      RemoteCardTableData,
      PrefetchHooks Function({bool categoryId})
    >;
typedef $$NotificationsTableTableCreateCompanionBuilder =
    NotificationsTableCompanion Function({
      Value<int> id,
      Value<String?> remoteId,
      required String title,
      required String description,
      required DateTime createdAt,
      Value<bool> isRead,
    });
typedef $$NotificationsTableTableUpdateCompanionBuilder =
    NotificationsTableCompanion Function({
      Value<int> id,
      Value<String?> remoteId,
      Value<String> title,
      Value<String> description,
      Value<DateTime> createdAt,
      Value<bool> isRead,
    });

class $$NotificationsTableTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationsTableTable> {
  $$NotificationsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotificationsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationsTableTable> {
  $$NotificationsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotificationsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationsTableTable> {
  $$NotificationsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);
}

class $$NotificationsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationsTableTable,
          NotificationTableData,
          $$NotificationsTableTableFilterComposer,
          $$NotificationsTableTableOrderingComposer,
          $$NotificationsTableTableAnnotationComposer,
          $$NotificationsTableTableCreateCompanionBuilder,
          $$NotificationsTableTableUpdateCompanionBuilder,
          (
            NotificationTableData,
            BaseReferences<
              _$AppDatabase,
              $NotificationsTableTable,
              NotificationTableData
            >,
          ),
          NotificationTableData,
          PrefetchHooks Function()
        > {
  $$NotificationsTableTableTableManager(
    _$AppDatabase db,
    $NotificationsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotificationsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
              }) => NotificationsTableCompanion(
                id: id,
                remoteId: remoteId,
                title: title,
                description: description,
                createdAt: createdAt,
                isRead: isRead,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                required String title,
                required String description,
                required DateTime createdAt,
                Value<bool> isRead = const Value.absent(),
              }) => NotificationsTableCompanion.insert(
                id: id,
                remoteId: remoteId,
                title: title,
                description: description,
                createdAt: createdAt,
                isRead: isRead,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotificationsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationsTableTable,
      NotificationTableData,
      $$NotificationsTableTableFilterComposer,
      $$NotificationsTableTableOrderingComposer,
      $$NotificationsTableTableAnnotationComposer,
      $$NotificationsTableTableCreateCompanionBuilder,
      $$NotificationsTableTableUpdateCompanionBuilder,
      (
        NotificationTableData,
        BaseReferences<
          _$AppDatabase,
          $NotificationsTableTable,
          NotificationTableData
        >,
      ),
      NotificationTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FavoritesTableTableTableManager get favoritesTable =>
      $$FavoritesTableTableTableManager(_db, _db.favoritesTable);
  $$OrdersTableTableTableManager get ordersTable =>
      $$OrdersTableTableTableManager(_db, _db.ordersTable);
  $$EventsTableTableTableManager get eventsTable =>
      $$EventsTableTableTableManager(_db, _db.eventsTable);
  $$DraftsTableTableTableManager get draftsTable =>
      $$DraftsTableTableTableManager(_db, _db.draftsTable);
  $$RemoteCategoriesTableTableTableManager get remoteCategoriesTable =>
      $$RemoteCategoriesTableTableTableManager(_db, _db.remoteCategoriesTable);
  $$RemoteCardsTableTableTableManager get remoteCardsTable =>
      $$RemoteCardsTableTableTableManager(_db, _db.remoteCardsTable);
  $$NotificationsTableTableTableManager get notificationsTable =>
      $$NotificationsTableTableTableManager(_db, _db.notificationsTable);
}
