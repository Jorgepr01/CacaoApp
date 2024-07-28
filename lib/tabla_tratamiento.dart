import 'package:clasificacion/MoreDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'escaneo_model.dart'; // Importa tu modelo de datos
// import 'api_escaneo_model.dart'; // Importa la función fetchEscaneos
// import 'seguimiento.dart';
import 'tratamiento_model.dart';
import 'api_tratamiento_model.dart';

class TablaTratamiento extends StatefulWidget {
  final int userId;
  TablaTratamiento({required this.userId});

  @override
  _EscaneosTableScreenState createState() => _EscaneosTableScreenState();
}

class _EscaneosTableScreenState extends State<TablaTratamiento> {
  Future<List<Tratamiento>>? futureEscaneos;
  List<Tratamiento>? escaneos;
  int _currentPage = 0;
  final int _rowsPerPage = 10;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    futureEscaneos = fetchTratamientos('${widget.userId}');
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
        title: Text('Tabla Tratamiento'),
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
            child: FutureBuilder<List<Tratamiento>>(
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
                    return (escaneo.nombre?.toLowerCase().contains(_searchQuery) ?? false);
                  }).toList();

                  final paginatedEscaneos = filteredEscaneos.skip(_currentPage * _rowsPerPage).take(_rowsPerPage).toList();
                  return SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateColor.resolveWith((states) =>  Color.fromARGB(255, 145, 86, 86)),
                        dataRowColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.selected) ? Color.fromARGB(255, 145, 86, 86) : Colors.white),
                        columns: const [
                          DataColumn(label: Text('Nombre', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                          DataColumn(label: Text('Aplicar', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                          DataColumn(label: Text('Dosis', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                          DataColumn(label: Text('Tiempo', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                          DataColumn(label: Text('Aplicación', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                        ],
                        rows: paginatedEscaneos.map((escaneo) {
                          return DataRow(
                            cells: [
                              DataCell(Text(escaneo.nombre ?? '')),
                              DataCell(Text('${escaneo.aplicar}')),
                              DataCell(Text(escaneo.dosis ?? '')),
                              DataCell(Text(escaneo.tiempo ?? '')),
                              DataCell(Text(escaneo.aplicacion ?? '')),
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
