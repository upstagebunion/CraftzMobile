import 'variante_model.dart';

class Producto {
  final String id;
  final String nombre;
  final String descripcion;
  final String categoria;
  final String subcategoria;
  final String? calidad;
  final String? corte;
  final List<Variante>? variantes;
  final List<String>? imagenes;
  final bool activo;
  final DateTime? fechaCreacion;

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.subcategoria,
    this.calidad,
    this.corte,
    required this.variantes,
    this.imagenes,
    this.activo = true,
    this.fechaCreacion,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['_id'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      categoria: json['categoria'] as String,
      subcategoria: json['subcategoria'] as String,
      calidad: json['calidad'] as String?,
      corte: json['corte'] as String?,
      variantes: (json['variantes'] as List)
          .map((variante) => Variante.fromJson(variante))
          .toList(),
      imagenes:
          (json['imagenes'] as List?)?.map((imagen) => imagen as String).toList(),
      activo: json['activo'] as bool? ?? true,
      fechaCreacion: json['fechaCreacion'] != null ? DateTime.parse(json['fechaCreacion']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'categoria': categoria,
      'subcategoria': subcategoria,
      'calidad': calidad,
      'corte': corte,
      'variantes': variantes?.map((variante) => variante.toJson()).toList(),
      'imagenes': imagenes,
      'activo': activo,
      'fechaCreacion': fechaCreacion != null ? fechaCreacion?.toIso8601String() : null,
    };
  }

  Producto copyWith({List<Variante>? variantes, String? nombre, String? descripcion, String? categoria, String? subcategoria, String? calidad, String? corte}) {
    return Producto(
      id: this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      categoria: categoria ?? this.categoria,
      subcategoria: subcategoria ?? this.subcategoria,
      calidad: calidad ?? this.calidad,
      corte: corte ?? this.corte,
      variantes: variantes ?? this.variantes,
      imagenes: this.imagenes,
      activo: this.activo,
      fechaCreacion: this.fechaCreacion,
    );
  }
}
