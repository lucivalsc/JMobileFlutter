import 'package:dartz/dartz.dart';
import 'package:connect_force_app/app/common/models/failure_models.dart';
import 'package:connect_force_app/app/common/usecase.dart';
import 'package:connect_force_app/app/layers/domain/repositories/storage_repository.dart';

class SaveDataToSendUsecase implements Usecase<List<Object>, void> {
  final IStorageRepository repository;

  const SaveDataToSendUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(List<Object> objects) async {
    return await repository.saveDataToSend(objects);
  }
}
