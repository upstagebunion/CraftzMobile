import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/catalogo_productos_repositorie.dart';
import '../../../providers/product_notifier.dart';

class ModalAgregarProductos {
  final WidgetRef ref;
  final Map<String, String>categories;

  ModalAgregarProductos(this.ref, this.categories);

  // Método para mostrar el formulario de agregar variante
  void mostrarFormularioAgregarVariante(BuildContext context, Producto producto) {
    final TextEditingController tipoController = TextEditingController();

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
                      await ref.read(productosProvider.notifier).agregarVariante(producto.id, nuevoTipo);
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
  void mostrarFormularioAgregarColor(BuildContext context, Producto producto, Variante variante) {
    final TextEditingController colorController = TextEditingController();
    final TextEditingController stockController = TextEditingController();
    final TextEditingController precioController = TextEditingController();

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
                  controller: colorController,
                  decoration: InputDecoration(labelText: 'Nombre del Color'),
                ),
              ),
              if (producto.categoria != categories['Ropa'])
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: stockController,
                    decoration: InputDecoration(labelText: 'Stock'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              if (producto.categoria != categories['Ropa'])
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: precioController,
                    decoration: InputDecoration(labelText: 'Precio'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ElevatedButton(
                onPressed: () async {
                  final nuevoColor = colorController.text.trim();
                  if (nuevoColor.isNotEmpty) {
                    try {
                      await ref.read(productosProvider.notifier).agregarColor(
                        producto.id,
                        variante.id,
                        nuevoColor,
                        producto.categoria != categories['Ropa'] ? int.parse(stockController.text) : null,
                        producto.categoria != categories['Ropa'] ? double.parse(precioController.text) : null,
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
        );
      },
    );
  }

  // Método para mostrar el formulario de agregar talla
  void mostrarFormularioAgregarTalla(BuildContext context, Producto producto, Variante variante, Color color) {
    final TextEditingController tallaController = TextEditingController();
    final TextEditingController stockController = TextEditingController();
    final TextEditingController precioController = TextEditingController();

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
                  controller: precioController,
                  decoration: InputDecoration(labelText: 'Precio'),
                  keyboardType: TextInputType.number,
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final nuevaTalla = tallaController.text.trim();
                  if (nuevaTalla.isNotEmpty) {
                    try {
                      await ref.read(productosProvider.notifier).agregarTalla(
                        producto.id,
                        variante.id,
                        color.id,
                        nuevaTalla,
                        int.parse(stockController.text),
                        double.parse(precioController.text),
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
        );
      },
    );
  }
}