// class User {
//   final String id;
//   final String name;
//   final String email;

//   User({required this.id, required this.name, required this.email});

//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       id: json['id'],
//       name: json['name'],
//       email: json['email'],
//     );
//   }
// }
class User {
  final int id_us;
  final String nombre_us;
  final String apellido_us;
  final String edad_us;
  final String ci_us;
  final String telefono;
  final String email_us;
  final String contrasena_us;
  final int tipo_us_id;
  final int estado_us_id;
  final String avatar;
  final String creado_en;
  final String? actualizado_en;
  final String? codigo_recupe;
  final String? fecha_recupe;
  final int id_tipo_us;
  final String nombre_tipo_us;
  final int id_estado_us;
  final String nombre_estado_us;


  
  // Añade más campos según sea necesario

  User({
    required this.id_us,
    required this.nombre_us,
    required this.apellido_us,
    required this.edad_us,
    required this.ci_us,
    required this.telefono,
    required this.email_us,
    required this.contrasena_us,
    required this.tipo_us_id,
    required this.estado_us_id,
    required this.avatar,
    required this.creado_en,
    required this.actualizado_en,
    required this.codigo_recupe,
    required this.fecha_recupe,
    required this.id_tipo_us,
    required this.nombre_tipo_us,
    required this.id_estado_us,
    required this.nombre_estado_us,
  });
}