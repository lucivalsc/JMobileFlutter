
import 'package:dartz/dartz.dart';
import 'package:jmobileflutter/app/common/models/failure_models.dart';
import 'package:jmobileflutter/app/common/usecase.dart';
import 'package:jmobileflutter/app/layers/domain/repositories/config_repository.dart';

class LoadConfigUsecase implements Usecase<NoParams, String> {
  final IConfigRepository repository;

  LoadConfigUsecase(this.repository);

  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    return await repository.loadConfig();
  }
}
