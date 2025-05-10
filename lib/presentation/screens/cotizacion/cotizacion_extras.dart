import 'package:craftz_app/data/repositories/catalogo_productos_repositorie.dart';
import 'package:craftz_app/providers/categories_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/cotizacion_repositories.dart';
import '../../../providers/cotizaciones_provider.dart';

class DetallesProductoBottomSheet extends ConsumerStatefulWidget {
  final Producto producto;

  const DetallesProductoBottomSheet({required this.producto});

  @override
  ConsumerState<DetallesProductoBottomSheet> createState() => DetallesProductoBottomSheetState();
}

class DetallesProductoBottomSheetState extends ConsumerState<DetallesProductoBottomSheet> {
  int cantidad = 1;
  Variante? varianteSeleccionada;
  Color? colorSeleccionado;
  Talla? tallaSeleccionada;
  List<Extra> extrasSeleccionados = [];

  @override
  Widget build(BuildContext context) {
    // Obtener la subcategoría usando el método del notifier
    final subcategoria = ref.read(categoriesProvider.notifier).getSubcategoria(widget.producto);
    
    // Si no encontramos la subcategoría, usamos valores por defecto
    final usaTallas = subcategoria?.usaTallas ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: [
          Text(
            widget.producto.nombre,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Selector de variante (si tiene)
          if (widget.producto.variantes?.isNotEmpty ?? false)
            _buildVarianteSelector(),
          
          // Selector de color (si tiene)
          if (varianteSeleccionada != null && varianteSeleccionada!.colores.isNotEmpty)
            _buildColorSelector(),
          
          // Selector de talla (si la subcategoría usa tallas)
          if (usaTallas)
            if (colorSeleccionado?.tallas?.isNotEmpty ?? false)
              _buildTallaSelector(),
          
          // Selector de cantidad
          _buildCantidadSelector(),
          
          // Botón para agregar
          ElevatedButton(
            onPressed: _puedeAgregar(usaTallas) ? () => _agregarProducto(ref) : null,
            child: const Text('Agregar a cotización'),
          ),
        ],
      ),
    );
  }

  bool _puedeAgregar(bool usaTallas) {
    // Validar selecciones según la estructura del producto
    if (widget.producto.variantes?.isNotEmpty ?? false) {
      if (varianteSeleccionada == null) return false;
      if (colorSeleccionado == null) return false;
      if (usaTallas && tallaSeleccionada == null) return false;
    }
    return true;
  }

  void _agregarProducto(WidgetRef ref) {
    // Obtener la subcategoría nuevamente para asegurarnos de tener los datos más recientes
    final subcategoria = ref.read(categoriesProvider.notifier).getSubcategoria(widget.producto);
    final usaTallas = subcategoria?.usaTallas ?? false;

    // Calcular precio base
    double precioBase = 0;
    if (usaTallas && tallaSeleccionada != null) {
      precioBase = tallaSeleccionada!.costo ?? 0;
    } else if (colorSeleccionado != null) {
      precioBase = colorSeleccionado!.costo ?? 0;
    }

    final productoCotizado = ProductoCotizado(
      productoRef: widget.producto.id,
      producto: ProductoCotizadoInfo(
        nombre: widget.producto.nombre,
        descripcion: widget.producto.descripcion,
      ),
      variante: varianteSeleccionada != null
          ? VarianteCotizada(
              id: varianteSeleccionada!.id,
              tipo: varianteSeleccionada!.tipo,
            )
          : null,
      color: colorSeleccionado != null
          ? ColorCotizado(
              id: colorSeleccionado!.id,
              nombre: colorSeleccionado!.color,
            )
          : null,
      talla: tallaSeleccionada != null
          ? TallaCotizada(
              id: tallaSeleccionada!.id,
              nombre: tallaSeleccionada!.talla,
            )
          : null,
      extras: extrasSeleccionados,
      cantidad: cantidad,
      precio: precioBase,
      precioFinal: precioBase * cantidad,
    );

    ref.read(cotizacionProvider.notifier).agregarProducto(productoCotizado);
    Navigator.pop(context);
  }

  Widget _buildVarianteSelector() {
    return DropdownButtonFormField<Variante>(
      decoration: const InputDecoration(labelText: 'Variante'),
      value: varianteSeleccionada,
      items: widget.producto.variantes!.map((variante) {
        return DropdownMenuItem(
          value: variante,
          child: Text(variante.tipo ?? 'Sin tipo'),
        );
      }).toList(),
      onChanged: (variante) {
        setState(() {
          varianteSeleccionada = variante;
          colorSeleccionado = null;
          tallaSeleccionada = null;
        });
      },
    );
  }

  Widget _buildColorSelector() {
    return DropdownButtonFormField<Color>(
      decoration: const InputDecoration(labelText: 'Color'),
      value: colorSeleccionado,
      items: varianteSeleccionada!.colores.map((color) {
        return DropdownMenuItem(
          value: color,
          child: Text(color.color),
        );
      }).toList(),
      onChanged: (color) {
        setState(() {
          colorSeleccionado = color;
          tallaSeleccionada = null;
        });
      },
    );
  }

  Widget _buildTallaSelector() {
    return DropdownButtonFormField<Talla>(
      decoration: const InputDecoration(labelText: 'Talla'),
      value: tallaSeleccionada,
      items: colorSeleccionado!.tallas!.map((talla) {
        return DropdownMenuItem(
          value: talla,
          child: Text(talla.talla ?? 'Sin talla'),
        );
      }).toList(),
      onChanged: (talla) {
        setState(() {
          tallaSeleccionada = talla;
        });
      },
    );
  }

  Widget _buildCantidadSelector() {
    return Row(
      children: [
        const Text('Cantidad:'),
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () {
            if (cantidad > 1) {
              setState(() => cantidad--);
            }
          },
        ),
        Text('$cantidad'),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => setState(() => cantidad++),
        ),
      ],
    );
  }
}