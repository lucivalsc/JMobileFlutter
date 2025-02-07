import 'package:dartz/dartz.dart';
import 'package:jmobileflutter/app/common/models/failure_models.dart';

abstract class IStorageRepository {
  Future<Either<Failure, void>> saveDataToSend(List<Object> objects);
  Future<Either<Failure, Map>> loadDataToSend(List<Object> objects);
  Future<Either<Failure, void>> deleteDataToSend(List<Object> objects);
}
