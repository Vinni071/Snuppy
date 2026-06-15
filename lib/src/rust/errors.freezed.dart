// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'errors.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CompileError {

 String get message; Span? get span;
/// Create a copy of CompileError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompileErrorCopyWith<CompileError> get copyWith => _$CompileErrorCopyWithImpl<CompileError>(this as CompileError, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompileError&&(identical(other.message, message) || other.message == message)&&(identical(other.span, span) || other.span == span));
}


@override
int get hashCode => Object.hash(runtimeType,message,span);

@override
String toString() {
  return 'CompileError(message: $message, span: $span)';
}


}

/// @nodoc
abstract mixin class $CompileErrorCopyWith<$Res>  {
  factory $CompileErrorCopyWith(CompileError value, $Res Function(CompileError) _then) = _$CompileErrorCopyWithImpl;
@useResult
$Res call({
 String message, Span? span
});




}
/// @nodoc
class _$CompileErrorCopyWithImpl<$Res>
    implements $CompileErrorCopyWith<$Res> {
  _$CompileErrorCopyWithImpl(this._self, this._then);

  final CompileError _self;
  final $Res Function(CompileError) _then;

/// Create a copy of CompileError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,Object? span = freezed,}) {
  return _then(_self.copyWith(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,span: freezed == span ? _self.span : span // ignore: cast_nullable_to_non_nullable
as Span?,
  ));
}

}


/// Adds pattern-matching-related methods to [CompileError].
extension CompileErrorPatterns on CompileError {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CompileError_LexerError value)?  lexerError,TResult Function( CompileError_ParserError value)?  parserError,TResult Function( CompileError_SemanticError value)?  semanticError,TResult Function( CompileError_RuntimeError value)?  runtimeError,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CompileError_LexerError() when lexerError != null:
return lexerError(_that);case CompileError_ParserError() when parserError != null:
return parserError(_that);case CompileError_SemanticError() when semanticError != null:
return semanticError(_that);case CompileError_RuntimeError() when runtimeError != null:
return runtimeError(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CompileError_LexerError value)  lexerError,required TResult Function( CompileError_ParserError value)  parserError,required TResult Function( CompileError_SemanticError value)  semanticError,required TResult Function( CompileError_RuntimeError value)  runtimeError,}){
final _that = this;
switch (_that) {
case CompileError_LexerError():
return lexerError(_that);case CompileError_ParserError():
return parserError(_that);case CompileError_SemanticError():
return semanticError(_that);case CompileError_RuntimeError():
return runtimeError(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CompileError_LexerError value)?  lexerError,TResult? Function( CompileError_ParserError value)?  parserError,TResult? Function( CompileError_SemanticError value)?  semanticError,TResult? Function( CompileError_RuntimeError value)?  runtimeError,}){
final _that = this;
switch (_that) {
case CompileError_LexerError() when lexerError != null:
return lexerError(_that);case CompileError_ParserError() when parserError != null:
return parserError(_that);case CompileError_SemanticError() when semanticError != null:
return semanticError(_that);case CompileError_RuntimeError() when runtimeError != null:
return runtimeError(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String message,  Span? span)?  lexerError,TResult Function( String message,  Span? span,  List<String> expected)?  parserError,TResult Function( String message,  Span? span,  String? suggestion)?  semanticError,TResult Function( String message,  Span? span,  List<String> callStack)?  runtimeError,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CompileError_LexerError() when lexerError != null:
return lexerError(_that.message,_that.span);case CompileError_ParserError() when parserError != null:
return parserError(_that.message,_that.span,_that.expected);case CompileError_SemanticError() when semanticError != null:
return semanticError(_that.message,_that.span,_that.suggestion);case CompileError_RuntimeError() when runtimeError != null:
return runtimeError(_that.message,_that.span,_that.callStack);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String message,  Span? span)  lexerError,required TResult Function( String message,  Span? span,  List<String> expected)  parserError,required TResult Function( String message,  Span? span,  String? suggestion)  semanticError,required TResult Function( String message,  Span? span,  List<String> callStack)  runtimeError,}) {final _that = this;
switch (_that) {
case CompileError_LexerError():
return lexerError(_that.message,_that.span);case CompileError_ParserError():
return parserError(_that.message,_that.span,_that.expected);case CompileError_SemanticError():
return semanticError(_that.message,_that.span,_that.suggestion);case CompileError_RuntimeError():
return runtimeError(_that.message,_that.span,_that.callStack);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String message,  Span? span)?  lexerError,TResult? Function( String message,  Span? span,  List<String> expected)?  parserError,TResult? Function( String message,  Span? span,  String? suggestion)?  semanticError,TResult? Function( String message,  Span? span,  List<String> callStack)?  runtimeError,}) {final _that = this;
switch (_that) {
case CompileError_LexerError() when lexerError != null:
return lexerError(_that.message,_that.span);case CompileError_ParserError() when parserError != null:
return parserError(_that.message,_that.span,_that.expected);case CompileError_SemanticError() when semanticError != null:
return semanticError(_that.message,_that.span,_that.suggestion);case CompileError_RuntimeError() when runtimeError != null:
return runtimeError(_that.message,_that.span,_that.callStack);case _:
  return null;

}
}

}

