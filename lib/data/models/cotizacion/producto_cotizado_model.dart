import 'package:craftz_app/data/models/cotizacion/extra_cotizado_model.dart';

import './descuento_model.dart';

class ProductoCotizado {
  final bool esTemporal;
  final String? productoRef;
  final ProductoCotizadoInfo producto;
  final VarianteCotizada? variante;
  final ColorCotizado? color;
  final TallaCotizada? talla;
  final String subcategoriaId;
  final List<ExtraCotizado> extras;
  final int cantidad;
  final Descuento? descuento;
  final double precioBase;
  final double precio;
  final double precioFinal;

  ProductoCotizado({
    this.esTemporal = false,
    this.productoRef,
    required this.producto,
    this.variante,
    this.color,
    this.talla,
    required this.subcategoriaId,
    this.extras = const [],
    this.cantidad = 1,
    this.descuento,
    required this.precioBase,
    required this.precio,
    required this.precioFinal,
  });

  ProductoCotizado copyWith({
    bool? esTemporal,
    String? productoRef,
    ProductoCotizadoInfo? producto,
    VarianteCotizada? variante,
    ColorCotizado? color,
    TallaCotizada? talla,
    String? subcategoriaId,
    List<ExtraCotizado>? extras,
    int? cantidad,
    Descuento? descuento,
    double? precioBase,
    double? precio,
    double? precioFinal,
  }) {
    return ProductoCotizado(
      esTemporal: esTemporal ?? this.esTemporal,
      productoRef: productoRef ?? this.productoRef,
      producto: producto ?? this.producto,
      variante: variante ?? this.variante,
      color: color ?? this.color,
      talla: talla ?? this.talla,
      subcategoriaId: subcategoriaId ?? this.subcategoriaId,
      extras: extras ?? this.extras,
      cantidad: cantidad ?? this.cantidad,
      descuento: descuento ?? this.descuento,
      precioBase: precioBase ?? this.precioBase,
      precio: precio ?? this.precio,
      precioFinal: precioFinal ?? this.precioFinal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'esTemporal' : esTemporal,
      'productoRef': productoRef,
      'producto': producto.toJson(),
      'variante': variante?.toJson(),
      'color': color?.toJson(),
      'talla': talla?.toJson(),
      'extras': extras.map((e) => e.toJson()).toList(),
      'cantidad': cantidad,
      'descuento': descuento?.toJson(),
      'precioBase': precioBase,
      'precio': precio,
      'precioFinal': precioFinal,
    };
  }

  factory ProductoCotizado.fromJson(Map<String, dynamic> json) {
    return ProductoCotizado(
      esTemporal: json['esTemporal'] ?? false,
      productoRef: json['productoRef'],
      producto: ProductoCotizadoInfo.fromJson(json['producto']),
      variante: json['variante'] != null 
          ? VarianteCotizada.fromJson(json['variante']) 
          : null,
      color: json['color'] != null 
          ? ColorCotizado.fromJson(json['color']) 
          : null,
      talla: json['talla'] != null 
          ? TallaCotizada.fromJson(json['talla']) 
          : null,
      subcategoriaId: json['subcategoriaId'] ?? '',
      extras: (json['extras'] as List?)
          ?.map((e) => ExtraCotizado.fromJson(e))
          .toList() ?? [],
      cantidad: json['cantidad'] ?? 1,
      descuento: json['descuento'] != null 
          ? Descuento.fromJson(json['descuento']) 
          : null,
      precioBase: json['precioBase']?.toDouble() ?? 0,
      precio: json['precio']?.toDouble() ?? 0,
      precioFinal: json['precioFinal']?.toDouble() ?? 0,
    );
  }
}

class ProductoCotizadoInfo {
  final String nombre;
  final String descripcion;

  ProductoCotizadoInfo({
    required this.nombre,
    required this.descripcion,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }

  factory ProductoCotizadoInfo.fromJson(Map<String, dynamic> json) {
    return ProductoCotizadoInfo(
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
    );
  }
}

class VarianteCotizada {
  final String id;
  final String? tipo;

  VarianteCotizada({
    required this.id,
    this.tipo,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo,
    };
  }

  factory VarianteCotizada.fromJson(Map<String, dynamic> json) {
    return VarianteCotizada(
      id: json['id'] ?? '',
      tipo: json['tipo'],
    );
  }
}

class ColorCotizado {
  final String id;
  final String nombre;

  ColorCotizado({
    required this.id,
    required this.nombre,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
    };
  }

  factory ColorCotizado.fromJson(Map<String, dynamic> json) {
    return ColorCotizado(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
    );
  }
}

class TallaCotizada {
  final String id;
  final String? nombre;

  TallaCotizada({
    required this.id,
    this.nombre,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
    };
  }

  factory TallaCotizada.fromJson(Map<String, dynamic> json) {
    return TallaCotizada(
      id: json['id'] ?? '',
      nombre: json['nombre'],
    );
  }
}

class ParametroCalculo {
  final String? id;
  final String nombre;
  final double valor;

  ParametroCalculo({
    this.id,
    required this.nombre,
    required this.valor,
  });

  Map<String, dynamic> toJson() {
    return {
      'id' : id,
      'nombre' : nombre,
      'valor' : valor,
    };
  }

  factory ParametroCalculo.fromJson(Map<String, dynamic> json) {
    return ParametroCalculo(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      valor: json['valor']?.toDouble() ?? 0,
    );
  }
}