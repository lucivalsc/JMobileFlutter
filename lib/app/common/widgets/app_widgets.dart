import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:connect_force_app/navigation.dart';

import '../styles/app_styles.dart';

class AppWidgets {
  final appStyles = AppStyles();

  final List<String> months = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro'
  ];

  Widget buildBoldText(double width, String text, {Color? color}) {
    return Flexible(
      child: Text(
        text,
        style: const TextStyle().copyWith(
          fontSize: appStyles.boldText.fontSize,
          fontWeight: appStyles.boldText.fontWeight,
          color: color ?? appStyles.boldText.color,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget buildThinText(double width, String text, {Color? color}) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: const TextStyle().copyWith(
          fontSize: appStyles.thinText.fontSize,
          fontWeight: appStyles.thinText.fontWeight,
          color: color ?? appStyles.thinText.color,
        ),
        maxLines: 4,
      ),
    );
  }

  Widget buildPrimaryButton(
    Function onPressed, {
    String label = "",
    bool enable = true,
    bool processing = false,
    Color? buttonColor,
    Widget? child,
    double? margin,
    double? tamanho,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(left: 15, right: 15, top: 10),
      height: 50,
      width: processing ? 50 : tamanho ?? double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor ?? appStyles.secondaryColor2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(processing ? 50 : 5),
          ),
          elevation: 0,
        ),
        onPressed: enable ? () => onPressed() : null,
        child: processing
            ? SizedBox(
                height: 20,
                width: 20,
                child: Center(
                  child: CircularProgressIndicator(
                    color: appStyles.colorWhite,
                    strokeWidth: 2,
                  ),
                ),
              )
            : child ??
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: appStyles.colorWhite,
                  ),
                ),
      ),
    );
  }

  Widget buildSecondaryButton(
    String label,
    Function onPressed, {
    bool enable = true,
    Color? color,
  }) {
    return SizedBox(
      height: 60,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9.0)),
            elevation: 0,
            side: enable ? BorderSide(color: color ?? appStyles.primaryColor, width: 0.5) : null),
        onPressed: enable ? () => onPressed() : null,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: enable ? color ?? appStyles.primaryColor : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget buildUserIcon({required double radius}) {
    return CircleAvatar(
      backgroundColor: appStyles.colorWhite,
      radius: radius,
      child: const ClipOval(
        child: Icon(
          Icons.person,
          size: 100,
        ),
      ),
    );
  }

  Widget buildEmptyInfo(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: const Alignment(0.04, 0.0),
            child: Image.asset(
              "lib/app/common/assets/empty_paper_2.png",
              scale: 2,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w100, fontSize: 34),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              subtitle,
              style: const TextStyle(fontWeight: FontWeight.w100, fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPrimaryButtonText(
    Function onPressed, {
    String label = "",
    bool enable = true,
    bool processing = false,
    Color? buttonColor,
    Widget? child,
    double? margin,
  }) {
    return Container(
      // margin: margin != null ? EdgeInsets.all(margin) : const EdgeInsets.all(0),

      margin: const EdgeInsets.only(left: 15, right: 15, top: 10),
      height: 50,
      width: double.infinity,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: buttonColor ?? appStyles.secondaryColor2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: 0,
        ),
        onPressed: enable ? () => onPressed() : null,
        child: processing
            ? SizedBox(
                height: 20,
                width: 20,
                child: Center(
                  child: CircularProgressIndicator(
                    color: appStyles.colorWhite,
                    strokeWidth: 2,
                  ),
                ),
              )
            : child ??
                Text(
                  label,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: appStyles.colorWhite,
                  ),
                ),
      ),
    );
  }

  buildButton(
    String title,
    String? tela,
    String? svg, [
    Function? funcao,
    BuildContext? context,
    bool? isFavorite,
    Function? funcaoFavorite,
  ]) {
    return GestureDetector(
      onTap: () {
        if (tela != null) {
          pushNamed(context!, tela);
        } else {
          funcao!();
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 10,
        child: Stack(
          children: [
            if (isFavorite != null)
              Positioned(
                right: 0,
                child: IconButton(
                  onPressed: () {
                    if (funcaoFavorite != null) {
                      funcaoFavorite();
                    }
                  },
                  icon: Icon(
                    Icons.star,
                    color: isFavorite == true ? appStyles.secondaryColor2 : Colors.grey,
                  ),
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset('lib/app/common/assets/svg/$svg.svg'),
                const SizedBox(height: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                      child: AutoSizeText(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: appStyles.primaryColor,
                          fontSize: 20,
                        ),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
