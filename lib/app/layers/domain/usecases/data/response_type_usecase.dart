import 'package:dartz/dartz.dart';
import 'package:connect_force_app/app/common/models/failure_models.dart';
import 'package:connect_force_app/app/common/usecase.dart';
import 'package:connect_force_app/app/layers/domain/repositories/data_repository.dart';

class ResponseTypeUsecase implements Usecase<List<Object>, List<Object>> {
  final IDataRepository repository;

  const ResponseTypeUsecase(this.repository);

  @override
  Future<Either<Failure, List<Object>>> call(List<Object> objects) async {
    return await repository.responseType(objects);
  }
}
