class Tratamiento {
  final int? id_estado_cacao;
  final String? nombre;
  final String? aplicar;
  final String? dosis;
  final String? tiempo;
  final String? aplicacion;
  final String? medida_manejo; // Corregir el campo de 'imgen_escaneo'


  Tratamiento({
    required this.id_estado_cacao,
    required this.nombre,
    required this.aplicar,
    this.dosis,
    required this.tiempo,
    required this.aplicacion,
    required this.medida_manejo,
    
  });

  factory Tratamiento.fromJson(Map<String, dynamic> json) {
    return Tratamiento(
      id_estado_cacao: json['id_estado_cacao'],
      nombre: json['nombre'] ?? '',
      aplicar: json['aplicar'],
      dosis: json['dosis'],
      tiempo: json['tiempo'],
      aplicacion: json['aplicacion'],
      medida_manejo: json['medida_manejo'], // Corregir el campo de 'imgen_escaneo'

    );
  }
}
