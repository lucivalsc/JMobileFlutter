import 'package:flutter/material.dart';
import 'package:jmobileflutter/controller/componentes.dart';
import 'package:jmobileflutter/controller/constantes.dart';

class SincronizarPage extends StatefulWidget {
  SincronizarPage({Key key}) : super(key: key);

  @override
  _SincronizarPageState createState() => _SincronizarPageState();
}

class _SincronizarPageState extends State<SincronizarPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: corPadrao,
        title: Text('Sincronizar'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(10),
              children: [
                botaoPadrao(
                  texto: 'Clientes',
                  funcao: () {},
                ),
                SizedBox(height: 10),
                botaoPadrao(
                  texto: 'Produtos',
                  funcao: () {},
                ),
                SizedBox(height: 10),
                botaoPadrao(
                  texto: 'Enviar clientes',
                  funcao: () {},
                ),
                SizedBox(height: 10),
                botaoPadrao(
                  texto: 'Contas a receber',
                  funcao: () {},
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
          SizedBox(height: 10),
          botaoPadrao(
            texto: 'Limpar base',
            funcao: () {},
            cor: Colors.red[700],
          ),
        ],
      ),
    );
  }

  _dados(String texto, String subtexto) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ListTile(
            title: Text(texto),
            subtitle: Text(subtexto),
          ),
        ),
        Container(
          height: 50,
          width: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            // color: corBarraInferior,
            border: Border.all(
              width: 1,
              color: corPadrao,
            ),
          ),
          child: TextField(
            keyboardType: TextInputType.number,
          ),
        )
      ],
    );
  }
}
