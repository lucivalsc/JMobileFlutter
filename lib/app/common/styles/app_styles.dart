import 'package:flutter/material.dart';

class AppStyles {
  // Colors of app:
  // final primaryColor = const Color.fromARGB(255, 64, 31, 19);
  final primaryColor = const Color.fromARGB(255, 4, 104, 87);
  final primaryColorInt = 0xFF85CFEE; //cor do cursor e textos de label ou hint
  final blackColor = const Color(0xFF231F20);
  final secondaryColor2 = const Color.fromARGB(255, 241, 186, 49);
  final secondaryColor3 = const Color.fromARGB(255, 110, 110, 110);
  final colorWhite = Colors.white;
  // final backgroundAvatarColor = Colors.white;
  // final primaryColor2 = const Color(0xFFFED09E);
  // final buttonColor = const Color.fromRGBO(133, 207, 238, 1);
  // final backgroundColor = Colors.white;
  // final dividerColor = const Color(0xFFFFFFFF);
  // final appbarBackButtonColor = Colors.white;
  // final tabBarBackgroundColor = Colors.white;

  Color failureScreenColor = const Color(0xFFEB4C5F);
  Color successScreenColor = const Color(0xFF04CD51);

  Map<int, Color> getSwatch() {
    return {
      50: primaryColor,
      100: primaryColor,
      200: primaryColor,
      300: primaryColor,
      400: primaryColor,
      500: primaryColor,
      600: primaryColor,
      700: primaryColor,
      800: primaryColor,
      900: primaryColor,
    };
  }

  // App paddings, margins and sizes:
  final screenPadding = const EdgeInsets.symmetric(horizontal: 20, vertical: 20);

  final loginPath = "lib/app/common/assets/png/logo.png";
  final fundoPath = "lib/app/common/assets/png/fundo.png";
  // final logoPath = "lib/app/common/assets/mt.jpeg";

  // Styles for texts:
  final boldText = const TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    color: Colors.black,
  );
  final normalText = const TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w300,
    color: Colors.black,
  );
  final thinText = const TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w100,
    color: Colors.black,
  );
  final configSectionTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: Colors.grey.shade800,
  );
  final configSectionSubtitleStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.grey.shade600,
  );
  final configCardTitleStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.grey.shade800,
  );
  final configCardTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.grey.shade400,
  );
  final configTagTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: Colors.grey.shade100,
  );
  final cardTitleTextStyle = const TextStyle(
    color: Colors.black87,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
  final cardSubtitleTextStyle = const TextStyle(
    color: Colors.black38,
    fontSize: 10,
    fontWeight: FontWeight.w600,
  );
  final inputTileLabel = const TextStyle(
    color: Colors.grey,
    fontSize: 14,
  );
  final inputTileValue = const TextStyle(
    color: Colors.black,
    fontSize: 14,
  );
  get appBarTitleStyle => const TextStyle(
        fontSize: 16,
        fontFamily: "RobotoSlab",
        color: Colors.white,
      );
}
