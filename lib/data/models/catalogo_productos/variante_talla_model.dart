class Talla {
  final String id;
  final String? talla;
  int stock;
  final double? costo;

  Talla({required this.id, this.talla, required this.stock, required this.costo});

  factory Talla.fromJson(Map<String, dynamic> json) {
    return Talla(
      id: json['_id'],
      talla: json['talla'] as String?,
      stock: json['stock'] as int,
      costo: json['costo'] != null ? (json['costo'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id' : id,
      'talla': talla,
      'stock': stock,
      'costo': costo,
    };
  }

  Talla copyWith({int? stock, String? talla, double? costo}) {
    return Talla(
      id: this.id,
      talla: talla ?? this.talla,
      stock: stock ?? this.stock,
      costo: costo ?? this.costo,
    );
  }
}
