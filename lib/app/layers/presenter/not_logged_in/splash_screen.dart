import 'package:jmobileflutter/app/common/styles/app_styles.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  final appStyles = AppStyles();

  SplashScreen({super.key});

  static const String route = "splash";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appStyles.colorWhite,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'JMobile',
              style: appStyles.boldText,
            ),
          ],
        ),
      ),
    );
  }
}
