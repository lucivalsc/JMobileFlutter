import 'package:jmobileflutter/app/common/widgets/app_widgets.dart';
import 'package:flutter/material.dart';
import 'package:jmobileflutter/app/common/styles/app_styles.dart';

class SuccessfulScreen extends StatelessWidget {
  final String description;
  final String? routeBack;
  final appStyles = AppStyles();
  final appWidgets = AppWidgets();
  SuccessfulScreen({required this.description, this.routeBack, super.key});

  static const String route = 'successful_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // CompanyBackground(constraints.maxHeight / 2),
              Container(
                height: constraints.maxHeight,
                width: constraints.maxWidth,
                color: appStyles.primaryColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              description,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.normal,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    appWidgets.buildPrimaryButton(
                      () {
                        if (routeBack != null) {
                          Navigator.of(context).popUntil((route) {
                            return route.settings.name == routeBack;
                          });
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                      label: 'OK',
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
