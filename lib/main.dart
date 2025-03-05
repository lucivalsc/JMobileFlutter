import 'package:connect_force_app/app/common/utils/functions.dart';
import 'package:connect_force_app/on_generate_route.dart';
import 'package:connect_force_app/provider_injections.dart';
import 'package:connect_force_app/starter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'app/common/styles/app_styles.dart';

/// Widget global para capturar erros
class CustomErrorWidget extends StatelessWidget {
  final String errorMessage;

  const CustomErrorWidget({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Erro')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Ocorreu um erro inesperado:\n$errorMessage',
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // // Captura erros na árvore de widgets (exibe um widget de erro)
  // ErrorWidget.builder = (FlutterErrorDetails details) {
  //   return CustomErrorWidget(errorMessage: details.exceptionAsString());
  // };

  // // Captura erros síncronos e os exibe corretamente
  // FlutterError.onError = (FlutterErrorDetails details) {
  //   FlutterError.dumpErrorToConsole(details);
  //   showErrorScreen(details);
  // };

  // // Captura erros assíncronos (exemplo: erro dentro de um Future)
  // PlatformDispatcher.instance.onError = (error, stack) {
  //   showErrorScreen(FlutterErrorDetails(exception: error, stack: stack));
  //   return true; // Indica que o erro foi tratado
  // };

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Color.fromRGBO(242, 242, 242, 1),
      systemNavigationBarDividerColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await startHiveStuff();

  runApp(const MainApp());
}

/// Exibe a tela de erro independentemente do estado do app
void showErrorScreen(FlutterErrorDetails details) {
  runApp(MaterialApp(
    home: CustomErrorWidget(errorMessage: details.exceptionAsString()),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appStyles = AppStyles();

    return MultiProvider(
      providers: providers,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale("pt", "BR")],
        theme: ThemeData(
          useMaterial3: false,
          primarySwatch: MaterialColor(
            appStyles.primaryColorInt,
            appStyles.getSwatch(),
          ),
          scaffoldBackgroundColor: appStyles.colorWhite,
          appBarTheme: AppBarTheme(
            backgroundColor: appStyles.primaryColor,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
            iconTheme: const IconThemeData(
              color: Colors.white,
            ),
            actionsIconTheme: IconThemeData(
              color: appStyles.colorWhite,
            ),
          ),
          listTileTheme: const ListTileThemeData(
            selectedTileColor: Colors.black12,
            selectedColor: Colors.black,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: appStyles.primaryColor,
              foregroundColor: appStyles.colorWhite,
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(color: Colors.black),
            ),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: appStyles.primaryColor,
          ),
          iconButtonTheme: IconButtonThemeData(
            style: TextButton.styleFrom(
              backgroundColor: appStyles.primaryColor,
              foregroundColor: appStyles.primaryColor,
            ),
          ),
          iconTheme: IconThemeData(
            color: appStyles.primaryColor,
          ),
        ),
        initialRoute: Starter.route,
        onGenerateRoute: onGenerateRoute,
      ),
    );
  }
}
