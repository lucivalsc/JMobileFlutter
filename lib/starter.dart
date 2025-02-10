import 'package:connect_force_app/app/layers/presenter/logged_in/main_menu_screen.dart';
import 'package:connect_force_app/app/layers/presenter/not_logged_in/login_screen.dart';
import 'package:connect_force_app/app/layers/presenter/not_logged_in/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:connect_force_app/app/layers/presenter/providers/config_provider.dart';
import 'package:provider/provider.dart';

class Starter extends StatefulWidget {
  const Starter({super.key});

  static const route = "starter_screen";

  @override
  State<Starter> createState() => _StarterState();
}

class _StarterState extends State<Starter> {
  late Future<void> future;
  late Widget nextScreen;
  late ConfigProvider configProvider;

  Future<void> startApp() async {
    configProvider = Provider.of<ConfigProvider>(context, listen: false);
    var userLogger = await configProvider.loadLastLoggedEmail();
    var passwordLogger = await configProvider.loadLastLoggedPassword();

    if (userLogger.isNotEmpty && passwordLogger.isNotEmpty) {
      nextScreen = const MainMenuScreen(); //MainMenuScreen
    } else {
      nextScreen = const LoginScreen();
    }
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  void initState() {
    super.initState();
    future = startApp();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: nextScreen,
          );
        } else {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: SplashScreen(),
          );
        }
      },
    );
  }
}
