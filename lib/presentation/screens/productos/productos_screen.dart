import 'package:craftz_app/data/repositories/categorias_repositorie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../data/repositories/catalogo_productos_repositorie.dart';
import '../../../providers/product_notifier.dart';
import '../../../providers/categories_provider.dart' as proveedorCategorias;
import '../../../controllers/products_controller.dart';
import './modal_agregar_productos.dart';
import 'form_producto.dart';
import 'package:craftz_app/presentation/widgets/appbar_widget.dart';

class ProductsPage extends ConsumerStatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  late ModalAgregarProductos modalAgregarProductos;

  @override
  void initState() {
    super.initState();
    // Llamamos al provider para cargar productos cuando se inicializa
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(proveedorCategorias.categoriesProvider.notifier).cargarCategorias();
      ref.read(productosProvider.notifier).cargarProductos();
    });
  }

  Widget _buildStockControls({
    required Producto producto,
    required Variante variante,
    required Calidad calidad,
    required Color color,
    required Subcategoria subcategoria,
    Talla? talla,
  }) {
    final productsNotifier = ref.read(productosProvider.notifier);
    final stock = talla?.stock ?? color.stock ?? 0;
    final canDecrease = stock > 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.remove),
          onPressed: canDecrease ? () {
            if (subcategoria.usaTallas && talla != null) {
              productsNotifier.actualizarStock(
                producto.id, variante.id, calidad.id, color.id, talla.id, -1
              );
            } else {
              productsNotifier.actualizarStock(
                producto.id, variante.id, calidad.id, color.id, null, -1
              );
            }
          } : null,
        ),
        Text('$stock'),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            if (subcategoria.usaTallas && talla != null) {
              productsNotifier.actualizarStock(
                producto.id, variante.id, calidad.id, color.id, talla.id, 1
              );
            } else {
              productsNotifier.actualizarStock(
                producto.id, variante.id, calidad.id, color.id, null, 1
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildTallaItem({
    required BuildContext context,
    required ProductsController productsController,
    required Producto producto,
    required Variante variante,
    required Calidad calidad,
    required Color color,
    required Talla talla,
    required Subcategoria subcategoria,
  }) {
    final colors = Theme.of(context).colorScheme;
    
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => productsController
              .eliminarTalla(context, producto.id, variante.id, calidad.id, color.id, talla.id),
            backgroundColor: colors.secondary,
            icon: Icons.delete,
            label: 'Eliminar',
          ),
          SlidableAction(
            onPressed: (context) => modalAgregarProductos.mostrarFormularioTalla(
              context, producto, variante, calidad, color, 
              isEditing: true, talla: talla
            ),
            backgroundColor: colors.primary,
            icon: Icons.edit,
            label: 'Editar',
          ),
        ],
      ),
      child: ListTile(
        title: Text('${talla.talla ?? talla.codigo}'),
        subtitle: Text('\$${talla.costo} - Stock: ${talla.stock}'),
        trailing: _buildStockControls(
          producto: producto,
          variante: variante,
          calidad: calidad,
          color: color,
          talla: talla,
          subcategoria: subcategoria,
        ),
      ),
    );
  }

  Widget _buildColorItem({
    required BuildContext context,
    required ProductsController productsController,
    required Producto producto,
    required Variante variante,
    required Calidad calidad,
    required Color color,
    required Subcategoria subcategoria,
  }) {
    final colors = Theme.of(context).colorScheme;
    
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => productsController
              .eliminarColor(context, producto.id, variante.id, calidad.id, color.id),
            backgroundColor: colors.secondary,
            icon: Icons.delete,
            label: 'Eliminar',
          ),
          SlidableAction(
            onPressed: (context) => modalAgregarProductos.mostrarFormularioColor(
              context, producto, variante, calidad, subcategoria,
              isEditing: true, 
              color: color
            ),
            backgroundColor: colors.primary,
            icon: Icons.edit,
            label: 'Editar',
          ),
        ],
      ),
      child: Card(
        child: ExpansionTile(
          title: Text(color.color),
          children: [
            if (subcategoria.usaTallas && color.tallas != null)
              ...color.tallas!.map((talla) => _buildTallaItem(
                context: context,
                productsController: productsController,
                producto: producto,
                variante: variante,
                calidad: calidad,
                color: color,
                talla: talla,
                subcategoria: subcategoria,
              )),
            if (!subcategoria.usaTallas)
              ListTile(
                title: Text('Stock: ${color.stock}'),
                subtitle: Text('\$${color.costo}'),
                trailing: _buildStockControls(
                  producto: producto,
                  variante: variante,
                  calidad: calidad,
                  color: color,
                  subcategoria: subcategoria,
                ),
              ),
            if (subcategoria.usaTallas)
              TextButton(
                onPressed: () => modalAgregarProductos.mostrarFormularioTalla(
                  context, producto, variante, calidad, color, isEditing: false
                ),
                child: Text('Agregar Talla'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalidadItem({
    required BuildContext context,
    required ProductsController productsController,
    required Producto producto,
    required Variante variante,
    required Calidad calidad,
    required Subcategoria subcategoria,
  }) {
    final colors = Theme.of(context).colorScheme;
    
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => productsController
              .eliminarCalidad(context, producto.id, variante.id, calidad.id),
            backgroundColor: colors.secondary,
            icon: Icons.delete,
            label: 'Eliminar',
          ),
          SlidableAction(
            onPressed: (context) => modalAgregarProductos.mostrarFormularioCalidad(
              context, producto, variante,
              isEditing: true,
              calidad: calidad,
            ),
            backgroundColor: colors.primary,
            icon: Icons.edit,
            label: 'Editar',
          ),
        ],
      ),
      child: Card(
        child: ExpansionTile(
          title: Text(calidad.calidad ?? 'Calidad única'),
          children: [
            ...calidad.colores.map((color) => _buildColorItem(
              context: context,
              productsController: productsController,
              producto: producto,
              variante: variante,
              calidad: calidad,
              color: color,
              subcategoria: subcategoria,
            )),
            TextButton(
              onPressed: () => modalAgregarProductos.mostrarFormularioColor(
                context, producto, variante, calidad, subcategoria
              ),
              child: Text('Agregar Color'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVarianteItem({
    required BuildContext context,
    required ProductsController productsController,
    required Producto producto,
    required Variante variante,
    required Subcategoria subcategoria,
  }) {
    final colors = Theme.of(context).colorScheme;
    
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => productsController
              .eliminarVariante(context, producto.id, variante.id),
            backgroundColor: colors.secondary,
            icon: Icons.delete,
            label: 'Eliminar',
          ),
          SlidableAction(
            onPressed: (context) => modalAgregarProductos.mostrarFormularioVariante(
              context, producto,
              isEditing: true,
              variante: variante,
            ),
            backgroundColor: colors.primary,
            icon: Icons.edit,
            label: 'Editar',
          ),
        ],
      ),
      child: Card(
        child: ExpansionTile(
          title: Text(variante.variante ?? 'Variante única'),
          children: [
            ...variante.calidades.map((calidad) => _buildCalidadItem(
              context: context,
              productsController: productsController,
              producto: producto,
              variante: variante,
              calidad: calidad,
              subcategoria: subcategoria,
            )),
            TextButton(
              onPressed: () => modalAgregarProductos.mostrarFormularioCalidad(
                context, producto, variante,
                isEditing: false,
              ),
              child: Text('Agregar Calidad'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ProductsController productsController = ProductsController(ref);
    final ColorScheme colors = Theme.of(context).colorScheme;
    final CatalogoCategorias categorias = ref.watch(proveedorCategorias.categoriesProvider);
    modalAgregarProductos = ModalAgregarProductos(ref, categorias);
    final currentContext = context;
    // Obtenemos el estado de carga
    final isLoading = ref.watch(isLoadingProvider) || ref.watch(proveedorCategorias.isLoadingCategories);
    final catalogo = ref.watch(productosProvider);
    final isSaving = ref.watch(isSavingProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: Text('Inventario de Productos'),
      ),
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
              itemCount: catalogo.productos.length,
              itemBuilder: (context, index) {
                final producto = catalogo.productos[index];
                final categoria = ref.read(proveedorCategorias.categoriesProvider.notifier).getCategoria(producto);
                final subcategoria = ref.read(proveedorCategorias.categoriesProvider.notifier).getSubcategoria(producto);

                if (categoria == null || subcategoria == null) {
                  return ListTile(title: Text('Error: Categoría no encontrada para ${producto.nombre}'));
                }

                return Card(
                  margin: EdgeInsets.all(8),
                  child: ExpansionTile(
                    title: Text(producto.nombre),
                    subtitle: Text('${categoria.nombre} > ${subcategoria.nombre}'),
                    children: [
                      ...producto.variantes!.map((variante) => _buildVarianteItem(
                        context: context,
                        productsController: productsController,
                        producto: producto,
                        variante: variante,
                        subcategoria: subcategoria,
                      )),
                      TextButton(
                        onPressed: () => modalAgregarProductos.mostrarFormularioVariante(context, producto),
                        child: Text('Agregar Variante'),
                      ),
                    ],
                  ),
                );
              },
            ),
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              heroTag: 'saveFloatingButton',
              onPressed: () async {
                await productsController.guardarCambios(context);
              },
              backgroundColor: colors.secondary,
              child: isSaving 
                ? SizedBox(
                    height: 25,
                    width: 25,
                    child: CircularProgressIndicator(color: Colors.white, backgroundColor: Colors.pink.shade100, strokeWidth: 3,)
                  )
                : Icon(Icons.save),
            ),
          ),
          Positioned(
            bottom: 80.0,
            right: 16.0,
            child:FloatingActionButton(
              heroTag: 'addProductFloatingButton',
              onPressed: () async {
                final bool? hasSucceed = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FormProductoScreen(),
                  ),
                );
                if (hasSucceed != null && hasSucceed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Producto creado exitosamente')),
                  );
                }
              },
              backgroundColor: colors.secondary,
              child: Icon(Icons.add_circle_rounded, color: colors.onSecondary),
            ),
          )
        ],
      ),
    );
  }
}
