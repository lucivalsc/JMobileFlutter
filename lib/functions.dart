import "package:another_flushbar/flushbar.dart";
import "package:flutter/material.dart";

void showFlushbar(BuildContext ctx, String title, String text, int seconds) {
  Flushbar(
    padding: const EdgeInsets.symmetric(vertical: 16),
    icon: Icon(
      Icons.error_outline_outlined,
      color: Theme.of(ctx).canvasColor,
    ),
    title: title,
    messageText: Align(
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(text: text, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    ),
    isDismissible: false,
    animationDuration: const Duration(milliseconds: 400),
    duration: Duration(seconds: seconds),
    backgroundColor: Theme.of(ctx).primaryColorDark,
  ).show(ctx);
}

Future loading(BuildContext context, [String? msg]) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: msg != null ? Text(msg) : const Text("Carregando..."),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: CircularProgressIndicator(),
              ),
            ],
          ),
        ),
      );
    },
  );
}
