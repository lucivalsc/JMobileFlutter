import 'dart:async';
import 'dart:convert';

import 'package:connect_force_app/app/layers/data/datasources/local/banco_datasource_implementation.dart';
import 'package:connect_force_app/app/layers/domain/usecases/data/datas_usecase.dart';
import 'package:connect_force_app/app/layers/domain/usecases/data/synchronous_usecase.dart';
import 'package:connect_force_app/app/layers/domain/usecases/storage/delete_data_to_send_usecase.dart';
import 'package:connect_force_app/app/layers/domain/usecases/storage/load_data_to_send_usecase.dart';
import 'package:connect_force_app/app/layers/domain/usecases/storage/save_data_to_send_usecase.dart';
import 'package:connect_force_app/app/layers/presenter/logged_in/failure_screen.dart';
import 'package:connect_force_app/app/layers/presenter/logged_in/successful_screen.dart';
import 'package:connect_force_app/app/layers/presenter/providers/auth_provider.dart';
import 'package:connect_force_app/app/layers/presenter/providers/config_provider.dart';
import 'package:connect_force_app/app/layers/presenter/providers/user_provider.dart';
import 'package:connect_force_app/navigation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

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

  final Databasepadrao banco = Databasepadrao.instance;
  late ConfigProvider _configProvider;
  late UserProvider userProvider;
  late AuthProvider authProvider;
  void setConfigProvider(ConfigProvider provider) => _configProvider = provider;
  void setUserProvider(UserProvider provider) => userProvider = provider;
  void setAuthProvider(AuthProvider provider) => authProvider = provider;

  // Variável para armazenar o status de envio de dados
  bool isSendData = false;

  changeSendData(bool value) {
    isSendData = value;
    notifyListeners();
  }

  // Lista de opções para tipo de pedido
  final List tipoPedido = [
    {'id': 1, 'text': 'Recebido'},
    {'id': 2, 'text': 'Não Recebido'}
  ];

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  int selectedMonthIndex = 0;

  Position? currentPosition;
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  // Adicione um StreamSubscription para monitorar a localização
  StreamSubscription<Position>? positionStreamSubscription;

  Future<void> getCurrentLocation(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('O serviço de localização está desativado.')),
      // );
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permissão de localização negada.')),
        );
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permissão de localização negada permanentemente.')),
      );
      return;
    }
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    // setState(() {
    currentPosition = position;
    latitudeController.text = position.latitude.toString();
    longitudeController.text = position.longitude.toString();
    // });
    notify();
  }

  void startListeningToLocationChanges(BuildContext context) {
    positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Atualiza a cada 10 metros de mudança
      ),
    ).listen((Position position) {
      // setState(() {
      currentPosition = position;
      latitudeController.text = position.latitude.toString();
      longitudeController.text = position.longitude.toString();
      // });
      notify();
    });

    // Detecta quando o serviço de localização é desativado
    Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      if (status == ServiceStatus.disabled) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('O serviço de localização foi desativado.')),
        // );
      }
    });
  }

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

  Future<void> synchronous(BuildContext context, {String key = 'start', bool showMessage = true}) async {
    final result = await _synchronousUsecase([
      key,
      -1,
      -1,
    ]);
    result.fold(
      (l) => showMessage
          ? push(
              context,
              FailureScreen(
                failureType: l.failureType,
                title: l.title,
                message: l.message,
              ),
            )
          : null,
      (r) => showMessage
          ? push(
              context,
              SuccessfulScreen(description: 'Sincronizado com sucesso!'),
            )
          : null,
    );
  }

  Future<List<Object>> datasResponse(
    BuildContext context, {
    String method = 'GET',
    String route = '',
    Map<String, dynamic>? payLoad,
    bool showMessage = true,
  }) async {
    final result = await _datasUsecase([
      method,
      route,
      payLoad ?? Map<String, dynamic>.from({}),
    ]);
    return result.fold(
      (l) async {
        if (showMessage) {
          await push(
            context,
            FailureScreen(
              failureType: l.failureType,
              title: l.title,
              message: l.message,
            ),
          );
        }

        return [];
      },
      (r) => r,
    );
  }

  Future<bool> enviarDados(
    BuildContext context, {
    required String tabela,
    required String campo,
    required String route,
  }) async {
    try {
      List<Object> enviadoComSucesso = [];
      // Consulta os dados onde o campo é nulo ou vazio
      List dados = await banco.consultarDadosDinamico(tabela, campo);

      if (dados.isEmpty) {
        return false; // Nenhum dado para enviar
      }

      // Convertendo todos os valores para String e substituindo strings vazias por ' '
      dados = dados.map((item) {
        return item.map((key, value) {
          String newValue = (value?.toString() ?? '').isEmpty ? ' ' : value.toString();
          if (key == 'DATAHORAMOBILE') {
            return MapEntry(key, DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()));
          } else if (key == 'DATAMOBILE') {
            return MapEntry(key, DateFormat('yyyy-MM-dd').format(DateTime.now()));
          }
          return MapEntry(key, newValue);
        });
      }).toList();

      // Envia os dados via evento
      for (var element in dados) {
        print(jsonEncode(element));
        var dbmPost = jsonEncode(
          {
            "entity": tabela,
            "in_insert": true,
            "new_id": false,
            "select": [element] // Mantém como Map
          },
        );

        enviadoComSucesso = await datasResponse(
          context,
          route: 'dbm',
          method: 'POST',
          payLoad: jsonDecode(dbmPost),
        );
      }
      if (enviadoComSucesso.isNotEmpty) {
        // Atualiza o campo com a data/hora atual
        await banco.atualizarDadosDinamico(tabela, campo);
        changeSendData(true);
        return true;
      } else {
        changeSendData(false);
        return false; // Falha ao enviar os dados
      }
    } catch (e) {
      print('Erro ao enviar dados: $e');
      return false;
    }
  }

  void notify() {
    notifyListeners();
  }

  static of(BuildContext context) {}
}
