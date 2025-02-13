import "package:connect_force_app/app/layers/presenter/logged_in/main_menu_screen.dart";
import "package:connect_force_app/app/layers/presenter/logged_in/screens/clientes/clientes_lista_screen.dart";
import "package:connect_force_app/app/layers/presenter/logged_in/screens/configuracao/configuracao_screen.dart";
import "package:connect_force_app/app/layers/presenter/logged_in/screens/pedidos/pedidos_lista_screen.dart";
import "package:connect_force_app/app/layers/presenter/logged_in/screens/produtos/produtos_lista_screen.dart";
import "package:connect_force_app/app/layers/presenter/logged_in/screens/conta_receber/conta_receber_lista_screen.dart";
import "package:connect_force_app/app/layers/presenter/logged_in/screens/relatorios/relatorios_screen.dart";
import "package:connect_force_app/app/layers/presenter/logged_in/screens/sincronizar/sincronizar_screen.dart";
import "package:connect_force_app/starter.dart";
import "package:flutter/material.dart";
import "package:responsive_sizer/responsive_sizer.dart";

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  final args = settings.arguments != null ? settings.arguments as List<dynamic> : null;
  switch (settings.name) {
    case Starter.route:
      return MaterialPageRoute(
        builder: (context) => ResponsiveSizer(
          builder: (context, orientation, screenType) {
            return const Starter();
          },
        ),
      );
    case MainMenuScreen.route:
      return pageRouteBuilder(const MainMenuScreen());
    case ConfiguracaoScreen.route:
      return pageRouteBuilder(const ConfiguracaoScreen());
    case SincronizarScreen.route:
      return pageRouteBuilder(const SincronizarScreen());
    case PedidosListaScreen.route:
      return pageRouteBuilder(PedidosListaScreen());
    case ClientesListaScreen.route:
      return pageRouteBuilder(ClientesListaScreen(isFromPedido: args?[0] ?? false));
    case ProdutosListaScreen.route:
      return pageRouteBuilder(ProdutosListaScreen(isFromPedido: args?[0] ?? false));
    case ContaReceberListaScreen.route:
      return pageRouteBuilder(const ContaReceberListaScreen());
    case RelatoriosScreen.route:
      return pageRouteBuilder(const RelatoriosScreen());
  }

  return null;
}

PageRouteBuilder pageRouteBuilder(Widget screen) {
  return PageRouteBuilder(
    pageBuilder: (context, a1, a2) => screen,
    transitionsBuilder: (context, a1, a2, child) => FadeTransition(opacity: a1, child: child),
  );
}
