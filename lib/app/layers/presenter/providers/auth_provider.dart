import 'package:connect_force_app/app/layers/presenter/logged_in/failure_screen.dart';
import 'package:connect_force_app/app/layers/presenter/logged_in/main_menu_screen.dart';
import 'package:connect_force_app/app/layers/presenter/providers/data_provider.dart';
import 'package:connect_force_app/navigation.dart';
import 'package:flutter/material.dart';
import 'package:connect_force_app/app/layers/domain/usecases/auth/alter_password_usecase.dart';
import 'package:connect_force_app/app/layers/domain/usecases/auth/sign_in_usecase.dart';
import 'package:connect_force_app/app/layers/domain/usecases/storage/save_data_to_send_usecase.dart';
import 'package:connect_force_app/app/layers/presenter/providers/config_provider.dart';
import 'package:connect_force_app/app/layers/presenter/providers/user_provider.dart';

class AuthProvider extends ChangeNotifier {
  final SignInUsecase signInUsecase;
  final SaveDataToSendUsecase saveDataToSendUsecase;
  final AlterPasswordUsecase alterPassordUseCase;

  late UserProvider userProvider;
  late ConfigProvider _configProvider;
  late DataProvider _dataProvider;

  AuthProvider(
    this.signInUsecase,
    this.saveDataToSendUsecase,
    this.alterPassordUseCase,
  );
  // final Endpoints endpoints = Endpoints();
  void setUserProvider(UserProvider provider) => userProvider = provider;
  void setConfigProvider(ConfigProvider provider) => _configProvider = provider;
  void setDataProvider(DataProvider provider) => _dataProvider = provider;

  Future signIn(BuildContext context, bool mounted, email, password, {bool forceCheckin = false}) async {
    final result = await signInUsecase([email, password]);

    await _configProvider.saveLastLoggedEmail(email);
    await _configProvider.saveLastLoggedPassword(password);

    return result.fold(
      (l) async {
        await push(
          context,
          FailureScreen(
            failureType: '',
            title: l.title,
            message: l.message,
          ),
        );
      },
      (r) async {
        Map payload = r[0] as Map;
        await _dataProvider.saveDataToSend(context, uri: 'login', payload: payload);
        await pushAndRemoveUntil(
          context,
          const MainMenuScreen(),
        );
      },
    );
  }

  static of(BuildContext context) {}

  // Future<void> checkAccessToken(
  //   BuildContext context,
  //   bool mounted,
  // ) async {
  //   var emailLogger = await _configProvider.loadLastLoggedEmail();
  //   var passwordLogger = await _configProvider.loadLastLoggedPassword();

  //   await signIn(context, mounted, emailLogger, passwordLogger,
  //       forceCheckin: true);
  // }
}
