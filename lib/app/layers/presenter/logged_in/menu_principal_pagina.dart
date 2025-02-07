import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:jmobileflutter/app/common/styles/app_styles.dart';
import 'package:jmobileflutter/app/common/widgets/app_widgets.dart';
import 'package:jmobileflutter/app/common/widgets/elevated_button_widget.dart';
import 'package:jmobileflutter/app/layers/presenter/logged_in/main_menu_list.dart';
import 'package:jmobileflutter/app/layers/presenter/logged_in/screens/produtos/produtos_lista_screen.dart';
import 'package:jmobileflutter/app/layers/presenter/not_logged_in/login_screen.dart';
import 'package:jmobileflutter/app/layers/presenter/providers/auth_provider.dart';
import 'package:jmobileflutter/app/layers/presenter/providers/config_provider.dart';
import 'package:jmobileflutter/app/layers/presenter/providers/data_provider.dart';
import 'package:flutter/material.dart';
import 'package:jmobileflutter/app/layers/presenter/providers/user_provider.dart';
import 'package:jmobileflutter/navigation.dart';
import 'package:provider/provider.dart';

class MenuPrincipalPagina extends StatefulWidget {
  final Map? itemFilial;
  const MenuPrincipalPagina({
    super.key,
    this.itemFilial,
  });

  static const String route = "menu_principal_pagina";

  @override
  State<MenuPrincipalPagina> createState() => _MenuPrincipalPaginaState();
}

class _MenuPrincipalPaginaState extends State<MenuPrincipalPagina> {
  List listsMarket = [];
  final appStyles = AppStyles();
  final appWidgets = AppWidgets();
  Position? _currentPosition;
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  late AuthProvider authProvider;
  late UserProvider userProvider;
  late ConfigProvider configProvider;
  late DataProvider dataProvider;
  late Future<void> future;
  Map usuario = {};

  // Adicione um StreamSubscription para monitorar a localização
  StreamSubscription<Position>? _positionStreamSubscription;

  Future<void> initScreen() async {
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    userProvider = Provider.of<UserProvider>(context, listen: false);
    configProvider = Provider.of<ConfigProvider>(context, listen: false);
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    configProvider.version();
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    usuario = await dataProvider.loadDataToSend(uri: 'login');
    await _getCurrentLocation();
    _startListeningToLocationChanges(); // Inicia o monitoramento da localização
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
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('O serviço de localização está desativado.')),
      );
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
    setState(() {
      _currentPosition = position;
      _latitudeController.text = position.latitude.toString();
      _longitudeController.text = position.longitude.toString();
    });
  }

  void _startListeningToLocationChanges() {
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Atualiza a cada 10 metros de mudança
      ),
    ).listen((Position position) {
      setState(() {
        _currentPosition = position;
        _latitudeController.text = position.latitude.toString();
        _longitudeController.text = position.longitude.toString();
      });
    });

    // Detecta quando o serviço de localização é desativado
    Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      if (status == ServiceStatus.disabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('O serviço de localização foi desativado.')),
        );
      }
    });
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
                          child: const Text("Cancelar"),
                        ),
                        SizedBox(width: 10),
                        TextButton(
                          onPressed: () => pushAndRemoveUntil(context, LoginScreen()),
                          child: const Text("Sair"),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(55),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Column(
                  children: [
                    Text(
                      "Olá, ${usuario['NOME']}",
                      style: TextStyle(fontSize: 16, color: appStyles.colorWhite),
                    ),
                    Divider(),
                    Row(
                      children: [
                        Text(
                          "Long.: ${_longitudeController.text}",
                          style: TextStyle(fontSize: 16, color: appStyles.colorWhite),
                        ),
                        const Spacer(),
                        Text(
                          "Lat.: ${_latitudeController.text}",
                          style: TextStyle(fontSize: 16, color: appStyles.colorWhite),
                        ),
                      ],
                    ),
                    Divider(),
                  ],
                ),
              ),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButtonWidget(
                        label: 'Nenhuma Venda',
                        onPressed: () {
                          push(context, ProdutosListaScreen());
                        }),
                    const SizedBox(width: 10),
                    ElevatedButtonWidget(label: 'Todos Enviados', onPressed: () {}),
                  ],
                ),
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
