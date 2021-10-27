import 'package:flutter/material.dart';
import 'package:jmobileflutter/controller/componentes.dart';
import 'package:jmobileflutter/controller/constantes.dart';

class RelatoriosPage extends StatefulWidget {
  RelatoriosPage({Key key}) : super(key: key);

  @override
  _RelatoriosPageState createState() => _RelatoriosPageState();
}

class _RelatoriosPageState extends State<RelatoriosPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: corPadrao,
        title: Text('Relatórios'),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            height: 180,
            color: corPadrao,
            child: Column(
              children: [
                Text(
                  'Data inicial',
                  style: TextStyle(color: Colors.white),
                ),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: TextField(),
                ),
                SizedBox(height: 10),
                Text(
                  'Data final',
                  style: TextStyle(color: Colors.white),
                ),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: TextField(),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(10),
              children: [
                botaoPadrao(
                  texto: 'Relatório recebidas',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
