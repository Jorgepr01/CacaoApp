class Escaneo {
  final int idEscaneo;
  final String escaneo;
  final int estadoEscaneo;
  final String? nombreEstadoCacao;
  final int porcentajeEscaneo;
  final String fechaEscaneo;
  final String imagenEscaneo; // Corregir el campo de 'imgen_escaneo'
  final int loteId;
  final String? nombreLote;
  final int usId;

  // trazabilidad

  final int? trasa_estado_cacao_id;
  final int? porcentaje_trazabilidad;
  final String? fecha_trazabilidad;
  final String? imgen_trazabilidad;
  final String? observacion;
  final String? nombre_estado_cacao_trazabilidad;

  Escaneo({
    required this.idEscaneo,
    required this.escaneo,
    required this.estadoEscaneo,
    this.nombreEstadoCacao,
    required this.porcentajeEscaneo,
    required this.fechaEscaneo,
    required this.imagenEscaneo,
    required this.loteId,
    this.nombreLote,
    required this.usId,
  // trazabilidad

    this.trasa_estado_cacao_id,
    this.porcentaje_trazabilidad,
    this.fecha_trazabilidad,
    this.imgen_trazabilidad,
    this.observacion,
    this.nombre_estado_cacao_trazabilidad,
    
  });

  factory Escaneo.fromJson(Map<String, dynamic> json) {
    return Escaneo(
      idEscaneo: json['id_escaneo'],
      escaneo: json['escaneo'] ?? '',
      estadoEscaneo: json['estado_cacao_escaneo'],
      nombreEstadoCacao: json['nombre_estado_cacao_escaneo'],
      porcentajeEscaneo: json['porcentaje_escaneo'],
      fechaEscaneo: json['fecha_escaneo'],
      imagenEscaneo: json['imgen_escaneo'], // Corregir el campo de 'imgen_escaneo'
      loteId: json['lote_id'],
      nombreLote: json['nombre_lote'],
      usId: json['us_id'],
    // trazabilidad
      trasa_estado_cacao_id: json['estado_cacao_trazabilidad'],
      porcentaje_trazabilidad: json['porcentaje_trazabilidad'],
      fecha_trazabilidad: json['fecha_trazabilidad'],
      imgen_trazabilidad: json['imgen_trazabilidad'],
      nombre_estado_cacao_trazabilidad: json['nombre_estado_cacao_trazabilidad'],
      observacion: json['observacion'],
    );
  }
}
