import 'package:jmobileflutter/app/common/models/exception_models.dart';
import 'package:jmobileflutter/app/common/models/failure_models.dart';
import 'package:jmobileflutter/app/layers/data/datasources/local/config_datasource.dart';
import 'package:jmobileflutter/app/layers/domain/repositories/config_repository.dart';
import 'package:dartz/dartz.dart';

class ConfigRepositoryImplementation implements IConfigRepository {
  final IConfigDatasource localDatasource;

  ConfigRepositoryImplementation(this.localDatasource);

  @override
  Future<Either<Failure, Map<String, String>?>> loadAddresses() async {
    try {
      final result = await localDatasource.loadAddresses();
      return Right(result);
    } on StorageException catch (e) {
      return Left(Failure(failureType: "StorageFailure", title: e.title, message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> saveAddresses(Map<String, String> map) async {
    try {
      await localDatasource.saveAddresses(map);
      return const Right(null);
    } on StorageException catch (e) {
      return Left(Failure(failureType: "StorageFailure", title: e.title, message: e.message));
    }
  }

  @override
  Future<Either<Failure, String?>> loadLastLoggedEmail() async {
    try {
      final result = await localDatasource.loadLastLoggedEmail();
      return Right(result);
    } on StorageException catch (e) {
      return Left(Failure(failureType: "StorageFailure", title: e.title, message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> saveLastLoggedEmail(String email) async {
    try {
      await localDatasource.saveLastLoggedEmail(email);
      return const Right(null);
    } on StorageException catch (e) {
      return Left(Failure(failureType: "StorageFailure", title: e.title, message: e.message));
    }
  }

  @override
  Future<Either<Failure, String?>> loadLastLoggedPassword() async {
    try {
      final result = await localDatasource.loadLastLoggedPassword();
      return Right(result);
    } on StorageException catch (e) {
      return Left(Failure(failureType: "StorageFailure", title: e.title, message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> saveLastLoggedPassword(String password) async {
    try {
      await localDatasource.saveLastLoggedPassword(password);
      return const Right(null);
    } on StorageException catch (e) {
      return Left(Failure(failureType: "StorageFailure", title: e.title, message: e.message));
    }
  }

  @override
  Future<Either<Failure, String>> version() async {
    try {
      String result = await localDatasource.version();
      return Right(result);
    } on StorageException catch (e) {
      return Left(Failure(failureType: "StorageFailure", title: e.title, message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> company(String value) async {
    try {
      await localDatasource.company(value);
      return const Right(null);
    } on StorageException catch (e) {
      return Left(Failure(failureType: "StorageFailure", title: e.title, message: e.message));
    }
  }

  @override
  Future<Either<Failure, String>> loadCompany() async {
    try {
      String result = await localDatasource.loadCompany();
      return Right(result);
    } on StorageException catch (e) {
      return Left(Failure(failureType: "StorageFailure", title: e.title, message: e.message));
    }
  }

  
  @override
  Future<Either<Failure, void>> saveConfig(String value) async {
    try {
      await localDatasource.saveConfig(value);
      return const Right(null);
    } on StorageException catch (e) {
      return Left(Failure(failureType: "StorageFailure", title: e.title, message: e.message));
    }
  }

  @override
  Future<Either<Failure, String>> loadConfig() async {
    try {
      String result = await localDatasource.loadConfig();
      return Right(result);
    } on StorageException catch (e) {
      return Left(Failure(failureType: "StorageFailure", title: e.title, message: e.message));
    }
  }
}
