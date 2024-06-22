import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('http://agrocacao.medianewsonline.com/agrocacao/Clasificacion-cacao/controllers/login_movil.php'),
      body: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) { 
      print(response.statusCode);
      var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      if (decodedResponse['message'] == "Login successful"){
        Map<String, dynamic> user = Map<String, dynamic>.from(decodedResponse['user']);
        print(user);
        _isAuthenticated = true;
        notifyListeners();
      }else{
        print(decodedResponse['message']);
        print("datos incorrectos");
        _isAuthenticated = false;
        notifyListeners();
      }
    } else {
      _isAuthenticated = false;
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
