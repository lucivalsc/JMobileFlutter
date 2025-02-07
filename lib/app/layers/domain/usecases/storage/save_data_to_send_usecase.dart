import 'package:dartz/dartz.dart';
import 'package:jmobileflutter/app/common/models/failure_models.dart';
import 'package:jmobileflutter/app/common/usecase.dart';
import 'package:jmobileflutter/app/layers/domain/repositories/storage_repository.dart';

class SaveDataToSendUsecase implements Usecase<List<Object>, void> {
  final IStorageRepository repository;

  const SaveDataToSendUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(List<Object> objects) async {
    return await repository.saveDataToSend(objects);
  }
}
