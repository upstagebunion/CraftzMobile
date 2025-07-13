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
    final TextEditingController nombreVarianteController = TextEditingController(text: isEditing && variante?.variante != null ? variante!.variante.toString() : '');
    final TextEditingController ordenController = TextEditingController(
        text: isEditing ? variante?.orden.toString() : '0');

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
                  controller: nombreVarianteController,
                  decoration: InputDecoration(
                    labelText: 'Nombre de Variante',
                    hintText: 'Dejar vacío para variante única'
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: ordenController,
                  decoration: InputDecoration(
                    labelText: 'Orden',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final nombre = nombreVarianteController.text.trim();
                  final orden = int.tryParse(ordenController.text) ?? 0;
                    try {
                      isEditing 
                      ? await ref.read(productosProvider.notifier).editarVariante(
                        producto.id,
                        variante!.id,
                        nombre.isEmpty ? null : nombre,
                        orden
                      )
                      : await ref.read(productosProvider.notifier).agregarVariante(producto.id, nombre.isEmpty ? null : nombre, orden);
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                },
                child: Text(isEditing ? 'Actualizar Variante' : 'Agregar Variante'),
              ),
            ],
          ),
        );
      },
    );
  }
  
  void mostrarFormularioCalidad(BuildContext context, Producto producto, Variante variante,
      {bool isEditing = false, Calidad? calidad}) {
    final TextEditingController nombreController = TextEditingController(
        text: isEditing ? calidad?.calidad : '');
    final TextEditingController ordenController = TextEditingController(
        text: isEditing ? calidad?.orden.toString() : '0');

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
                  controller: nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre de Calidad',
                    hintText: 'Dejar vacío para calidad única'
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: ordenController,
                  decoration: InputDecoration(
                    labelText: 'Orden',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final nombre = nombreController.text.trim();
                  final orden = int.tryParse(ordenController.text) ?? 0;
                  try {
                    isEditing
                      ? await ref.read(productosProvider.notifier).editarCalidad(
                          producto.id,
                          variante.id,
                          calidad!.id,
                          nombre.isEmpty ? null : nombre,
                          orden,
                        )
                      : await ref.read(productosProvider.notifier).agregarCalidad(
                          producto.id,
                          variante.id,
                          nombre.isEmpty ? null : nombre,
                          orden,
                        );
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                child: Text(isEditing ? 'Actualizar Calidad' : 'Agregar Calidad'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Método para mostrar el formulario de agregar color
  void mostrarFormularioColor(BuildContext context, Producto producto, Variante variante, Calidad calidad, Subcategoria subcategoria, {bool isEditing = false, Color? color}) {
    final TextEditingController nombreColorController = TextEditingController(
        text: isEditing ? color?.color : '');
    final TextEditingController hexController = TextEditingController(
        text: isEditing ? color?.codigoHex : '#FFFFFF');
    final TextEditingController stockController = TextEditingController(
        text: isEditing && color?.stock != null ? color!.stock.toString() : '0');
    final TextEditingController costoController = TextEditingController(
        text: isEditing && color?.costo != null ? color!.costo.toString() : '0.0');
    final TextEditingController ordenController = TextEditingController(
        text: isEditing ? color?.orden.toString() : '0');
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
                    controller: nombreColorController,
                    decoration: InputDecoration(labelText: 'Nombre del Color'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: hexController,
                    decoration: InputDecoration(labelText: 'Código HEX'),
                  ),
                ),
                if (!usaTallas)...[
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
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: ordenController,
                    decoration: InputDecoration(labelText: 'Orden'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final nombre = nombreColorController.text.trim();
                    final hex = hexController.text.trim();
                    final orden = int.tryParse(ordenController.text) ?? 0;

                    if (nombre.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('El nombre del color es requerido')),
                      );
                      return;
                    }

                    try {
                      isEditing 
                      ? await ref.read(productosProvider.notifier).editarColor(
                        producto.id,
                        variante.id,
                        calidad.id,
                        color!.id,
                        nombre,
                        hex,
                        subcategoria.usaTallas ? null : int.parse(stockController.text),
                        subcategoria.usaTallas ? null : double.parse(costoController.text),
                        orden,
                      )
                      : await ref.read(productosProvider.notifier).agregarColor(
                        producto.id,
                        variante.id,
                        calidad.id,
                        nombre,
                        hex,
                        subcategoria.usaTallas ? null : int.parse(stockController.text),
                        subcategoria.usaTallas ? null : double.parse(costoController.text),
                        orden,
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                  child: Text(isEditing ? 'Actualizar Color' : 'Agregar Color'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Método para mostrar el formulario de agregar talla
  void mostrarFormularioTalla(BuildContext context, Producto producto, Variante variante, Calidad calidad, Color color, {bool isEditing = false, Talla? talla}) {
    final TextEditingController skuController = TextEditingController(
        text: isEditing ? talla?.talla : '');
    final TextEditingController codigoController = TextEditingController(
        text: isEditing ? talla?.codigo : '');
    final TextEditingController nombreController = TextEditingController(
        text: isEditing ? talla?.talla : '');
    final TextEditingController stockController = TextEditingController(
        text: isEditing ? talla?.stock.toString() : '0');
    final TextEditingController costoController = TextEditingController(
        text: isEditing ? talla?.costo.toString() : '0.0');
    final TextEditingController ordenController = TextEditingController(
        text: isEditing ? talla?.orden.toString() : '0');

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
                    controller: skuController,
                    decoration: InputDecoration(labelText: 'SKU'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: codigoController,
                    decoration: InputDecoration(labelText: 'Código (ej. "CH", "M")'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: nombreController,
                    decoration: InputDecoration(labelText: 'Nombre (ej. "Chica", "Mediana")'),
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
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: ordenController,
                    decoration: InputDecoration(labelText: 'Orden'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final codigo = codigoController.text.trim();

                    if (codigo.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('El código es requerido')),
                      );
                      return;
                    }
                    
                    try {
                      isEditing 
                      ? await ref.read(productosProvider.notifier).editarTalla(
                          producto.id,
                          variante.id,
                          calidad.id,
                          color.id,
                          talla!.id,
                          codigo,
                          nombreController.text.trim(),
                          int.parse(stockController.text),
                          double.parse(costoController.text),
                          int.parse(ordenController.text),
                          skuController.text.trim()
                        )
                      : await ref.read(productosProvider.notifier).agregarTalla(
                          producto.id,
                          variante.id,
                          calidad.id,
                          color.id,
                          codigo,
                          nombreController.text.trim(),
                          int.parse(stockController.text),
                          double.parse(costoController.text),
                          int.parse(ordenController.text),
                          skuController.text.trim()
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                  child: Text(isEditing ? 'Actualizar Talla' : 'Agregar Talla'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}