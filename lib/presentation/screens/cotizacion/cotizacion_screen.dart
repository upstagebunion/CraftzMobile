import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:craftz_app/data/repositories/cotizacion_repositories.dart';
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

  final String cotizacionId;
  final bool nuevaCotizacion;

  const CotizacionScreen({
    Key? key,
    required this.cotizacionId,
    this.nuevaCotizacion = true,
  }) :super(key: key);

  @override
  _CotizacionScreenState createState() => _CotizacionScreenState();
}

class _CotizacionScreenState extends ConsumerState<CotizacionScreen>{
  late String cotizacionId = widget.cotizacionId;
  late Cotizacion? _cotizacionLocal;

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
    final colors = Theme.of(context).colorScheme;
    final isLoading = ref.watch(isLoadingProvider) || ref.watch(proveedorCategorias.isLoadingCategories)
                      || ref.watch(isLoadingCostosElaboracion) || ref.watch(isLoadingExtras);
    late final productos;
    late final categorias;
    if (!isLoading) {
      productos = ref.watch(productosProvider).productos;
      categorias = ref.watch(proveedorCategorias.categoriesProvider).categorias;
      _cotizacionLocal = ref.watch(cotizacionesProvider.select(
          (state) => state.cotizaciones.firstWhere(
            (c) => c.id == cotizacionId
          ),
        ),
      );
    } 
    
    return Scaffold(
      appBar: AppBar(
        title: widget.nuevaCotizacion 
          ? Text('Nueva Cotización')
          : Text('Cotizacion ${_cotizacionLocal!.clienteNombre}'),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        titleTextStyle: Theme.of(context).textTheme.headlineSmall,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _guardarCotizacion(ref, context),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack( 
          children: [
            isLoading || _cotizacionLocal == null
              ? const Center(child: CircularProgressIndicator())
              : _buildContent(context, ref, productos),
            Positioned(
              right: 16,
              top: MediaQuery.of(context).size.height - 340,
              child: FloatingActionButton(
                onPressed: () => _mostrarSelectorProductos(context, ref, productos, categorias),
                child: const Icon(Icons.add)
              )
            ),
          ]
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List<Producto> productos) {
    final List<ProductoCotizado> productosEnCotizacion = _cotizacionLocal!.productos;

    return Column(
      children: [
        // Lista de productos en la cotización
        Expanded(
          child: ListView.builder(
            itemCount: productosEnCotizacion.length,
            itemBuilder: (context, index) {
              return ProductoTile(
                producto: productosEnCotizacion[index],
                onRemove: () => ref.read(cotizacionesProvider.notifier).removerProductoDeCotizacion(_cotizacionLocal!.id!, index),
                onUpdate: (ProductoCotizado nuevoProducto) => ref.read(cotizacionesProvider.notifier)
                  .actualizarProductoEnCotizacion(_cotizacionLocal!.id!, index, nuevoProducto),
              );
            },
          ),
        ),
        // Resumen y total
        ResumenCotizacion(cotizacionId: cotizacionId),
      ],
    );
  }

  void _mostrarSelectorProductos(BuildContext context, WidgetRef ref, List<Producto> productos, List<Categoria> categorias) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SelectorProductosBottomSheet(productos: productos, categorias: categorias, cotizacionId: _cotizacionLocal!.id!);
      },
    );
  }

  void _guardarCotizacion(WidgetRef ref, dynamic context) async {
    try {
      widget.nuevaCotizacion 
        ? await ref.read(cotizacionesProvider.notifier).agregarCotizacion(_cotizacionLocal!)
        : await ref.read(cotizacionesProvider.notifier).actualizarCotizacion(_cotizacionLocal!);
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