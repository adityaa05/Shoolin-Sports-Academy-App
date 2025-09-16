import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionChangeController = StreamController<bool>.broadcast();

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen(_connectionChanged);
    _checkInitialConnection();
  }

  Stream<bool> get connectionChange => _connectionChangeController.stream;

  void _connectionChanged(ConnectivityResult result) {
    _connectionChangeController.add(_isConnected(result));
  }

  Future<void> _checkInitialConnection() async {
    final result = await _connectivity.checkConnectivity();
    _connectionChangeController.add(_isConnected(result));
  }

  bool _isConnected(ConnectivityResult result) {
    return result == ConnectivityResult.mobile || result == ConnectivityResult.wifi;
  }

  void dispose() {
    _connectionChangeController.close();
  }
} 