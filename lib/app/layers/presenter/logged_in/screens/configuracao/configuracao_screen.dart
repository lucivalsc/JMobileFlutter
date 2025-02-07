import 'package:jmobileflutter/app/common/styles/app_styles.dart';
import 'package:jmobileflutter/app/common/widgets/elevated_button_widget.dart';
import 'package:jmobileflutter/app/common/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:jmobileflutter/app/layers/presenter/providers/data_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfiguracaoScreen extends StatefulWidget {
  const ConfiguracaoScreen({super.key});

  static const String route = "configuracao_screen";

  @override
  State<ConfiguracaoScreen> createState() => _ConfiguracaoScreenState();
}

class _ConfiguracaoScreenState extends State<ConfiguracaoScreen> {
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
    return WillPopScope(
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
          child: ElevatedButtonWidget(
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
        ),
      ),
    );
  }
}
