import 'package:connect_force_app/app/common/styles/app_styles.dart';
import 'package:connect_force_app/navigation.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class BuildMainMenuButton extends StatelessWidget {
  final String title;
  final String? tela;
  final IconData? icon;
  final Function? funcao;
  final Function() onItemTapped;

  const BuildMainMenuButton({
    super.key,
    required this.title,
    required this.tela,
    required this.icon,
    this.funcao,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (tela != null) {
          await pushNamed(context, tela!);
        } else if (funcao != null) {
          funcao!();
        }
        onItemTapped.call();
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: BorderSide(color: Colors.grey, width: 1),
        ),
        elevation: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.width / 6.5,
              width: MediaQuery.of(context).size.width / 6.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppStyles().secondaryColor2,
              ),
              child: Icon(
                icon,
                size: MediaQuery.of(context).size.width / 8.5,
                color: AppStyles().primaryColor, // substitua por appStyles.blackColor, se desejar
              ),
            ),
            const SizedBox(height: 12),
            AutoSizeText(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black, // substitua por appStyles.blackColor, se desejar
                fontSize: 16,
                fontFamily: 'serif',
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
