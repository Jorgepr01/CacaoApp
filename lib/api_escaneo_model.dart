import 'dart:convert';
import 'package:http/http.dart' as http;
import 'escaneo_model.dart'; // Importa tu modelo de datos

Future<List<Escaneo>> fetchEscaneos(String userId) async {

      final response = await http.post(
      Uri.parse('http://agrocacao.medianewsonline.com/agrocacao/Clasificacion-cacao/controllers/movil/seguimiento_movil.php'),
      body: {'user_id': userId},
    );

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    print(jsonResponse);
    return jsonResponse.map((escaneo) => Escaneo.fromJson(escaneo)).toList();
  } else {
    throw Exception('Failed to load escaneos');
  }
}
