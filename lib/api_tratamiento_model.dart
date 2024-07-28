import 'dart:convert';
import 'package:http/http.dart' as http;
import 'tratamiento_model.dart'; // Importa tu modelo de datos

Future<List<Tratamiento>> fetchTratamientos(String userId) async {
  final response = await http.post(
    Uri.parse('http://agrocacao.medianewsonline.com/agrocacao/Clasificacion-cacao/controllers/movil/tratamiento.php'),
    body: {'us_id': userId},
  );
  
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    final List<dynamic> tratamientosJson = jsonResponse['data'];
    print(tratamientosJson);
    return tratamientosJson.map((tratamiento) => Tratamiento.fromJson(tratamiento)).toList();
  } else {
    throw Exception('Failed to load tratamientos');
  }
}