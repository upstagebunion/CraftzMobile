import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:craftz_app/data/repositories/catalogo_productos_repositorie.dart';
import 'package:craftz_app/data/repositories/categorias_repositorie.dart';
import 'package:craftz_app/controllers/products_controller.dart';
import 'cotizacion_detalles_producto.dart';

class SelectorProductosBottomSheet extends ConsumerWidget {
  final String cotizacionId;
  final List<Producto> productos;
  final List<Categoria> categorias;

  const SelectorProductosBottomSheet({required this.productos, required this.categorias, required this.cotizacionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    ProductsController productsController = ProductsController(ref);

    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        children: [
          Text(
            'Selecciona un producto',
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: categorias.length,
              itemBuilder: (context, categoriaIndex) {
                final categoria = categorias[categoriaIndex];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        categoria.nombre,
                        style: textTheme.titleMedium
                        ),
                      ),
                    ...categoria.subcategorias.map((subcategoria) {
                      final productosDeSubcategoria = productsController.obtenerProductosPorSubcategoria(
                        productos,
                        subcategoria
                      );
                      return ExpansionTile(
                        title: Text(subcategoria.nombre, style: textTheme.titleSmall),
                        children: productosDeSubcategoria.map((producto) => ListTile(
                          title: Text(producto.nombre, style: textTheme.bodyLarge),
                          subtitle: Text(producto.descripcion, style: textTheme.bodyMedium),
                          trailing: const Icon(Icons.add_shopping_cart),
                          onTap: () {
                            Navigator.pop(context);
                            _mostrarDetallesProducto(context, ref, producto);
                          },
                        )).toList(),
                      );
                    }).toList(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDetallesProducto(BuildContext context, WidgetRef ref, Producto producto) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DetallesProductoBottomSheet(producto: producto, cotizacionId: cotizacionId);
      },
    );
  }
}