/// @nodoc


class CompileError_LexerError extends CompileError {
  const CompileError_LexerError({required this.message, this.span}): super._();
  

@override final  String message;
@override final  Span? span;

/// Create a copy of CompileError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompileError_LexerErrorCopyWith<CompileError_LexerError> get copyWith => _$CompileError_LexerErrorCopyWithImpl<CompileError_LexerError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompileError_LexerError&&(identical(other.message, message) || other.message == message)&&(identical(other.span, span) || other.span == span));
}


@override
int get hashCode => Object.hash(runtimeType,message,span);

@override
String toString() {
  return 'CompileError.lexerError(message: $message, span: $span)';
}


}

/// @nodoc
abstract mixin class $CompileError_LexerErrorCopyWith<$Res> implements $CompileErrorCopyWith<$Res> {
  factory $CompileError_LexerErrorCopyWith(CompileError_LexerError value, $Res Function(CompileError_LexerError) _then) = _$CompileError_LexerErrorCopyWithImpl;
@override @useResult
$Res call({
 String message, Span? span
});




}
/// @nodoc
class _$CompileError_LexerErrorCopyWithImpl<$Res>
    implements $CompileError_LexerErrorCopyWith<$Res> {
  _$CompileError_LexerErrorCopyWithImpl(this._self, this._then);

  final CompileError_LexerError _self;
  final $Res Function(CompileError_LexerError) _then;

/// Create a copy of CompileError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? span = freezed,}) {
  return _then(CompileError_LexerError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,span: freezed == span ? _self.span : span // ignore: cast_nullable_to_non_nullable
as Span?,
  ));
}


}

/// @nodoc


class CompileError_ParserError extends CompileError {
  const CompileError_ParserError({required this.message, this.span, required final  List<String> expected}): _expected = expected,super._();
  

@override final  String message;
@override final  Span? span;
 final  List<String> _expected;
 List<String> get expected {
  if (_expected is EqualUnmodifiableListView) return _expected;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_expected);
}


/// Create a copy of CompileError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompileError_ParserErrorCopyWith<CompileError_ParserError> get copyWith => _$CompileError_ParserErrorCopyWithImpl<CompileError_ParserError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompileError_ParserError&&(identical(other.message, message) || other.message == message)&&(identical(other.span, span) || other.span == span)&&const DeepCollectionEquality().equals(other._expected, _expected));
}


@override
int get hashCode => Object.hash(runtimeType,message,span,const DeepCollectionEquality().hash(_expected));

@override
String toString() {
  return 'CompileError.parserError(message: $message, span: $span, expected: $expected)';
}


}

