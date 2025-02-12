import 'package:intl/intl.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

class ReciboImpressao {
  final Map filialData;
  final Map usuarioData;
  final List itensPedido;
  final double valorTotalItens;
  final String formaPagamento;
  final String observacao;

  ReciboImpressao({
    required this.filialData,
    required this.usuarioData,
    required this.itensPedido,
    required this.valorTotalItens,
    required this.formaPagamento,
    required this.observacao,
  });

  Future<List<int>> gerarRecibo() async {
    List<int> bytes = [];
    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    // Inicializa formatadores
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final numberFormat = NumberFormat.decimalPattern('pt_BR');

    // Dados da filial
    bytes += generator.text(
      "${filialData['NOME']}",
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );

    bytes += generator.text(
      'CNPJ: ${filialData['CNPJ']}',
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.text(
      '${filialData['ENDERECO']}, ${filialData['CIDADE']} - ${filialData['ESTADO']}',
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.text(
      'Telefone: ${filialData['TELEFONE']}',
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.hr();

    // Dados do usuário
    bytes += generator.text(
      usuarioData['razaoSocial']!,
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );

    bytes += generator.text(
      'CNPJ/CPF: ${usuarioData['cnpj']}',
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.text(
      '${usuarioData['enderecoRua']}, ${usuarioData['enderecoNumero']}, ${usuarioData['enderecoCep']}, ${usuarioData['enderecoCidade']} - ${usuarioData['enderecoEstado']}',
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.text(
      'Telefone: ${usuarioData['telefone']}',
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.hr();

    bytes += generator.text('PEDIDO', styles: const PosStyles(align: PosAlign.center, bold: true));

    bytes += generator.hr();

    // Cabeçalho da Tabela
    bytes += generator.row(
      [
        PosColumn(
          text: 'Codigo',
          width: 2,
          styles: const PosStyles(align: PosAlign.left, bold: true),
        ),
        PosColumn(
          text: 'Item',
          width: 4, // Ajuste para caber corretamente no papel mm80
          styles: const PosStyles(align: PosAlign.left, bold: true),
        ),
        PosColumn(
          text: 'Preco',
          width: 2,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
        PosColumn(
          text: 'Qtde',
          width: 2,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
        PosColumn(
          text: 'Total',
          width: 2,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
      ],
    );

    // Itens da Tabela
    for (var item in itensPedido) {
      bytes += generator.row(
        [
          PosColumn(
            text: item['CODIGOEAN'].toString(),
            width: 5,
            styles: const PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: item['DESCRICAOCOMPLETA'].toString(),
            width: 7,
            styles: const PosStyles(align: PosAlign.left),
          ),
        ],
      );

      bytes += generator.row(
        [
          PosColumn(
            text: currencyFormat.format(double.parse(item['VALORUNITARIO']!)),
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
          PosColumn(
            text: numberFormat.format(double.parse(item['QUANTIDADE']!)),
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
          PosColumn(
            text: currencyFormat.format(double.parse(item['VALORTOTAL']!)),
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ],
      );
    }

    bytes += generator.hr(ch: '-', linesAfter: 1);

    // Totalizadores
    bytes += generator.text(
      'Valor Total: ${currencyFormat.format(valorTotalItens)}',
      styles: const PosStyles(align: PosAlign.right),
    );
    bytes += generator.text(
      'Qtde Itens: ${itensPedido.length}',
      styles: const PosStyles(align: PosAlign.right),
    );

    bytes += generator.text(
      'Forma de Pagamento: $formaPagamento',
      styles: const PosStyles(align: PosAlign.right),
    );

    bytes += generator.hr(ch: '-', linesAfter: 1);

    bytes += generator.text(
      'Obs.: $observacao',
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.hr(ch: '-', linesAfter: 1);

    // Rodapé
    bytes += generator.text('Obrigado pela preferência!', styles: const PosStyles(align: PosAlign.center, bold: true));

    bytes += generator.text(
      DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()),
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.cut();

    return bytes;
  }
}
