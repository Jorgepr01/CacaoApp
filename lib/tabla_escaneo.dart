import 'package:flutter/material.dart';
import 'escaneo_model.dart'; // Importa tu modelo de datos
import 'api_escaneo_model.dart'; // Importa la función fetchEscaneos

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: EscaneosTableScreen(),
    );
  }
}

class EscaneosTableScreen extends StatefulWidget {
  @override
  _EscaneosTableScreenState createState() => _EscaneosTableScreenState();
}

class _EscaneosTableScreenState extends State<EscaneosTableScreen> {
  Future<List<Escaneo>>? futureEscaneos;

  @override
  void initState() {
    super.initState();
    futureEscaneos = fetchEscaneos('1');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Escaneos Cacao'),
      ),
      body: FutureBuilder<List<Escaneo>>(
        future: futureEscaneos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay datos disponibles'));
          } else {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Escaneo')),
                  DataColumn(label: Text('Estado')),
                  DataColumn(label: Text('Porcentaje')),
                  DataColumn(label: Text('Fecha')),
                  DataColumn(label: Text('Imagen')),
                  DataColumn(label: Text('Usuario ID')),
                  DataColumn(label: Text('Latitud')),
                  DataColumn(label: Text('Longitud')),
                ],
                rows: snapshot.data!.map((escaneo) {
                  return DataRow(
                    cells: [
                      DataCell(Text(escaneo.idEscaneo.toString())),
                      DataCell(Text(escaneo.escaneo)),
                      DataCell(Text(escaneo.estadoEscaneo.toString())),
                      DataCell(Text(escaneo.porcentajeEscaneo.toString())),
                      DataCell(Text(escaneo.fechaEscaneo)),
                      DataCell(Text(escaneo.imagenEscaneo)),
                      DataCell(Text(escaneo.usId.toString())),
                      DataCell(Text(escaneo.latitud.toString())),
                      DataCell(Text(escaneo.longitud.toString())),
                    ],
                  );
                }).toList(),
              ),
            );
          }
        },
      ),
    );
  }
}

