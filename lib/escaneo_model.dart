class Escaneo {
  final int idEscaneo;
  final String escaneo;
  final int estadoEscaneo;
  final int porcentajeEscaneo;
  final String fechaEscaneo;
  final String imagenEscaneo; // Corregir el campo de 'imgen_escaneo'
  final int loteId;
  final int usId;
  final String? nombreLote;
  final String? nombreEstadoCacao;
  final int? trasa_estado_cacao_id;

  Escaneo({
    required this.idEscaneo,
    required this.escaneo,
    required this.estadoEscaneo,
    required this.porcentajeEscaneo,
    required this.fechaEscaneo,
    required this.imagenEscaneo,
    required this.loteId,
    required this.usId,
    this.nombreLote,
    this.nombreEstadoCacao,
    this.trasa_estado_cacao_id,
  });

  factory Escaneo.fromJson(Map<String, dynamic> json) {
    return Escaneo(
      idEscaneo: json['id_escaneo'],
      escaneo: json['escaneo'] ?? '',
      estadoEscaneo: json['estado_cacao_escaneo'],
      porcentajeEscaneo: json['porcentaje_escaneo'],
      fechaEscaneo: json['fecha_escaneo'],
      imagenEscaneo: json['imgen_escaneo'], // Corregir el campo de 'imgen_escaneo'
      loteId: json['lote_id'],
      usId: json['us_id'],
      nombreLote: json['nombre_lote'],
      nombreEstadoCacao: json['nombre_estado_cacao_escaneo'],
      trasa_estado_cacao_id: json['estado_cacao_trasabilidad'],
    );
  }
}
