import 'package:clasificacion/MoreDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'escaneo_model.dart'; // Importa tu modelo de datos
import 'api_escaneo_model.dart'; // Importa la función fetchEscaneos
import 'seguimiento.dart';

class EscaneosTableScreen extends StatefulWidget {
  final int userId;
  final int tipoUs;
  EscaneosTableScreen({required this.userId, required this.tipoUs});

  @override
  _EscaneosTableScreenState createState() => _EscaneosTableScreenState();
}

class _EscaneosTableScreenState extends State<EscaneosTableScreen> {
  Future<List<Escaneo>>? futureEscaneos;
  List<Escaneo>? escaneos;
  int _currentPage = 0;
  final int _rowsPerPage = 10;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    futureEscaneos = fetchEscaneos('${widget.userId}', '${widget.tipoUs}');
    futureEscaneos?.then((data) {
      setState(() {
        escaneos = data;
      });
    });
  }

  Future<Image> _loadNetworkImage(String url) async {
    final response = await http.get(
      Uri.parse(url),
      headers: {'User-Agent': 'Mozilla/5.0'}, // Agregar cabecera User-Agent
    );
    if (response.statusCode == 200) {
      return Image.memory(response.bodyBytes);
    } else {
      throw Exception('Failed to load image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tabla escaneos'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Buscar Estado Cacao',
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Escaneo>>(
              future: futureEscaneos,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No hay datos disponibles'));
                } else {
                  final filteredEscaneos = escaneos!.where((escaneo) {
                    return (escaneo.nombreEstadoCacao?.toLowerCase().contains(_searchQuery) ?? false);
                  }).toList();

                  final paginatedEscaneos = filteredEscaneos.skip(_currentPage * _rowsPerPage).take(_rowsPerPage).toList();
                  return SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateColor.resolveWith((states) =>  Color.fromARGB(255, 145, 86, 86)),
                        dataRowColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.selected) ? Color.fromARGB(255, 145, 86, 86) : Colors.white),
                        columns: const [
                          DataColumn(label: Text('Estado Cacao', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                          // DataColumn(label: Text('Escaneo', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                          DataColumn(label: Text('Porcentaje', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                          DataColumn(label: Text('Fecha del deteccion', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                          // DataColumn(label: Text('Imagen', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                          DataColumn(label: Text('Lote', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                          // DataColumn(label: Text('Primer Seguimiento', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                          // DataColumn(label: Text('Seguimiento-Actual', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                          // DataColumn(label: Center(child: Text('Accion', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)))),
                          DataColumn(label: Center(child: Text('Ver más detalles', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)))),
                        ],
                        rows: paginatedEscaneos.map((escaneo) {
                          return DataRow(
                            cells: [
                              DataCell(Text(escaneo.nombreEstadoCacao ?? '')),
                              // DataCell(Text(escaneo.escaneo)),
                              DataCell(Text('${escaneo.porcentajeEscaneo}%')),
                              DataCell(
                                escaneo.fechaEscaneo != null
                                ? Text("${escaneo.fechaEscaneo}")
                                : Text('No hay datos')
                              ),
                              // DataCell(
                              //   FutureBuilder<Image>(
                              //     future: _loadNetworkImage('http://agrocacao.medianewsonline.com/agrocacao/Clasificacion-cacao/uploads/cacao/${escaneo.imagenEscaneo}'),
                              //     builder: (context, snapshot) {
                              //       if (snapshot.connectionState == ConnectionState.waiting) {
                              //         return CircularProgressIndicator();
                              //       } else if (snapshot.hasError) {
                              //         print(snapshot.error);
                              //         return Text('Error');
                              //       } else {
                              //         return snapshot.data ?? Text('No Image');
                              //       }
                              //     },
                              //   ),
                              // ),
                              DataCell(Text(escaneo.nombreLote ?? '')),
                              // DataCell(
                              //    escaneo.estadoEscaneo == 1
                              //    ? Text('Sano', style: TextStyle(color:  const Color.fromARGB(255, 46, 120, 48)))
                              //    : Text('Infectado', style: TextStyle(color: Color.fromARGB(255, 156, 53, 46)))
                              // ),
                              // DataCell(
                              //    escaneo.trasa_estado_cacao_id == 1 || escaneo.estadoEscaneo == 1
                              //    ? Text('Sano', style: TextStyle(color: const Color.fromARGB(255, 46, 120, 48)))
                              //    : Text('Infectado', style: TextStyle(color: Color.fromARGB(255, 156, 53, 46)))
                              // ),
                              // DataCell(
                              //   escaneo.trasa_estado_cacao_id == 1 || escaneo.estadoEscaneo == 1
                              //       ? Center(child: Text('Sano', style: TextStyle(color: const Color.fromARGB(255, 46, 120, 48))))
                              //       : ElevatedButton(
                              //           onPressed: () {
                              //             Navigator.push(
                              //               context,
                              //               MaterialPageRoute(
                              //                 builder: (context) => Seguimiento(idEscaneo: escaneo.idEscaneo),
                              //               ),
                              //             );
                              //           },
                              //           child: Text('Seguimiento'),
                              //           style: ElevatedButton.styleFrom(
                              //             foregroundColor: Colors.white, backgroundColor: Color.fromARGB(255, 108, 168, 110),
                              //           ),
                              //         )
                              // ),
                              DataCell(
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MoreDetailsScreen(userId: widget.userId, tipoUs: widget.tipoUs, idEscaneo: escaneo.idEscaneo),
                                      ),
                                    );
                                  },
                                  child: Text('Ver más detalles'),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white, backgroundColor: Color.fromARGB(181, 145, 86, 86),
                                  ),
                                )
                              )
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          if (escaneos != null && escaneos!.isNotEmpty) _buildPaginationControls(),
        ],
      ),
    );
  }

  Widget _buildPaginationControls() {
    final totalPages = (escaneos!.length / _rowsPerPage).ceil();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _currentPage > 0 ? () {
            setState(() {
              _currentPage--;
            });
          } : null,
        ),
        Text('Página ${_currentPage + 1} de $totalPages'),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: _currentPage < totalPages - 1 ? () {
            setState(() {
              _currentPage++;
            });
          } : null,
        ),
      ],
    );
  }
}
