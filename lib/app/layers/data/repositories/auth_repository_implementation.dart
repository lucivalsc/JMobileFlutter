import 'package:dartz/dartz.dart';

import '../../../common/models/exception_models.dart';
import '../../../common/models/failure_models.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_datasource.dart';

class AuthRepositoryImplementation implements IAuthRepository {
  final IAuthDatasource datasource;

  AuthRepositoryImplementation(this.datasource);

  @override
  Future<Either<Failure, List<Object>>> signIn(List<Object> object) async {
    try {
      final result = await datasource.signIn(object);
      return Right(result);
    } on ServerException catch (e) {
      return Left(
        Failure(
          failureType: "ServerFailure",
          title: e.title,
          message: e.message,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<Object>>> alterPassword(List<Object> object) async {
    try {
      final result = await datasource.alterPassword(object);
      return Right(result);
    } on ServerException catch (e) {
      return Left(
        Failure(
          failureType: "ServerFailure",
          title: e.title,
          message: e.message,
        ),
      );
    }
  }
}
