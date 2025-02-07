import 'package:equatable/equatable.dart';

class ServerException extends Equatable implements Exception {
  final int? id, statusCode;
  final String? title, message;

  const ServerException({this.id, this.statusCode, this.title, this.message});

  @override
  List<Object?> get props => [id, statusCode, title, message];
}

class StorageException extends Equatable implements Exception {
  final int? id;
  final String? title, message;

  const StorageException({this.id, this.title, this.message});

  @override
  List<Object?> get props => [id, title, message];
}
