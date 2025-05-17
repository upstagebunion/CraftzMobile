class Descuento {
  final String? razon;
  final String tipo; // 'cantidad' o 'porcentaje'
  final double valor;

  Descuento({
    this.razon,
    required this.tipo,
    required this.valor,
  });

  factory Descuento.fromJson(Map<String, dynamic> json) {
    return Descuento(
      razon: json['razon'],
      tipo: json['tipo'] ?? 'cantidad',
      valor: json['valor']?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'razon': razon,
      'tipo': tipo,
      'valor': valor,
    };
  }

  double aplicarDescuento(double precio) {
    if (tipo == 'porcentaje') {
      return precio * (1 - valor / 100);
    } else {
      return precio - valor;
    }
  }

  String descripcion() {
    if (tipo == 'porcentaje') {
      return '${valor}%${razon != null ? ' ($razon)' : ''}';
    } else {
      return '\$${valor.toStringAsFixed(2)}${razon != null ? ' ($razon)' : ''}';
    }
  }
}