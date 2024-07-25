import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> CorreoRecuperacion(String email) async {

      final response = await http.post(
      Uri.parse('http://agrocacao.medianewsonline.com/agrocacao/Clasificacion-cacao/controllers/movil/email_movil.php'),
      body: {'funcion': 'recuperar', 'email': email},
    );

  if (response.statusCode == 200) {
    print(response.statusCode);
    print('todos bien ${response.body}');
  } else {
    print('error ${response.statusCode}');
    print('error ${response.body}');
    throw Exception('Failed to load escaneos');
  }
}
