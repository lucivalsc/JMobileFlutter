import "package:dartz/dartz.dart";
import "package:equatable/equatable.dart";

import "models/failure_models.dart";

abstract class Usecase<Input, Output> {
  Future<Either<Failure, Output>> call(Input params);
}

class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}
