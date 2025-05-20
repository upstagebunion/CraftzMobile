import './producto_vendido_model.dart';

enum EstadoVenta {
  pendiente,
  confirmado,
  preparado,
  liquidado,
  entregado,
  devuelto
}

enum MetodoPago {
  efectivo,
  tarjeta,
  transferencia
}

class Venta {
  final String id;
  final String cliente;
  final String? clienteNombre;
  final double subTotal;
  final double total;
  final List<ProductoVendido> productos;
  final Descuento? descuentoGlobal;
  final bool ventaEnLinea;
  final EstadoVenta estado;
  final List<Pago> pagos;
  final double restante;
  final DateTime fechaCreacion;
  final DateTime? fechaLiquidacion;
  final String? vendedor;

  Venta({
    required this.id,
    required this.cliente,
    this.clienteNombre,
    required this.subTotal,
    required this.total,
    required this.productos,
    this.descuentoGlobal,
    this.ventaEnLinea = false,
    this.estado = EstadoVenta.pendiente,
    this.pagos = const [],
    required this.restante,
    DateTime? fechaCreacion,
    this.fechaLiquidacion,
    this.vendedor,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  factory Venta.fromJson(Map<String, dynamic> json) {
    return Venta(
      id: json['_id'] ?? json['id'],
      cliente: json['cliente']['_id'],
      clienteNombre: json['cliente']['nombre'],
      subTotal: json['subTotal']?.toDouble() ?? 0.0,
      total: json['total']?.toDouble() ?? 0.0,
      productos: (json['productos'] as List<dynamic>?)
          ?.map((p) => ProductoVendido.fromJson(p))
          .toList() ?? [],
      descuentoGlobal: json['descuentoGlobal'] != null 
          ? Descuento.fromJson(json['descuentoGlobal']) 
          : null,
      ventaEnLinea: json['ventaEnLinea'] ?? false,
      estado: EstadoVenta.values.firstWhere(
        (e) => e.name == json['estado'],
        orElse: () => EstadoVenta.pendiente,
      ),
      pagos: (json['pagos'] as List<dynamic>?)
          ?.map((p) => Pago.fromJson(p))
          .toList() ?? [],
      restante: json['restante']?.toDouble() ?? 0.0,
      fechaCreacion: json['fechaCreacion'] != null 
          ? DateTime.parse(json['fechaCreacion']) 
          : null,
      fechaLiquidacion: json['fechaLiquidacion'] != null 
          ? DateTime.parse(json['fechaLiquidacion']) 
          : null,
      vendedor: json['vendedor'] != null
        ? json['vendedor']['nombre']
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cliente': cliente,
      'clienteNombre': clienteNombre,
      'subTotal': subTotal,
      'total': total,
      'productos': productos.map((p) => p.toJson()).toList(),
      'descuentoGlobal': descuentoGlobal?.toJson(),
      'ventaEnLinea': ventaEnLinea,
      'estado': estado.name,
      'pagos': pagos.map((p) => p.toJson()).toList(),
      'restante': restante,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaLiquidacion': fechaLiquidacion?.toIso8601String(),
      'vendedor': vendedor,
    };
  }

  Venta copyWith({
    String? id,
    String? cliente,
    String? clienteNombre,
    double? subTotal,
    double? total,
    List<ProductoVendido>? productos,
    Descuento? descuentoGlobal,
    bool? ventaEnLinea,
    EstadoVenta? estado,
    List<Pago>? pagos,
    double? restante,
    DateTime? fechaCreacion,
    DateTime? fechaLiquidacion,
    String? vendedor,
  }) {
    return Venta(
      id: id ?? this.id,
      cliente: cliente ?? this.cliente,
      clienteNombre: clienteNombre ?? this.clienteNombre,
      subTotal: subTotal ?? this.subTotal,
      total: total ?? this.total,
      productos: productos ?? this.productos,
      descuentoGlobal: descuentoGlobal ?? this.descuentoGlobal,
      ventaEnLinea: ventaEnLinea ?? this.ventaEnLinea,
      estado: estado ?? this.estado,
      pagos: pagos ?? this.pagos,
      restante: restante ?? this.restante,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaLiquidacion: fechaLiquidacion ?? this.fechaLiquidacion,
      vendedor: vendedor ?? this.vendedor,
    );
  }
}