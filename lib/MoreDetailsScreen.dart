import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'escaneo_model.dart'; // Importa tu modelo de datos
import 'api_escaneo_model.dart'; // Importa la función fetchEscaneos
import 'seguimiento.dart';

class MoreDetailsScreen extends StatefulWidget {
  final int userId;
  final int tipoUs;
  final int idEscaneo;
  MoreDetailsScreen({required this.userId, required this.tipoUs, required this.idEscaneo});

  @override
  _EscaneosTableScreenState createState() => _EscaneosTableScreenState();
}

class _EscaneosTableScreenState extends State<MoreDetailsScreen> {
  Future<List<Escaneo>>? futureEscaneos;
  List<Escaneo>? escaneos;
  int _currentPage = 0;
  final int _rowsPerPage = 10;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
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
        title: Text('Tabla seguimiento'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            // child: TextField(
            //   decoration: InputDecoration(
            //     labelText: 'Buscar Estado Cacao',
            //     suffixIcon: Icon(Icons.search),
            //     border: OutlineInputBorder(),
            //   ),
            //   onChanged: (query) {
            //     setState(() {
            //       _searchQuery = query.toLowerCase();
            //     });
            //   },
            // ),
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
                    final matchesIdEscaneo = escaneo.idEscaneo == widget.idEscaneo;
                    final matchesSearchQuery = (escaneo.nombreEstadoCacao?.toLowerCase().contains(_searchQuery) ?? false);
                    return matchesIdEscaneo && matchesSearchQuery;
                  }).toList();

                  final paginatedEscaneos = filteredEscaneos.skip(_currentPage * _rowsPerPage).take(_rowsPerPage).toList();
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: MaterialStateColor.resolveWith((states) => Color.fromARGB(255, 145, 86, 86)),
                            dataRowColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.selected) ? Color.fromARGB(255, 145, 86, 86) : Colors.white),
                            columns: const [
                              DataColumn(label: Text('Seguimiento', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                              // DataColumn(label: Text('Escaneo', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                              DataColumn(label: Text('Porcentaje', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                              DataColumn(label: Text('Fecha del Seguimiento', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                              DataColumn(label: Text('observacion', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                              // DataColumn(label: Text('Seguimiento-Actual', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                              DataColumn(label: Center(child: Text('Accion', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)))),
                            ],
                            rows: paginatedEscaneos.map((escaneo) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(escaneo.nombre_estado_cacao_trazabilidad ?? 'No hay datos')),
                                  // DataCell(Text(escaneo.escaneo)),
                                  DataCell(
                                    escaneo.porcentaje_trazabilidad != null
                                    ? Text('${escaneo.porcentaje_trazabilidad}%')
                                    : Text('No hay datos')
                                    ),
                                    DataCell(
                                      escaneo.fecha_trazabilidad != null
                                      ? Text("${escaneo.fecha_trazabilidad}")
                                      : Text('No hay datos')
                                    ),
                                    DataCell(
                                      escaneo.observacion != null
                                      ? Text("${escaneo.observacion}")
                                      : Text('No hay datos')
                                    ),
                                  // DataCell(Text(escaneo.nombreLote ?? '')),
                                  // DataCell(
                                  //   escaneo.estadoEscaneo == 1
                                  //       ? Text('Sano', style: TextStyle(color: const Color.fromARGB(255, 46, 120, 48)))
                                  //       : Text('Infectado', style: TextStyle(color: Color.fromARGB(255, 156, 53, 46)))
                                  // ),
                                  // DataCell(
                                  //   escaneo.trasa_estado_cacao_id == 1 || escaneo.estadoEscaneo == 1
                                  //       ? Text('Sano', style: TextStyle(color: const Color.fromARGB(255, 46, 120, 48)))
                                  //       : Text('Infectado', style: TextStyle(color: Color.fromARGB(255, 156, 53, 46)))
                                  // ),
                                  DataCell(
                                    escaneo.trasa_estado_cacao_id == 1 || escaneo.estadoEscaneo == 1
                                        ? Center(child: Text('Sano', style: TextStyle(color: const Color.fromARGB(255, 46, 120, 48))))
                                        : ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => Seguimiento(idEscaneo: escaneo.idEscaneo),
                                                ),
                                              );
                                            },
                                            child: Text('Seguimiento'),
                                            style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.white, backgroundColor: Color.fromARGB(255, 108, 168, 110),
                                            ),
                                          )
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
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
