class Talla {
  final String id;
  final String? talla;
  int stock;
  final double precio;

  Talla({required this.id, this.talla, required this.stock, required this.precio});

  factory Talla.fromJson(Map<String, dynamic> json) {
    return Talla(
      id: json['_id'],
      talla: json['talla'] as String?,
      stock: json['stock'] as int,
      precio: (json['precio'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id' : id,
      'talla': talla,
      'stock': stock,
      'precio': precio,
    };
  }

  Talla copyWith({int? stock}) {
    return Talla(
      id: this.id,
      talla: this.talla,
      stock: stock ?? this.stock,
      precio: this.precio,
    );
  }
}
