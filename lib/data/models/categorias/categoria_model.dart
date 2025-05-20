import './subcategoria_model.dart';

class Categoria {
  final String id;
  final String nombre;
  final List<Subcategoria> subcategorias;

  Categoria({required this.id, required this.nombre, required this.subcategorias});

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['_id'] as String,
      nombre: json['nombre'] as String,
      subcategorias: (json['subcategorias'] as List)
          .map((subcategoria) => Subcategoria.fromJson(subcategoria))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'nombre': nombre,
      'subcategorias': subcategorias.map((subcategoria) => subcategoria.toJson()).toList(),
    };
  }

  Categoria copyWith({
    String? id,
    String? nombre,
    List<Subcategoria>? subcategorias
  }) {
    return Categoria(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      subcategorias: subcategorias ?? this.subcategorias
    );
  }
}