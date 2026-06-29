// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $FavoritesTableTable extends FavoritesTable with TableInfo<$FavoritesTableTable, FavoriteTableData>{
@override final GeneratedDatabase attachedDatabase;
final String? _alias;
$FavoritesTableTable(this.attachedDatabase, [this._alias]);
static const VerificationMeta _idMeta = const VerificationMeta('id');
@override
late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false, hasAutoIncrement: true, type: DriftSqlType.int, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
@override
late final GeneratedColumn<String> cardId = GeneratedColumn<String>('card_id', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true, defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
static const VerificationMeta _titleMeta = const VerificationMeta('title');
@override
late final GeneratedColumn<String> title = GeneratedColumn<String>('title', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _colorValueMeta = const VerificationMeta('colorValue');
@override
late final GeneratedColumn<int> colorValue = GeneratedColumn<int>('color_value', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
static const VerificationMeta _supabaseUserIdMeta = const VerificationMeta('supabaseUserId');
@override
late final GeneratedColumn<String> supabaseUserId = GeneratedColumn<String>('supabase_user_id', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _favoritedAtMeta = const VerificationMeta('favoritedAt');
@override
late final GeneratedColumn<DateTime> favoritedAt = GeneratedColumn<DateTime>('favorited_at', aliasedName, false, type: DriftSqlType.dateTime, requiredDuringInsert: true);
@override
List<GeneratedColumn> get $columns => [id, cardId, title, colorValue, supabaseUserId, favoritedAt];
@override
String get aliasedName => _alias ?? actualTableName;
@override
 String get actualTableName => $name;
static const String $name = 'favorites_table';
@override
VerificationContext validateIntegrity(Insertable<FavoriteTableData> instance, {bool isInserting = false}) {
final context = VerificationContext();
final data = instance.toColumns(true);
if (data.containsKey('id')) {
context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));}if (data.containsKey('card_id')) {
context.handle(_cardIdMeta, cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta));} else if (isInserting) {
context.missing(_cardIdMeta);
}
if (data.containsKey('title')) {
context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));} else if (isInserting) {
context.missing(_titleMeta);
}
if (data.containsKey('color_value')) {
context.handle(_colorValueMeta, colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta));} else if (isInserting) {
context.missing(_colorValueMeta);
}
if (data.containsKey('supabase_user_id')) {
context.handle(_supabaseUserIdMeta, supabaseUserId.isAcceptableOrUnknown(data['supabase_user_id']!, _supabaseUserIdMeta));} else if (isInserting) {
context.missing(_supabaseUserIdMeta);
}
if (data.containsKey('favorited_at')) {
context.handle(_favoritedAtMeta, favoritedAt.isAcceptableOrUnknown(data['favorited_at']!, _favoritedAtMeta));} else if (isInserting) {
context.missing(_favoritedAtMeta);
}
return context;
}
@override
Set<GeneratedColumn> get $primaryKey => {id};
@override FavoriteTableData map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return FavoriteTableData(id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!, cardId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}card_id'])!, title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!, colorValue: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}color_value'])!, supabaseUserId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}supabase_user_id'])!, favoritedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}favorited_at'])!, );
}
@override
$FavoritesTableTable createAlias(String alias) {
return $FavoritesTableTable(attachedDatabase, alias);}}class FavoriteTableData extends DataClass implements Insertable<FavoriteTableData> 
{
final int id;
final String cardId;
final String title;
final int colorValue;
final String supabaseUserId;
final DateTime favoritedAt;
const FavoriteTableData({required this.id, required this.cardId, required this.title, required this.colorValue, required this.supabaseUserId, required this.favoritedAt});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};map['id'] = Variable<int>(id);
map['card_id'] = Variable<String>(cardId);
map['title'] = Variable<String>(title);
map['color_value'] = Variable<int>(colorValue);
map['supabase_user_id'] = Variable<String>(supabaseUserId);
map['favorited_at'] = Variable<DateTime>(favoritedAt);
return map; 
}
FavoritesTableCompanion toCompanion(bool nullToAbsent) {
return FavoritesTableCompanion(id: Value(id),cardId: Value(cardId),title: Value(title),colorValue: Value(colorValue),supabaseUserId: Value(supabaseUserId),favoritedAt: Value(favoritedAt),);
}
factory FavoriteTableData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return FavoriteTableData(id: serializer.fromJson<int>(json['id']),cardId: serializer.fromJson<String>(json['cardId']),title: serializer.fromJson<String>(json['title']),colorValue: serializer.fromJson<int>(json['colorValue']),supabaseUserId: serializer.fromJson<String>(json['supabaseUserId']),favoritedAt: serializer.fromJson<DateTime>(json['favoritedAt']),);}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
'id': serializer.toJson<int>(id),'cardId': serializer.toJson<String>(cardId),'title': serializer.toJson<String>(title),'colorValue': serializer.toJson<int>(colorValue),'supabaseUserId': serializer.toJson<String>(supabaseUserId),'favoritedAt': serializer.toJson<DateTime>(favoritedAt),};}FavoriteTableData copyWith({int? id,String? cardId,String? title,int? colorValue,String? supabaseUserId,DateTime? favoritedAt}) => FavoriteTableData(id: id ?? this.id,cardId: cardId ?? this.cardId,title: title ?? this.title,colorValue: colorValue ?? this.colorValue,supabaseUserId: supabaseUserId ?? this.supabaseUserId,favoritedAt: favoritedAt ?? this.favoritedAt,);FavoriteTableData copyWithCompanion(FavoritesTableCompanion data) {
return FavoriteTableData(
id: data.id.present ? data.id.value : this.id,cardId: data.cardId.present ? data.cardId.value : this.cardId,title: data.title.present ? data.title.value : this.title,colorValue: data.colorValue.present ? data.colorValue.value : this.colorValue,supabaseUserId: data.supabaseUserId.present ? data.supabaseUserId.value : this.supabaseUserId,favoritedAt: data.favoritedAt.present ? data.favoritedAt.value : this.favoritedAt,);
}
@override
String toString() {return (StringBuffer('FavoriteTableData(')..write('id: $id, ')..write('cardId: $cardId, ')..write('title: $title, ')..write('colorValue: $colorValue, ')..write('supabaseUserId: $supabaseUserId, ')..write('favoritedAt: $favoritedAt')..write(')')).toString();}
@override
 int get hashCode => Object.hash(id, cardId, title, colorValue, supabaseUserId, favoritedAt);@override
