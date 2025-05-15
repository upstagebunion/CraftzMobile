import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:craftz_app/data/models/cotizacion/producto_cotizado_model.dart';
import 'package:craftz_app/data/repositories/catalogo_productos_repositorie.dart';
import 'package:craftz_app/data/repositories/categorias_repositorie.dart';

import 'package:craftz_app/providers/cotizaciones_provider.dart';
import 'package:craftz_app/providers/categories_provider.dart' as proveedorCategorias;
import 'package:craftz_app/providers/product_notifier.dart';
import 'package:craftz_app/providers/extras_provider.dart';
import 'package:craftz_app/providers/parametros_costos_provider.dart';

import './cotizacion_resumen.dart';
import './cotizacion_selector_productos.dart';
import './cotizacion_tile_producto.dart';

class CotizacionScreen extends ConsumerStatefulWidget {
  @override
  _CotizacionScreenState createState() => _CotizacionScreenState();
}

class _CotizacionScreenState extends ConsumerState<CotizacionScreen>{

  @override
  void initState() {
    super.initState();
    // Llamamos al provider para cargar productos cuando se inicializa
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(proveedorCategorias.categoriesProvider.notifier).cargarCategorias();
      ref.read(productosProvider.notifier).cargarProductos();
      ref.read(extrasProvider.notifier).cargarExtras();
      ref.read(costosElaboracionProvider.notifier).cargarCostosElaboracion();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider) || ref.watch(proveedorCategorias.isLoadingCategories)
                      || ref.watch(isLoadingCostosElaboracion) || ref.watch(isLoadingExtras);
    late final productos;
    late final categorias;
    if (!isLoading) {
      productos = ref.watch(productosProvider).productos;
      categorias = ref.watch(proveedorCategorias.categoriesProvider).categorias;
    } 
    
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
      body: Stack( 
        children: [
          isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(context, ref, productos),
          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height - 320,
            child: FloatingActionButton(
              onPressed: () => _mostrarSelectorProductos(context, ref, productos, categorias),
              child: const Icon(Icons.add)
            )
          ),
        ]
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

  void _mostrarSelectorProductos(BuildContext context, WidgetRef ref, List<Producto> productos, List<Categoria> categorias) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SelectorProductosBottomSheet(productos: productos, categorias: categorias);
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