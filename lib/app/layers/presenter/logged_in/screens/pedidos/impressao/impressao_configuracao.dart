// import 'package:flutter_mobx/flutter_mobx.dart';
// import 'package:intl/intl.dart';
// import 'package:jmobileflutter/app/common/theme/cores.dart';
// import 'package:jmobileflutter/app/common/theme/my_app_bar.dart';
// import 'package:jmobileflutter/app/common/theme/texto_formatado_lista.dart';
// import 'package:jmobileflutter/app/layers/presenter/screens/logged_in/view/comercial/pedidos/impressao/imports.dart';
// import 'package:jmobileflutter/app/layers/presenter/screens/logged_in/view/comercial/pedidos/pedido_store.dart';
// import 'package:bluetooth_thermal_printer_plus/bluetooth_thermal_printer_plus.dart';

// class ImpressaoConfiguracaoScreen extends StatefulWidget {
//   final PedidoStore store;
//   const ImpressaoConfiguracaoScreen({
//     super.key,
//     required this.store,
//   });

//   @override
//   State<ImpressaoConfiguracaoScreen> createState() => _ImpressaoConfiguracaoScreenState();
// }

// class _ImpressaoConfiguracaoScreenState extends State<ImpressaoConfiguracaoScreen> {
//   NumberFormat formatacao = NumberFormat.simpleCurrency(locale: 'pt_BR');

//   List availableBluetoothDevices = [];
//   bool isConnected = false;

//   @override
//   void initState() {
//     super.initState();
//     getBluetoothDevices();
//   }

//   @override
//   void dispose() {
//     // Desconectar e limpar a instância do printer ao sair da tela
//     if (isConnected) {
//       BluetoothThermalPrinter.disconnect();
//     }
//     super.dispose();
//   }

//   Future<void> getBluetoothDevices() async {
//     await requestPermissions();
//     try {
//       final List bluetooths = await BluetoothThermalPrinter.getBluetooths ?? []; // Acesso correto ao método estático
//       setState(() {
//         availableBluetoothDevices = bluetooths;
//       });
//     } catch (e) {
//       // Adicione tratamento de erros apropriado aqui
//       debugPrint('Erro ao obter dispositivos Bluetooth: $e');
//     }
//   }

//   Future<void> requestPermissions() async {
//     try {
//       if (await Permission.bluetooth.isGranted &&
//           await Permission.bluetoothScan.isGranted &&
//           await Permission.bluetoothConnect.isGranted) {
//         // Permissões já concedidas
//         return;
//       }

//       // Solicitar permissões
//       await [Permission.bluetooth, Permission.bluetoothScan, Permission.bluetoothConnect].request();
//     } catch (e) {
//       // Adicione tratamento de erros apropriado aqui
//       debugPrint('Erro ao solicitar permissões: $e');
//     }
//   }

//   Future<void> connectToDevice(String mac) async {
//     try {
//       if (isConnected) {
//         await BluetoothThermalPrinter.disconnect(); // Acesso correto ao método estático
//         setState(() {
//           isConnected = false;
//         });
//       }

//       var value = await BluetoothThermalPrinter.connect(mac); // Acesso correto ao método estático
//       final bool result = value != '';
//       setState(() {
//         isConnected = result;
//       });
//     } catch (e) {
//       // Adicione tratamento de erros apropriado aqui
//       debugPrint('Erro ao conectar ao dispositivo Bluetooth: $e');
//     }
//   }

//   Future<void> printTicket(PedidoStore store) async {
//     try {
//       var connectionStatus = await BluetoothThermalPrinter.connectionStatus; // Acesso correto à propriedade estática
//       if (connectionStatus == "true") {
//         List<int> bytes = await getTicket(store);
//         final result = await BluetoothThermalPrinter.writeBytes(bytes); // Acesso correto ao método estático
//         debugPrint("Print $result");
//       } else {
//         // Tratar cenário de não conectado
//         debugPrint('Não está conectado ao dispositivo Bluetooth.');
//       }
//     } catch (e) {
//       // Adicione tratamento de erros apropriado aqui
//       debugPrint('Erro ao imprimir o ticket: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Observer(
//         builder: (_) => Scaffold(
//           body: Container(
//             color: Cores.corBarraStatus,
//             child: Column(
//               children: [
//                 const Cabecalho(),
//                 const MyAppBar(texto: 'Configuração da Impressão'),
//                 Text('ID do pedido: ${widget.store.guid!}'),
//                 Divider(color: Cores.corPadrao),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 10, right: 10),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             TextoFormatadoLista(
//                               titulo: 'Razão Social:',
//                               texto: widget.store.razaoSocial,
//                             ),
//                             TextoFormatadoLista(
//                               titulo: 'CNPJ/CPF:',
//                               texto: widget.store.cnpj ?? '',
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Divider(color: Cores.corPadrao),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 10, right: 10),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextoFormatadoLista(
//                           titulo: 'Condição de pagamento:',
//                           texto: widget.store.listaPrazoPagamentoAtiva ?? '',
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Divider(color: Cores.corPadrao),
//                 Container(
//                   margin: const EdgeInsets.all(5),
//                   padding: const EdgeInsets.all(5),
//                   color: Colors.black12,
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 10, right: 10),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Flexible(
//                           child: TextoFormatadoLista(
//                             titulo: 'Valor Total',
//                             texto: formatacao.format(double.parse(widget.store.valorTotalItens.toString())),
//                           ),
//                         ),
//                         Flexible(
//                           child: TextoFormatadoLista(
//                             textAlign: TextAlign.end,
//                             titulo: 'Qtde Itens',
//                             texto: widget.store.pedidositens.length.toString(),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const Divider(),
//                 Expanded(
//                   child: ListView.separated(
//                     separatorBuilder: (BuildContext context, int index) => const Divider(),
//                     itemCount: availableBluetoothDevices.length,
//                     itemBuilder: (context, index) {
//                       final device = availableBluetoothDevices[index];
//                       List list = device.split("#");
//                       return ListTile(
//                         title: Text(list[0]),
//                         onTap: () {
//                           final mac = device.split("#")[1].trim();
//                           connectToDevice(mac);
//                         },
//                         subtitle: const Text("IMPRIMIR"),
//                         trailing: const Icon(Icons.print),
//                       );
//                     },
//                   ),
//                 ),
//                 if (isConnected) ...[
//                   ElevatedButton(
//                     onPressed: () {
//                       printTicket(widget.store);
//                     },
//                     style: ElevatedButton.styleFrom(
//                       minimumSize: Size(MediaQuery.of(context).size.width - 8, 50),
//                       backgroundColor: Cores.corPadrao,
//                     ),
//                     child: const Text('Imprimir Cupom'),
//                   ),
//                   const SizedBox(height: 10),
//                 ]
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
