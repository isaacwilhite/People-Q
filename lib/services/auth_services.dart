import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final _storage = FlutterSecureStorage();
  final _authStatusController = StreamController<bool>.broadcast();

  AuthService() {
    _broadcastAuthStatus();
  }

  Stream<bool> get authStatusStream => _authStatusController.stream;

  Future<void> storeToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
    _broadcastAuthStatus();
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> signOut() async {
    await _storage.delete(key: 'auth_token');
    _broadcastAuthStatus();
  }

  void _broadcastAuthStatus() async {
    final token = await getToken();
    _authStatusController.sink.add(token != null);
  }

  void dispose() {
    _authStatusController.close();
  }
}
