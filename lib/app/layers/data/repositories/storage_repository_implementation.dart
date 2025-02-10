import 'package:connect_force_app/app/common/models/exception_models.dart';
import 'package:connect_force_app/app/common/models/failure_models.dart';
import 'package:connect_force_app/app/layers/data/datasources/local/storage_datasource.dart';
import 'package:dartz/dartz.dart';
import 'package:connect_force_app/app/layers/domain/repositories/storage_repository.dart';

class StorageRepositoryImplementation implements IStorageRepository {
  final IStorageDatasource datasource;

  StorageRepositoryImplementation(this.datasource);

  @override
  Future<Either<Failure, void>> saveDataToSend(List<Object> objects) async {
    try {
      await datasource.saveDataToSend(objects);
      return const Right(null);
    } on StorageException catch (e) {
      return Left(Failure(failureType: "StorageFailure", title: e.title, message: e.message));
    }
  }

  @override
  Future<Either<Failure, Map>> loadDataToSend(List<Object> objects) async {
    try {
      final result = await datasource.loadDataToSend(objects);
      return Right(result);
    } on StorageException catch (e) {
      return Left(Failure(failureType: "StorageFailure", title: e.title, message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDataToSend(List<Object> objects) async {
    try {
      await datasource.deleteDataToSend(objects);
      return const Right(null);
    } on StorageException catch (e) {
      return Left(Failure(failureType: "StorageFailure", title: e.title, message: e.message));
    }
  }
}
