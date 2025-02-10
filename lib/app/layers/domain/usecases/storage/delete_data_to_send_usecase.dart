import 'package:dartz/dartz.dart';
import 'package:connect_force_app/app/common/models/failure_models.dart';
import 'package:connect_force_app/app/common/usecase.dart';
import 'package:connect_force_app/app/layers/domain/repositories/storage_repository.dart';

class DeleteDataToSendUsecase implements Usecase<List<Object>, void> {
  final IStorageRepository repository;

  const DeleteDataToSendUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(List<Object> objects) async {
    return await repository.deleteDataToSend(objects);
  }
}