bool operator ==(Object other) => identical(this, other) || (other is FavoriteTableData && other.id == this.id && other.cardId == this.cardId && other.title == this.title && other.colorValue == this.colorValue && other.supabaseUserId == this.supabaseUserId && other.favoritedAt == this.favoritedAt);
}class FavoritesTableCompanion extends UpdateCompanion<FavoriteTableData> {
final Value<int> id;
final Value<String> cardId;
final Value<String> title;
final Value<int> colorValue;
final Value<String> supabaseUserId;
final Value<DateTime> favoritedAt;
const FavoritesTableCompanion({this.id = const Value.absent(),this.cardId = const Value.absent(),this.title = const Value.absent(),this.colorValue = const Value.absent(),this.supabaseUserId = const Value.absent(),this.favoritedAt = const Value.absent(),});
FavoritesTableCompanion.insert({this.id = const Value.absent(),required String cardId,required String title,required int colorValue,required String supabaseUserId,required DateTime favoritedAt,}): cardId = Value(cardId), title = Value(title), colorValue = Value(colorValue), supabaseUserId = Value(supabaseUserId), favoritedAt = Value(favoritedAt);
static Insertable<FavoriteTableData> custom({Expression<int>? id, 
Expression<String>? cardId, 
Expression<String>? title, 
Expression<int>? colorValue, 
Expression<String>? supabaseUserId, 
Expression<DateTime>? favoritedAt, 
}) {
return RawValuesInsertable({if (id != null)'id': id,if (cardId != null)'card_id': cardId,if (title != null)'title': title,if (colorValue != null)'color_value': colorValue,if (supabaseUserId != null)'supabase_user_id': supabaseUserId,if (favoritedAt != null)'favorited_at': favoritedAt,});
}FavoritesTableCompanion copyWith({Value<int>? id, Value<String>? cardId, Value<String>? title, Value<int>? colorValue, Value<String>? supabaseUserId, Value<DateTime>? favoritedAt}) {
return FavoritesTableCompanion(id: id ?? this.id,cardId: cardId ?? this.cardId,title: title ?? this.title,colorValue: colorValue ?? this.colorValue,supabaseUserId: supabaseUserId ?? this.supabaseUserId,favoritedAt: favoritedAt ?? this.favoritedAt,);
}
@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};if (id.present) {
map['id'] = Variable<int>(id.value);}
if (cardId.present) {
map['card_id'] = Variable<String>(cardId.value);}
if (title.present) {
map['title'] = Variable<String>(title.value);}
if (colorValue.present) {
map['color_value'] = Variable<int>(colorValue.value);}
if (supabaseUserId.present) {
map['supabase_user_id'] = Variable<String>(supabaseUserId.value);}
if (favoritedAt.present) {
map['favorited_at'] = Variable<DateTime>(favoritedAt.value);}
return map; 
}
@override
String toString() {return (StringBuffer('FavoritesTableCompanion(')..write('id: $id, ')..write('cardId: $cardId, ')..write('title: $title, ')..write('colorValue: $colorValue, ')..write('supabaseUserId: $supabaseUserId, ')..write('favoritedAt: $favoritedAt')..write(')')).toString();}
}
class $OrdersTableTable extends OrdersTable with TableInfo<$OrdersTableTable, OrderTableData>{
@override final GeneratedDatabase attachedDatabase;
final String? _alias;
$OrdersTableTable(this.attachedDatabase, [this._alias]);
static const VerificationMeta _idMeta = const VerificationMeta('id');
@override
late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false, hasAutoIncrement: true, type: DriftSqlType.int, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
@override
late final GeneratedColumn<String> cardId = GeneratedColumn<String>('card_id', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _titleMeta = const VerificationMeta('title');
@override
late final GeneratedColumn<String> title = GeneratedColumn<String>('title', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _messageMeta = const VerificationMeta('message');
@override
late final GeneratedColumn<String> message = GeneratedColumn<String>('message', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _addedAtMeta = const VerificationMeta('addedAt');
@override
late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>('added_at', aliasedName, false, type: DriftSqlType.dateTime, requiredDuringInsert: true);
@override
List<GeneratedColumn> get $columns => [id, cardId, title, message, addedAt];
@override
String get aliasedName => _alias ?? actualTableName;
@override
 String get actualTableName => $name;
static const String $name = 'orders_table';
@override
VerificationContext validateIntegrity(Insertable<OrderTableData> instance, {bool isInserting = false}) {
final context = VerificationContext();
final data = instance.toColumns(true);
if (data.containsKey('id')) {
context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));}if (data.containsKey('card_id')) {
context.handle(_cardIdMeta, cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta));} else if (isInserting) {
context.missing(_cardIdMeta);
}
if (data.containsKey('title')) {
context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));} else if (isInserting) {
context.missing(_titleMeta);
}
if (data.containsKey('message')) {
context.handle(_messageMeta, message.isAcceptableOrUnknown(data['message']!, _messageMeta));} else if (isInserting) {
context.missing(_messageMeta);
}
if (data.containsKey('added_at')) {
context.handle(_addedAtMeta, addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta));} else if (isInserting) {
context.missing(_addedAtMeta);
}
return context;
}
@override
Set<GeneratedColumn> get $primaryKey => {id};
@override OrderTableData map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return OrderTableData(id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!, cardId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}card_id'])!, title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!, message: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}message'])!, addedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}added_at'])!, );
}
@override
$OrdersTableTable createAlias(String alias) {
return $OrdersTableTable(attachedDatabase, alias);}}class OrderTableData extends DataClass implements Insertable<OrderTableData> 
{
final int id;
final String cardId;
final String title;
final String message;
final DateTime addedAt;
const OrderTableData({required this.id, required this.cardId, required this.title, required this.message, required this.addedAt});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};map['id'] = Variable<int>(id);
map['card_id'] = Variable<String>(cardId);
map['title'] = Variable<String>(title);
map['message'] = Variable<String>(message);
map['added_at'] = Variable<DateTime>(addedAt);
return map; 
}
OrdersTableCompanion toCompanion(bool nullToAbsent) {
return OrdersTableCompanion(id: Value(id),cardId: Value(cardId),title: Value(title),message: Value(message),addedAt: Value(addedAt),);
}
factory OrderTableData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return OrderTableData(id: serializer.fromJson<int>(json['id']),cardId: serializer.fromJson<String>(json['cardId']),title: serializer.fromJson<String>(json['title']),message: serializer.fromJson<String>(json['message']),addedAt: serializer.fromJson<DateTime>(json['addedAt']),);}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
'id': serializer.toJson<int>(id),'cardId': serializer.toJson<String>(cardId),'title': serializer.toJson<String>(title),'message': serializer.toJson<String>(message),'addedAt': serializer.toJson<DateTime>(addedAt),};}OrderTableData copyWith({int? id,String? cardId,String? title,String? message,DateTime? addedAt}) => OrderTableData(id: id ?? this.id,cardId: cardId ?? this.cardId,title: title ?? this.title,message: message ?? this.message,addedAt: addedAt ?? this.addedAt,);OrderTableData copyWithCompanion(OrdersTableCompanion data) {
return OrderTableData(
id: data.id.present ? data.id.value : this.id,cardId: data.cardId.present ? data.cardId.value : this.cardId,title: data.title.present ? data.title.value : this.title,message: data.message.present ? data.message.value : this.message,addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,);
}
@override
String toString() {return (StringBuffer('OrderTableData(')..write('id: $id, ')..write('cardId: $cardId, ')..write('title: $title, ')..write('message: $message, ')..write('addedAt: $addedAt')..write(')')).toString();}
@override
 int get hashCode => Object.hash(id, cardId, title, message, addedAt);@override
