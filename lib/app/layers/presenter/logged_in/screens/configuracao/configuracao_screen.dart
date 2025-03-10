import 'dart:io';

import 'package:connect_force_app/app/common/styles/app_styles.dart';
import 'package:connect_force_app/app/common/widgets/elevated_button_widget.dart';
import 'package:connect_force_app/app/common/widgets/text_field_widget.dart';
import 'package:connect_force_app/app/layers/data/datasources/local/banco_datasource_implementation.dart';
import 'package:connect_force_app/app/layers/presenter/providers/data_provider.dart';
import 'package:connect_force_app/loading_overlay.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfiguracaoScreen extends StatefulWidget {
  const ConfiguracaoScreen({super.key});

  static const String route = "configuracao_screen";

  @override
  State<ConfiguracaoScreen> createState() => _ConfiguracaoScreenState();
}

class _ConfiguracaoScreenState extends State<ConfiguracaoScreen> {
  final Databasepadrao banco = Databasepadrao.instance;
  bool isScreenLocked = false;
  late DataProvider dataProvider;
  late Future<void> future;
  final appStyles = AppStyles();
  Map usuario = {};

  TextEditingController userLogger = TextEditingController();
  TextEditingController passwordLogger = TextEditingController();

  TextEditingController hostController = TextEditingController();
  TextEditingController portController = TextEditingController();

  Future<void> initScreen() async {
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    usuario = await dataProvider.loadDataToSend(uri: 'login');
    await loadConfiguracao();
    setState(() {});
  }

  Future<void> salvarConfiguracao() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('host', hostController.text);
    preferences.setString('port', portController.text);
    preferences.setString('user', userLogger.text);
    preferences.setString('password', passwordLogger.text);
  }

  Future<void> loadConfiguracao() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    hostController.text = preferences.getString('host') ?? '';
    portController.text = preferences.getString('port') ?? '';
    userLogger.text = preferences.getString('user') ?? '';
    passwordLogger.text = preferences.getString('password') ?? '';
  }

  @override
  void initState() {
    super.initState();
    future = initScreen();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isScreenLocked,
      child: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Configuração"),
          ),
          body: FutureBuilder(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Dados de acesso",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFieldWidget(
                        label: 'Host (IP)',
                        // icon: Icons.lock,
                        controller: hostController,
                      ),
                      SizedBox(height: 10),
                      TextFieldWidget(
                        label: 'Porta',
                        // icon: Icons.lock,
                        controller: portController,
                      ),
                      SizedBox(height: 10),
                      TextFieldWidget(
                        label: 'Usuário',
                        // icon: Icons.lock,
                        controller: userLogger,
                      ),
                      SizedBox(height: 10),
                      TextFieldWidget(
                        label: 'Senha',
                        // icon: Icons.lock,
                        controller: passwordLogger,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButtonWidget(
                  label: 'SALVAR CONFIGURAÇÃO',
                  onPressed: () async {
                    setState(() => isScreenLocked = true);
                    // Oculta o teclado se estiver ativo
                    FocusManager.instance.primaryFocus?.unfocus();
                    await salvarConfiguracao();
                    Navigator.pop(context);

                    setState(() => isScreenLocked = false);
                  },
                ),
                if (kDebugMode) ...[
                  const SizedBox(height: 10),
                  ElevatedButtonWidget(
                    label: 'ENVIAR BANCO',
                    onPressed: () async {
                      setState(() => isScreenLocked = true);
                      await enviarBancoDados();
                      setState(() => isScreenLocked = false);
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButtonWidget(
                    label: 'LIMPAR BANCO',
                    onPressed: () async {
                      setState(() => isScreenLocked = true);
                      try {
                        await banco.deleteAll('MOBILE_CLIENTE');
                        await banco.deleteAll('MOBILE_CONTATOS');
                        await banco.deleteAll('MOBILE_ITEMPEDIDO');
                        await banco.deleteAll('MOBILE_PEDIDO');
                        await banco.deleteAll('MOBILE_PARCELAS');
                        setState(() => isScreenLocked = false);
                      } catch (e) {
                        setState(() => isScreenLocked = false);
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//lucival
var token = '5857531142:AAF7dcQRgCK5wQWGIPL_gk3UaWz3nFmnfFg';
var chatId = '793933959';

enviarBancoDados() async {
  // Obter o caminho do banco de dados Sqflite
  Directory documentsDirectory = await getApplicationDocumentsDirectory();
  String path = p.join(documentsDirectory.path, 'bd');

  // Ler o arquivo do banco de dados
  File dbFile = File(path);
  List<int> bytes = await dbFile.readAsBytes();

  // Enviar o arquivo via HTTP para a API do Telegram
  String url = 'https://api.telegram.org/bot$token/sendDocument';
  var request = http.MultipartRequest('POST', Uri.parse(url))
    ..fields['chat_id'] = chatId
    ..files.add(
      http.MultipartFile.fromBytes(
        'document',
        bytes,
        filename: 'bd.db',
      ),
    );

  await request.send();
}
