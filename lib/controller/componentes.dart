import 'package:flutter/material.dart';

import 'package:jmobileflutter/controller/constantes.dart';

class botaoPadrao extends StatelessWidget {
  final String texto;
  final Function funcao;
  final Color cor;

  const botaoPadrao({
    Key key,
    this.texto,
    this.funcao,
    this.cor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: funcao,
      child: Container(
        padding: EdgeInsets.all(5),
        height: 48,
        width: (MediaQuery.of(context).size.width - 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          // color: corBarraInferior,
          border: Border.all(
            width: 1,
            color: cor == null ? corPadrao : cor,
          ),
        ),
        child: Center(
            child: Text(
          '$texto',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: cor == null ? corPadrao : cor,
          ),
        )),
      ),
    );
  }
}
