import 'package:craftz_app/data/repositories/categorias_repositorie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../data/repositories/catalogo_productos_repositorie.dart';
import '../../../providers/product_notifier.dart';
import '../../../providers/categories_provider.dart' as proveedorCategorias;
import '../../../controllers/products_controller.dart';
import './modal_agregar_productos.dart';
import './agregar_producto.dart';

class ProductsPage extends ConsumerStatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  late ModalAgregarProductos modalAgregarProductos;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    // Llamamos al provider para cargar productos cuando se inicializa
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(proveedorCategorias.categoriesProvider.notifier).cargarCategorias();
      ref.read(productosProvider.notifier).cargarProductos();
    });
  }

  @override
  Widget build(BuildContext context) {
    ProductsController productsController = ProductsController(ref);
    final ColorScheme colors = Theme.of(context).colorScheme;
    final CatalogoCategorias categorias = ref.watch(proveedorCategorias.categoriesProvider);
    modalAgregarProductos = ModalAgregarProductos(ref, categorias);
    // Obtenemos el estado de carga
    final isLoading = ref.watch(isLoadingProvider) || ref.watch(proveedorCategorias.isLoadingCategories);
    final catalogo = ref.watch(productosProvider);
    final isSaving = ref.watch(isSavingProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Inventario de Productos'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: catalogo.productos.length,
              itemBuilder: (context, index) {
                Producto producto = catalogo.productos[index];
                Categoria? categoria = ref.read(proveedorCategorias.categoriesProvider.notifier).getCategoria(producto);
                Subcategoria? subcategoria = ref.read(proveedorCategorias.categoriesProvider.notifier).getSubcategoria(producto);
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: _isExpanded ? Colors.transparent : Colors.grey,
                        width: 0.5,
                      ), // Solo un borde en la parte inferior
                    ),
                  ),
                  child: categoria == null && subcategoria == null
                    ? Text('Error al obtener la categoria y subcategoria de ${producto.nombre}')
                    : Slidable(
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) async {
                              productsController.eliminarProducto(context, producto.id);
                            },
                            backgroundColor: colors.secondary,
                            icon: Icons.delete,
                            label: 'Eliminar',
                          ),
                        ],
                      ),
                      child: ExpansionTile(
                        onExpansionChanged: (bool expanded) {
                          setState(() {
                            _isExpanded = expanded;
                          });
                        },
                        title: Row(
                          children: [
                            Padding(padding: EdgeInsets.symmetric(vertical: 20)),
                            Icon(Icons.shopping_bag),
                            SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(producto.nombre),
                                  Text(
                                    producto.descripcion,
                                    style: TextStyle(fontSize: 10),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        children: [
                          ...producto.variantes!.map((variante) {
                            return Slidable(
                              endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (context) async {
                                      productsController.eliminarVariante(context, producto.id, variante.id);
                                    },
                                    backgroundColor: colors.secondary,
                                    icon: Icons.delete,
                                    label: 'Eliminar',
                                  ),
                                ],
                              ),
                              child: ExpansionTile(
                                title: Text(variante.tipo ?? 'Accesorio'),
                                children: [
                                  ...variante.colores.map((color) {
                                    return Slidable(
                                      endActionPane: ActionPane(
                                        motion: const ScrollMotion(),
                                        children: [
                                          SlidableAction(
                                            onPressed: (context) async {
                                              productsController.eliminarColor(context, producto.id, variante.id, color.id);
                                            },
                                            backgroundColor: colors.secondary,
                                            icon: Icons.delete,
                                            label: 'Eliminar',
                                          ),
                                        ],
                                      ),
                                      child: ExpansionTile(
                                        title: Text(color.color),
                                        children: [
                                          if (color.tallas != null && subcategoria!.usaTallas) ...color.tallas!.map((talla) {
                                            return Slidable(
                                              endActionPane: ActionPane(
                                                motion: const ScrollMotion(),
                                                children: [
                                                  SlidableAction(
                                                    onPressed: (context) async {
                                                      productsController.eliminarTalla(context, producto.id, variante.id, color.id, talla.id);
                                                    },
                                                    backgroundColor: colors.secondary,
                                                    icon: Icons.delete,
                                                    label: 'Eliminar',
                                                  ),
                                                ],
                                              ),
                                              child: ListTile(
                                                title: Text('${talla.talla} - \$${talla.precio}'),
                                                subtitle: Text('Stock: ${talla.stock}'),
                                                trailing: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      icon: Icon(Icons.remove),
                                                      onPressed: () {
                                                        setState(() {
                                                          talla.stock = talla.stock > 0 ? talla.stock - 1 : talla.stock;
                                                        });
                                                      },
                                                    ),
                                                    IconButton(
                                                      icon: Icon(Icons.add),
                                                      onPressed: () {
                                                        setState(() {
                                                          talla.stock++;
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          if (!subcategoria!.usaTallas) ListTile(
                                            title: Text('Stock: ${color.stock}'),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: Icon(Icons.remove),
                                                  onPressed: () {
                                                    setState(() {
                                                      color.stock = color.stock! > 0 ? color.stock! - 1 : color.stock!;
                                                    });
                                                  },
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.add),
                                                  onPressed: () {
                                                    setState(() {
                                                      color.stock = color.stock! + 1;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (subcategoria.usaTallas)
                                            TextButton(
                                              onPressed: () {
                                                modalAgregarProductos.mostrarFormularioAgregarTalla(context, producto, variante, color);
                                              },
                                              child: Text('Agregar Talla'),
                                            ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  TextButton(
                                    onPressed: () {
                                      modalAgregarProductos.mostrarFormularioAgregarColor(context, producto, variante, subcategoria!);
                                    },
                                    child: Text('Agregar Color'),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          TextButton(
                            onPressed: () {
                              modalAgregarProductos.mostrarFormularioAgregarVariante(context, producto);
                            },
                            child: Text('Agregar Variante'),
                          ),
                        ],
                      ),
                    ),
                );
              },
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
                    builder: (context) => AgregarProductoScreen(),
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
