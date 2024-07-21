import 'dart:convert';
import 'package:http/http.dart' as http;
import 'escaneo_model.dart'; // Importa tu modelo de datos

Future<List<Escaneo>> fetchEscaneos(String userId, String tipoUs) async {
  final response = await http.post(
    Uri.parse('http://agrocacao.medianewsonline.com/agrocacao/Clasificacion-cacao/controllers/movil/seguimiento_movil.php'),
    body: {'us_id': userId, 'tipo': tipoUs},
  );
  
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    final List<dynamic> escaneosJson = jsonResponse['data'];
    return escaneosJson.map((escaneo) => Escaneo.fromJson(escaneo)).toList();
  } else {
    throw Exception('Failed to load escaneos');
  }
}
