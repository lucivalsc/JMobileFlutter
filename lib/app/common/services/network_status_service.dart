import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:data_connection_checker_nulls/data_connection_checker_nulls.dart';

enum NetworkStatus { online, offline }

class NetworkStatusService {
  late StreamController<NetworkStatus> _streamController;
  late StreamSubscription _subscription;
  late Timer _timer;
  //
  bool isEnable = true, _isStreamSubscriptionActive = false;

  NetworkStatusService();

  void enableService(bool value) {
    isEnable = value;
    if (value) {
      _streamController = StreamController<NetworkStatus>();
      _timer = newTimer;
      checkInternetAccess().then((value) {
        if (!_isStreamSubscriptionActive) {
          _subscription = newSubscription;
          _isStreamSubscriptionActive = true;
        }

        if (_timer.isActive) {
          _timer.cancel();
        }

        if (value == NetworkStatus.offline) {
          _streamController.add(value);
        } else {
          _timer = newTimer;
        }
      });
    } else {
      _subscription.cancel();
      _isStreamSubscriptionActive = false;
      _timer.cancel();
      _streamController.close();
    }
  }

  Future<NetworkStatus> checkInternetAccess() async {
    final status = await Connectivity().checkConnectivity();
    if (status == ConnectivityResult.wifi || status == ConnectivityResult.mobile) {
      return await DataConnectionChecker().hasConnection.then((value) => value ? NetworkStatus.online : NetworkStatus.offline);
    } else {
      return NetworkStatus.offline;
    }
  }

  Stream<NetworkStatus> get stream => _streamController.stream;

  StreamSubscription get newSubscription => Connectivity().onConnectivityChanged.listen(
        (status) async {
          if (status == ConnectivityResult.mobile || status == ConnectivityResult.wifi) {
            if (!_timer.isActive) _timer = newTimer;
            if (await DataConnectionChecker().hasConnection) {
              _streamController.add(NetworkStatus.online);
            } else {
              _streamController.add(NetworkStatus.offline);
            }
          } else {
            _timer.cancel();
            _streamController.add(NetworkStatus.offline);
          }
        },
      );

  Timer get newTimer => Timer.periodic(const Duration(seconds: 15), (_) async {
        final status = await Connectivity().checkConnectivity();
        if (status == ConnectivityResult.wifi || status == ConnectivityResult.mobile) {
          if (await DataConnectionChecker().hasConnection) {
            _streamController.add(NetworkStatus.online);
          } else {
            _streamController.add(NetworkStatus.offline);
          }
        } else {
          _streamController.add(NetworkStatus.offline);
          _timer.cancel();
        }
      });
}
