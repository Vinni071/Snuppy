// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'environment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Value {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Value);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Value()';
}


}

/// @nodoc
class $ValueCopyWith<$Res>  {
$ValueCopyWith(Value _, $Res Function(Value) __);
}


/// Adds pattern-matching-related methods to [Value].
extension ValuePatterns on Value {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Value_Int value)?  int,TResult Function( Value_Float value)?  float,TResult Function( Value_String value)?  string,TResult Function( Value_Bool value)?  bool,TResult Function( Value_Null value)?  null_,TResult Function( Value_Function value)?  function,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Value_Int() when int != null:
return int(_that);case Value_Float() when float != null:
return float(_that);case Value_String() when string != null:
return string(_that);case Value_Bool() when bool != null:
return bool(_that);case Value_Null() when null_ != null:
return null_(_that);case Value_Function() when function != null:
return function(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Value_Int value)  int,required TResult Function( Value_Float value)  float,required TResult Function( Value_String value)  string,required TResult Function( Value_Bool value)  bool,required TResult Function( Value_Null value)  null_,required TResult Function( Value_Function value)  function,}){
final _that = this;
switch (_that) {
case Value_Int():
return int(_that);case Value_Float():
return float(_that);case Value_String():
return string(_that);case Value_Bool():
return bool(_that);case Value_Null():
return null_(_that);case Value_Function():
return function(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Value_Int value)?  int,TResult? Function( Value_Float value)?  float,TResult? Function( Value_String value)?  string,TResult? Function( Value_Bool value)?  bool,TResult? Function( Value_Null value)?  null_,TResult? Function( Value_Function value)?  function,}){
final _that = this;
switch (_that) {
case Value_Int() when int != null:
return int(_that);case Value_Float() when float != null:
return float(_that);case Value_String() when string != null:
return string(_that);case Value_Bool() when bool != null:
return bool(_that);case Value_Null() when null_ != null:
return null_(_that);case Value_Function() when function != null:
return function(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int field0)?  int,TResult Function( double field0)?  float,TResult Function( String field0)?  string,TResult Function( bool field0)?  bool,TResult Function()?  null_,TResult Function( String name,  List<String> params,  int bodyIndex)?  function,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Value_Int() when int != null:
return int(_that.field0);case Value_Float() when float != null:
return float(_that.field0);case Value_String() when string != null:
return string(_that.field0);case Value_Bool() when bool != null:
return bool(_that.field0);case Value_Null() when null_ != null:
return null_();case Value_Function() when function != null:
return function(_that.name,_that.params,_that.bodyIndex);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int field0)  int,required TResult Function( double field0)  float,required TResult Function( String field0)  string,required TResult Function( bool field0)  bool,required TResult Function()  null_,required TResult Function( String name,  List<String> params,  int bodyIndex)  function,}) {final _that = this;
switch (_that) {
case Value_Int():
return int(_that.field0);case Value_Float():
return float(_that.field0);case Value_String():
return string(_that.field0);case Value_Bool():
return bool(_that.field0);case Value_Null():
return null_();case Value_Function():
return function(_that.name,_that.params,_that.bodyIndex);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int field0)?  int,TResult? Function( double field0)?  float,TResult? Function( String field0)?  string,TResult? Function( bool field0)?  bool,TResult? Function()?  null_,TResult? Function( String name,  List<String> params,  int bodyIndex)?  function,}) {final _that = this;
switch (_that) {
case Value_Int() when int != null:
return int(_that.field0);case Value_Float() when float != null:
return float(_that.field0);case Value_String() when string != null:
return string(_that.field0);case Value_Bool() when bool != null:
return bool(_that.field0);case Value_Null() when null_ != null:
return null_();case Value_Function() when function != null:
return function(_that.name,_that.params,_that.bodyIndex);case _:
  return null;

}
}

}

/// @nodoc


class Value_Int extends Value {
  const Value_Int(this.field0): super._();
  

