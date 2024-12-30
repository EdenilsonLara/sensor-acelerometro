class Perfil {
  final String id;
  final String nombre;
  final String apodo;
  final int edad;
  final int record;
  final String image;

  Perfil({
    required this.id,
    required this.nombre,
    required this.apodo,
    required this.edad,
    required this.record,
    required this.image,
  });

  factory Perfil.fromJson(Map<String, dynamic> json) {
    return Perfil(
      id: json['_id'] ?? '',
      nombre: json['nombre'] ?? '',
      apodo: json['apodo'] ?? '',
      edad: json['edad'] ?? 0,
      record: json['record'] ?? 0,
      image: json['image'] ?? '',
    );
  }
}
