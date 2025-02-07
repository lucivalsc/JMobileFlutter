import '../../../../common/models/failure_models.dart';
import '../../../../common/usecase.dart';
import 'package:dartz/dartz.dart';

import '../../repositories/auth_repository.dart';

class SignInUsecase implements Usecase<List<String>, List<Object>> {
  final IAuthRepository repository;

  const SignInUsecase(this.repository);

  @override
  Future<Either<Failure, List<Object>>> call(List<Object> object) async {
    return await repository.signIn(object);
  }
}
