

import 'package:craftz_app/data/models/cotizacion/producto_cotizado_model.dart';
import 'package:craftz_app/data/repositories/catalogo_productos_repositorie.dart';
import 'package:craftz_app/providers/cotizaciones_provider.dart';
import 'package:craftz_app/providers/product_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './cotizacion_resumen.dart';
import './cotizacion_selector_productos.dart';
import './cotizacion_tile_producto.dart';

class CotizacionScreen extends ConsumerWidget {
  const CotizacionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productos = ref.watch(productosProvider).productos;
    final isLoading = ref.watch(isLoadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Cotización'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _guardarCotizacion(ref, context),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(context, ref, productos),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarSelectorProductos(context, ref, productos),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List<Producto> productos) {
    final cotizacion = ref.watch(cotizacionProvider);
    
    return Column(
      children: [
        // Lista de productos en la cotización
        Expanded(
          child: ListView.builder(
            itemCount: cotizacion.productos.length,
            itemBuilder: (context, index) {
              return ProductoTile(
                producto: cotizacion.productos[index],
                onRemove: () => ref.read(cotizacionProvider.notifier).removerProducto(index),
                onUpdate: (ProductoCotizado nuevoProducto) => ref.read(cotizacionProvider.notifier)
                  .actualizarProducto(index, nuevoProducto),
              );
            },
          ),
        ),
        // Resumen y total
        ResumenCotizacion(),
      ],
    );
  }

  void _mostrarSelectorProductos(BuildContext context, WidgetRef ref, List<Producto> productos) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SelectorProductosBottomSheet(productos: productos);
      },
    );
  }

  void _guardarCotizacion(WidgetRef ref, dynamic context) async {
    try {
      await ref.read(cotizacionProvider.notifier).guardarCotizacion();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cotización guardada exitosamente')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }
}