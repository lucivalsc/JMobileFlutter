import 'package:jmobileflutter/app/common/widgets/app_widgets.dart';
import 'package:flutter/material.dart';
import 'package:jmobileflutter/app/common/styles/app_styles.dart';

class FailureScreen extends StatelessWidget {
  final String failureType;
  final String? title;
  final String? message;
  final appStyles = AppStyles();
  final appWidgets = AppWidgets();

  static const route = "failure";

  FailureScreen({required this.failureType, this.title, this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appStyles.failureScreenColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;
            final width = constraints.maxWidth;
            return Stack(
              children: [
                // CompanyBackground(height),
                Container(
                  height: height,
                  width: width,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Column(
                        children: [
                          SizedBox(height: 60),
                          // Container(
                          //   height: 80,
                          //   width: 80,
                          //   decoration: BoxDecoration(
                          //     image: DecorationImage(
                          //       fit: BoxFit.contain,
                          //       image: AssetImage(appStyles.failureIconPath),
                          //       colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (title != null) appWidgets.buildBoldText(width, title!, color: Colors.white),
                            appWidgets.buildThinText(width, message ?? "Houve um erro desconhecido :(",
                                color: Colors.white),
                            const SizedBox(height: 40),
                            appWidgets.buildSecondaryButton(
                              "CANCELAR",
                              () => Navigator.of(context).pop(),
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
