/// Stub implementation of ThreeDRService for web platform
/// Web doesn't support serial communication or dart:ffi

abstract class SerialPort {
  String get name;
  bool get isOpen;
  Future<void> openReadWrite();
  Future<void> close();
  List<int> read(int size);
  int write(List<int> data);
}

class ThreeDRService {
  String connectionMode = 'mock';
  String devicePort = 'COM1';
  String remoteHost = 'localhost';
  int remotePort = 14550;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    // Web doesn't support serial - use mock data only
    _isConnected = false;
  }

  Future<void> disconnect() async {
    _isConnected = false;
  }

  Future<List<int>> readSerialData() async {
    return [];
  }

  void updatePort(String port) {
    devicePort = port;
  }

  void updateHost(String host) {
    remoteHost = host;
  }

  void updateRemotePort(int port) {
    remotePort = port;
  }

  Future<bool> testConnection() async {
    return false;
  }

  List<String> getAvailablePorts() {
    return [];
  }
}
