import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class RelatoriosDeVendasScreen extends StatelessWidget {
  const RelatoriosDeVendasScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Relatório de Vendas por Fornecedor',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 250,
            child: _buildBarChartForFornecedor(),
          ),
          const SizedBox(height: 20),
          Divider(),
          const Text(
            'Relatório de Vendas por Cliente',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 250,
            child: _buildBarChartForCliente(),
          ),
          const SizedBox(height: 20),
          Divider(),
          const Text(
            'Gráfico de Pizza - Percentual de Atingimento',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 250,
            child: _buildPieChart(),
          ),
        ],
      ),
    );
  }

  // Gráfico de Barras para Fornecedores (Fábricas)
  Widget _buildBarChartForFornecedor() {
    final data = [
      SalesData('Fábrica A', 50, 100000),
      SalesData('Fábrica B', 75, 80000),
    ];
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      title: ChartTitle(text: 'Percentual de Atingimento por Fornecedor'),
      series: [
        ColumnSeries<SalesData, String>(
          dataSource: data,
          xValueMapper: (SalesData sales, _) => sales.label,
          yValueMapper: (SalesData sales, _) => (sales.value / sales.metaMensal) * 100, // Percentual de atingimento
          color: Colors.green,
          borderRadius: BorderRadius.circular(10),
        ),
      ],
    );
  }

  // Gráfico de Barras para Clientes
  Widget _buildBarChartForCliente() {
    final data = [
      SalesData('Cliente X', 50, 20000),
      SalesData('Cliente Y', 83, 30000),
    ];
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      title: ChartTitle(text: 'Percentual de Atingimento por Cliente'),
      series: [
        ColumnSeries<SalesData, String>(
          dataSource: data,
          xValueMapper: (SalesData sales, _) => sales.label,
          yValueMapper: (SalesData sales, _) => (sales.value / sales.metaMensal) * 100, // Percentual de atingimento
          color: Colors.blue,
          borderRadius: BorderRadius.circular(10),
        ),
      ],
    );
  }

  // Gráfico de Pizza para Percentual de Atingimento
  Widget _buildPieChart() {
    final data = [
      SalesData('Atingido', 50, 100000),
      SalesData('Restante', 50, 100000),
    ];
    return SfCircularChart(
      title: ChartTitle(text: 'Percentual Atingido vs Restante'),
      legend: Legend(isVisible: true),
      series: <PieSeries<SalesData, String>>[
        PieSeries<SalesData, String>(
          dataSource: data,
          xValueMapper: (SalesData sales, _) => sales.label,
          yValueMapper: (SalesData sales, _) => sales.value,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        ),
      ],
    );
  }
}

class SalesData {
  final String label;
  final double value;
  final double metaMensal;

  SalesData(this.label, this.value, this.metaMensal);
}


// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';

// class RelatoriosDeVendasScreen extends StatelessWidget {
//   const RelatoriosDeVendasScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         children: [
//           const Text(
//             'Gráfico de Barras',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(
//             height: 250,
//             child: _buildBarChart(),
//           ),
//           const SizedBox(height: 20),
//           Divider(),
//           const Text(
//             'Gráfico de Pizza',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(
//             height: 250,
//             child: _buildPieChart(),
//           ),
//           const SizedBox(height: 20),
//           Divider(),
//           const Text(
//             'Gráfico de Linha',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(
//             height: 250,
//             child: _buildLineChart(),
//           ),
//           const SizedBox(height: 20),
//           Divider(),
//           const Text(
//             'Gráfico de Área',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(
//             height: 250,
//             child: _buildAreaChart(),
//           ),
//           const SizedBox(height: 20),
//           Divider(),
//           const Text(
//             'Gráfico de Dispersão',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(
//             height: 250,
//             child: _buildScatterChart(),
//           ),
//         ],
//       ),
//     );
//   }

//   // Gráfico de Barras
//   Widget _buildBarChart() {
//     final data = [
//       SalesData('Jan', 30),
//       SalesData('Feb', 50),
//       SalesData('Mar', 70),
//       SalesData('Apr', 40),
//     ];
//     return SfCartesianChart(
//       primaryXAxis: CategoryAxis(),
//       title: ChartTitle(text: 'Vendas Mensais'),
//       series: [
//         ColumnSeries<SalesData, String>(
//           dataSource: data,
//           xValueMapper: (SalesData sales, _) => sales.label,
//           yValueMapper: (SalesData sales, _) => sales.value,
//           color: Colors.blue,
//         ),
//       ],
//     );
//   }

//   // Gráfico de Pizza
//   Widget _buildPieChart() {
//     final data = [
//       SalesData('Produto A', 40),
//       SalesData('Produto B', 30),
//       SalesData('Produto C', 20),
//       SalesData('Produto D', 10),
//     ];
//     return SfCircularChart(
//       title: ChartTitle(text: 'Participação por Produto'),
//       legend: Legend(isVisible: true),
//       series: <PieSeries<SalesData, String>>[
//         PieSeries<SalesData, String>(
//           dataSource: data,
//           xValueMapper: (SalesData sales, _) => sales.label,
//           yValueMapper: (SalesData sales, _) => sales.value,
//           dataLabelSettings: const DataLabelSettings(isVisible: true),
//         ),
//       ],
//     );
//   }

//   // Gráfico de Linha
//   Widget _buildLineChart() {
//     final data = [
//       SalesData('Jan', 30),
//       SalesData('Feb', 40),
//       SalesData('Mar', 50),
//       SalesData('Apr', 35),
//     ];
//     return SfCartesianChart(
//       primaryXAxis: CategoryAxis(),
//       title: ChartTitle(text: 'Crescimento Mensal'),
//       series: [
//         LineSeries<SalesData, String>(
//           dataSource: data,
//           xValueMapper: (SalesData sales, _) => sales.label,
//           yValueMapper: (SalesData sales, _) => sales.value,
//           color: Colors.green,
//         ),
//       ],
//     );
//   }

//   // Gráfico de Área
//   Widget _buildAreaChart() {
//     final data = [
//       SalesData('Jan', 10),
//       SalesData('Feb', 20),
//       SalesData('Mar', 15),
//       SalesData('Apr', 25),
//     ];
//     return SfCartesianChart(
//       primaryXAxis: CategoryAxis(),
//       title: ChartTitle(text: 'Área de Crescimento'),
//       series: [
//         AreaSeries<SalesData, String>(
//           dataSource: data,
//           xValueMapper: (SalesData sales, _) => sales.label,
//           yValueMapper: (SalesData sales, _) => sales.value,
//           color: Colors.red.withOpacity(0.5),
//           borderColor: Colors.red,
//           borderWidth: 2,
//         ),
//       ],
//     );
//   }

//   // Gráfico de Dispersão
//   Widget _buildScatterChart() {
//     final data = [
//       SalesData('Jan', 5),
//       SalesData('Feb', 25),
//       SalesData('Mar', 100),
//       SalesData('Apr', 75),
//     ];
//     return SfCartesianChart(
//       primaryXAxis: CategoryAxis(),
//       title: ChartTitle(text: 'Vendas por Dispersão'),
//       series: [
//         ScatterSeries<SalesData, String>(
//           dataSource: data,
//           xValueMapper: (SalesData sales, _) => sales.label,
//           yValueMapper: (SalesData sales, _) => sales.value,
//           color: Colors.purple,
//         ),
//       ],
//     );
//   }
// }

// class SalesData {
//   final String label;
//   final int value;

//   SalesData(this.label, this.value);
// }
