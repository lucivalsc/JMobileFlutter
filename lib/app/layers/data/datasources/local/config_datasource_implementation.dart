import 'package:hive/hive.dart';
import 'package:jmobileflutter/app/common/models/exception_models.dart';
import 'package:jmobileflutter/app/common/utils/cryptography.dart';
import 'package:jmobileflutter/app/layers/data/datasources/local/config_datasource.dart';
// import 'package:package_info/package_info.dart';

class ConfigDatasourceImplementation implements IConfigDatasource {
  @override
  Future<Map<String, String>?> loadAddresses() async {
    try {
      final box = await Hive.openBox('configProviderState');
      return box.get('addresses');
    } catch (e) {
      throw StorageException(message: e.toString());
    }
  }

  @override
  Future<void> saveAddresses(Map<String, String> strings) async {
    try {
      final box = await Hive.openBox('configProviderState');
      await box.put('addresses', strings);
    } catch (e) {
      throw StorageException(message: e.toString());
    }
  }

  @override
  Future<String?> loadLastLoggedEmail() async {
    try {
      final box = await Hive.openBox('configProviderState');
      return box.get('lastLoggedEmail');
    } catch (e) {
      throw StorageException(message: e.toString());
    }
  }

  @override
  Future<void> saveLastLoggedEmail(String address) async {
    try {
      final box = await Hive.openBox('configProviderState');
      await box.put('lastLoggedEmail', address);
    } catch (e) {
      throw StorageException(message: e.toString());
    }
  }

  @override
  Future<String?> loadLastLoggedPassword() async {
    try {
      final password =
          await Hive.openBox('configProviderState').then((box) => box.get('lastLoggedPassword'));
      if (password != null) {
        return Cryptography.decrypt(password);
      } else {
        return "";
      }
    } catch (e) {
      throw StorageException(message: e.toString());
    }
  }

  @override
  Future<void> saveLastLoggedPassword(String address) async {
    try {
      final box = await Hive.openBox('configProviderState');
      await box.put('lastLoggedPassword', Cryptography.encrypt(address));
    } catch (e) {
      throw StorageException(message: e.toString());
    }
  }

  @override
  Future<String> version() async {
    try {
      // var info = await PackageInfo.fromPlatform();
      // return '${info.version}.${info.buildNumber}';
      return '';
    } catch (e) {
      throw StorageException(message: e.toString());
    }
  }

  @override
  Future<void> company(String value) async {
    try {
      final box = await Hive.openBox('configProviderState');
      await box.put('company', value);
    } catch (e) {
      throw StorageException(message: e.toString());
    }
  }

  @override
  Future<String> loadCompany() async {
    try {
      final value = await Hive.openBox('configProviderState').then((box) => box.get('company'));
      return value ?? '';
    } catch (e) {
      throw StorageException(message: e.toString());
    }
  }

  @override
  Future<void> saveConfig(String value) async {
    try {
      final box = await Hive.openBox('configProviderState');
      await box.put('config', value);
    } catch (e) {
      throw StorageException(message: e.toString());
    }
  }

  @override
  Future<String> loadConfig() async {
    try {
      final value = await Hive.openBox('configProviderState').then((box) => box.get('config'));
      return value ?? '';
    } catch (e) {
      throw StorageException(message: e.toString());
    }
  }
}
