import 'package:flutter/material.dart';
import 'escaneo_model.dart'; // Importa tu modelo de datos
import 'api_escaneo_model_tras.dart'; // Importa la función fetchEscaneos
import 'seguimiento.dart';

class EscaneosTableScreen_Tras extends StatefulWidget {
  final int userId;
  EscaneosTableScreen_Tras({required this.userId});
  @override
  _EscaneosTableScreenState createState() => _EscaneosTableScreenState();
}

class _EscaneosTableScreenState extends State<EscaneosTableScreen_Tras> {
  Future<List<Escaneo>>? futureEscaneos;
  List<Escaneo>? escaneos;
  int _currentPage = 0;
  final int _rowsPerPage = 10;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    futureEscaneos = fetchEscaneos('${widget.userId}');
    futureEscaneos?.then((data) {
      setState(() {
        escaneos = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Escaneos Cacao'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Buscar',
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
                    return escaneo.escaneo.toLowerCase().contains(_searchQuery) ||
                           escaneo.porcentajeEscaneo.toString().contains(_searchQuery) ||
                           escaneo.latitud.toString().contains(_searchQuery) ||
                           escaneo.longitud.toString().contains(_searchQuery);
                  }).toList();

                  final paginatedEscaneos = filteredEscaneos.skip(_currentPage * _rowsPerPage).take(_rowsPerPage).toList();
                  return SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateColor.resolveWith((states) =>  Color.fromARGB(255, 145, 86, 86)),
                        dataRowColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.selected) ? Color.fromARGB(255, 145, 86, 86) : Colors.white),
                        columns: const [
                          DataColumn(label: Text('Escaneo', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                          DataColumn(label: Text('Porcentaje', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                          DataColumn(label: Text('Imagen', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                          DataColumn(label: Text('Latitud', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                          DataColumn(label: Text('Longitud', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                          DataColumn(label: Text('Seguimiento', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                        ],
                        rows: paginatedEscaneos.map((escaneo) {
                          return DataRow(
                            cells: [
                              DataCell(Text(escaneo.escaneo)),
                              DataCell(Text('${escaneo.porcentajeEscaneo}%')),
                              DataCell(Text(escaneo.imagenEscaneo)),
                              DataCell(Text(escaneo.latitud.toString())),
                              DataCell(Text(escaneo.longitud.toString())),
                              DataCell(
                                escaneo.estadoEscaneo != 3
                                    ? ElevatedButton(
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
                                          foregroundColor: Colors.white, backgroundColor: Color.fromARGB(255, 107, 164, 109),
                                        ),
                                      )
                                    : Center(child: Text('Sano', style: TextStyle(color: Colors.green))),
                              ),
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
