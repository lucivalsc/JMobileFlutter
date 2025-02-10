import 'package:flutter/material.dart';
import 'package:connect_force_app/app/layers/data/datasources/local/banco_datasource_implementation.dart';
import 'package:connect_force_app/app/layers/presenter/providers/config_provider.dart';

class UserProvider extends ChangeNotifier {
  Databasepadrao banco = Databasepadrao.instance;
  late ConfigProvider configProvider;
  UserProvider();
  void setConfigProvider(ConfigProvider provider) => configProvider = provider;

  bool hasInternet = true, wasSomethingSaved = false, wasSomethingDeleted = false, hasSomethingToDownload = false;
  bool hasSomethingToUpload = false, hasWarnedSomethingToUpload = false;
  Future<bool> checkIfUserHasSomethingToUpload() async {
    List<Map> mobileCliente = await banco.consultarDadosDinamico('MOBILE_CLIENTE', 'LAST_CHANGE');
    List<Map> mobileContatos = await banco.consultarDadosDinamico('MOBILE_CONTATOS', 'LAST_CHANGE');
    List<Map> mobileItemPedido = await banco.consultarDadosDinamico('MOBILE_ITEMPEDIDO', 'DATAHORAMOBILE');
    List<Map> mobilePedido = await banco.consultarDadosDinamico('MOBILE_PEDIDO', 'DATAMOBILE');

    if (mobileCliente.isNotEmpty ||
        mobileContatos.isNotEmpty ||
        mobileItemPedido.isNotEmpty ||
        mobilePedido.isNotEmpty) {
      hasWarnedSomethingToUpload = false;
      hasSomethingToUpload = true;
      notifyListeners();
      return true;
    } else {
      hasWarnedSomethingToUpload = true;
      hasSomethingToUpload = false;
      return false;
    }
  }
}
