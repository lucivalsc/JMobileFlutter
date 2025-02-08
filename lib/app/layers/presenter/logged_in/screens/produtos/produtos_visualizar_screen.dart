import 'package:flutter/material.dart';
import 'package:jmobileflutter/app/layers/presenter/logged_in/screens/produtos/image_scrape_service.dart';

class ProdutosVisualizarScreen extends StatefulWidget {
  final Map<String, dynamic> produto;

  const ProdutosVisualizarScreen({super.key, required this.produto});

  @override
  State<ProdutosVisualizarScreen> createState() => _ProdutosVisualizarScreenState();
}

class _ProdutosVisualizarScreenState extends State<ProdutosVisualizarScreen> {
  final ImageScraperService _imageScraperService = ImageScraperService();
  List<String> _imageUrls = [];
  bool _isLoading = false;
  late Future<void> future;

  @override
  void initState() {
    super.initState();
    future = initScreen();
  }

  Future<void> initScreen() async {
    _searchImages();
  }

  Future<void> _searchImages() async {
    setState(() {
      _isLoading = true;
      _imageUrls = [];
    });

    final searchTerm = widget.produto['NOMEPROD'];
    final images = await _imageScraperService.fetchImages(searchTerm);

    setState(() {
      _isLoading = false;
      _imageUrls = images;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detalhes do Produto")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _isLoading
                    ? Container(
                        height: 200,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        child: const Center(child: CircularProgressIndicator()),
                      )
                    : _imageUrls.isNotEmpty
                        ? Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: const BorderSide(color: Colors.grey, width: 0.5),
                            ),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.network(
                                    _imageUrls[0],
                                    fit: BoxFit.contain,
                                    height: 200,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(child: Text('Erro ao carregar imagem'));
                                    },
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Imagem meramente ilustrativa',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w300,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Container(
                            height: 200,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            child: const Center(
                              child: Text(
                                'Nenhuma imagem\n encontrada',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 32,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  // fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ),
                SizedBox(height: 16),
                Text(
                  widget.produto["NOMEPROD"],
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                _buildDetailRow("Código do Produto", widget.produto["CODPROD"]),
                _buildDetailRow("Código", widget.produto["CODIGO"]),
                _buildDetailRow("Data de Reajuste", widget.produto["DATREAJ"]),
                _buildDetailRow("Estoque", widget.produto["ESTATU"].toString()),
                _buildDetailRow("Preço", "R\$ ${widget.produto["PRECO"].toStringAsFixed(2)}"),
                _buildDetailRow("Última Alteração", widget.produto["LAST_CHANGE"]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }
}
