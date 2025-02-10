import 'package:connect_force_app/app/common/widgets/elevated_button_widget.dart';
import 'package:connect_force_app/app/common/widgets/text_field_widget.dart';

import 'package:flutter/material.dart';

class NovaContaPagina extends StatefulWidget {
  const NovaContaPagina({super.key});

  @override
  State<NovaContaPagina> createState() => _NovaContaPaginaState();
}

class _NovaContaPaginaState extends State<NovaContaPagina> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastro"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            const TextFieldWidget(label: 'Nome Completo', icon: Icons.person),
            const SizedBox(height: 10),
            const TextFieldWidget(label: 'E-mail', icon: Icons.email),
            const SizedBox(height: 10),
            const TextFieldWidget(label: 'Senha', icon: Icons.lock),
            const SizedBox(height: 10),
            const TextFieldWidget(label: 'Celular', icon: Icons.phone),
            const SizedBox(height: 10),
            const TextFieldWidget(label: 'CPF', icon: Icons.assignment_ind),
            const SizedBox(height: 20),
            ElevatedButtonWidget(label: 'Cadastrar Ùsuario', onPressed: () {})
          ],
        ),
      ),
    );
  }
}
