import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:craftz_app/data/repositories/cotizacion_repositories.dart';
import 'package:craftz_app/data/repositories/catalogo_productos_repositorie.dart';
import 'package:craftz_app/data/repositories/categorias_repositorie.dart';
import 'package:craftz_app/data/repositories/clientes_repositorie.dart';

import 'package:craftz_app/providers/cotizaciones_provider.dart';
import 'package:craftz_app/providers/categories_provider.dart' as proveedorCategorias;
import 'package:craftz_app/providers/product_notifier.dart';
import 'package:craftz_app/providers/extras_provider.dart';
import 'package:craftz_app/providers/parametros_costos_provider.dart';
import 'package:craftz_app/providers/clientes_provider.dart';
import 'package:craftz_app/presentation/widgets/appbar_widget.dart';

import './cotizacion_resumen.dart';
import './cotizacion_selector_productos.dart';
import './cotizacion_tile_producto.dart';

class CotizacionScreen extends ConsumerStatefulWidget {

  final String cotizacionId;
  final bool nuevaCotizacion;
  final contextPrincipal;

  const CotizacionScreen({
    Key? key,
    required this.cotizacionId,
    this.nuevaCotizacion = true,
    required this.contextPrincipal
  }) :super(key: key);

  @override
  _CotizacionScreenState createState() => _CotizacionScreenState();
}

class _CotizacionScreenState extends ConsumerState<CotizacionScreen>{
  late String cotizacionId = widget.cotizacionId;
  Cotizacion? _cotizacionLocal;
  late TextEditingController _clienteSearchController;

  @override
  void initState() {
    
    super.initState();
    _clienteSearchController = TextEditingController();
    // Llamamos al provider para cargar productos cuando se inicializa
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(proveedorCategorias.categoriesProvider.notifier).cargarCategorias();
      ref.read(productosProvider.notifier).cargarProductos();
      ref.read(extrasProvider.notifier).cargarExtras();
      ref.read(costosElaboracionProvider.notifier).cargarCostosElaboracion();
      ref.read(clientesProvider.notifier).cargarClientes();
    });
  }

  @override
  void dispose() {
    _clienteSearchController.dispose();
    super.dispose();
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
            (c) => c.id == cotizacionId,
            orElse: null,
          ),
        ),
      );
    } 
    
    return _cotizacionLocal == null 
    ? const SizedBox.shrink()
    : Scaffold(
      appBar: CustomAppBar(
        title: widget.nuevaCotizacion 
          ? Text('Nueva Cotización')
          : Text('Cotizacion ${_cotizacionLocal!.clienteNombre}'),
        actions: [
          if (_cotizacionLocal != null && _cotizacionLocal!.cliente == '')
          IconButton(
            icon: const Icon(Icons.face_retouching_natural_rounded),
            onPressed: () => _mostrarSelectorCliente(context)
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
        ResumenCotizacion(
          cotizacionId: cotizacionId,
          contextPrincipal: widget.contextPrincipal
        ),
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

  void _mostrarSelectorCliente(BuildContext context) {
    final clientes = ref.watch(clientesProvider).clientes;
    final isLoading = ref.watch(isLoadingClientes);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Seleccionar cliente'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _clienteSearchController,
                  decoration: const InputDecoration(
                    labelText: 'Buscar cliente',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    // TODO: implementar busqueda
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: clientes.length,
                          itemBuilder: (context, index) {
                            final cliente = clientes[index];
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(cliente.nombre[0]),
                              ),
                              title: Text('${cliente.nombre} ${cliente.apellidoPaterno ?? ''}'),
                              subtitle: Text(cliente.telefono ?? 'Sin teléfono'),
                              onTap: () {
                                _actualizarClienteEnCotizacion(cliente);
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Nuevo cliente'),
              onPressed: () {
                Navigator.pop(context);
                _mostrarFormularioCliente(context);
              },
            ),
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  void _mostrarFormularioCliente(BuildContext context) {
    final nombreController = TextEditingController();
    final telefonoController = TextEditingController();
    final correoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nuevo cliente'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre*'),
                ),
                TextField(
                  controller: telefonoController,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: correoController,
                  decoration: const InputDecoration(labelText: 'Correo electrónico'),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Guardar'),
              onPressed: () async {
                if (nombreController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('El nombre es obligatorio')),
                  );
                  return;
                }

                try {
                  final nuevoCliente = Cliente(
                    id: '', // El backend generará el ID
                    nombre: nombreController.text,
                    telefono: telefonoController.text,
                    correo: correoController.text,
                    fechaRegistro: DateTime.now(),
                  );

                  // Guardar el cliente y actualizar la cotización
                  await ref.read(clientesProvider.notifier).agregarCliente(nuevoCliente);
                  _actualizarClienteEnCotizacion(nuevoCliente);
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al guardar cliente: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _actualizarClienteEnCotizacion(Cliente cliente) async {
    await ref.read(cotizacionesProvider.notifier).actualizarCotizacionLocalmente(
        _cotizacionLocal!.copyWith(
        clienteId: cliente.id,
        clienteNombre: '${cliente.nombre} ${cliente.apellidoPaterno ?? ''}',
      )
    );
    
  }
}