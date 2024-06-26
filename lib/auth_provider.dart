import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'user.dart';


class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  // crear el objeto de usuario
  User? _user;
  bool get isAuthenticated => _isAuthenticated;

  User? get user => _user;

  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('http://agrocacao.medianewsonline.com/agrocacao/Clasificacion-cacao/controllers/movil/login_movil.php'),
      body: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      if (decodedResponse['message'] == "Login successful"){
        Map<String, dynamic> userData = Map<String, dynamic>.from(decodedResponse['user']);
        _user = User(
          id_us: userData['id_us'],
          nombre_us: userData['nombre_us'],
          apellido_us: userData['apellido_us'],
          edad_us: userData['edad_us'],
          ci_us: userData['ci_us'],
          telefono: userData['telefono'],
          email_us: userData['email_us'],
          contrasena_us: userData['contrasena_us'],
          tipo_us_id: userData['tipo_us_id'],
          estado_us_id: userData['estado_us_id'],
          avatar: userData['avatar'],
          creado_en: userData['creado_en'],
          actualizado_en: userData['actualizado_en'],
          fecha_recupe: userData['fecha_recupe'],
          codigo_recupe: userData['codigo_recupe'],
          id_tipo_us: userData['id_tipo_us'],
          nombre_tipo_us: userData['nombre_tipo_us'],
          id_estado_us: userData['id_estado_us'],
          nombre_estado_us: userData['nombre_estado_us'],
        // Añade más campos según sea necesario
        );
        print(_user);
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
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
