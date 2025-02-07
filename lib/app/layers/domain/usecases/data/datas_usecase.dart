import 'package:dartz/dartz.dart';
import 'package:jmobileflutter/app/common/models/failure_models.dart';
import 'package:jmobileflutter/app/common/usecase.dart';
import 'package:jmobileflutter/app/layers/domain/repositories/data_repository.dart';

class DatasUsecase implements Usecase<List<Object>, List<Object>> {
  final IDataRepository repository;

  const DatasUsecase(this.repository);

  @override
  Future<Either<Failure, List<Object>>> call(List<Object> objects) async {
    return await repository.datas(objects);
  }
}
