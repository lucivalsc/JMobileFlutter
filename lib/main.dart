import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jmobileflutter/configuracaopage.dart';
import 'package:jmobileflutter/controller/constantes.dart';
import 'package:jmobileflutter/controller/imagens_svg.dart';
import 'package:jmobileflutter/relatorios.dart';
import 'package:jmobileflutter/sincronizar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.light.copyWith(
      statusBarColor: corPadrao,
      systemNavigationBarColor: corBarraInferior,
      //statusBarBrightness: Brightness.dark,
      //Ícones superior e inferior
      //statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Principal(),
  ));
}

class Principal extends StatefulWidget {
  Principal({Key key}) : super(key: key);

  @override
  _PrincipalState createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: corPadrao,
        title: Text('JMobile - Usuário'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(10),
              children: [
                Text(
                  'Atualizado em: 12/07/2021 18:32:02',
                  style: TextStyle(fontSize: 10),
                ),
                Text(
                  'Latitude: 0 Longitude: 0',
                  style: TextStyle(fontSize: 10),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _botaoInfo(texto: '35 vendas'),
                    _botaoInfo(texto: '15 não enviadas'),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _botaoAtividade(texto: 'Pedidos', imagem: Pedidos),
                    _botaoAtividade(
                        texto: 'Sincronizar',
                        imagem: Sincronizar,
                        funcao: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SincronizarPage(),
                            ),
                          );
                        }),
                    _botaoAtividade(
                        texto: 'Configuração',
                        imagem: Configuracao,
                        funcao: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConfiguracaoPage(),
                            ),
                          );
                        }),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _botaoAtividade(texto: 'Receber', imagem: Receber),
                    _botaoAtividade(
                        texto: 'Relatórios',
                        imagem: Relatorios,
                        funcao: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RelatoriosPage(),
                            ),
                          );
                        }),
                    _botaoAtividade(),
                  ],
                ),
              ],
            ),
          ),
          Text(
            'Versão 1.0.0',
            style: TextStyle(fontSize: 10),
          )
        ],
      ),
    );
  }

  _botaoInfo({String texto}) {
    return Container(
      height: 45,
      width: (MediaQuery.of(context).size.width - 40) / 2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: corBarraInferior,
      ),
      child: Center(
        child: Text(
          '$texto',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  _botaoAtividade({String texto, String imagem, Function funcao}) {
    return InkWell(
      onTap: funcao,
      child: Container(
        padding: EdgeInsets.all(5),
        height: 100,
        width: (MediaQuery.of(context).size.width - 40) / 3,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          // color: corBarraInferior,
          border: Border.all(
            width: 1,
            color: texto == null ? Colors.transparent : corPadrao,
          ),
        ),
        child: Column(
          children: [
            imagem == null
                ? Container()
                : SvgPicture.string(
                    imagem,
                    height: 50,
                  ),
            Text(texto == null ? '' : '$texto'),
          ],
        ),
      ),
    );
  }
}
