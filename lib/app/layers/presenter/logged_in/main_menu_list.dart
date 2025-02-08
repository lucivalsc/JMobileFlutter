import 'package:flutter/material.dart';
import 'package:jmobileflutter/app/common/styles/app_styles.dart';
import 'package:jmobileflutter/app/common/widgets/app_widgets.dart';
import 'package:jmobileflutter/app/common/widgets/build_main_menu_button.dart';
import 'package:jmobileflutter/app/layers/presenter/providers/auth_provider.dart';
import 'package:jmobileflutter/app/layers/presenter/providers/user_provider.dart';

class MainMenuList extends StatefulWidget {
  final AuthProvider provider;
  final UserProvider userProvider;
  const MainMenuList({
    super.key,
    required this.provider,
    required this.userProvider,
  });

  @override
  State<MainMenuList> createState() => _MainMenuListState();
}

class _MainMenuListState extends State<MainMenuList> {
  final appStyles = AppStyles();
  final appWidgets = AppWidgets();

  final List<Map<String, dynamic>> listButtons = [
    {
      'title': 'Pedidos',
      'route': 'pedidos_lista_screen',
      'icon': Icons.shopping_bag,
    },
    {
      'title': 'A Receber',
      'route': 'conta_receber_lista_screen',
      'icon': Icons.attach_money_rounded,
    },
    {
      'title': 'Relatórios',
      'route': 'relatorios_screen',
      'icon': Icons.bar_chart_outlined,
    },
    {
      'title': 'Produtos',
      'route': 'produtos_lista_screen',
      'icon': Icons.shopping_bag,
    },
    {
      'title': 'Clientes',
      'route': 'clientes_lista_screen',
      'icon': Icons.people,
    },
    {
      'title': 'Sincronizar',
      'route': 'sincronizar_screen',
      'icon': Icons.autorenew,
    },
    {
      'title': 'Configurações',
      'route': 'configuracao_screen',
      'icon': Icons.settings,
    },
  ];
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: constraints.maxHeight,
          width: constraints.maxWidth,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    childAspectRatio: 1.4,
                  ),
                  itemCount: listButtons.length,
                  itemBuilder: (context, index) {
                    return BuildMainMenuButton(
                      title: listButtons[index]['title'],
                      tela: listButtons[index]['route'],
                      icon: listButtons[index]['icon'],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
