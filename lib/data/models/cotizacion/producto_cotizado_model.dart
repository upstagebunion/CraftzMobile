import './extra_model.dart';
import './descuento_model.dart';

class ProductoCotizado {
  final String productoRef;
  final ProductoCotizadoInfo producto;
  final VarianteCotizada? variante;
  final ColorCotizado? color;
  final TallaCotizada? talla;
  final List<Extra> extras;
  final int cantidad;
  final Descuento? descuento;
  final double precio;
  final double precioFinal;

  ProductoCotizado({
    required this.productoRef,
    required this.producto,
    this.variante,
    this.color,
    this.talla,
    this.extras = const [],
    this.cantidad = 1,
    this.descuento,
    required this.precio,
    required this.precioFinal,
  });

  ProductoCotizado copyWith({
    String? productoRef,
    ProductoCotizadoInfo? producto,
    VarianteCotizada? variante,
    ColorCotizado? color,
    TallaCotizada? talla,
    List<Extra>? extras,
    int? cantidad,
    Descuento? descuento,
    double? precio,
    double? precioFinal,
  }) {
    return ProductoCotizado(
      productoRef: productoRef ?? this.productoRef,
      producto: producto ?? this.producto,
      variante: variante ?? this.variante,
      color: color ?? this.color,
      talla: talla ?? this.talla,
      extras: extras ?? this.extras,
      cantidad: cantidad ?? this.cantidad,
      descuento: descuento ?? this.descuento,
      precio: precio ?? this.precio,
      precioFinal: precioFinal ?? this.precioFinal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productoRef': productoRef,
      'producto': producto.toJson(),
      'variante': variante?.toJson(),
      'color': color?.toJson(),
      'talla': talla?.toJson(),
      'extras': extras.map((e) => e.toJson()).toList(),
      'cantidad': cantidad,
      'descuento': descuento?.toJson(),
      'precio': precio,
      'precioFinal': precioFinal,
    };
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
}

