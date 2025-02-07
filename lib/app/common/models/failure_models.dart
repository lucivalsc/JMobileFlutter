import "package:equatable/equatable.dart";

class Failure extends Equatable {
  final String failureType;
  final String? title;
  final String? message;

  const Failure({required this.failureType, this.title, this.message});

  @override
  List<Object?> get props => [failureType, title, message];
}
