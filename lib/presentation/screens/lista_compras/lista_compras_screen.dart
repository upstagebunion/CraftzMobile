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
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: isLoading
      ? Center(child: CircularProgressIndicator())
      :  _buildProductList(categorias, catalogo),
      floatingActionButton: FloatingActionButton(
        onPressed: _generatePurchaseList,
        child: Icon(Icons.picture_as_pdf),
        tooltip: 'Generar PDF',
      ),
    );
  }
  void _showFilterDialog() {
    // Implementar diálogo de filtrado
  }

  Future<void> _generatePurchaseList() async {
    // Implementar generación de PDF
  }

  Widget _buildProductList(CatalogoCategorias categories, CatalogoProductos products) {
    final categoriesWithLowStock = categories.categorias.where((category) {
      return category.subcategorias.any((subcategory) {
        return _getProductsWithLowStock(products, subcategory).isNotEmpty;
      });
    }).toList();

    if (categoriesWithLowStock.isEmpty) {
      return Center(
        child: Text(
          '¡Todo en orden! No hay productos con stock bajo',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: categoriesWithLowStock.length,
      itemBuilder: (context, categoryIndex) {
        final category = categoriesWithLowStock[categoryIndex];
        return _buildCategoryCard(category, products);
      },
    );
  }

  Widget _buildCategoryCard(Categoria category, CatalogoProductos products) {
    final subcategoriesWithLowStock = category.subcategorias.where((subcategory) {
      return _getProductsWithLowStock(products, subcategory).isNotEmpty;
    }).toList();

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: ExpansionTile(
        title: Text(
          category.nombre,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        children: subcategoriesWithLowStock.map((subcategory) {
          return _buildSubcategoryTile(subcategory, products);
        }).toList(),
      ),
    );
  }

  Widget _buildSubcategoryTile(Subcategoria subcategory, CatalogoProductos products) {
    final lowStockProducts = _getProductsWithLowStock(products, subcategory);
    
    return ExpansionTile(
      title: Text(
        subcategory.nombre,
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      children: lowStockProducts.map((product) {
        return _buildProductTile(product, subcategory.usaTallas);
      }).toList(),
    );
  }

  Widget _buildProductTile(Producto product, bool usesSizes) {
    final groupedItems = _groupLowStockItems(product, usesSizes);
  
    return ExpansionTile(
      title: Text(product.nombre),
      subtitle: Text('${_countTotalLowStockItems(groupedItems)} variantes con stock bajo'),
      children: groupedItems.entries.map((variantEntry) {
        // Expansión por variante
        return ExpansionTile(
          title: Text(variantEntry.key),
          children: variantEntry.value.entries.expand((qualityEntry) {
            // Widgets para cada calidad (no expandible)
            return [
              // Divider/Header de calidad
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  qualityEntry.key,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                  ),
                ),
              ),
              // Items de esta calidad
              ...qualityEntry.value.map((item) => _buildLowStockItemTile(item, usesSizes)),
              // Separador entre calidades (excepto después de la última)
              if (qualityEntry.key != variantEntry.value.keys.last)
                const Divider(height: 1, thickness: 1),
            ];
          }).toList(),
        );
      }).toList(),
    );
  }

  Widget _buildLowStockItemTile(LowStockItem item, bool usesSizes) {
    return ListTile(
      title: Text('${item.colorName}'),
      subtitle: usesSizes && item.sizeName != null
          ? Text('Talla: ${item.sizeName} | Stock: ${item.currentStock}')
          : Text('Stock: ${item.currentStock}'),
      trailing: Chip(
        label: Text('Comprar: ${item.suggestedPurchase}'),
        backgroundColor: Colors.red.withOpacity(0.2),
      ),
      leading: usesSizes && item.sizeName != null
          ? Icon(Icons.straighten, color: Colors.red)
          : Icon(Icons.color_lens, color: Colors.red),
    );
  }

  List<Producto> _getProductsWithLowStock(CatalogoProductos products, Subcategoria subcategory) {
    return products.productos.where((product) {
      return product.subcategoria == subcategory.id &&
          product.variantes!.any((variant) {
            return variant.calidades.any((quality) {
              return quality.colores.any((color) {
                if (subcategory.usaTallas) {
                  return color.tallas?.any((size) => size.stock < 2) ?? false;
                } else {
                  return color.stock != null && color.stock! < 2;
                }
              });
            });
          });
    }).toList();
  }

  List<LowStockItem> _getLowStockItems(Producto product, bool usesSizes) {
    final List<LowStockItem> items = [];
    
    for (final Variante variant in product.variantes ?? []) {
      for (final Calidad quality in variant.calidades) {
        for (final Color color in quality.colores) {
          if (usesSizes) {
            for (final Talla size in color.tallas ?? []) {
              if (size.stock < 2) {
                items.add(LowStockItem(
                  variantName: variant.variante,
                  qualityName: quality.calidad,
                  colorName: color.color,
                  sizeName: size.talla ?? size.codigo,
                  currentStock: size.stock,
                  suggestedPurchase: 2 - size.stock,
                ));
              }
            }
          } else if (color.stock != null && color.stock! < 2) {
            items.add(LowStockItem(
              variantName: variant.variante,
              qualityName: quality.calidad,
              colorName: color.color,
              currentStock: color.stock!,
              suggestedPurchase: 2 - color.stock!,
            ));
          }
        }
      }
    }
    
    return items;
  }

  int _countTotalLowStockItems(Map<String, Map<String, List<LowStockItem>>> groupedItems) {
    return groupedItems.values.fold(0, (total, qualities) {
      return total + qualities.values.fold(0, (sum, items) => sum + items.length);
    });
  }

  Map<String, Map<String, List<LowStockItem>>> _groupLowStockItems(Producto product, bool usesSizes) {
    final items = _getLowStockItems(product, usesSizes);
    final Map<String, Map<String, List<LowStockItem>>> groupedItems = {};

    for (final item in items) {
      if (!groupedItems.containsKey(item.variantName)) {
        groupedItems[item.variantName ?? 'Sin variante definida'] = {};
      }
      
      final String variantName = item.variantName ?? 'Sin variante definida';
      if (!groupedItems[variantName]!.containsKey(item.qualityName)) {
        groupedItems[variantName]![item.qualityName ?? 'Sin calidad definida'] = [];
      }
      
      final String qualityName = item.qualityName ?? 'Sin calidad definida';
      groupedItems[variantName]![qualityName]!.add(item);
    }

    return groupedItems;
  }

  // Función para construir los ítems individuales (puedes personalizarla)
 /* Widget _buildLowStockItemTile(LowStockItem item, bool usesSizes) {
    return ListTile(
      title: Text(usesSizes ? '${item.colorName} - Talla ${item.sizeName}' : item.colorName),
      subtitle: Text('Stock: ${item.currentStock}'),
      trailing: Text('Sugerido: ${item.suggestedPurchase}'),
    );
  }*/
}

