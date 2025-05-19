import './venta_model.dart';

class ProductoVendido {
  final bool esTemporal;
  final String? productoRef;
  final ProductoVendidoInfo producto;
  final VarianteVendida? variante;
  final ColorVendido? color;
  final TallaVendida? talla;
  final List<ExtraVendido> extras;
  final int cantidad;
  final Descuento? descuento;
  final double precioBase;
  final double precio;
  final double precioFinal;

  ProductoVendido({
    this.esTemporal = false,
    this.productoRef,
    required this.producto,
    this.variante,
    this.color,
    this.talla,
    this.extras = const [],
    this.cantidad = 1,
    this.descuento,
    required this.precioBase,
    required this.precio,
    required this.precioFinal,
  });

  factory ProductoVendido.fromJson(Map<String, dynamic> json) {
    return ProductoVendido(
      esTemporal: json['esTemporal'] ?? false,
      productoRef: json['productoRef'],
      producto: ProductoVendidoInfo.fromJson(json['producto']),
      variante: json['variante'] != null 
          ? VarianteVendida.fromJson(json['variante']) 
          : null,
      color: json['color'] != null 
          ? ColorVendido.fromJson(json['color']) 
          : null,
      talla: json['talla'] != null 
          ? TallaVendida.fromJson(json['talla']) 
          : null,
      extras: (json['extras'] as List<dynamic>?)
          ?.map((e) => ExtraVendido.fromJson(e))
          .toList() ?? [],
      cantidad: json['cantidad'] ?? 1,
      descuento: json['descuento'] != null 
          ? Descuento.fromJson(json['descuento']) 
          : null,
      precioBase: json['precioBase']?.toDouble() ?? 0.0,
      precio: json['precio']?.toDouble() ?? 0.0,
      precioFinal: json['precioFinal']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'esTemporal': esTemporal,
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
}

class ProductoVendidoInfo {
  final String nombre;
  final String descripcion;

  ProductoVendidoInfo({
    required this.nombre,
    required this.descripcion,
  });

  factory ProductoVendidoInfo.fromJson(Map<String, dynamic> json) {
    return ProductoVendidoInfo(
      nombre: json['nombre'],
      descripcion: json['descripcion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }
}

class VarianteVendida {
  final String? id;
  final String? tipo;
  final String? nombreCompleto;

  VarianteVendida({
    this.id,
    this.tipo,
    this.nombreCompleto,
  });

  factory VarianteVendida.fromJson(Map<String, dynamic> json) {
    return VarianteVendida(
      id: json['id'],
      tipo: json['tipo'],
      nombreCompleto: json['nombreCompleto'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo,
      'nombreCompleto': nombreCompleto,
    };
  }
}

class ColorVendido {
  final String? id;
  final String? nombre;

  ColorVendido({
    this.id,
    this.nombre,
  });

  factory ColorVendido.fromJson(Map<String, dynamic> json) {
    return ColorVendido(
      id: json['id'],
      nombre: json['nombre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
    };
  }
}

class TallaVendida {
  final String? id;
  final String? nombre;

  TallaVendida({
    this.id,
    this.nombre,
  });

  factory TallaVendida.fromJson(Map<String, dynamic> json) {
    return TallaVendida(
      id: json['id'],
      nombre: json['nombre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
    };
  }
}

class ExtraVendido {
  final bool esTemporal;
  final String? extraRef;
  final String nombre;
  final UnidadExtra unidad;
  final double monto;
  final double? anchoCm;
  final double? largoCm;
  final ParametroCalculo? parametroCalculo;

  ExtraVendido({
    this.esTemporal = false,
    this.extraRef,
    required this.nombre,
    required this.unidad,
    required this.monto,
    this.anchoCm,
    this.largoCm,
    this.parametroCalculo,
  });

  factory ExtraVendido.fromJson(Map<String, dynamic> json) {
    return ExtraVendido(
      esTemporal: json['esTemporal'] ?? false,
      extraRef: json['extraRef'],
      nombre: json['nombre'],
      unidad: UnidadExtra.values.firstWhere(
        (e) => e.name == json['unidad'],
        orElse: () => UnidadExtra.pieza,
      ),
      monto: json['monto']?.toDouble() ?? 0.0,
      anchoCm: json['anchoCm']?.toDouble(),
      largoCm: json['largoCm']?.toDouble(),
      parametroCalculo: json['parametroCalculo'] != null 
          ? ParametroCalculo.fromJson(json['parametroCalculo']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'esTemporal': esTemporal,
      'extraRef': extraRef,
      'nombre': nombre,
      'unidad': unidad.name,
      'monto': monto,
      'anchoCm': anchoCm,
      'largoCm': largoCm,
      'parametroCalculo': parametroCalculo?.toJson(),
    };
  }
}

class ParametroCalculo {
  final String? nombre;
  final double? valor;

  ParametroCalculo({
    this.nombre,
    this.valor,
  });

  factory ParametroCalculo.fromJson(Map<String, dynamic> json) {
    return ParametroCalculo(
      nombre: json['nombre'],
      valor: json['valor']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'valor': valor,
    };
  }
}

class Pago {
  final String? razon;
  final double monto;
  final MetodoPago metodo;
  final DateTime fecha;

  Pago({
    this.razon,
    required this.monto,
    required this.metodo,
    DateTime? fecha,
  }) : fecha = fecha ?? DateTime.now();

  factory Pago.fromJson(Map<String, dynamic> json) {
    return Pago(
      razon: json['razon'],
      monto: json['monto']?.toDouble() ?? 0.0,
      metodo: MetodoPago.values.firstWhere(
        (e) => e.name == json['metodo'],
        orElse: () => MetodoPago.efectivo,
      ),
      fecha: json['fecha'] != null 
          ? DateTime.parse(json['fecha']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'razon': razon,
      'monto': monto,
      'metodo': metodo.name,
      'fecha': fecha.toIso8601String(),
    };
  }
}

class Descuento {
  final String? razon;
  final TipoDescuento tipo;
  final double valor;

  Descuento({
    this.razon,
    required this.tipo,
    required this.valor,
  });

  factory Descuento.fromJson(Map<String, dynamic> json) {
    return Descuento(
      razon: json['razon'],
      tipo: TipoDescuento.values.firstWhere(
        (e) => e.name == json['tipo'],
        orElse: () => TipoDescuento.porcentaje,
      ),
      valor: json['valor']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'razon': razon,
      'tipo': tipo.name,
      'valor': valor,
    };
  }
}

enum TipoDescuento { cantidad, porcentaje }
enum UnidadExtra { pieza, cm_cuadrado }