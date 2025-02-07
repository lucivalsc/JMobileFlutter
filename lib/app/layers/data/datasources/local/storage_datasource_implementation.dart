import 'package:hive/hive.dart';
import 'package:jmobileflutter/app/common/models/exception_models.dart';
import 'package:jmobileflutter/app/layers/data/datasources/local/storage_datasource.dart';

class StorageDatasourceImplementation implements IStorageDatasource {
  @override
  Future<Map> loadDataToSend(List<Object> objects) async {
    final environment = objects[0] as String;
    final stakeholderCodext = objects[1] as String;
    final branchID = objects[2] as String;
    final uri = objects[3] as String;
    try {
      final box =
          await Hive.openBox('${environment}_${stakeholderCodext}_${branchID}_${uri}_toSend');
      return box.toMap();
    } catch (e) {
      throw StorageException(message: e.toString());
    }
  }

  @override
  Future<void> saveDataToSend(List<Object> objects) async {
    final environment = objects[0] as String;
    final stakeholderCodext = objects[1] as String;
    final branchID = objects[2] as String;
    final uri = objects[3] as String;
    final map = objects[4] as Map;

    try {
      await Hive.openBox('${environment}_${stakeholderCodext}_${branchID}_${uri}_toSend')
          .then((box) async {
        await box.putAll(map);
        await box.close();
      });
    } catch (e) {
      throw StorageException(message: e.toString());
    }
  }

  @override
  Future<void> deleteDataToSend(List<Object> objects) async {
    final environment = objects[0] as String;
    final stakeholderCodext = objects[1] as String;
    final branchID = objects[2] as String;
    final uri = objects[3] as String;
    final map = objects[4] as Map<String, dynamic>;

    final boxName = '${environment}_${stakeholderCodext}_${branchID}_${uri}_toSend';

    try {
      final box = await Hive.openBox(boxName);

      if (map.containsKey('payload')) {
        final payload = map['payload'];
        if (payload != null) {
          final screen = payload['screen'];
          if (screen != null) {
            await box.delete(screen);
          } else {
            // Lidar com o caso em que 'payload' ou 'screen' é nulo, se necessário.
          }
        } else {
          // Lidar com o caso em que 'payload' é nulo, se necessário.
        }
      } else if (map.containsKey('created')) {
        final screen = map['created'];
        await box.delete(screen);
      }
    } catch (e) {
      throw StorageException(message: e.toString());
    }
  }
}
