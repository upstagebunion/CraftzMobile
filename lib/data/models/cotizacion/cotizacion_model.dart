

import 'package:craftz_app/data/models/cotizacion/descuento_model.dart';
import 'package:craftz_app/data/models/cotizacion/producto_cotizado_model.dart';

class Cotizacion {
  final String id;
  final String clienteId;
  final String? clienteNombre; // Para mostrar sin necesidad de cargar el cliente
  final double subTotal;
  final double total;
  final List<ProductoCotizado> productos;
  final Descuento? descuentoGlobal;
  final bool ventaEnLinea;
  final DateTime fechaCreacion;
  final DateTime expira;
  final String? ventaId; // Si se convirtió en venta

  Cotizacion({
    required this.id,
    required this.clienteId,
    this.clienteNombre,
    required this.subTotal,
    required this.total,
    required this.productos,
    this.descuentoGlobal,
    this.ventaEnLinea = false,
    DateTime? fechaCreacion,
    DateTime? expira,
    this.ventaId,
  }) : 
    fechaCreacion = fechaCreacion ?? DateTime.now(),
    expira = expira ?? DateTime.now().add(const Duration(days: 15));

  factory Cotizacion.empty() => Cotizacion(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        clienteId: '',
        subTotal: 0,
        total: 0,
        productos: [],
        ventaEnLinea: false,
      );

  Cotizacion copyWith({
    String? id,
    String? clienteId,
    String? clienteNombre,
    double? subTotal,
    double? total,
    List<ProductoCotizado>? productos,
    Descuento? descuentoGlobal,
    bool? ventaEnLinea,
    DateTime? fechaCreacion,
    DateTime? expira,
    String? ventaId,
  }) {
    return Cotizacion(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      clienteNombre: clienteNombre ?? this.clienteNombre,
      subTotal: subTotal ?? this.subTotal,
      total: total ?? this.total,
      productos: productos ?? this.productos,
      descuentoGlobal: descuentoGlobal ?? this.descuentoGlobal,
      ventaEnLinea: ventaEnLinea ?? this.ventaEnLinea,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      expira: expira ?? this.expira,
      ventaId: ventaId ?? this.ventaId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clienteId': clienteId,
      'clienteNombre': clienteNombre,
      'subTotal': subTotal,
      'total': total,
      'productos': productos.map((p) => p.toJson()).toList(),
      'descuentoGlobal': descuentoGlobal?.toJson(),
      'ventaEnLinea': ventaEnLinea,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'expira': expira.toIso8601String(),
      'ventaId': ventaId,
    };
  }

  factory Cotizacion.fromJson(Map<String, dynamic> json) {
    return Cotizacion(
      id: json['id'],
      clienteId: json['clienteId'],
      clienteNombre: json['clienteNombre'],
      subTotal: json['subTotal']?.toDouble() ?? 0,
      total: json['total']?.toDouble() ?? 0,
      productos: (json['productos'] as List)
          .map((p) => ProductoCotizado.fromJson(p))
          .toList(),
      descuentoGlobal: json['descuentoGlobal'] != null
          ? Descuento.fromJson(json['descuentoGlobal'])
          : null,
      ventaEnLinea: json['ventaEnLinea'] ?? false,
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      expira: DateTime.parse(json['expira']),
      ventaId: json['ventaId'],
    );
  }
}