bool operator ==(Object other) => identical(this, other) || (other is OrderTableData && other.id == this.id && other.cardId == this.cardId && other.title == this.title && other.message == this.message && other.addedAt == this.addedAt);
}class OrdersTableCompanion extends UpdateCompanion<OrderTableData> {
final Value<int> id;
final Value<String> cardId;
final Value<String> title;
final Value<String> message;
final Value<DateTime> addedAt;
const OrdersTableCompanion({this.id = const Value.absent(),this.cardId = const Value.absent(),this.title = const Value.absent(),this.message = const Value.absent(),this.addedAt = const Value.absent(),});
OrdersTableCompanion.insert({this.id = const Value.absent(),required String cardId,required String title,required String message,required DateTime addedAt,}): cardId = Value(cardId), title = Value(title), message = Value(message), addedAt = Value(addedAt);
static Insertable<OrderTableData> custom({Expression<int>? id, 
Expression<String>? cardId, 
Expression<String>? title, 
Expression<String>? message, 
Expression<DateTime>? addedAt, 
}) {
return RawValuesInsertable({if (id != null)'id': id,if (cardId != null)'card_id': cardId,if (title != null)'title': title,if (message != null)'message': message,if (addedAt != null)'added_at': addedAt,});
}OrdersTableCompanion copyWith({Value<int>? id, Value<String>? cardId, Value<String>? title, Value<String>? message, Value<DateTime>? addedAt}) {
return OrdersTableCompanion(id: id ?? this.id,cardId: cardId ?? this.cardId,title: title ?? this.title,message: message ?? this.message,addedAt: addedAt ?? this.addedAt,);
}
@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};if (id.present) {
map['id'] = Variable<int>(id.value);}
if (cardId.present) {
map['card_id'] = Variable<String>(cardId.value);}
if (title.present) {
map['title'] = Variable<String>(title.value);}
if (message.present) {
map['message'] = Variable<String>(message.value);}
if (addedAt.present) {
map['added_at'] = Variable<DateTime>(addedAt.value);}
return map; 
}
@override
String toString() {return (StringBuffer('OrdersTableCompanion(')..write('id: $id, ')..write('cardId: $cardId, ')..write('title: $title, ')..write('message: $message, ')..write('addedAt: $addedAt')..write(')')).toString();}
}
class $EventsTableTable extends EventsTable with TableInfo<$EventsTableTable, EventTableData>{
@override final GeneratedDatabase attachedDatabase;
final String? _alias;
$EventsTableTable(this.attachedDatabase, [this._alias]);
static const VerificationMeta _idMeta = const VerificationMeta('id');
@override
late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false, hasAutoIncrement: true, type: DriftSqlType.int, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
static const VerificationMeta _titleMeta = const VerificationMeta('title');
@override
late final GeneratedColumn<String> title = GeneratedColumn<String>('title', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _dateMeta = const VerificationMeta('date');
@override
late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>('date', aliasedName, false, type: DriftSqlType.dateTime, requiredDuringInsert: true);
static const VerificationMeta _reminderMeta = const VerificationMeta('reminder');
@override
late final GeneratedColumn<String> reminder = GeneratedColumn<String>('reminder', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _isCustomMeta = const VerificationMeta('isCustom');
@override
late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>('is_custom', aliasedName, false, type: DriftSqlType.bool, requiredDuringInsert: true, defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_custom" IN (0, 1))'));
@override
List<GeneratedColumn> get $columns => [id, title, date, reminder, isCustom];
@override
String get aliasedName => _alias ?? actualTableName;
@override
 String get actualTableName => $name;
static const String $name = 'events_table';
@override
VerificationContext validateIntegrity(Insertable<EventTableData> instance, {bool isInserting = false}) {
final context = VerificationContext();
final data = instance.toColumns(true);
if (data.containsKey('id')) {
context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));}if (data.containsKey('title')) {
context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));} else if (isInserting) {
context.missing(_titleMeta);
}
if (data.containsKey('date')) {
context.handle(_dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));} else if (isInserting) {
context.missing(_dateMeta);
}
if (data.containsKey('reminder')) {
context.handle(_reminderMeta, reminder.isAcceptableOrUnknown(data['reminder']!, _reminderMeta));} else if (isInserting) {
context.missing(_reminderMeta);
}
if (data.containsKey('is_custom')) {
context.handle(_isCustomMeta, isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta));} else if (isInserting) {
context.missing(_isCustomMeta);
}
return context;
}
@override
Set<GeneratedColumn> get $primaryKey => {id};
@override EventTableData map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return EventTableData(id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!, title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!, date: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!, reminder: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}reminder'])!, isCustom: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}is_custom'])!, );
}
@override
$EventsTableTable createAlias(String alias) {
return $EventsTableTable(attachedDatabase, alias);}}class EventTableData extends DataClass implements Insertable<EventTableData> 
{
final int id;
final String title;
final DateTime date;
final String reminder;
final bool isCustom;
const EventTableData({required this.id, required this.title, required this.date, required this.reminder, required this.isCustom});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};map['id'] = Variable<int>(id);
map['title'] = Variable<String>(title);
map['date'] = Variable<DateTime>(date);
map['reminder'] = Variable<String>(reminder);
map['is_custom'] = Variable<bool>(isCustom);
return map; 
}
EventsTableCompanion toCompanion(bool nullToAbsent) {
return EventsTableCompanion(id: Value(id),title: Value(title),date: Value(date),reminder: Value(reminder),isCustom: Value(isCustom),);
}
factory EventTableData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return EventTableData(id: serializer.fromJson<int>(json['id']),title: serializer.fromJson<String>(json['title']),date: serializer.fromJson<DateTime>(json['date']),reminder: serializer.fromJson<String>(json['reminder']),isCustom: serializer.fromJson<bool>(json['isCustom']),);}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
'id': serializer.toJson<int>(id),'title': serializer.toJson<String>(title),'date': serializer.toJson<DateTime>(date),'reminder': serializer.toJson<String>(reminder),'isCustom': serializer.toJson<bool>(isCustom),};}EventTableData copyWith({int? id,String? title,DateTime? date,String? reminder,bool? isCustom}) => EventTableData(id: id ?? this.id,title: title ?? this.title,date: date ?? this.date,reminder: reminder ?? this.reminder,isCustom: isCustom ?? this.isCustom,);EventTableData copyWithCompanion(EventsTableCompanion data) {
return EventTableData(
id: data.id.present ? data.id.value : this.id,title: data.title.present ? data.title.value : this.title,date: data.date.present ? data.date.value : this.date,reminder: data.reminder.present ? data.reminder.value : this.reminder,isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,);
}
@override
String toString() {return (StringBuffer('EventTableData(')..write('id: $id, ')..write('title: $title, ')..write('date: $date, ')..write('reminder: $reminder, ')..write('isCustom: $isCustom')..write(')')).toString();}
@override
 int get hashCode => Object.hash(id, title, date, reminder, isCustom);@override
