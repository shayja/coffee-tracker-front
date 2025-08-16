// file: lib/core/network/network_info.dart
// This file defines the NetworkInfo interface for checking internet connectivity.
import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  /// Checks if the device is connected to the internet.
  Future<bool> get isConnected;
}

// Implementation of [NetworkInfo] that uses the [Connectivity] package
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  /// Constructor for [NetworkInfoImpl].
  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final connectivityResults = await connectivity.checkConnectivity();
    return connectivityResults.contains(ConnectivityResult.mobile) ||
        connectivityResults.contains(ConnectivityResult.wifi);
  }
}
