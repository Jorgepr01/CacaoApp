class Lote {
  final int idLote;
  final String nombre;
  final String descripcion;
  final String latitud;
  final String longitud;
  final int estadoLoteId;

  Lote({
    required this.idLote,
    required this.nombre,
    required this.descripcion,
    required this.latitud,
    required this.longitud,
    required this.estadoLoteId,
  });

  factory Lote.fromJson(Map<String, dynamic> json) {
    return Lote(
      idLote: json['id_lote'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      latitud: json['latitud'],
      longitud: json['longitud'],
      estadoLoteId: json['estado_lote_id'],
    );
  }
}
