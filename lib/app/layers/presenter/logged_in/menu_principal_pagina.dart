import 'dart:async';
import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:jmobileflutter/app/common/styles/app_styles.dart';
import 'package:jmobileflutter/app/common/widgets/app_widgets.dart';
import 'package:jmobileflutter/app/layers/data/datasources/local/banco_datasource_implementation.dart';
import 'package:jmobileflutter/app/layers/presenter/logged_in/main_menu_list.dart';
import 'package:jmobileflutter/app/layers/presenter/not_logged_in/login_screen.dart';
import 'package:jmobileflutter/app/layers/presenter/providers/auth_provider.dart';
import 'package:jmobileflutter/app/layers/presenter/providers/config_provider.dart';
import 'package:jmobileflutter/app/layers/presenter/providers/data_provider.dart';
import 'package:flutter/material.dart';
import 'package:jmobileflutter/app/layers/presenter/providers/user_provider.dart';
import 'package:jmobileflutter/navigation.dart';
import 'package:provider/provider.dart';

class MenuPrincipalPagina extends StatefulWidget {
  const MenuPrincipalPagina({super.key});

  static const String route = "menu_principal_pagina";

  @override
  State<MenuPrincipalPagina> createState() => _MenuPrincipalPaginaState();
}

class _MenuPrincipalPaginaState extends State<MenuPrincipalPagina> {
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
      final DateTime now = DateTime.now();
      final DateTime inicioDia = DateTime(now.year, now.month, now.day, 0, 0, 1);
      final DateTime fimDia = DateTime(now.year, now.month, now.day, 23, 59, 59);

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
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    future = initScreen();
  }

  @override
  void dispose() {
    // Cancela o stream quando o widget for descartado
    dataProvider.positionStreamSubscription?.cancel();
    super.dispose();
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
                          onPressed: () => pushAndRemoveUntil(context, LoginScreen()),
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
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
