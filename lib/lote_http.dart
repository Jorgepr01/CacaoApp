import 'dart:convert';
import 'package:http/http.dart' as http;
import 'lote_model.dart';

Future<List<Lote>> fetchLotes() async {
  final response = await http.post(
    Uri.parse('http://agrocacao.medianewsonline.com/agrocacao/Clasificacion-cacao/controllers/movil/lote_movil.php'),
    body: {'funcion': 'datos_lote'},
  );
  print(response.body);
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    final List<dynamic> lotesJson = jsonResponse['data'];

    return lotesJson.map((json) => Lote.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar los datos de los lotes');
  }
}
