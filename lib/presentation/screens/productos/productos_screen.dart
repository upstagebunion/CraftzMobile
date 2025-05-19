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
                  Producto producto = catalogo.productos[index];
                  Categoria? categoria = ref.read(proveedorCategorias.categoriesProvider.notifier).getCategoria(producto);
                  Subcategoria? subcategoria = ref.read(proveedorCategorias.categoriesProvider.notifier).getSubcategoria(producto);
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide.none,
                        top: BorderSide.none,
                        left: BorderSide.none,
                        right: BorderSide.none
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
                            SlidableAction(
                              onPressed: (context) async {
                                final bool? hasSucceed = await Navigator.push(
                                  currentContext,
                                  MaterialPageRoute(
                                    builder: (context) => FormProductoScreen(
                                      isEditing: true,
                                      producto: producto
                                    ),
                                  ),
                                );
                                if (hasSucceed != null && hasSucceed) {
                                  if(!currentContext.mounted) return;
                                  ScaffoldMessenger.of(currentContext).showSnackBar(
                                    SnackBar(content: Text('Producto actualizado exitosamente')),
                                  );
                                }
                              },
                              backgroundColor: colors.primary,
                              icon: Icons.edit,
                              label: 'Editar',
                            ),
                          ],
                        ),
                        child: ExpansionTile(
                          shape: RoundedRectangleBorder(side: BorderSide.none, borderRadius: BorderRadius.circular(20)),
                          backgroundColor: colors.primary.withAlpha(15),
                          onExpansionChanged: (bool expanded) {
                            setState(() {
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
                                    SlidableAction(
                                      onPressed: (context) async {
                                        modalAgregarProductos.mostrarFormularioVariante(context, producto, isEditing: true, variante: variante);
                                      },
                                      backgroundColor: colors.primary,
                                      icon: Icons.edit,
                                      label: 'Editar',
                                    ),
                                  ],
                                ),
                                child: ExpansionTile(
                                  shape: RoundedRectangleBorder(side: BorderSide.none, borderRadius: BorderRadius.circular(20)),
                                  backgroundColor: colors.primary.withAlpha(10),
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
                                            SlidableAction(
                                              onPressed: (context) async {
                                                modalAgregarProductos.mostrarFormularioColor(context, producto, variante, subcategoria!, isEditing: true, color:color);
                                              },
                                              backgroundColor: colors.primary,
                                              icon: Icons.edit,
                                              label: 'Editar',
                                            ),
                                          ],
                                        ),
                                        child: ExpansionTile(
                                          shape: RoundedRectangleBorder(side: BorderSide.none, borderRadius: BorderRadius.circular(20)),
                                          backgroundColor: colors.primary.withAlpha(10),
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
                                                    SlidableAction(
                                                      onPressed: (context) async {
                                                        modalAgregarProductos.mostrarFormularioTalla(context, producto, variante, color, isEditing: true, talla:talla);
                                                      },
                                                      backgroundColor: colors.primary,
                                                      icon: Icons.edit,
                                                      label: 'Editar',
                                                    ),
                                                  ],
                                                ),
                                                child: ListTile(
                                                  title: Text('${talla.talla} - \$${talla.costo}'),
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
                                              subtitle: Text('\$${color.costo}'),
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
                                                  modalAgregarProductos.mostrarFormularioTalla(context, producto, variante, color, isEditing: false);
                                                },
                                                child: Text('Agregar Talla'),
                                              ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    TextButton(
                                      onPressed: () {
                                        modalAgregarProductos.mostrarFormularioColor(context, producto, variante, subcategoria!, isEditing: false);
                                      },
                                      child: Text('Agregar Color'),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            TextButton(
                              onPressed: () {
                                modalAgregarProductos.mostrarFormularioVariante(context, producto);
                              },
                              child: Text('Agregar Variante'),
                            ),
                          ],
                        ),
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
