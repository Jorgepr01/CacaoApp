import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('http://agrocacao.medianewsonline.com/agrocacao/Clasificacion-cacao/controllers/login.php'),
      body: {'usuario': email, 'password': password},
    );

    if (response.statusCode == 200) {
      _isAuthenticated = true;
      notifyListeners();
    } else {
      print(response.statusCode);
      print(response.body);
      print("error al iniciar sesion");
    }
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
}
