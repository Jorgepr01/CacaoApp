class Escaneo {
  final int idEscaneo;
  final String escaneo;
  final int estadoEscaneo;
  final int porcentajeEscaneo;
  final String fechaEscaneo;
  final String imagenEscaneo; // Corregir el campo de 'imgen_escaneo'
  final int usId;
  final String latitud;
  final String longitud;
  Escaneo({
    required this.idEscaneo,
    required this.escaneo,
    required this.estadoEscaneo,
    required this.porcentajeEscaneo,
    required this.fechaEscaneo,
    required this.imagenEscaneo,
    required this.usId,
    required this.latitud,
    required this.longitud,
  });

  factory Escaneo.fromJson(Map<String, dynamic> json) {
    return Escaneo(
      idEscaneo: json['id_escaneo'],
      escaneo: json['escaneo'] ?? '',
      estadoEscaneo: json['estado_escaneo_id'],
      porcentajeEscaneo: json['porcentaje_escaneo'],
      fechaEscaneo: json['fecha_escaneo'],
      imagenEscaneo: json['imgen_escaneo'], // Corregir el campo de 'imgen_escaneo'
      usId: json['us_id'],
      latitud: json['latitud'] ?? '0.0',
      longitud: json['longitud']?? '0.0'
    );
  }
}
