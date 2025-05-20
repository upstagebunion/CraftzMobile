import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../../providers/categories_provider.dart';
import '../../../providers/product_notifier.dart';
import '../../../data/repositories/catalogo_productos_repositorie.dart';
import '../../../data/repositories/categorias_repositorie.dart';
import '../../../controllers/missing_products_controller.dart';
import 'package:craftz_app/presentation/widgets/appbar_widget.dart';

class ListaComprasScreen extends ConsumerStatefulWidget {
  @override
  _ListaComprasScreenState createState() => _ListaComprasScreenState();
}

class _ListaComprasScreenState extends ConsumerState<ListaComprasScreen> {

  @override
  void initState() {
    super.initState();
    // Llamamos al provider para cargar productos cuando se inicializa
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoriesProvider.notifier).cargarCategorias();
      ref.read(productosProvider.notifier).cargarProductos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final CatalogoCategorias categorias = ref.watch(categoriesProvider);
    final CatalogoProductos catalogo = ref.watch(productosProvider);
    final isLoading = ref.watch(isLoadingProvider) || ref.watch(isLoadingCategories);

    return Scaffold(
      appBar: CustomAppBar(
        title: Text('Productos Faltos de Stock'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Filtrado de productos por comprar
            },
          ),
        ],
      ),
      body: isLoading
      ? Center(child: CircularProgressIndicator())
      :  ProductosFaltosStockScreen(categorias, catalogo),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Generacion de PDF de lista de compras
        },
        child: Icon(Icons.shopping_cart),
      ),
    );
  }
}

class ProductosFaltosStockScreen extends StatelessWidget {
  final CatalogoCategorias catalogoCategorias;
  final CatalogoProductos catalogoProductos;

  ProductosFaltosStockScreen(this.catalogoCategorias, this.catalogoProductos);

  @override
  Widget build(BuildContext context) {
    final MissingProductsController missingProductsController = MissingProductsController(catalogoCategorias: catalogoCategorias, catalogoProductos: catalogoProductos);
    return SafeArea(
      child: ListView.builder(
          itemCount: catalogoCategorias.categorias.length,
          itemBuilder: (context, index) {
            final categoria = catalogoCategorias.categorias[index];
      
            final subcategoriasConProductos = categoria.subcategorias.where((subcategoria) {
              final productosFiltrados = missingProductsController.obtenerProductosFaltosStockPorSubcategoria(subcategoria);
              return productosFiltrados.isNotEmpty;
            }).toList();
      
            if (subcategoriasConProductos.isEmpty) {
              return SizedBox.shrink(); // No mostrar si no hay elementos
            }
      
            return ExpansionTile(
              title: Text(categoria.nombre),
              children: subcategoriasConProductos.map((subcategoria) {
                final productosFiltrados = missingProductsController.obtenerProductosFaltosStockPorSubcategoria(subcategoria);
      
                return ExpansionTile(
                  title: Text(subcategoria.nombre),
                  children: productosFiltrados.map((producto) {
                    return ProductoExpansionTile(
                      producto: producto,
                      usaTallas: subcategoria.usaTallas,
                    );
                  }).toList(),
                );
              }).toList(),
            );
          }),
    );
  }
}

class ProductoExpansionTile extends StatelessWidget {
  final Producto producto;
  final bool usaTallas;

  ProductoExpansionTile({required this.producto, required this.usaTallas});

  @override
  Widget build(BuildContext context) {
    final variantesConItems = producto.variantes?.where((variante) {
      return variante.colores.any((color) {
        if (usaTallas) {
          return color.tallas?.any((talla) => talla.stock < 2) ?? false;
        } else {
          return color.stock != null && color.stock! < 2;
        }
      });
    }).toList();

    if (variantesConItems == null || variantesConItems.isEmpty) {
      return SizedBox.shrink(); // No mostrar si no hay elementos
    }

    return ExpansionTile(
      title: Text(producto.nombre),
      children: variantesConItems.map((variante) {
        final coloresConItems = variante.colores.where((color) {
          if (usaTallas) {
            return color.tallas?.any((talla) => talla.stock < 2) ?? false;
          } else {
            return color.stock != null && color.stock! < 2;
          }
        }).toList();

        if (coloresConItems.isEmpty) {
          return SizedBox.shrink(); // No mostrar si no hay elementos
        }

        return ListTile(
          title: Text(variante.tipo ?? 'Variante'),
          subtitle: Column(
            children: coloresConItems.map((color) {
              final List<Talla>? items = usaTallas
                  ? color.tallas?.where((talla) => talla.stock < 2).toList() ?? []
                  : null;
              final List<Color> colores = [color];

              return ListTile(
                title: Text(color.color),
                subtitle: Column(
                  children: items != null 
                  ? items.map((item) {
                      return ListTile(
                          title: Row(
                            children: [
                              Icon(Icons.warning, color: Colors.red,),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Talla: ${item.talla}'),
                                  Text('Stock: ${item.stock} | Sugerido: ${2 - item.stock}')
                                ],
                              )
                            ]
                          ),
                      );
                    }).toList()
                  : colores.map((item) {
                      return ListTile(
                        title: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.red,),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Color: ${color.color}'),
                                Text('Stock: ${item.stock} | Sugerido: ${2 - item.stock!}'),
                              ],
                            )
                          ]
                        ),
                      );
                    }).toList()
                )
              );
            }).toList(),
          )
        );
      }).toList(),
    );
  }
}