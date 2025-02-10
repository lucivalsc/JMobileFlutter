import 'package:dartz/dartz.dart';
import 'package:connect_force_app/app/common/models/failure_models.dart';

abstract class IConfigRepository {
  Future<Either<Failure, Map<String, String>?>> loadAddresses();
  Future<Either<Failure, void>> saveAddresses(Map<String, String> map);
  Future<Either<Failure, String?>> loadLastLoggedEmail();
  Future<Either<Failure, void>> saveLastLoggedEmail(String email);
  Future<Either<Failure, String?>> loadLastLoggedPassword();
  Future<Either<Failure, void>> saveLastLoggedPassword(String password);
  Future<Either<Failure, String>> version();
  Future<Either<Failure, void>> company(String value);
  Future<Either<Failure, String>> loadCompany();
  Future<Either<Failure, void>> saveConfig(String value);
  Future<Either<Failure, String>> loadConfig();
}
