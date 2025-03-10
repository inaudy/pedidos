import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfo(this._connectivity);

  /// ✅ Returns `true` if the device has an active internet connection
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();

    // ✅ Check if device is connected to Wi-Fi or Mobile Data
    if (results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi)) {
      return await _hasInternetAccess(); // ✅ Confirm internet access
    }
    return false;
  }

  /// ✅ Additional check: Try reaching an external server
  Future<bool> _hasInternetAccess() async {
    try {
      final result =
          await InternetAddress.lookup('google.com'); // Test real connection
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false; // ✅ No internet access
    }
  }
}
