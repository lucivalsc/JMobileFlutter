import 'package:jmobileflutter/app/common/styles/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:jmobileflutter/app/layers/presenter/logged_in/screens/pedidos/pedidos.dart';
import 'package:jmobileflutter/app/layers/presenter/providers/data_provider.dart';
import 'package:jmobileflutter/navigation.dart';
import 'package:provider/provider.dart';

class PedidosListaScreen extends StatefulWidget {
  const PedidosListaScreen({super.key});

  static const String route = "pedidos_lista_screen";

  @override
  State<PedidosListaScreen> createState() => _PedidosListaScreenState();
}

class _PedidosListaScreenState extends State<PedidosListaScreen> {
  bool isScreenLocked = false;
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
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Lista de Pedidos"),
        ),
        body: FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Lista de Pedidos de Vendas.",
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
        floatingActionButton: FloatingActionButton.extended(
          label: const Text("Novo Pedido"),
          onPressed: () {
            push(context, PedidosScreen());
          },
        ),
      ),
    );
  }
}
