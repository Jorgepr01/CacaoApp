import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> CodigoRecuperacion(String email,cod_recup,nuevo_pass) async {
      final response = await http.post(
      Uri.parse('http://agrocacao.medianewsonline.com/agrocacao/Clasificacion-cacao/controllers/movil/email_movil.php'),
      body: {'funcion': 'recuperar_contra', 'email': email,'cod_recup':cod_recup,'nuevo_pass':nuevo_pass},
    );

  if (response.statusCode == 200) {
    print('todos bien ${response.body}');
  } else {
    throw Exception('Failed to load escaneos');
  }
}
