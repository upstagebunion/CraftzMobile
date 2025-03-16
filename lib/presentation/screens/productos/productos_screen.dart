import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/catalogo_productos_repositorie.dart';
import '../../../providers/product_notifier.dart';
import '../../../controllers/products_controller.dart';
import './modal_agregar_productos.dart';

class ProductsPage extends ConsumerStatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  late ModalAgregarProductos modalAgregarProductos;
  String selectedCategory = 'All';
  String selectedSubCategory = 'All';
  Map<String, String> categories = {'All': '0', 'Ropa' : '679f20466e47b57563c44f94', 'Tazas': '679f20ad6e47b57563c44f97', 'Accesorios': '679f20be6e47b57563c44f9a'};
  List<String> subCategories = ['All', 'SubCategory 1', 'SubCategory 2'];

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    modalAgregarProductos = ModalAgregarProductos(ref, categories);
    // Llamamos al provider para cargar productos cuando se inicializa
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productosProvider.notifier).cargarProductos();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el estado de carga
    final isLoading = ref.watch(isLoadingProvider);
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
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: _isExpanded ? Colors.transparent : Colors.grey,
                        width: 0.5,
                      ), // Solo un borde en la parte inferior
                    ),
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
                        return ExpansionTile(
                          title: Text(variante.tipo ?? 'Accesorio'),
                          children: [
                            ...variante.colores.map((color) {
                              return ExpansionTile(
                                title: Text(color.color),
                                children: [
                                  if (color.tallas != null && producto.categoria == categories['Ropa']) ...color.tallas!.map((talla) {
                                    return ListTile(
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
                                    );
                                  }).toList(),
                                  if (producto.categoria != categories['Ropa']) ListTile(
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
                                  if (producto.categoria == categories['Ropa'])
                                    TextButton(
                                      onPressed: () {
                                        modalAgregarProductos.mostrarFormularioAgregarTalla(context, producto, variante, color);
                                      },
                                      child: Text('Agregar Talla'),
                                    ),
                                ],
                              );
                            }).toList(),
                            TextButton(
                              onPressed: () {
                                modalAgregarProductos.mostrarFormularioAgregarColor(context, producto, variante);
                              },
                              child: Text('Agregar Color'),
                            ),
                          ],
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
                );
              },
            ),
      floatingActionButton: IconButton(
        onPressed: () async {
          ProductsController productsController = ProductsController(ref);
          await productsController.guardarCambios(context);
        },
        icon: isSaving ? CircularProgressIndicator() : Icon(Icons.save),
      ),
    );
  }
}
