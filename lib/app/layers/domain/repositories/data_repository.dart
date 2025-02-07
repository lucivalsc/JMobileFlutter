import 'package:dartz/dartz.dart';
import 'package:jmobileflutter/app/common/models/failure_models.dart';

abstract class IDataRepository {
  Future<Either<Failure, List<Object>>> datas(List<Object> strings);
  Future<Either<Failure, List<Object>>> responseType(List<Object> strings);
  Future<Either<Failure, List<Object>>> synchronous(List<Object> strings);
}
