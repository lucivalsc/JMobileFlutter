import 'package:dartz/dartz.dart';
import 'package:jmobileflutter/app/common/models/failure_models.dart';
import 'package:jmobileflutter/app/common/usecase.dart';
import 'package:jmobileflutter/app/layers/domain/repositories/storage_repository.dart';

class DeleteDataToSendUsecase implements Usecase<List<Object>, void> {
  final IStorageRepository repository;

  const DeleteDataToSendUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(List<Object> objects) async {
    return await repository.deleteDataToSend(objects);
  }
}
