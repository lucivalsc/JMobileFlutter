import 'package:connect_force_app/app/common/styles/app_styles.dart';
import 'package:connect_force_app/app/common/widgets/elevated_button_widget.dart';
import 'package:connect_force_app/app/layers/presenter/logged_in/screens/configuracao/configuracao_screen.dart';
import 'package:connect_force_app/app/layers/presenter/providers/auth_provider.dart';
import 'package:connect_force_app/app/layers/presenter/providers/config_provider.dart';
import 'package:connect_force_app/app/layers/presenter/providers/data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isScreenLocked = false;
  bool passwordVisible = true;
  AppStyles appStyles = AppStyles();

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

  bool validateUserAndPassword() {
    return userLogger.text.isNotEmpty && passwordLogger.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  appStyles.primaryColor,
                  Colors.teal.shade100,
                ],
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 100),
                const Text(
                  'Olá!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                const Text(
                  'Seja bem-vindo ao JMobile',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 50),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            reverse: true,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 250),
                Text(
                  'Acessar',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: appStyles.primaryColor,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: userLogger,
                  decoration: InputDecoration(
                    labelText: 'Usuário',
                    prefixIcon: const Icon(Icons.email),
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordLogger,
                  obscureText: passwordVisible,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(passwordVisible ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          passwordVisible = !passwordVisible;
                        });
                      },
                    ),
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButtonWidget(
                    onPressed: () async {
                      setState(() => isScreenLocked = true);
                      FocusManager.instance.primaryFocus?.unfocus();

                      if (validateUserAndPassword()) {
                        await authProvider.signIn(
                          context,
                          mounted,
                          userLogger.text,
                          passwordLogger.text,
                        );
                      } else {
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
                    label: 'ACESSAR',
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    child: Text(
                      'CONFIGURAÇÃO',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: appStyles.primaryColor,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ConfiguracaoScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    configProvider.versionBuild,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
