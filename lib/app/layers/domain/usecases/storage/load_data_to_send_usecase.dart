import 'package:dartz/dartz.dart';
import 'package:jmobileflutter/app/common/models/failure_models.dart';
import 'package:jmobileflutter/app/common/usecase.dart';
import 'package:jmobileflutter/app/layers/domain/repositories/storage_repository.dart';

class LoadDataToSendUsecase implements Usecase<List<Object>, Map> {
  final IStorageRepository repository;

  const LoadDataToSendUsecase(this.repository);

  @override
  Future<Either<Failure, Map>> call(List<Object> objects) async {
    return await repository.loadDataToSend(objects);
  }
}
