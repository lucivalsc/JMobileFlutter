import 'package:flutter/material.dart';
import 'package:jmobileflutter/controller/componentes.dart';
import 'package:jmobileflutter/controller/constantes.dart';

class ConfiguracaoPage extends StatefulWidget {
  ConfiguracaoPage({Key key}) : super(key: key);

  @override
  _ConfiguracaoState createState() => _ConfiguracaoState();
}

class _ConfiguracaoState extends State<ConfiguracaoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: corPadrao,
        title: Text('Configuração'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(10),
              children: [
                _dados('IP', 'Digite o IP do servidor'),
                _dados('Porta', 'Porta do servidor'),
                _dados('Usuário', 'Usuário do servidor'),
                _dados('Senha', 'Senha do servidor'),
              ],
            ),
          ),
          botaoPadrao(
            texto: 'SALVAR CONFIGURAÇÃO',
            funcao: () {},
          ),
          SizedBox(height: 10),
          botaoPadrao(
            texto: 'EFETUAR LOGIN',
            funcao: () {},
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
