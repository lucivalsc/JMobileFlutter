import 'package:jmobileflutter/app/layers/presenter/logged_in/menu_principal_pagina.dart';
import 'package:jmobileflutter/app/layers/presenter/not_logged_in/login_screen.dart';
import 'package:jmobileflutter/app/layers/presenter/not_logged_in/splash_screen.dart';
import 'package:flutter/material.dart';

class Starter extends StatefulWidget {
  const Starter({Key? key}) : super(key: key);

  static const route = "starter_screen";

  @override
  State<Starter> createState() => _StarterState();
}

class _StarterState extends State<Starter> {
  late Future<void> future;
  late Widget nextScreen;

  Future<void> startApp() async {
    
    if (false == true) {
      nextScreen = const MenuPrincipalPagina(); //MainMenuScreen
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
