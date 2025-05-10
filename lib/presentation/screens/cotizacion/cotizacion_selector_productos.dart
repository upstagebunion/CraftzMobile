import 'package:craftz_app/data/repositories/catalogo_productos_repositorie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './cotizacion_extras.dart';

class SelectorProductosBottomSheet extends ConsumerWidget {
  final List<Producto> productos;

  const SelectorProductosBottomSheet({required this.productos});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        children: [
          const Text(
            'Selecciona un producto',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: productos.length,
              itemBuilder: (context, index) {
                final producto = productos[index];
                return ListTile(
                  title: Text(producto.nombre),
                  subtitle: Text(producto.descripcion),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(context);
                    _mostrarDetallesProducto(context, ref, producto);
                  },
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
        return DetallesProductoBottomSheet(producto: producto);
      },
    );
  }
}