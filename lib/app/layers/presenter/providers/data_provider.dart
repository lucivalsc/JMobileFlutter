import 'dart:async';
import 'package:jmobileflutter/app/layers/domain/usecases/data/datas_usecase.dart';
import 'package:jmobileflutter/app/layers/domain/usecases/data/synchronous_usecase.dart';
import 'package:jmobileflutter/app/layers/domain/usecases/storage/delete_data_to_send_usecase.dart';
import 'package:jmobileflutter/app/layers/domain/usecases/storage/load_data_to_send_usecase.dart';
import 'package:jmobileflutter/app/layers/domain/usecases/storage/save_data_to_send_usecase.dart';
import 'package:jmobileflutter/app/layers/presenter/logged_in/failure_screen.dart';
import 'package:jmobileflutter/app/layers/presenter/logged_in/successful_screen.dart';
import 'package:jmobileflutter/app/layers/presenter/providers/auth_provider.dart';
import 'package:jmobileflutter/app/layers/presenter/providers/config_provider.dart';
import 'package:jmobileflutter/app/layers/presenter/providers/user_provider.dart';
import 'package:jmobileflutter/navigation.dart';
import 'package:flutter/material.dart';

class DataProvider extends ChangeNotifier {
  final DatasUsecase _datasUsecase;
  final LoadDataToSendUsecase _loadDataToSendUsecase;
  final SaveDataToSendUsecase _saveDataToSendUsecase;
  final DeleteDataToSendUsecase _deleteDataToSendUsecase;
  final SynchronousUsecase _synchronousUsecase;
  DataProvider(
    this._datasUsecase,
    this._loadDataToSendUsecase,
    this._saveDataToSendUsecase,
    this._deleteDataToSendUsecase,
    this._synchronousUsecase,
  );

  late ConfigProvider _configProvider;
  late UserProvider userProvider;
  late AuthProvider authProvider;
  void setConfigProvider(ConfigProvider provider) => _configProvider = provider;
  void setUserProvider(UserProvider provider) => userProvider = provider;
  void setAuthProvider(AuthProvider provider) => authProvider = provider;

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  int selectedMonthIndex = 0;
  // int selectedButtonIndex = 0;
  // String pInicio = '';
  // String pFinal = '';

  Future<Map> loadDataToSend({
    required String uri,
  }) async {
    final result = await _loadDataToSendUsecase([
      _configProvider.environment,
      '0',
      '0',
      uri,
    ]);
    return result.fold(
      (l) => {},
      (r) => r,
    );
  }

  Future<void> saveDataToSend(
    BuildContext context, {
    required String uri,
    required Map payload,
    bool forceMultipart = false,
  }) async {
    // await authProvider.checkAccessToken(context, true);
    final result = await _saveDataToSendUsecase([
      _configProvider.environment,
      '0',
      '0',
      uri,
      payload,
      forceMultipart,
    ]);
    result.fold(
      (l) => push(
        context,
        FailureScreen(
          failureType: l.failureType,
          title: l.title,
          message: l.message,
        ),
      ),
      (r) => {},
    );
  }

  Future<void> deleteDataToSend(BuildContext context,
      {required String uri, required Map payload, bool forceMultipart = false}) async {
    // await authProvider.checkAccessToken(context, true);
    final result = await _deleteDataToSendUsecase([
      _configProvider.environment,
      '0',
      '0',
      uri,
      payload.entries.first.value,
      forceMultipart,
    ]);
    result.fold(
      (l) => push(
        context,
        FailureScreen(
          failureType: l.failureType,
          title: l.title,
          message: l.message,
        ),
      ),
      (r) => {},
    );
  }

  Future<void> synchronous(BuildContext context) async {
    final result = await _synchronousUsecase([]);
    result.fold(
      (l) => push(
        context,
        FailureScreen(
          failureType: l.failureType,
          title: l.title,
          message: l.message,
        ),
      ),
      (r) => push(
        context,
        SuccessfulScreen(description: 'Sincronizado com sucesso!'),
      ),
    );
  }

  void notify() {
    notifyListeners();
  }

  static of(BuildContext context) {}
}