class LowStockItem {
  final String? variantName;
  final String? qualityName;
  final String colorName;
  final String? sizeName;
  final int currentStock;
  final int suggestedPurchase;

  LowStockItem({
    this.variantName,
    this.qualityName,
    required this.colorName,
    this.sizeName,
    required this.currentStock,
    required this.suggestedPurchase,
  });
}

/*class ProductosFaltosStockScreen extends StatelessWidget {
  final CatalogoCategorias catalogoCategorias;
  final CatalogoProductos catalogoProductos;

  ProductosFaltosStockScreen(this.catalogoCategorias, this.catalogoProductos);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final MissingProductsController missingProductsController = MissingProductsController(catalogoCategorias: catalogoCategorias, catalogoProductos: catalogoProductos);
    return SafeArea(
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * .95,
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
          
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(top: 10),
                  child: ExpansionTile(
                    shape: RoundedRectangleBorder(side: BorderSide.none, borderRadius: BorderRadius.circular(20)),
                    title: Text(categoria.nombre),
                    children: subcategoriasConProductos.map((subcategoria) {
                      final productosFiltrados = missingProductsController.obtenerProductosFaltosStockPorSubcategoria(subcategoria);
                        
                      return SizedBox(
                        width: MediaQuery.of(context).size.width *.90,
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(side: BorderSide(color: colors.primary), borderRadius: BorderRadius.circular(20)),
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ExpansionTile(
                            shape: RoundedRectangleBorder(side: BorderSide.none, borderRadius: BorderRadius.circular(20)),
                            title: Text(subcategoria.nombre),
                            children: productosFiltrados.map((producto) {
                              return ProductoExpansionTile(
                                producto: producto,
                                usaTallas: subcategoria.usaTallas,
                                colors: colors
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }),
        ),
      ),
    );
  }
}

class ProductoExpansionTile extends StatelessWidget {
  final Producto producto;
  final bool usaTallas;
  final ColorScheme colors;

  ProductoExpansionTile({required this.producto, required this.usaTallas, required this.colors});

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

    return Card(
      color: Colors.white,
      child: ExpansionTile(
        backgroundColor: colors.primary.withAlpha(10),
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
      ),
    );
  }
}*/