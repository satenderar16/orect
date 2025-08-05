import 'dart:async';
import 'dart:io' show  Socket;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:universal_html/html.dart' as html;
import 'internet_state.dart';


class InternetNotifier extends StateNotifier<InternetState> {
  StreamSubscription? _connectivitySubscription;
  Timer? _periodicTimer;

  InternetNotifier()
      : super(const InternetState(
    hasInternet: true,

    connectionType: ConnectionType.unknown,
  )) {
  init();
  }
Future<void> init()async{
    _isConnect();
}
  void _isConnect() {
    if (kIsWeb) {
      final online = html.window.navigator.onLine ?? false;
      state = state.copyWith(
        hasInternet: online,
        connectionType: ConnectionType.unknown,
      );

      html.window.onOnline.listen((event) {
        state = state.copyWith(hasInternet: true);
      });

      html.window.onOffline.listen((event) {
        state = state.copyWith(hasInternet: false);
      });
    } else {
      _connectivitySubscription = Connectivity()
          .onConnectivityChanged
          .listen((List<ConnectivityResult> results) async {
        final isConnected = results.any((r) => r != ConnectivityResult.none);
        final connectionType = _mapConnectivityResult(results.firstOrNull);
        if (isConnected) {
          final hasInternet = await _checkInternetAccess();
          state = InternetState(
            hasInternet: hasInternet,
            connectionType: connectionType,
          );
        } else {
          state = InternetState(
            hasInternet: false,
            connectionType: ConnectionType.none,
          );
        }
      });

      Connectivity().checkConnectivity().then((result) async {
        final connectionType = _mapConnectivityResult(result.firstOrNull);
        final hasInternet = await _checkInternetAccess();
        state = InternetState(
          hasInternet: hasInternet,
          connectionType: connectionType,
        );
      });


      _periodicTimer = Timer.periodic(
        const Duration(seconds: 30),
            (_) async {
          final hasInternet = await _checkInternetAccess();
          if (state.hasInternet != hasInternet) {
            state = state.copyWith(hasInternet: hasInternet);
          }
        },
      );
    }
  }

  Future<bool> _checkInternetAccess({Duration? duration, String? address}) async {
    try {
      final socket = await Socket.connect(address  ?? '8.8.8.8', 53, timeout:duration ?? const Duration(seconds: 5));
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> retryConnection({Duration? timeOut,String? address}) async {
    final hasInternet = await _checkInternetAccess(duration: timeOut,address: address);
    state = state.copyWith(hasInternet: hasInternet);
  }

  ConnectionType _mapConnectivityResult(ConnectivityResult? result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return ConnectionType.wifi;
      case ConnectivityResult.mobile:
        return ConnectionType.mobile;
      case ConnectivityResult.ethernet:
        return ConnectionType.ethernet;
      case ConnectivityResult.none:
        return ConnectionType.none;
      default:
        return ConnectionType.unknown;
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _periodicTimer?.cancel();
    super.dispose();
  }
}
