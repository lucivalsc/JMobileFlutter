import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(.7),
      body: Center(
        child: Lottie.asset(
          'lib/app/common/assets/lottie/loading2.json',
          height: MediaQuery.of(context).size.width / 2,
        ),
        // CircularProgressIndicator(),
      ),
    );
  }
}
