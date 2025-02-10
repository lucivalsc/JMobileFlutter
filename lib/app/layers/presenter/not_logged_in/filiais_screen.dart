import 'package:flutter/material.dart';
import 'package:connect_force_app/app/layers/presenter/logged_in/main_menu_screen.dart';

class FiliaisScreen extends StatelessWidget {
  final Map data;

  // Constructor para receber o Map via parâmetro
  const FiliaisScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    var user = data['user'];
    var filiais = user['filiais'];

    return Scaffold(
      appBar: AppBar(title: Text("filiais")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nome do usuário
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  child: Icon(Icons.person),
                  // backgroundImage: AssetImage('assets/user_photo.png'), // Foto do usuário (se houver)
                ),
                SizedBox(width: 10),
                Text(
                  'Olá, ${user['fullName']}',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Título
            Text(
              'Escolha a Filial',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),

            // Lista de filiais
            Expanded(
              child: ListView.builder(
                itemCount: filiais.length,
                itemBuilder: (context, index) {
                  var filial = filiais[index];
                  return ListTile(
                    leading: Icon(Icons.business),
                    title: Text(filial['nome']),
                    subtitle: Text('${filial['endereco']}, ${filial['cidade']} - ${filial['estado']}'),
                    trailing: filial['isPrincipal'] ? Icon(Icons.star, color: Colors.amber) : null,
                    onTap: () {
                      // Ação ao selecionar a filial
                      Navigator.of(context).pop();
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) => MenuPrincipalPagina(itemFilial: filial),
                      //   ),
                      // );
                      // showDialog(
                      //   context: context,
                      //   builder: (context) => AlertDialog(
                      //     title: Text('Filial Selecionada'),
                      //     content: Text('Você escolheu a filial: ${filial['nome']}'),
                      //     actions: [
                      //       TextButton(
                      //         onPressed: () {
                      //           Navigator.of(context).pop();
                      //         },
                      //         child: Text('Fechar'),
                      //       ),
                      //     ],
                      //   ),
                      // );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
