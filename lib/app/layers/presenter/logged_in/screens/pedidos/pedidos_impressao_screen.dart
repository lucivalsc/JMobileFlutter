import 'package:connect_force_app/app/common/utils/functions.dart';
import 'package:connect_force_app/app/common/widgets/text_rich_format.dart';
import 'package:connect_force_app/app/layers/data/datasources/local/banco_datasource_implementation.dart';
import 'package:connect_force_app/app/layers/presenter/providers/data_provider.dart';
import 'package:connect_force_app/app/layers/presenter/providers/pedido_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PedidosImpressaoScreen extends StatefulWidget {
  final int idPedido;
  const PedidosImpressaoScreen({super.key, required this.idPedido});

  @override
  State<PedidosImpressaoScreen> createState() => _PedidosImpressaoScreenState();
}

class _PedidosImpressaoScreenState extends State<PedidosImpressaoScreen> {
  final Databasepadrao banco = Databasepadrao.instance;
  late DataProvider dataProvider;
  late PedidoProvider pedidoProvider;
  late Future<void> future;

  @override
  void initState() {
    super.initState();
    future = initScreen();
  }

  @override
  void dispose() {
    pedidoProvider.disconnectBluetooth();
    super.dispose();
  }

  Future<void> initScreen() async {
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    pedidoProvider = Provider.of<PedidoProvider>(context, listen: false);
    pedidoProvider.usuario = await dataProvider.loadDataToSend(uri: 'login');
    pedidoProvider.listaPedido = await banco.imprimirPedido(widget.idPedido.toString());

    await pedidoProvider.getBluetoothDevices();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recibo'),
        actions: [
          IconButton(
            icon: Icon(Icons.print),
            onPressed: () async {
              pedidoProvider.showDeviceSelectionModal(context, dataProvider);
            },
          ),
          // IconButton(
          //   icon: Icon(Icons.picture_as_pdf),
          //   onPressed: () async {
          //     await pedidoProvider.generateAndOpenPdf();
          //   },
          // ),
        ],
      ),
      body: FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: SafeArea(child: const Center(child: CircularProgressIndicator())));
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // Cabeçalho
                Center(
                  child: Text(
                    'Recibo de Venda',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Divider(),
                TextRichFormat(
                    title: 'Data Impressão: ', subtitle: DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())),
                SizedBox(height: 8),
                TextRichFormat(
                    title: 'Data Venda: ', subtitle: formatDatetime(pedidoProvider.listaPedido[0]['DATAHORA'])),
                SizedBox(height: 8),
                TextRichFormat(title: 'Número de Venda: ', subtitle: '${pedidoProvider.listaPedido[0]['IDPEDIDO']}'),
                SizedBox(height: 8),
                TextRichFormat(title: 'Vendedor: ', subtitle: '${pedidoProvider.usuario['NOME']}'),
                SizedBox(height: 8),
                TextRichFormat(title: 'Latitude: ', subtitle: dataProvider.latitudeController.text),
                SizedBox(height: 8),
                TextRichFormat(title: 'Longitude: ', subtitle: dataProvider.longitudeController.text),
                SizedBox(height: 16),
                Divider(),
                // Informações do Cliente
                TextRichFormat(title: 'Cliente: ', subtitle: '${pedidoProvider.listaPedido[0]['CODIGORELATORIO']}'),
                Text('${pedidoProvider.listaPedido[0]['NOMECLIENTE']}'),
                SizedBox(height: 16),
                // Produtos
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '-------------- Produtos --------------',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: pedidoProvider.listaPedido.length,
                  itemBuilder: (context, index) {
                    var item = pedidoProvider.listaPedido[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Alinhando título à esquerda e valor à direita
                          TextRichFormat(
                            title: 'Código Produto: ',
                            subtitle: item['CODIGOPRODUTO'] ?? '',
                          ),
                          TextRichFormat(
                            title: 'Descrição: ',
                            subtitle: item['NOMEPROD'] ?? '',
                          ),
                          Divider(),
                          TextRichFormat(
                            title: 'Quantidade: ',
                            subtitle:
                                '${formatCurrency(item['QTDE'], symbol: '')} X  ${formatCurrency(item['VALORUNITARIO'])}',
                          ),
                          TextRichFormat(
                            title: 'Total: ',
                            subtitle: formatCurrency(item['VALORTOTAL']),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: 16),
                // Totais
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Produtos:'),
                    Text(formatCurrency(pedidoProvider.listaPedido[0]['TOTALPRODUTOS'], symbol: '')),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Valor Total:'),
                    Text('R\$ ${pedidoProvider.listaPedido[0]['VALORTOTAL']}'),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Desconto:'),
                    Text(formatCurrency(pedidoProvider.listaPedido[0]['DESCONTO'])),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Entrada:'),
                    Text(formatCurrency(pedidoProvider.listaPedido[0]['VALORENTRADA'])),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Valor Parcelado:'),
                    Text(formatCurrency(pedidoProvider.listaPedido[0]['VALORTOTALCALC'] /
                        int.parse(pedidoProvider.listaPedido[0]['PRAZOPAGTO']))),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Prazo Pagamento:'),
                    Text('${pedidoProvider.listaPedido[0]['PRAZOPAGTO']}'),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('1º Vencimento:'),
                    Text(formatDate(pedidoProvider.listaPedido[0]['INICIO_VENCIMENTO'])),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
