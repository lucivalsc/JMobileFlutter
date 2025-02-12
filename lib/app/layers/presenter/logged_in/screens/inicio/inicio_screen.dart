import 'package:connect_force_app/app/common/styles/app_styles.dart';
import 'package:connect_force_app/app/layers/presenter/logged_in/screens/relatorios/relatorios_screen.dart';
import 'package:connect_force_app/app/layers/presenter/providers/data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InicioScreen extends StatefulWidget {
  final Map itemFilial;
  const InicioScreen({super.key, required this.itemFilial});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  List listsMarket = [];
  late DataProvider dataProvider;
  late Future<void> future;

  final appStyles = AppStyles();
  Map usuario = {};
  Future<void> initScreen() async {
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    usuario = await dataProvider.loadDataToSend(uri: 'login');
    // await Future.delayed(const Duration(seconds: 5));
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    future = initScreen();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(58),
                child: Column(
                  children: [
                    Text(
                      "Bem-vindo!",
                      style: TextStyle(fontSize: 20, color: appStyles.colorWhite),
                    ),
                    Text(
                      "Ola, ${usuario['user']['email']}",
                      style: TextStyle(fontSize: 16, color: appStyles.colorWhite),
                    ),
                    Divider(),
                    Text(
                      "Filial - ${widget.itemFilial['nome'] ?? '-'}",
                      style: TextStyle(fontSize: 16, color: appStyles.colorWhite),
                    ),
                    Divider(),
                  ],
                ),
              ),
            ),
            body: RelatoriosScreen());
      },
    );
  }
}
