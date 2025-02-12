import 'package:connect_force_app/app/common/widgets/text_field_date.dart';
import 'package:connect_force_app/app/layers/presenter/logged_in/screens/relatorios/relatorios_condi/relatorios_condi_screen.dart';
import 'package:connect_force_app/app/layers/presenter/logged_in/screens/relatorios/relatorios_recebidas/relatorios_recebidas_screen.dart';
import 'package:connect_force_app/navigation.dart';
import 'package:flutter/material.dart';

class RelatoriosScreen extends StatefulWidget {
  const RelatoriosScreen({super.key});

  static const String route = "relatorios_screen";
  @override
  State<RelatoriosScreen> createState() => RelatoriosScreenState();
}

class RelatoriosScreenState extends State<RelatoriosScreen> {
  TextEditingController dateInicialController = TextEditingController();
  TextEditingController dateFinalController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Relatórios')),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          ListTile(
            title: const Text('Relatório recebidas'),
            subtitle: const Text('Relatório de vendas por condicionador'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              showDialogDate(
                'Relatório recebidas',
                () {
                  push(
                    context,
                    RelatoriosRecebidasScreen(
                      periodoInicial: dateInicialController.text,
                      periodoFinal: dateFinalController.text,
                    ),
                  );
                },
              );
            },
          ),
          ListTile(
            title: const Text('Relatório Condi'),
            subtitle: const Text('Relatório de vendas por condicionador'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              showDialogDate(
                'Relatório Condi',
                () {
                  push(
                    context,
                    RelatoriosCondiScreen(
                      tipoPedido: 'C',
                      periodoInicial: dateInicialController.text,
                      periodoFinal: dateFinalController.text,
                    ),
                  );
                },
              );
            },
          ),
          ListTile(
            title: const Text('Relatório vendas'),
            subtitle: const Text('Relatório de vendas por condicionador'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              showDialogDate(
                'Relatório vendas',
                () {
                  push(
                    context,
                    RelatoriosCondiScreen(
                      tipoPedido: 'P',
                      periodoInicial: dateInicialController.text,
                      periodoFinal: dateFinalController.text,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  showDialogDate(String titulo, Function push) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titulo),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFieldDate(
                controller: dateInicialController,
                label: 'Data inicial',
              ),
              TextFieldDate(
                controller: dateFinalController,
                label: 'Data final',
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Fechar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Gerar Relatório'),
              onPressed: () {
                Navigator.of(context).pop();
                push();
              },
            ),
          ],
        );
      },
    );
  }
}
