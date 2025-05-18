// cliente_model.dart
class Cliente {
  final String id;
  final String nombre;
  final String? apellidoPaterno;
  final String? apellidoMaterno;
  final String? alias;
  final int compras;
  final String? correo;
  final String? telefono;
  final DateTime fechaRegistro;
  final DateTime? ultimaCompra;
  final List<String>? historialCompras;

  Cliente({
    required this.id,
    required this.nombre,
    this.apellidoPaterno,
    this.apellidoMaterno,
    this.alias,
    this.compras = 0,
    this.correo,
    this.telefono,
    required this.fechaRegistro,
    this.ultimaCompra,
    this.historialCompras,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['_id'] ?? json['id'],
      nombre: json['nombre'],
      apellidoPaterno: json['apellido_paterno'],
      apellidoMaterno: json['apellido_materno'],
      alias: json['alias'],
      compras: json['compras'] ?? 0,
      correo: json['correo'],
      telefono: json['telefono'],
      fechaRegistro: DateTime.parse(json['fecha_registro']),
      ultimaCompra: json['ultima_compra'] != null ? DateTime.parse(json['ultima_compra']) : null,
      historialCompras: json['historial_compras'] != null ? List<String>.from(json['historial_compras']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'apellido_paterno': apellidoPaterno,
      'apellido_materno': apellidoMaterno,
      'alias': alias,
      'compras': compras,
      'correo': correo,
      'telefono': telefono,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'ultima_compra': ultimaCompra?.toIso8601String(),
      'historial_compras': historialCompras,
    };
  }
}