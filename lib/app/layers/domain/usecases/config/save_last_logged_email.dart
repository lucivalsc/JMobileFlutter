
import 'package:dartz/dartz.dart';
import 'package:jmobileflutter/app/common/models/failure_models.dart';
import 'package:jmobileflutter/app/common/usecase.dart';
import 'package:jmobileflutter/app/layers/domain/repositories/config_repository.dart';

class SaveLastLoggedEmailUsecase implements Usecase<String, void> {
  final IConfigRepository repository;

  const SaveLastLoggedEmailUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(String email) async {
    return await repository.saveLastLoggedEmail(email);
  }
}
