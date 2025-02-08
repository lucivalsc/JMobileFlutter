/* 
  Tamanho médio: isz:m 
  Tamanho grande: isz:l 
  Tamanho extra grande: isz:ex 
  Qualidade de alta resolução (HD): iar:rc (retângulo alto), iar:s (quadrado), etc. 
*/ 
 
import 'package:html/parser.dart'; 
import 'package:http/http.dart' as http; 
 
class ImageScraperService { 
  Future<List<String>> fetchImages(String searchTerm) async { 
    if (searchTerm.trim().isEmpty) return []; 
 
    // Formatação do termo de busca para a URL 
    final formattedTerm = searchTerm.replaceAll(' ', '+'); 
    const filter = '&iar=rc&sca_esv=567693071&tbm=isch&source=hp&biw=1552&bih=786&ei=y_sNZe-cIJDi5OUPgIy1kA8&iflsig=AO6bgOgAAAAAZQ4J23NJKTekiMslbKGH9RsoY8bonegg&ved=0ahUKEwivrtn6ib-BAxUQMbkGHQBGDfIQ4dUDCAc&uact=5&oq=cabo+de+antena+&gs_lp=EgNpbWciD2NhYm8gZGUgYW50ZW5hIDIFEAAYgAQyBRAAGIAEMgUQABiABDIFEAAYgAQyBRAAGIAEMgUQABiABDIFEAAYgAQyBRAAGIAEMgQQABgeMgQQABgeSKceUMAEWIMccAB4AJABAJgBe6ABog2qAQQwLjE1uAEDyAEA-AEBigILZ3dzLXdpei1pbWeoAgDCAgQQABgDwgIIEAAYsQMYgwHCAggQABiABBixAw&sclient=img'; 
    // URL da pesquisa Google Imagens com filtro de tamanho grande 
    final url = Uri.parse('https://www.google.com/search?q=$formattedTerm$filter'); 
 
    try { 
      // Realiza a requisição GET 
      final response = await http.get(url); 
      if (response.statusCode != 200) throw Exception('Falha ao acessar o Google Imagens.'); 
 
      // Parse do conteúdo HTML 
      final document = parse(response.body); 
 
      // Captura as tags de imagem que contêm URLs 
      final imageElements = document.querySelectorAll('img'); 
      final imageUrls = <String>[]; 
 
      for (var element in imageElements) { 
        final src = element.attributes['src']; 
 
        // Verifica se a URL da imagem não está vazia e é válida 
        if (src != null && src.startsWith('http')) { 
          imageUrls.add(src); 
        } 
      } 
 
      return imageUrls; 
    } catch (e) { 
      print('Erro ao buscar imagens: $e'); 
      return []; 
    } 
  } 
}