bool operator ==(Object other) => identical(this, other) || (other is EventTableData && other.id == this.id && other.title == this.title && other.date == this.date && other.reminder == this.reminder && other.isCustom == this.isCustom);
}class EventsTableCompanion extends UpdateCompanion<EventTableData> {
final Value<int> id;
final Value<String> title;
final Value<DateTime> date;
final Value<String> reminder;
final Value<bool> isCustom;
const EventsTableCompanion({this.id = const Value.absent(),this.title = const Value.absent(),this.date = const Value.absent(),this.reminder = const Value.absent(),this.isCustom = const Value.absent(),});
EventsTableCompanion.insert({this.id = const Value.absent(),required String title,required DateTime date,required String reminder,required bool isCustom,}): title = Value(title), date = Value(date), reminder = Value(reminder), isCustom = Value(isCustom);
static Insertable<EventTableData> custom({Expression<int>? id, 
Expression<String>? title, 
Expression<DateTime>? date, 
Expression<String>? reminder, 
Expression<bool>? isCustom, 
}) {
return RawValuesInsertable({if (id != null)'id': id,if (title != null)'title': title,if (date != null)'date': date,if (reminder != null)'reminder': reminder,if (isCustom != null)'is_custom': isCustom,});
}EventsTableCompanion copyWith({Value<int>? id, Value<String>? title, Value<DateTime>? date, Value<String>? reminder, Value<bool>? isCustom}) {
return EventsTableCompanion(id: id ?? this.id,title: title ?? this.title,date: date ?? this.date,reminder: reminder ?? this.reminder,isCustom: isCustom ?? this.isCustom,);
}
@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};if (id.present) {
map['id'] = Variable<int>(id.value);}
if (title.present) {
map['title'] = Variable<String>(title.value);}
if (date.present) {
map['date'] = Variable<DateTime>(date.value);}
if (reminder.present) {
map['reminder'] = Variable<String>(reminder.value);}
if (isCustom.present) {
map['is_custom'] = Variable<bool>(isCustom.value);}
return map; 
}
@override
String toString() {return (StringBuffer('EventsTableCompanion(')..write('id: $id, ')..write('title: $title, ')..write('date: $date, ')..write('reminder: $reminder, ')..write('isCustom: $isCustom')..write(')')).toString();}
}
class $DraftsTableTable extends DraftsTable with TableInfo<$DraftsTableTable, DraftTableData>{
@override final GeneratedDatabase attachedDatabase;
final String? _alias;
$DraftsTableTable(this.attachedDatabase, [this._alias]);
static const VerificationMeta _idMeta = const VerificationMeta('id');
@override
late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false, hasAutoIncrement: true, type: DriftSqlType.int, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
@override
late final GeneratedColumn<String> cardId = GeneratedColumn<String>('card_id', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _coverTextMeta = const VerificationMeta('coverText');
@override
late final GeneratedColumn<String> coverText = GeneratedColumn<String>('cover_text', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _insideMessageMeta = const VerificationMeta('insideMessage');
@override
late final GeneratedColumn<String> insideMessage = GeneratedColumn<String>('inside_message', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _savedAtMeta = const VerificationMeta('savedAt');
@override
late final GeneratedColumn<DateTime> savedAt = GeneratedColumn<DateTime>('saved_at', aliasedName, false, type: DriftSqlType.dateTime, requiredDuringInsert: true);
static const VerificationMeta _draftNameMeta = const VerificationMeta('draftName');
@override
late final GeneratedColumn<String> draftName = GeneratedColumn<String>('draft_name', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
@override
List<GeneratedColumn> get $columns => [id, cardId, coverText, insideMessage, savedAt, draftName];
@override
String get aliasedName => _alias ?? actualTableName;
@override
 String get actualTableName => $name;
static const String $name = 'drafts_table';
@override
VerificationContext validateIntegrity(Insertable<DraftTableData> instance, {bool isInserting = false}) {
final context = VerificationContext();
final data = instance.toColumns(true);
if (data.containsKey('id')) {
context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));}if (data.containsKey('card_id')) {
context.handle(_cardIdMeta, cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta));} else if (isInserting) {
context.missing(_cardIdMeta);
}
if (data.containsKey('cover_text')) {
context.handle(_coverTextMeta, coverText.isAcceptableOrUnknown(data['cover_text']!, _coverTextMeta));} else if (isInserting) {
context.missing(_coverTextMeta);
}
if (data.containsKey('inside_message')) {
context.handle(_insideMessageMeta, insideMessage.isAcceptableOrUnknown(data['inside_message']!, _insideMessageMeta));} else if (isInserting) {
context.missing(_insideMessageMeta);
}
if (data.containsKey('saved_at')) {
context.handle(_savedAtMeta, savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta));} else if (isInserting) {
context.missing(_savedAtMeta);
}
if (data.containsKey('draft_name')) {
context.handle(_draftNameMeta, draftName.isAcceptableOrUnknown(data['draft_name']!, _draftNameMeta));}return context;
}
@override
Set<GeneratedColumn> get $primaryKey => {id};
@override DraftTableData map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return DraftTableData(id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!, cardId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}card_id'])!, coverText: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}cover_text'])!, insideMessage: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}inside_message'])!, savedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}saved_at'])!, draftName: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}draft_name']), );
}
@override
$DraftsTableTable createAlias(String alias) {
return $DraftsTableTable(attachedDatabase, alias);}}class DraftTableData extends DataClass implements Insertable<DraftTableData> 
{
final int id;
final String cardId;
final String coverText;
final String insideMessage;
final DateTime savedAt;
final String? draftName;
const DraftTableData({required this.id, required this.cardId, required this.coverText, required this.insideMessage, required this.savedAt, this.draftName});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};map['id'] = Variable<int>(id);
map['card_id'] = Variable<String>(cardId);
map['cover_text'] = Variable<String>(coverText);
map['inside_message'] = Variable<String>(insideMessage);
map['saved_at'] = Variable<DateTime>(savedAt);
if (!nullToAbsent || draftName != null){map['draft_name'] = Variable<String>(draftName);
}return map; 
}
DraftsTableCompanion toCompanion(bool nullToAbsent) {
return DraftsTableCompanion(id: Value(id),cardId: Value(cardId),coverText: Value(coverText),insideMessage: Value(insideMessage),savedAt: Value(savedAt),draftName: draftName == null && nullToAbsent ? const Value.absent() : Value(draftName),);
}
factory DraftTableData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return DraftTableData(id: serializer.fromJson<int>(json['id']),cardId: serializer.fromJson<String>(json['cardId']),coverText: serializer.fromJson<String>(json['coverText']),insideMessage: serializer.fromJson<String>(json['insideMessage']),savedAt: serializer.fromJson<DateTime>(json['savedAt']),draftName: serializer.fromJson<String?>(json['draftName']),);}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
'id': serializer.toJson<int>(id),'cardId': serializer.toJson<String>(cardId),'coverText': serializer.toJson<String>(coverText),'insideMessage': serializer.toJson<String>(insideMessage),'savedAt': serializer.toJson<DateTime>(savedAt),'draftName': serializer.toJson<String?>(draftName),};}DraftTableData copyWith({int? id,String? cardId,String? coverText,String? insideMessage,DateTime? savedAt,Value<String?> draftName = const Value.absent()}) => DraftTableData(id: id ?? this.id,cardId: cardId ?? this.cardId,coverText: coverText ?? this.coverText,insideMessage: insideMessage ?? this.insideMessage,savedAt: savedAt ?? this.savedAt,draftName: draftName.present ? draftName.value : this.draftName,);DraftTableData copyWithCompanion(DraftsTableCompanion data) {
return DraftTableData(
id: data.id.present ? data.id.value : this.id,cardId: data.cardId.present ? data.cardId.value : this.cardId,coverText: data.coverText.present ? data.coverText.value : this.coverText,insideMessage: data.insideMessage.present ? data.insideMessage.value : this.insideMessage,savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,draftName: data.draftName.present ? data.draftName.value : this.draftName,);
}
@override
String toString() {return (StringBuffer('DraftTableData(')..write('id: $id, ')..write('cardId: $cardId, ')..write('coverText: $coverText, ')..write('insideMessage: $insideMessage, ')..write('savedAt: $savedAt, ')..write('draftName: $draftName')..write(')')).toString();}
@override
 int get hashCode => Object.hash(id, cardId, coverText, insideMessage, savedAt, draftName);@override
