import 'package:jmobileflutter/app/common/styles/app_styles.dart';
import 'package:jmobileflutter/app/common/widgets/elevated_button_widget.dart';
import 'package:jmobileflutter/app/common/widgets/text_field_widget.dart';
import 'package:jmobileflutter/app/layers/presenter/logged_in/screens/configuracao/configuracao_screen.dart';
import 'package:jmobileflutter/app/layers/presenter/providers/auth_provider.dart';
import 'package:jmobileflutter/app/layers/presenter/providers/config_provider.dart';
import 'package:jmobileflutter/app/layers/presenter/providers/data_provider.dart';
import 'package:flutter/material.dart';
import 'package:jmobileflutter/navigation.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final appStyles = AppStyles();
  bool isScreenLocked = false;
  bool password = true;

  late AuthProvider authProvider;
  late ConfigProvider configProvider;
  late DataProvider dataProvider;

  late Future<void> future;

  TextEditingController userLogger = TextEditingController();
  TextEditingController passwordLogger = TextEditingController();

  Future<void> initScreen() async {
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    configProvider = Provider.of<ConfigProvider>(context, listen: false);
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    configProvider.version();
    userLogger.text = await configProvider.loadLastLoggedEmail();
    passwordLogger.text = await configProvider.loadLastLoggedPassword();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    future = initScreen();
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Stack(
      children: [
        Container(
          constraints: const BoxConstraints.expand(),
          padding: EdgeInsets.only(top: statusBarHeight),
          decoration: BoxDecoration(
            color: appStyles.colorWhite,
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.2,
                  ),
                  Text(
                    'JMobile',
                    textAlign: TextAlign.center,
                    style: appStyles.boldText,
                  ),
                  const SizedBox(height: 50),
                  TextFieldWidget(
                    label: 'Úsuario',
                    icon: Icons.person,
                    controller: userLogger,
                  ),
                  const SizedBox(height: 10),
                  TextFieldWidget(
                    label: 'Senha',
                    icon: Icons.lock,
                    controller: passwordLogger,
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButtonWidget(
                    label: 'ENTRAR',
                    onPressed: () async {
                      setState(() => isScreenLocked = true);
                      // Oculta o teclado se estiver ativo
                      FocusManager.instance.primaryFocus?.unfocus();

                      // Validate user and password
                      if (validateUserAndPassword()) {
                        await authProvider.signIn(
                          context,
                          mounted,
                          userLogger.text,
                          passwordLogger.text,
                        );
                      } else {
                        // Display AlertDialog for invalid user/password
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Credenciais inválidas"),
                              content: const Text("Insira usuário e senha válidos."),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("OK"),
                                ),
                              ],
                            );
                          },
                        );
                      }
                      setState(() => isScreenLocked = false);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    child: Text(
                      'CONFIGURAÇÃO',
                      style: appStyles.configCardTitleStyle,
                    ),
                    onPressed: () {
                      push(context, ConfiguracaoScreen());
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(configProvider.versionBuild),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool validateUserAndPassword() {
    if (userLogger.text.isEmpty || passwordLogger.text.isEmpty) {
      return false;
    }
    return true;
  }
}
