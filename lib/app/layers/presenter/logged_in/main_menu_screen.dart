import 'dart:async';
import 'package:connect_force_app/app/common/services/network_status_service.dart';
import 'package:connect_force_app/app/common/styles/app_styles.dart';
import 'package:connect_force_app/app/common/widgets/app_widgets.dart';
import 'package:connect_force_app/app/layers/data/datasources/local/banco_datasource_implementation.dart';
import 'package:connect_force_app/app/layers/presenter/logged_in/main_menu_list.dart';
import 'package:connect_force_app/app/layers/presenter/not_logged_in/login_screen.dart';
import 'package:connect_force_app/app/layers/presenter/providers/auth_provider.dart';
import 'package:connect_force_app/app/layers/presenter/providers/config_provider.dart';
import 'package:connect_force_app/app/layers/presenter/providers/data_provider.dart';
import 'package:flutter/material.dart';
import 'package:connect_force_app/app/layers/presenter/providers/user_provider.dart';
import 'package:connect_force_app/functions.dart';
import 'package:connect_force_app/navigation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  static const String route = "menu_principal_pagina";

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  Databasepadrao banco = Databasepadrao.instance;
  List listsMarket = [];
  final appStyles = AppStyles();
  final appWidgets = AppWidgets();
  late AuthProvider authProvider;
  late UserProvider userProvider;
  late ConfigProvider configProvider;
  late DataProvider dataProvider;
  late Future<void> future;
  Map usuario = {};
  bool isSending = false;
  late NetworkStatusService _networkStatusService;

  // String _textAtualizado = '';
  String _enviadosText = '';
  String _vendasText = '';

  // Função para atualizar os dados
  Future<void> _atualizarDados() async {
    // Consultas SQL
    const String sqlNaoEnviado = '''
      SELECT COUNT(*) AS total 
      FROM MOBILE_PEDIDO 
      WHERE  datamobile IS NULL 
    ''';
    // AND datahora BETWEEN ? AND ?

    const String sqlNrVendas = '''
      SELECT COUNT(*) AS total 
      FROM MOBILE_PEDIDO 
    ''';
    // WHERE datahora BETWEEN ? AND ?

    try {
      // Definir datas
      // final DateTime now = DateTime.now();
      // final DateTime inicioDia = DateTime(now.year, now.month, now.day, 0, 0, 1);
      // final DateTime fimDia = DateTime(now.year, now.month, now.day, 23, 59, 59);

      var resultNaoEnviado = await banco.dataReturnFull(sqlNaoEnviado);
      var resultNrVendas = await banco.dataReturnFull(sqlNrVendas);

      final int naoEnviado = resultNaoEnviado.isNotEmpty ? resultNaoEnviado.first['total'] as int : 0;

      final int nrVendas = resultNrVendas.isNotEmpty ? resultNrVendas.first['total'] as int : 0;

      // Atualizar texto para exibição
      setState(() {
        // _textAtualizado =
        //     'Atualizado em: ${DateTime.now().toString()}\nLatitude: ${_lerINI('Localizacao', 'Latitude')}\nLongitude: ${_lerINI('Localizacao', 'Longitude')}';

        switch (naoEnviado) {
          case 0:
            _enviadosText = 'Todos Enviados';
            break;
          default:
            _enviadosText = '$naoEnviado Pedidos a Enviar';
        }

        switch (nrVendas) {
          case 0:
            _vendasText = 'Nenhuma venda';
            break;
          case 1:
            _vendasText = '1 Venda';
            break;
          default:
            _vendasText = '$nrVendas Vendas';
        }
      });
    } catch (e) {
      print('Erro ao atualizar dados: $e');
    }
  }

  Future<void> initScreen() async {
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    userProvider = Provider.of<UserProvider>(context, listen: false);
    configProvider = Provider.of<ConfigProvider>(context, listen: false);
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    configProvider.version();
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    usuario = await dataProvider.loadDataToSend(uri: 'login');
    await dataProvider.getCurrentLocation(context);
    dataProvider.startListeningToLocationChanges(context); // Inicia o monitoramento da localização
    _atualizarDados();
    // Verifica o status da localização
    _checkLocationStatus();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    future = initScreen();
    _networkStatusService = Provider.of<NetworkStatusService>(context, listen: false)..enableService(true);

    _networkStatusService.stream.listen((status) {
      if (status == NetworkStatus.online) {
        userProvider.checkIfUserHasSomethingToUpload().then((value) {
          dataProvider.changeSendData(value);
          print(dataProvider.isSendData);
        });
      } else {
        if (userProvider.hasSomethingToUpload && !userProvider.hasWarnedSomethingToUpload) {
          showFlushbar(
            context,
            "Dados A Enviar",
            "Você possui dados locais que precisam ser enviados ao servidor. Esses dados serão enviados automaticamente quando uma conexão ativa à Internet for detectada.",
            5,
          );
          userProvider.hasWarnedSomethingToUpload = true;
        }
      }
    });
  }

  @override
  void dispose() {
    // Cancela o stream quando o widget for descartado
    dataProvider.positionStreamSubscription?.cancel();
    // Cancela o monitoramento ao destruir o widget
    _networkStatusService.enableService(false);
    super.dispose();
  }

  Future<void> sendData() async {
    setState(() => isSending = true);
    await dataProvider.enviarDados(
      context,
      tabela: 'MOBILE_CLIENTE',
      campo: 'LAST_CHANGE',
      route: 'MobileCliente',
    );
    await dataProvider.enviarDados(
      context,
      tabela: 'MOBILE_CONTATOS',
      campo: 'LAST_CHANGE',
      route: 'MobileContatos',
    );
    await dataProvider.enviarDados(
      context,
      tabela: 'MOBILE_PEDIDO',
      campo: 'DATAMOBILE',
      route: 'MobilePedido',
    );
    await dataProvider.enviarDados(
      context,
      tabela: 'MOBILE_ITEMPEDIDO',
      campo: 'DATAHORAMOBILE',
      route: 'MobileItemPedido',
    );
    // await dataProvider.enviarDados(
    //   context,
    //   tabela: 'MOBILE_PARCELAS',
    //   campo: 'DATAHORAMOBILE',
    //   route: 'MobileParcelas',
    // );

    // isSendData = false;
    setState(() => isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text("Bem-vindo(a)!"),
            automaticallyImplyLeading: false,
            actions: [
              if (!isSending)
                ListenableBuilder(
                  listenable: dataProvider,
                  builder: (context, value) {
                    return SizedBox(
                      width: 50,
                      child: IconButton(
                        icon: Icon(
                          Icons.cloud_upload,
                          color: dataProvider.isSendData ? appStyles.secondaryColor2 : appStyles.secondaryColor3,
                        ),
                        onPressed: dataProvider.isSendData
                            ? () async {
                                await sendData();
                                future = initScreen();
                              }
                            : null,
                      ),
                    );
                  },
                ),
              if (isSending)
                Row(
                  children: [
                    Center(
                      child: SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black.withAlpha(170),
                        ),
                      ),
                    ),
                    const SizedBox(width: 22),
                  ],
                ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Logout"),
                      content: const Text("Tem certeza que deseja sair?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text(
                            "Cancelar",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        SizedBox(width: 10),
                        TextButton(
                          onPressed: () {
                            authProvider.signOut();
                            pushAndRemoveUntil(context, LoginScreen());
                          },
                          child: const Text(
                            "Sair",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(80),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Column(
                  children: [
                    Text(
                      "Olá, ${usuario['NOME']}",
                      style: TextStyle(fontSize: 16, color: appStyles.colorWhite),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          "Long.: ${dataProvider.longitudeController.text}",
                          style: TextStyle(fontSize: 16, color: appStyles.colorWhite),
                        ),
                        const Spacer(),
                        Text(
                          "Lat.: ${dataProvider.latitudeController.text}",
                          style: TextStyle(fontSize: 16, color: appStyles.colorWhite),
                        ),
                      ],
                    ),
                    // SizedBox(height: 4),
                    Divider(color: appStyles.colorWhite),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              _vendasText,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Container(
                              height: 20,
                              width: 1,
                              color: Colors.white,
                            ),
                            Text(
                              _enviadosText,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            child: Column(
              children: [
                Expanded(
                  child: MainMenuList(
                    userProvider: userProvider,
                    provider: authProvider,
                    onItemTapped: () => initScreen(),
                  ),
                ),
                Text(
                  isLocationEnabled == null
                      ? "Verificando status da localização..."
                      : isLocationEnabled!
                          ? "Localização ativada ✅"
                          : "Localização desativada ❌",
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  late Stream<Position> positionStream;
  bool? isLocationEnabled;

  // Verifica e escuta mudanças no status da localização
  void _checkLocationStatus() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    _updateLocationStatus(enabled);

    // Escuta mudanças na configuração da localização
    Geolocator.getServiceStatusStream().listen((status) {
      bool isEnabled = status == ServiceStatus.enabled;
      if (isLocationEnabled != isEnabled) {
        _updateLocationStatus(isEnabled);
      }
    });
  }

  // Atualiza o estado e limpa os campos se necessário
  void _updateLocationStatus(bool isEnabled) {
    setState(() => isLocationEnabled = isEnabled);
    _showSnackBar(isEnabled);

    if (!isEnabled) {
      dataProvider.latitudeController.text = '';
      dataProvider.longitudeController.text = '';
    } else {
      // Cancela o stream quando o widget for descartado
      dataProvider.positionStreamSubscription?.cancel();
      dataProvider.startListeningToLocationChanges(context);
    }
    setState(() {});
  }

  // Exibe a mensagem via SnackBar
  void _showSnackBar(bool isEnabled) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEnabled ? "Localização ativada ✅" : "Localização desativada ❌!",
        ),
        duration: Duration(seconds: 2),
        backgroundColor: isEnabled ? Colors.green : Colors.red,
      ),
    );
  }
}