 final  int field0;

/// Create a copy of Value
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$Value_IntCopyWith<Value_Int> get copyWith => _$Value_IntCopyWithImpl<Value_Int>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Value_Int&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'Value.int(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $Value_IntCopyWith<$Res> implements $ValueCopyWith<$Res> {
  factory $Value_IntCopyWith(Value_Int value, $Res Function(Value_Int) _then) = _$Value_IntCopyWithImpl;
@useResult
$Res call({
 int field0
});




}
/// @nodoc
class _$Value_IntCopyWithImpl<$Res>
    implements $Value_IntCopyWith<$Res> {
  _$Value_IntCopyWithImpl(this._self, this._then);

  final Value_Int _self;
  final $Res Function(Value_Int) _then;

/// Create a copy of Value
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(Value_Int(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class Value_Float extends Value {
  const Value_Float(this.field0): super._();
  

 final  double field0;

/// Create a copy of Value
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$Value_FloatCopyWith<Value_Float> get copyWith => _$Value_FloatCopyWithImpl<Value_Float>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Value_Float&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'Value.float(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $Value_FloatCopyWith<$Res> implements $ValueCopyWith<$Res> {
  factory $Value_FloatCopyWith(Value_Float value, $Res Function(Value_Float) _then) = _$Value_FloatCopyWithImpl;
@useResult
$Res call({
 double field0
});




}
/// @nodoc
class _$Value_FloatCopyWithImpl<$Res>
    implements $Value_FloatCopyWith<$Res> {
  _$Value_FloatCopyWithImpl(this._self, this._then);

  final Value_Float _self;
  final $Res Function(Value_Float) _then;

/// Create a copy of Value
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(Value_Float(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc


class Value_String extends Value {
  const Value_String(this.field0): super._();
  

 final  String field0;

/// Create a copy of Value
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$Value_StringCopyWith<Value_String> get copyWith => _$Value_StringCopyWithImpl<Value_String>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Value_String&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'Value.string(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $Value_StringCopyWith<$Res> implements $ValueCopyWith<$Res> {
  factory $Value_StringCopyWith(Value_String value, $Res Function(Value_String) _then) = _$Value_StringCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$Value_StringCopyWithImpl<$Res>
    implements $Value_StringCopyWith<$Res> {
  _$Value_StringCopyWithImpl(this._self, this._then);

  final Value_String _self;
  final $Res Function(Value_String) _then;

/// Create a copy of Value
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(Value_String(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class Value_Bool extends Value {
  const Value_Bool(this.field0): super._();
  

 final  bool field0;

/// Create a copy of Value
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$Value_BoolCopyWith<Value_Bool> get copyWith => _$Value_BoolCopyWithImpl<Value_Bool>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Value_Bool&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'Value.bool(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $Value_BoolCopyWith<$Res> implements $ValueCopyWith<$Res> {
  factory $Value_BoolCopyWith(Value_Bool value, $Res Function(Value_Bool) _then) = _$Value_BoolCopyWithImpl;
@useResult
$Res call({
 bool field0
});




}
/// @nodoc
class _$Value_BoolCopyWithImpl<$Res>
    implements $Value_BoolCopyWith<$Res> {
  _$Value_BoolCopyWithImpl(this._self, this._then);

  final Value_Bool _self;
  final $Res Function(Value_Bool) _then;

/// Create a copy of Value
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(Value_Bool(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class Value_Null extends Value {
  const Value_Null(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Value_Null);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Value.null_()';
}


}




/// @nodoc


class Value_Function extends Value {
  const Value_Function({required this.name, required final  List<String> params, required this.bodyIndex}): _params = params,super._();
  

 final  String name;
 final  List<String> _params;
 List<String> get params {
  if (_params is EqualUnmodifiableListView) return _params;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_params);
}

/// Index into the program's statement list where the function body lives.
/// The actual body is looked up from the AST during execution.
 final  int bodyIndex;

/// Create a copy of Value
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$Value_FunctionCopyWith<Value_Function> get copyWith => _$Value_FunctionCopyWithImpl<Value_Function>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Value_Function&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._params, _params)&&(identical(other.bodyIndex, bodyIndex) || other.bodyIndex == bodyIndex));
}


@override
int get hashCode => Object.hash(runtimeType,name,const DeepCollectionEquality().hash(_params),bodyIndex);

@override
String toString() {
  return 'Value.function(name: $name, params: $params, bodyIndex: $bodyIndex)';
}


}

/// @nodoc
abstract mixin class $Value_FunctionCopyWith<$Res> implements $ValueCopyWith<$Res> {
  factory $Value_FunctionCopyWith(Value_Function value, $Res Function(Value_Function) _then) = _$Value_FunctionCopyWithImpl;
@useResult
$Res call({
 String name, List<String> params, int bodyIndex
});




}
/// @nodoc
class _$Value_FunctionCopyWithImpl<$Res>
    implements $Value_FunctionCopyWith<$Res> {
  _$Value_FunctionCopyWithImpl(this._self, this._then);

  final Value_Function _self;
  final $Res Function(Value_Function) _then;

/// Create a copy of Value
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? name = null,Object? params = null,Object? bodyIndex = null,}) {
  return _then(Value_Function(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,params: null == params ? _self._params : params // ignore: cast_nullable_to_non_nullable
as List<String>,bodyIndex: null == bodyIndex ? _self.bodyIndex : bodyIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