/// @nodoc
abstract mixin class $CompileError_ParserErrorCopyWith<$Res> implements $CompileErrorCopyWith<$Res> {
  factory $CompileError_ParserErrorCopyWith(CompileError_ParserError value, $Res Function(CompileError_ParserError) _then) = _$CompileError_ParserErrorCopyWithImpl;
@override @useResult
$Res call({
 String message, Span? span, List<String> expected
});




}
/// @nodoc
class _$CompileError_ParserErrorCopyWithImpl<$Res>
    implements $CompileError_ParserErrorCopyWith<$Res> {
  _$CompileError_ParserErrorCopyWithImpl(this._self, this._then);

  final CompileError_ParserError _self;
  final $Res Function(CompileError_ParserError) _then;

/// Create a copy of CompileError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? span = freezed,Object? expected = null,}) {
  return _then(CompileError_ParserError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,span: freezed == span ? _self.span : span // ignore: cast_nullable_to_non_nullable
as Span?,expected: null == expected ? _self._expected : expected // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class CompileError_SemanticError extends CompileError {
  const CompileError_SemanticError({required this.message, this.span, this.suggestion}): super._();
  

@override final  String message;
@override final  Span? span;
 final  String? suggestion;

/// Create a copy of CompileError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompileError_SemanticErrorCopyWith<CompileError_SemanticError> get copyWith => _$CompileError_SemanticErrorCopyWithImpl<CompileError_SemanticError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompileError_SemanticError&&(identical(other.message, message) || other.message == message)&&(identical(other.span, span) || other.span == span)&&(identical(other.suggestion, suggestion) || other.suggestion == suggestion));
}


@override
int get hashCode => Object.hash(runtimeType,message,span,suggestion);

@override
String toString() {
  return 'CompileError.semanticError(message: $message, span: $span, suggestion: $suggestion)';
}


}

/// @nodoc
abstract mixin class $CompileError_SemanticErrorCopyWith<$Res> implements $CompileErrorCopyWith<$Res> {
  factory $CompileError_SemanticErrorCopyWith(CompileError_SemanticError value, $Res Function(CompileError_SemanticError) _then) = _$CompileError_SemanticErrorCopyWithImpl;
@override @useResult
$Res call({
 String message, Span? span, String? suggestion
});




}
/// @nodoc
class _$CompileError_SemanticErrorCopyWithImpl<$Res>
    implements $CompileError_SemanticErrorCopyWith<$Res> {
  _$CompileError_SemanticErrorCopyWithImpl(this._self, this._then);

  final CompileError_SemanticError _self;
  final $Res Function(CompileError_SemanticError) _then;

/// Create a copy of CompileError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? span = freezed,Object? suggestion = freezed,}) {
  return _then(CompileError_SemanticError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,span: freezed == span ? _self.span : span // ignore: cast_nullable_to_non_nullable
as Span?,suggestion: freezed == suggestion ? _self.suggestion : suggestion // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class CompileError_RuntimeError extends CompileError {
  const CompileError_RuntimeError({required this.message, this.span, required final  List<String> callStack}): _callStack = callStack,super._();
  

@override final  String message;
@override final  Span? span;
 final  List<String> _callStack;
 List<String> get callStack {
  if (_callStack is EqualUnmodifiableListView) return _callStack;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_callStack);
}


/// Create a copy of CompileError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompileError_RuntimeErrorCopyWith<CompileError_RuntimeError> get copyWith => _$CompileError_RuntimeErrorCopyWithImpl<CompileError_RuntimeError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompileError_RuntimeError&&(identical(other.message, message) || other.message == message)&&(identical(other.span, span) || other.span == span)&&const DeepCollectionEquality().equals(other._callStack, _callStack));
}


@override
int get hashCode => Object.hash(runtimeType,message,span,const DeepCollectionEquality().hash(_callStack));

@override
String toString() {
  return 'CompileError.runtimeError(message: $message, span: $span, callStack: $callStack)';
}


}

/// @nodoc
abstract mixin class $CompileError_RuntimeErrorCopyWith<$Res> implements $CompileErrorCopyWith<$Res> {
  factory $CompileError_RuntimeErrorCopyWith(CompileError_RuntimeError value, $Res Function(CompileError_RuntimeError) _then) = _$CompileError_RuntimeErrorCopyWithImpl;
@override @useResult
$Res call({
 String message, Span? span, List<String> callStack
});




}
/// @nodoc
class _$CompileError_RuntimeErrorCopyWithImpl<$Res>
    implements $CompileError_RuntimeErrorCopyWith<$Res> {
  _$CompileError_RuntimeErrorCopyWithImpl(this._self, this._then);

  final CompileError_RuntimeError _self;
  final $Res Function(CompileError_RuntimeError) _then;

/// Create a copy of CompileError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? span = freezed,Object? callStack = null,}) {
  return _then(CompileError_RuntimeError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,span: freezed == span ? _self.span : span // ignore: cast_nullable_to_non_nullable
as Span?,callStack: null == callStack ? _self._callStack : callStack // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
