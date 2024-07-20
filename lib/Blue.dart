import 'dart:convert';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BlueDevice {
  static BlueDevice instance = BlueDevice();
  // final BluetoothStateNotifier connectionProvider;
  BluetoothConnection? connection;
  String _deviceName = 'Unknown Device';
  String _connectionStatus = 'Not Connected';
  bool _isConnected = false;

  String get deviceName => _deviceName;
  String get connectionStatus => _connectionStatus;
  bool get isConnected => _isConnected;

  Future<bool> connect(String address, String dir) async {
    try {
      connection = await BluetoothConnection.toAddress(address);
      print('Connected to the device: $address');
      _isConnected = true;
      sendData(dir);
      return true;
    } catch (exception) {
      print('Cannot connect, exception occurred: $exception');
      _isConnected = false;
      return false;
    }
  }

  void sendData(String data) {
    if (connection != null && connection!.isConnected) {
      data = data.trim();
      connection!.output.add(
        utf8.encode(data),
      );
      print(data);
    }
  }

// void disconnect() {
//   if (connection != null) {
//     connection!.close();
//     connection = null;
//     connectionProvider.updateConnectionsStatus(false);
//   }
// }
}
