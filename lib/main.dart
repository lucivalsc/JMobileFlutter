import 'package:jmobileflutter/on_generate_route.dart';
import 'package:jmobileflutter/starter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:flutter_localizations/flutter_localizations.dart";
import 'package:jmobileflutter/app/common/utils/functions.dart';
import 'package:jmobileflutter/provider_injections.dart';
import 'package:provider/provider.dart';

import 'app/common/styles/app_styles.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
                // backgroundColor: appStyles.primaryColor,
              //   foregroundColor: appStyles.colorWhite,
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
