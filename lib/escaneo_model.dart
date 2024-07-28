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

  // Trasabilidad


  final int? trasa_estado_cacao_id;
  final int? porcentaje_trasabilidad;
  final String? fecha_trasabilidad;
  final String? imgen_trasabilidad;
  final String? observacion;
  final String? nombre_estado_cacao_trasabilidad;

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
  // Trasabilidad

    this.trasa_estado_cacao_id,
    this.porcentaje_trasabilidad,
    this.fecha_trasabilidad,
    this.imgen_trasabilidad,
    this.observacion,
    this.nombre_estado_cacao_trasabilidad,
    
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
    // Trasabilidad
      trasa_estado_cacao_id: json['estado_cacao_trasabilidad'],
      porcentaje_trasabilidad: json['porcentaje_trasabilidad'],
      fecha_trasabilidad: json['fecha_trasabilidad'],
      imgen_trasabilidad: json['imgen_trasabilidad'],
      nombre_estado_cacao_trasabilidad: json['nombre_estado_cacao_trasabilidad'],
      observacion: json['observacion'],
    );
  }
}