bool operator ==(Object other) => identical(this, other) || (other is DraftTableData && other.id == this.id && other.cardId == this.cardId && other.coverText == this.coverText && other.insideMessage == this.insideMessage && other.savedAt == this.savedAt && other.draftName == this.draftName);
}class DraftsTableCompanion extends UpdateCompanion<DraftTableData> {
final Value<int> id;
final Value<String> cardId;
final Value<String> coverText;
final Value<String> insideMessage;
final Value<DateTime> savedAt;
final Value<String?> draftName;
const DraftsTableCompanion({this.id = const Value.absent(),this.cardId = const Value.absent(),this.coverText = const Value.absent(),this.insideMessage = const Value.absent(),this.savedAt = const Value.absent(),this.draftName = const Value.absent(),});
DraftsTableCompanion.insert({this.id = const Value.absent(),required String cardId,required String coverText,required String insideMessage,required DateTime savedAt,this.draftName = const Value.absent(),}): cardId = Value(cardId), coverText = Value(coverText), insideMessage = Value(insideMessage), savedAt = Value(savedAt);
static Insertable<DraftTableData> custom({Expression<int>? id, 
Expression<String>? cardId, 
Expression<String>? coverText, 
Expression<String>? insideMessage, 
Expression<DateTime>? savedAt, 
Expression<String>? draftName, 
}) {
return RawValuesInsertable({if (id != null)'id': id,if (cardId != null)'card_id': cardId,if (coverText != null)'cover_text': coverText,if (insideMessage != null)'inside_message': insideMessage,if (savedAt != null)'saved_at': savedAt,if (draftName != null)'draft_name': draftName,});
}DraftsTableCompanion copyWith({Value<int>? id, Value<String>? cardId, Value<String>? coverText, Value<String>? insideMessage, Value<DateTime>? savedAt, Value<String?>? draftName}) {
return DraftsTableCompanion(id: id ?? this.id,cardId: cardId ?? this.cardId,coverText: coverText ?? this.coverText,insideMessage: insideMessage ?? this.insideMessage,savedAt: savedAt ?? this.savedAt,draftName: draftName ?? this.draftName,);
}
@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};if (id.present) {
map['id'] = Variable<int>(id.value);}
if (cardId.present) {
map['card_id'] = Variable<String>(cardId.value);}
if (coverText.present) {
map['cover_text'] = Variable<String>(coverText.value);}
if (insideMessage.present) {
map['inside_message'] = Variable<String>(insideMessage.value);}
if (savedAt.present) {
map['saved_at'] = Variable<DateTime>(savedAt.value);}
if (draftName.present) {
map['draft_name'] = Variable<String>(draftName.value);}
return map; 
}
@override
String toString() {return (StringBuffer('DraftsTableCompanion(')..write('id: $id, ')..write('cardId: $cardId, ')..write('coverText: $coverText, ')..write('insideMessage: $insideMessage, ')..write('savedAt: $savedAt, ')..write('draftName: $draftName')..write(')')).toString();}
}
abstract class _$AppDatabase extends GeneratedDatabase{
_$AppDatabase(QueryExecutor e): super(e);
$AppDatabaseManager get managers => $AppDatabaseManager(this);
late final $FavoritesTableTable favoritesTable = $FavoritesTableTable(this);
late final $OrdersTableTable ordersTable = $OrdersTableTable(this);
late final $EventsTableTable eventsTable = $EventsTableTable(this);
late final $DraftsTableTable draftsTable = $DraftsTableTable(this);
@override
Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
@override
List<DatabaseSchemaEntity> get allSchemaEntities => [favoritesTable, ordersTable, eventsTable, draftsTable];
}
typedef $$FavoritesTableTableCreateCompanionBuilder = FavoritesTableCompanion Function({Value<int> id,required String cardId,required String title,required int colorValue,required String supabaseUserId,required DateTime favoritedAt,});
typedef $$FavoritesTableTableUpdateCompanionBuilder = FavoritesTableCompanion Function({Value<int> id,Value<String> cardId,Value<String> title,Value<int> colorValue,Value<String> supabaseUserId,Value<DateTime> favoritedAt,});
class $$FavoritesTableTableFilterComposer extends Composer<
        _$AppDatabase,
        $FavoritesTableTable> {
        $$FavoritesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnFilters<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get cardId => $composableBuilder(
      column: $table.cardId,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get title => $composableBuilder(
      column: $table.title,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<int> get colorValue => $composableBuilder(
      column: $table.colorValue,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get supabaseUserId => $composableBuilder(
      column: $table.supabaseUserId,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<DateTime> get favoritedAt => $composableBuilder(
      column: $table.favoritedAt,
      builder: (column) => 
      ColumnFilters(column));
      
        }
      class $$FavoritesTableTableOrderingComposer extends Composer<
        _$AppDatabase,
        $FavoritesTableTable> {
        $$FavoritesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get cardId => $composableBuilder(
      column: $table.cardId,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<int> get colorValue => $composableBuilder(
      column: $table.colorValue,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get supabaseUserId => $composableBuilder(
      column: $table.supabaseUserId,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<DateTime> get favoritedAt => $composableBuilder(
      column: $table.favoritedAt,
      builder: (column) => 
      ColumnOrderings(column));
      
        }
      class $$FavoritesTableTableAnnotationComposer extends Composer<
        _$AppDatabase,
        $FavoritesTableTable> {
        $$FavoritesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          GeneratedColumn<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => column);
      
GeneratedColumn<String> get cardId => $composableBuilder(
      column: $table.cardId,
      builder: (column) => column);
      
GeneratedColumn<String> get title => $composableBuilder(
      column: $table.title,
      builder: (column) => column);
      
GeneratedColumn<int> get colorValue => $composableBuilder(
      column: $table.colorValue,
      builder: (column) => column);
      
GeneratedColumn<String> get supabaseUserId => $composableBuilder(
      column: $table.supabaseUserId,
      builder: (column) => column);
      
GeneratedColumn<DateTime> get favoritedAt => $composableBuilder(
      column: $table.favoritedAt,
      builder: (column) => column);
      
        }
      class $$FavoritesTableTableTableManager extends RootTableManager    <_$AppDatabase,
    $FavoritesTableTable,
    FavoriteTableData,
    $$FavoritesTableTableFilterComposer,
    $$FavoritesTableTableOrderingComposer,
    $$FavoritesTableTableAnnotationComposer,
    $$FavoritesTableTableCreateCompanionBuilder,
    $$FavoritesTableTableUpdateCompanionBuilder,
    (FavoriteTableData,BaseReferences<_$AppDatabase,$FavoritesTableTable,FavoriteTableData>),
    FavoriteTableData,
    PrefetchHooks Function()
    > {
    $$FavoritesTableTableTableManager(_$AppDatabase db, $FavoritesTableTable table) : super(
      TableManagerState(
        db: db,
        table: table,
        createFilteringComposer: () => $$FavoritesTableTableFilterComposer($db: db,$table:table),
        createOrderingComposer: () => $$FavoritesTableTableOrderingComposer($db: db,$table:table),
        createComputedFieldComposer: () => $$FavoritesTableTableAnnotationComposer($db: db,$table:table),
        updateCompanionCallback: ({Value<int> id = const Value.absent(),Value<String> cardId = const Value.absent(),Value<String> title = const Value.absent(),Value<int> colorValue = const Value.absent(),Value<String> supabaseUserId = const Value.absent(),Value<DateTime> favoritedAt = const Value.absent(),})=> FavoritesTableCompanion(id: id,cardId: cardId,title: title,colorValue: colorValue,supabaseUserId: supabaseUserId,favoritedAt: favoritedAt,),
        createCompanionCallback: ({Value<int> id = const Value.absent(),required String cardId,required String title,required int colorValue,required String supabaseUserId,required DateTime favoritedAt,})=> FavoritesTableCompanion.insert(id: id,cardId: cardId,title: title,colorValue: colorValue,supabaseUserId: supabaseUserId,favoritedAt: favoritedAt,),
        withReferenceMapper: (p0) => p0
              .map(
                  (e) =>
                     (e.readTable(table), BaseReferences(db, table, e))
                  )
              .toList(),
        prefetchHooksCallback: null,
        ));
        }
    typedef $$FavoritesTableTableProcessedTableManager = ProcessedTableManager    <_$AppDatabase,
    $FavoritesTableTable,
    FavoriteTableData,
    $$FavoritesTableTableFilterComposer,
    $$FavoritesTableTableOrderingComposer,
    $$FavoritesTableTableAnnotationComposer,
    $$FavoritesTableTableCreateCompanionBuilder,
    $$FavoritesTableTableUpdateCompanionBuilder,
    (FavoriteTableData,BaseReferences<_$AppDatabase,$FavoritesTableTable,FavoriteTableData>),
    FavoriteTableData,
    PrefetchHooks Function()
    >;typedef $$OrdersTableTableCreateCompanionBuilder = OrdersTableCompanion Function({Value<int> id,required String cardId,required String title,required String message,required DateTime addedAt,});
typedef $$OrdersTableTableUpdateCompanionBuilder = OrdersTableCompanion Function({Value<int> id,Value<String> cardId,Value<String> title,Value<String> message,Value<DateTime> addedAt,});
class $$OrdersTableTableFilterComposer extends Composer<
        _$AppDatabase,
        $OrdersTableTable> {
        $$OrdersTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnFilters<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get cardId => $composableBuilder(
      column: $table.cardId,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get title => $composableBuilder(
      column: $table.title,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get message => $composableBuilder(
      column: $table.message,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt,
      builder: (column) => 
      ColumnFilters(column));
      
        }
      class $$OrdersTableTableOrderingComposer extends Composer<
        _$AppDatabase,
        $OrdersTableTable> {
        $$OrdersTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get cardId => $composableBuilder(
      column: $table.cardId,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get message => $composableBuilder(
      column: $table.message,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt,
      builder: (column) => 
      ColumnOrderings(column));
      
        }
      class $$OrdersTableTableAnnotationComposer extends Composer<
        _$AppDatabase,
        $OrdersTableTable> {
        $$OrdersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          GeneratedColumn<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => column);
      
GeneratedColumn<String> get cardId => $composableBuilder(
      column: $table.cardId,
      builder: (column) => column);
      
GeneratedColumn<String> get title => $composableBuilder(
      column: $table.title,
      builder: (column) => column);
      
GeneratedColumn<String> get message => $composableBuilder(
      column: $table.message,
      builder: (column) => column);
      
GeneratedColumn<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt,
      builder: (column) => column);
      
        }
      class $$OrdersTableTableTableManager extends RootTableManager    <_$AppDatabase,
    $OrdersTableTable,
    OrderTableData,
    $$OrdersTableTableFilterComposer,
    $$OrdersTableTableOrderingComposer,
    $$OrdersTableTableAnnotationComposer,
    $$OrdersTableTableCreateCompanionBuilder,
    $$OrdersTableTableUpdateCompanionBuilder,
    (OrderTableData,BaseReferences<_$AppDatabase,$OrdersTableTable,OrderTableData>),
    OrderTableData,
    PrefetchHooks Function()
    > {
    $$OrdersTableTableTableManager(_$AppDatabase db, $OrdersTableTable table) : super(
      TableManagerState(
        db: db,
        table: table,
        createFilteringComposer: () => $$OrdersTableTableFilterComposer($db: db,$table:table),
        createOrderingComposer: () => $$OrdersTableTableOrderingComposer($db: db,$table:table),
        createComputedFieldComposer: () => $$OrdersTableTableAnnotationComposer($db: db,$table:table),
        updateCompanionCallback: ({Value<int> id = const Value.absent(),Value<String> cardId = const Value.absent(),Value<String> title = const Value.absent(),Value<String> message = const Value.absent(),Value<DateTime> addedAt = const Value.absent(),})=> OrdersTableCompanion(id: id,cardId: cardId,title: title,message: message,addedAt: addedAt,),
        createCompanionCallback: ({Value<int> id = const Value.absent(),required String cardId,required String title,required String message,required DateTime addedAt,})=> OrdersTableCompanion.insert(id: id,cardId: cardId,title: title,message: message,addedAt: addedAt,),
        withReferenceMapper: (p0) => p0
              .map(
                  (e) =>
                     (e.readTable(table), BaseReferences(db, table, e))
                  )
              .toList(),
        prefetchHooksCallback: null,
        ));
        }
    typedef $$OrdersTableTableProcessedTableManager = ProcessedTableManager    <_$AppDatabase,
    $OrdersTableTable,
    OrderTableData,
    $$OrdersTableTableFilterComposer,
    $$OrdersTableTableOrderingComposer,
    $$OrdersTableTableAnnotationComposer,
    $$OrdersTableTableCreateCompanionBuilder,
    $$OrdersTableTableUpdateCompanionBuilder,
    (OrderTableData,BaseReferences<_$AppDatabase,$OrdersTableTable,OrderTableData>),
    OrderTableData,
    PrefetchHooks Function()
    >;typedef $$EventsTableTableCreateCompanionBuilder = EventsTableCompanion Function({Value<int> id,required String title,required DateTime date,required String reminder,required bool isCustom,});
typedef $$EventsTableTableUpdateCompanionBuilder = EventsTableCompanion Function({Value<int> id,Value<String> title,Value<DateTime> date,Value<String> reminder,Value<bool> isCustom,});
class $$EventsTableTableFilterComposer extends Composer<
        _$AppDatabase,
        $EventsTableTable> {
        $$EventsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnFilters<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get title => $composableBuilder(
      column: $table.title,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get reminder => $composableBuilder(
      column: $table.reminder,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<bool> get isCustom => $composableBuilder(
      column: $table.isCustom,
      builder: (column) => 
      ColumnFilters(column));
      
        }
      class $$EventsTableTableOrderingComposer extends Composer<
        _$AppDatabase,
        $EventsTableTable> {
        $$EventsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get reminder => $composableBuilder(
      column: $table.reminder,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<bool> get isCustom => $composableBuilder(
      column: $table.isCustom,
      builder: (column) => 
      ColumnOrderings(column));
      
        }
      class $$EventsTableTableAnnotationComposer extends Composer<
        _$AppDatabase,
        $EventsTableTable> {
        $$EventsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          GeneratedColumn<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => column);
      
GeneratedColumn<String> get title => $composableBuilder(
      column: $table.title,
      builder: (column) => column);
      
GeneratedColumn<DateTime> get date => $composableBuilder(
      column: $table.date,
      builder: (column) => column);
      
GeneratedColumn<String> get reminder => $composableBuilder(
      column: $table.reminder,
      builder: (column) => column);
      
GeneratedColumn<bool> get isCustom => $composableBuilder(
      column: $table.isCustom,
      builder: (column) => column);
      
        }
      class $$EventsTableTableTableManager extends RootTableManager    <_$AppDatabase,
    $EventsTableTable,
    EventTableData,
    $$EventsTableTableFilterComposer,
    $$EventsTableTableOrderingComposer,
    $$EventsTableTableAnnotationComposer,
    $$EventsTableTableCreateCompanionBuilder,
    $$EventsTableTableUpdateCompanionBuilder,
    (EventTableData,BaseReferences<_$AppDatabase,$EventsTableTable,EventTableData>),
    EventTableData,
    PrefetchHooks Function()
    > {
    $$EventsTableTableTableManager(_$AppDatabase db, $EventsTableTable table) : super(
      TableManagerState(
        db: db,
        table: table,
        createFilteringComposer: () => $$EventsTableTableFilterComposer($db: db,$table:table),
        createOrderingComposer: () => $$EventsTableTableOrderingComposer($db: db,$table:table),
        createComputedFieldComposer: () => $$EventsTableTableAnnotationComposer($db: db,$table:table),
        updateCompanionCallback: ({Value<int> id = const Value.absent(),Value<String> title = const Value.absent(),Value<DateTime> date = const Value.absent(),Value<String> reminder = const Value.absent(),Value<bool> isCustom = const Value.absent(),})=> EventsTableCompanion(id: id,title: title,date: date,reminder: reminder,isCustom: isCustom,),
        createCompanionCallback: ({Value<int> id = const Value.absent(),required String title,required DateTime date,required String reminder,required bool isCustom,})=> EventsTableCompanion.insert(id: id,title: title,date: date,reminder: reminder,isCustom: isCustom,),
        withReferenceMapper: (p0) => p0
              .map(
                  (e) =>
                     (e.readTable(table), BaseReferences(db, table, e))
                  )
              .toList(),
        prefetchHooksCallback: null,
        ));
        }
    typedef $$EventsTableTableProcessedTableManager = ProcessedTableManager    <_$AppDatabase,
    $EventsTableTable,
    EventTableData,
    $$EventsTableTableFilterComposer,
    $$EventsTableTableOrderingComposer,
    $$EventsTableTableAnnotationComposer,
    $$EventsTableTableCreateCompanionBuilder,
    $$EventsTableTableUpdateCompanionBuilder,
    (EventTableData,BaseReferences<_$AppDatabase,$EventsTableTable,EventTableData>),
    EventTableData,
    PrefetchHooks Function()
    >;typedef $$DraftsTableTableCreateCompanionBuilder = DraftsTableCompanion Function({Value<int> id,required String cardId,required String coverText,required String insideMessage,required DateTime savedAt,Value<String?> draftName,});
typedef $$DraftsTableTableUpdateCompanionBuilder = DraftsTableCompanion Function({Value<int> id,Value<String> cardId,Value<String> coverText,Value<String> insideMessage,Value<DateTime> savedAt,Value<String?> draftName,});
class $$DraftsTableTableFilterComposer extends Composer<
        _$AppDatabase,
        $DraftsTableTable> {
        $$DraftsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnFilters<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get cardId => $composableBuilder(
      column: $table.cardId,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get coverText => $composableBuilder(
      column: $table.coverText,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get insideMessage => $composableBuilder(
      column: $table.insideMessage,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<DateTime> get savedAt => $composableBuilder(
      column: $table.savedAt,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get draftName => $composableBuilder(
      column: $table.draftName,
      builder: (column) => 
      ColumnFilters(column));
      
        }
      class $$DraftsTableTableOrderingComposer extends Composer<
        _$AppDatabase,
        $DraftsTableTable> {
        $$DraftsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get cardId => $composableBuilder(
      column: $table.cardId,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get coverText => $composableBuilder(
      column: $table.coverText,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get insideMessage => $composableBuilder(
      column: $table.insideMessage,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<DateTime> get savedAt => $composableBuilder(
      column: $table.savedAt,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get draftName => $composableBuilder(
      column: $table.draftName,
      builder: (column) => 
      ColumnOrderings(column));
      
        }
      class $$DraftsTableTableAnnotationComposer extends Composer<
        _$AppDatabase,
        $DraftsTableTable> {
        $$DraftsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          GeneratedColumn<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => column);
      
GeneratedColumn<String> get cardId => $composableBuilder(
      column: $table.cardId,
      builder: (column) => column);
      
GeneratedColumn<String> get coverText => $composableBuilder(
      column: $table.coverText,
      builder: (column) => column);
      
GeneratedColumn<String> get insideMessage => $composableBuilder(
      column: $table.insideMessage,
      builder: (column) => column);
      
GeneratedColumn<DateTime> get savedAt => $composableBuilder(
      column: $table.savedAt,
      builder: (column) => column);
      
GeneratedColumn<String> get draftName => $composableBuilder(
      column: $table.draftName,
      builder: (column) => column);
      
        }
      class $$DraftsTableTableTableManager extends RootTableManager    <_$AppDatabase,
    $DraftsTableTable,
    DraftTableData,
    $$DraftsTableTableFilterComposer,
    $$DraftsTableTableOrderingComposer,
    $$DraftsTableTableAnnotationComposer,
    $$DraftsTableTableCreateCompanionBuilder,
    $$DraftsTableTableUpdateCompanionBuilder,
    (DraftTableData,BaseReferences<_$AppDatabase,$DraftsTableTable,DraftTableData>),
    DraftTableData,
    PrefetchHooks Function()
    > {
    $$DraftsTableTableTableManager(_$AppDatabase db, $DraftsTableTable table) : super(
      TableManagerState(
        db: db,
        table: table,
        createFilteringComposer: () => $$DraftsTableTableFilterComposer($db: db,$table:table),
        createOrderingComposer: () => $$DraftsTableTableOrderingComposer($db: db,$table:table),
        createComputedFieldComposer: () => $$DraftsTableTableAnnotationComposer($db: db,$table:table),
        updateCompanionCallback: ({Value<int> id = const Value.absent(),Value<String> cardId = const Value.absent(),Value<String> coverText = const Value.absent(),Value<String> insideMessage = const Value.absent(),Value<DateTime> savedAt = const Value.absent(),Value<String?> draftName = const Value.absent(),})=> DraftsTableCompanion(id: id,cardId: cardId,coverText: coverText,insideMessage: insideMessage,savedAt: savedAt,draftName: draftName,),
        createCompanionCallback: ({Value<int> id = const Value.absent(),required String cardId,required String coverText,required String insideMessage,required DateTime savedAt,Value<String?> draftName = const Value.absent(),})=> DraftsTableCompanion.insert(id: id,cardId: cardId,coverText: coverText,insideMessage: insideMessage,savedAt: savedAt,draftName: draftName,),
        withReferenceMapper: (p0) => p0
              .map(
                  (e) =>
                     (e.readTable(table), BaseReferences(db, table, e))
                  )
              .toList(),
        prefetchHooksCallback: null,
        ));
        }
    typedef $$DraftsTableTableProcessedTableManager = ProcessedTableManager    <_$AppDatabase,
    $DraftsTableTable,
    DraftTableData,
    $$DraftsTableTableFilterComposer,
    $$DraftsTableTableOrderingComposer,
    $$DraftsTableTableAnnotationComposer,
    $$DraftsTableTableCreateCompanionBuilder,
    $$DraftsTableTableUpdateCompanionBuilder,
    (DraftTableData,BaseReferences<_$AppDatabase,$DraftsTableTable,DraftTableData>),
    DraftTableData,
    PrefetchHooks Function()
    >;class $AppDatabaseManager {
final _$AppDatabase _db;
$AppDatabaseManager(this._db);
$$FavoritesTableTableTableManager get favoritesTable => $$FavoritesTableTableTableManager(_db, _db.favoritesTable);
$$OrdersTableTableTableManager get ordersTable => $$OrdersTableTableTableManager(_db, _db.ordersTable);
$$EventsTableTableTableManager get eventsTable => $$EventsTableTableTableManager(_db, _db.eventsTable);
$$DraftsTableTableTableManager get draftsTable => $$DraftsTableTableTableManager(_db, _db.draftsTable);
}
