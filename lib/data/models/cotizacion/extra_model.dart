class Extra {
  final String id;
  final String nombre;
  final String unidad; // 'pieza' o 'cm_cuadrado'
  final double monto;

  Extra({
    required this.id,
    required this.nombre,
    required this.unidad,
    required this.monto,
  });

  factory Extra.fromJson(Map<String, dynamic> json) {
    return Extra(
      id: json['_id'] ?? json['id'],
      nombre: json['nombre'],
      unidad: json['unidad'],
      monto: json['monto'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'nombre': nombre,
      'unidad': unidad,
      'monto': monto,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Extra &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}