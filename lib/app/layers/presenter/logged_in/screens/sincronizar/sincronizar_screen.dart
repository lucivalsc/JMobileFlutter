import 'package:connect_force_app/app/common/styles/app_styles.dart';
import 'package:connect_force_app/app/common/widgets/elevated_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:connect_force_app/app/layers/presenter/logged_in/successful_screen.dart';
import 'package:connect_force_app/app/layers/presenter/providers/data_provider.dart';
import 'package:connect_force_app/navigation.dart';
import 'package:provider/provider.dart';

class SincronizarScreen extends StatefulWidget {
  const SincronizarScreen({super.key});

  static const String route = "sincronizar_screen";

  @override
  State<SincronizarScreen> createState() => _SincronizarScreenState();
}

class _SincronizarScreenState extends State<SincronizarScreen> {
  bool isSyncing = false;
  late DataProvider dataProvider;
  late Future<void> future;
  final appStyles = AppStyles();

  Future<void> initScreen() async {
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    future = initScreen();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !isSyncing,
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: const Text("Sincronizar"),
            ),
            body: FutureBuilder(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Sincronização de dados",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Clique no botão para sincronizar os dados.",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButtonWidget(
                label: 'SINCRONIZAR DADOS',
                onPressed: isSyncing
                    ? () {}
                    : () async {
                        setState(() => isSyncing = true);
                        await dataProvider.synchronous(context, showMessage: false);
                        await dataProvider.synchronous(context, key: 'contas');
                        if (mounted) {
                          setState(() => isSyncing = false);
                          await push(
                            context,
                            SuccessfulScreen(
                              description: 'Sincronizado com sucesso!',
                            ),
                          );
                        }
                      },
              ),
            ),
          ),
          if (isSyncing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    Text(
                      'Sincronizando...',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
