import 'package:craftz_app/data/repositories/categorias_repositorie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/catalogo_productos_repositorie.dart';
import '../../../providers/product_notifier.dart';

class ModalAgregarProductos {
  final WidgetRef ref;
  final CatalogoCategorias categories;

  ModalAgregarProductos(this.ref, this.categories);

  // Método para mostrar el formulario de agregar variante
  void mostrarFormularioVariante(BuildContext context, Producto producto, {bool isEditing = false, Variante? variante}) {
    final TextEditingController tipoController = TextEditingController(text: isEditing && variante?.tipo != null ? variante!.tipo.toString() : '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: tipoController,
                  decoration: InputDecoration(labelText: 'Tipo de Variante'),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final nuevoTipo = tipoController.text.trim();
                  if (nuevoTipo.isNotEmpty) {
                    try {
                      isEditing 
                      ? ref.read(productosProvider.notifier).editarVariante(
                        producto.id,
                        variante!.id,
                        nuevoTipo,
                      )
                      : await ref.read(productosProvider.notifier).agregarVariante(producto.id, nuevoTipo);
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                child: Text('Guardar Variante'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Método para mostrar el formulario de agregar color
  void mostrarFormularioColor(BuildContext context, Producto producto, Variante variante, Subcategoria subcategoria, {bool isEditing = false, Color? color}) {
    final TextEditingController colorController = TextEditingController(text: isEditing ? color?.color : '');
    final TextEditingController stockController = TextEditingController(text: isEditing && color?.stock != null ? color!.stock.toString() : '');
    final TextEditingController costoController = TextEditingController(text: isEditing && color?.costo != null ? color!.costo.toString() : '');
    final bool usaTallas = subcategoria.usaTallas;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: colorController,
                    decoration: InputDecoration(labelText: 'Nombre del Color'),
                  ),
                ),
                if (!usaTallas)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: stockController,
                      decoration: InputDecoration(labelText: 'Stock'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                if (!usaTallas)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: costoController,
                      decoration: InputDecoration(labelText: 'Costo'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ElevatedButton(
                  onPressed: () async {
                    final nuevoColor = colorController.text.trim();
                    if (nuevoColor.isNotEmpty) {
                      try {
                        isEditing 
                        ? await ref.read(productosProvider.notifier).editarColor(
                          producto.id,
                          variante.id,
                          color!.id,
                          nuevoColor,
                          !usaTallas ? int.parse(stockController.text) : null,
                          !usaTallas ? double.parse(costoController.text) : null
                        )
                        : await ref.read(productosProvider.notifier).agregarColor(
                          producto.id,
                          variante.id,
                          nuevoColor,
                          !usaTallas ? int.parse(stockController.text) : null,
                          !usaTallas ? double.parse(costoController.text) : null,
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                  child: Text('Guardar Color'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Método para mostrar el formulario de agregar talla
  void mostrarFormularioTalla(BuildContext context, Producto producto, Variante variante, Color color, {bool isEditing = false, Talla? talla}) {
    final TextEditingController tallaController = TextEditingController(text: isEditing ? talla?.talla : '');
    final TextEditingController stockController = TextEditingController(text: isEditing && talla?.stock != null ? talla!.stock.toString() : '');
    final TextEditingController costoController = TextEditingController(text: isEditing && talla?.costo != null ? talla!.costo.toString() : '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: tallaController,
                    decoration: InputDecoration(labelText: 'Talla'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: stockController,
                    decoration: InputDecoration(labelText: 'Stock'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: costoController,
                    decoration: InputDecoration(labelText: 'Costo'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final nuevaTalla = tallaController.text.trim();
                    if (nuevaTalla.isNotEmpty) {
                      try {
                        isEditing 
                        ? await ref.read(productosProvider.notifier).editarTalla(
                          producto.id,
                          variante.id,
                          color.id,
                          talla!.id,
                          nuevaTalla, 
                          int.parse(stockController.text),
                          double.parse(costoController.text)
                          )
                        : await ref.read(productosProvider.notifier).agregarTalla(
                          producto.id,
                          variante.id,
                          color.id,
                          nuevaTalla,
                          int.parse(stockController.text),
                          double.parse(costoController.text),
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                  child: Text('Guardar Talla'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}