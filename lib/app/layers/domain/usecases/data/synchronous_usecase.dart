import 'package:dartz/dartz.dart';
import 'package:jmobileflutter/app/common/models/failure_models.dart';
import 'package:jmobileflutter/app/common/usecase.dart';
import 'package:jmobileflutter/app/layers/domain/repositories/data_repository.dart';

class SynchronousUsecase implements Usecase<List<Object>, List<Object>> {
  final IDataRepository repository;

  const SynchronousUsecase(this.repository);

  @override
  Future<Either<Failure, List<Object>>> call(List<Object> objects) async {
    return await repository.synchronous(objects);
  }
}
