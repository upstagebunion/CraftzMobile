import 'variante_model.dart';
import 'config_variantes_model.dart';
import 'imagen_model.dart';
import 'metadata_model.dart';

class Producto {
  final String id;
  final String nombre;
  final String descripcion;
  final String categoria;
  final String subcategoria;
  final ConfigVariantes configVariantes;
  final List<Variante>? variantes;
  final List<Imagen>? imagenes;
  final bool activo;
  final Metadata metadata;
  bool modificado;

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.subcategoria,
    required this.configVariantes,
    required this.variantes,
    required this.imagenes,
    required this.activo,
    required this.metadata,
    this.modificado = false,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['_id'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      categoria: json['categoria'] as String,
      subcategoria: json['subcategoria'] as String,
      configVariantes: ConfigVariantes.fromJson(json['configVariantes']),
      variantes: (json['variantes'] as List<dynamic>)
          .map((variante) => Variante.fromJson(variante))
          .toList(),
      imagenes: (json['imagenes'] as List<dynamic>)
          .map((imagen) => Imagen.fromJson(imagen))
          .toList(),
      activo: json['activo'] as bool,
      metadata: Metadata.fromJson(json['metadata']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'categoria': categoria,
      'subcategoria': subcategoria,
      'configVariantes': configVariantes.toJson(),
      'variantes': variantes?.map((v) => v.toJson()).toList(),
      'imagenes': imagenes?.map((img) => img.toJson()).toList(),
      'activo': activo,
      'metadata': metadata.toJson(),
    };
  }

  Producto copyWith({
    List<Variante>? variantes,
    String? nombre,
    String? descripcion,
    String? categoria,
    String? subcategoria,
    ConfigVariantes? configVariantes,
    List<Imagen>? imagenes,
    Metadata? metadata,
    bool? activo,
    bool? modificado}) {
    final variantesModificadas = variantes?.any((v) => v.modificado) ?? 
                               this.variantes?.any((v) => v.modificado) ?? false;
    return Producto(
      id: this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      categoria: categoria ?? this.categoria,
      subcategoria: subcategoria ?? this.subcategoria,
      configVariantes: configVariantes ?? this.configVariantes,
      variantes: variantes ?? this.variantes,
      imagenes: imagenes ?? this.imagenes,
      activo: activo ?? this.activo,
      metadata: metadata ?? this.metadata,
      modificado: modificado ?? variantesModificadas,
    );
  }
}
