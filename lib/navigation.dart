import 'package:flutter/material.dart';

import 'functions.dart';

Future pushNamed(BuildContext context, String name, {Object? arguments}) async {
  try {
    return await Navigator.of(context).pushNamed(name, arguments: arguments);
  } catch (e) {
    showFlushbar(context, "Operação Inválida", "A tela desejada não possui implementação.", 3);
  }
}

Future push(BuildContext context, Widget screen, {String? name}) async {
  return await Navigator.of(context).push(
    PageRouteBuilder(
      settings: RouteSettings(name: name),
      pageBuilder: (context, a1, a2) => screen,
      transitionsBuilder: (context, a1, a2, child) => FadeTransition(opacity: a1, child: child),
    ),
  );
}

Future pushWithoutFading(BuildContext context, Widget screen) async {
  return await Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => screen),
  );
}

Future pushReplacement(BuildContext context, Widget screen) async {
  return await Navigator.of(context).pushReplacement(
    PageRouteBuilder(
      pageBuilder: (context, a1, a2) => screen,
      transitionsBuilder: (context, a1, a2, child) => FadeTransition(opacity: a1, child: child),
    ),
  );
}

Future pushAndRemoveUntil(BuildContext context, Widget screen) async {
  return await Navigator.of(context).pushAndRemoveUntil(
    PageRouteBuilder(
      pageBuilder: (context, a1, a2) => screen,
      transitionsBuilder: (context, a1, a2, child) => FadeTransition(opacity: a1, child: child),
    ),
    (route) => route.isFirst,
  );
}
