import 'package:flutter/material.dart';
import 'escaneo_model.dart'; // Importa tu modelo de datos
import 'api_escaneo_model.dart'; // Importa la función fetchEscaneos
import 'seguimiento.dart';


class EscaneosTableScreen extends StatefulWidget {
  final int userId;

  EscaneosTableScreen({required this.userId});

  @override
  _EscaneosTableScreenState createState() => _EscaneosTableScreenState();
}

class _EscaneosTableScreenState extends State<EscaneosTableScreen> {
  Future<List<Escaneo>>? futureEscaneos;

  @override
  void initState() {
    super.initState();
    futureEscaneos = fetchEscaneos('${widget.userId}');
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child:DataTable(
                columns: const [
                  // DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Escaneo')),
                  // DataColumn(label: Text('Estado')),
                  DataColumn(label: Text('Porcentaje')),
                  // DataColumn(label: Text('Fecha')),
                  DataColumn(label: Text('Imagen')),
                  // DataColumn(label: Text('Usuario ID')),
                  DataColumn(label: Text('Latitud')),
                  DataColumn(label: Text('Longitud')),
                  DataColumn(label: Text('Seguimiento')),
                ],
                rows: snapshot.data!.map((escaneo) {
                  return DataRow(
                    cells: [
                      // DataCell(Text(escaneo.idEscaneo.toString())),
                      DataCell(Text(escaneo.escaneo)),
                      // DataCell(Text(escaneo.estadoEscaneo.toString())),
                      DataCell(Text(escaneo.porcentajeEscaneo.toString())),
                      // DataCell(Text(escaneo.fechaEscaneo)),
                      DataCell(Text(escaneo.imagenEscaneo)),
                      // DataCell(Text(escaneo.usId.toString())),
                      DataCell(Text(escaneo.latitud.toString())),
                      DataCell(Text(escaneo.longitud.toString())),
                      DataCell(
// Mostrar botón solo si estadoEscaneo es 1
                        escaneo.estadoEscaneo == '1'
                            ? ElevatedButton(
                                  onPressed: () {
                                    // logica del boton
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Seguimiento(idEscaneo: escaneo.idEscaneo),
                                      ),
                                    );
                                    },
                                  child: Text('Seguimiento'),
                                )
                            : Center(
                               child: Text('Sano'),
                              ), // Mostrar texto si la condición no se cumple
                      ),
                    ],
                  );
                }).toList(),
              )
              ),
            );
          }
        },
      ),
    );
  }
}

