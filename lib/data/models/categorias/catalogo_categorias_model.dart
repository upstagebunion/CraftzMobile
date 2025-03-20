import './categoria_model.dart';

class CatalogoCategorias {
  final List<Categoria> categorias;

  CatalogoCategorias({required this.categorias});

  factory CatalogoCategorias.fromJson(List<dynamic> json) {
    return CatalogoCategorias(
      categorias: json.map((categoria) => Categoria.fromJson(categoria)).toList(),
    );
  }

  List<Map<String, dynamic>> toJson() {
    return categorias.map((categoria) => categoria.toJson()).toList();
  }
}