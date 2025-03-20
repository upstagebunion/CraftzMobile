class Subcategoria {
  final String id;
  final String nombre;
  final String categoria;
  final bool usaTallas;

  Subcategoria({required this.id,required this.nombre, required this.categoria, required this.usaTallas});

  factory Subcategoria.fromJson(Map<String, dynamic> json) {
    return Subcategoria(
      id: json['_id'],
      nombre: json['nombre'] as String,
      categoria: json['categoria'] as String,
      usaTallas: json['usaTallas'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id' : id,
      'nombre': nombre,
      'categoria': categoria,
      'usaTallas': usaTallas,
    };
  }

  Subcategoria copyWith({String? nombre, String? categoria}) {
    return Subcategoria(
      id: this.id,
      nombre: nombre ?? this.nombre,
      categoria: categoria ?? this.categoria,
      usaTallas: this.usaTallas,
    );
  }
}