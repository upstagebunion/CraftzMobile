import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../data/repositories/cotizacion_repositories.dart';

import 'package:craftz_app/providers/product_notifier.dart';
import 'package:craftz_app/providers/extras_provider.dart';
import 'package:craftz_app/core/utils/calculadorCosto.dart';

class ProductoTile extends ConsumerStatefulWidget {
  final ProductoCotizado producto;
  final VoidCallback onRemove;
  final Function(ProductoCotizado) onUpdate;

  const ProductoTile({
    required this.producto,
    required this.onRemove,
    required this.onUpdate,
  });

  @override
  __ProductoTileState createState() => __ProductoTileState();
}

class __ProductoTileState extends ConsumerState<ProductoTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Slidable(
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) async {
                    _mostrarDialogoDescuento();
                  },
                  backgroundColor: Colors.blue,
                  icon: Icons.discount,
                  label: 'Agregar Descuento',
                ),
                SlidableAction(
                  onPressed: (context) async {
                    //TODO: Eliminar producto
                  },
                  backgroundColor: Colors.red,
                  icon: Icons.delete,
                  label: 'Eliminar',
                ),
              ]
            ),
            child: ListTile(
              title: Text(widget.producto.producto.nombre),
              subtitle: Text(
                '${widget.producto.cantidad} x \$${widget.producto.precioFinal / widget.producto.cantidad} = \$${widget.producto.precioFinal}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_shopping_cart),
                    onPressed: () => _mostrarDialogoExtras(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (widget.producto.cantidad > 1) {
                        final nuevaCantidad = widget.producto.cantidad - 1;
                        final nuevoPrecioFinal = (widget.producto.precio * nuevaCantidad);

                        widget.onUpdate(widget.producto.copyWith(
                          cantidad: nuevaCantidad,
                          precioFinal: nuevoPrecioFinal,
                        ));
                      }
                    },
                  ),
                  Text('${widget.producto.cantidad}'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      final nuevaCantidad = widget.producto.cantidad + 1;
                      final nuevoPrecioFinal = (widget.producto.precio * nuevaCantidad);
                      widget.onUpdate(widget.producto.copyWith(
                        cantidad: nuevaCantidad,
                        precioFinal: nuevoPrecioFinal,
                      ));
                    },
                  ),
                ],
              ),
              onTap: () => setState(() => _expanded = !_expanded),
            ),
          ),
          if (_expanded) _buildDetallesExpandidos(),
        ],
      ),
    );
  }

  Widget _buildDetallesExpandidos() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.producto.variante != null)
            Text('Variante: ${widget.producto.variante!.tipo}'),
          if (widget.producto.color != null)
            Text('Color: ${widget.producto.color!.nombre}'),
          if (widget.producto.talla != null)
            Text('Talla: ${widget.producto.talla!.nombre}'),
          if (widget.producto.extras.isNotEmpty) ...[
            const Text('Extras:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...widget.producto.extras.map((extra) => 
              Text('- ${extra.nombre}: \$${extra.monto} (${extra.unidad})'),
            ),
          ],
          if (widget.producto.descuento != null)
            Text('Descuento: ${_formatearDescuento(widget.producto.descuento!)}'),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.onRemove,
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoExtras() async {
  final CalculadorCostos calculador = CalculadorCostos(ref);
  final productoOriginal = ref.read(productosProvider.notifier) //TODO Agregar el ref de producto y de variante
    .obtenerProductoPorId(widget.producto.productoRef);
  
  // Obtener extras disponibles para esta subcategoría
  final extrasDisponibles = await ref.watch(extrasProvider).extras;

  final extrasActualizados = await showDialog<List<Extra>>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return DialogoExtras(
            producto: widget.producto,
            extrasDisponibles: extrasDisponibles,
            calculador: calculador,
            subcategoriaId: productoOriginal!.subcategoria,
            onExtrasUpdated: (nuevosExtras, nuevoPrecio) {
              widget.onUpdate(widget.producto.copyWith(
                extras: nuevosExtras,
                precio: nuevoPrecio,
              ));
              // Forzar reconstrucción del diálogo
              setStateDialog(() {});
            },
          );
        },
      );
    },
  );

  // Si se actualizaron extras, forzar reconstrucción del padre
  if (extrasActualizados != null) {
    setState(() {});
  }
}

  void _mostrarDialogoDescuento() {
    String razon = widget.producto.descuento?.razon ?? '';
    String tipo = widget.producto.descuento?.tipo ?? 'porcentaje';
    double valor = widget.producto.descuento?.valor ?? 0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Aplicar descuento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Razón del descuento'),
                onChanged: (value) => razon = value,
              ),
              DropdownButtonFormField<String>(
                value: tipo,
                items: const [
                  DropdownMenuItem(value: 'porcentaje', child: Text('Porcentaje')),
                  DropdownMenuItem(value: 'cantidad', child: Text('Cantidad fija')),
                ],
                onChanged: (value) => tipo = value!,
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: tipo == 'porcentaje' ? 'Porcentaje (%)' : 'Cantidad (\$)',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => valor = double.tryParse(value) ?? 0,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final descuento = Descuento(
                  razon: razon,
                  tipo: tipo,
                  valor: valor,
                );
                
                // Calcular nuevo precio con descuento
                double nuevoPrecio = _aplicarDescuento(
                  widget.producto.precioFinal,
                  descuento,
                );
                
                widget.onUpdate(widget.producto.copyWith(
                  descuento: descuento,
                  precioFinal: nuevoPrecio,
                ));
                
                Navigator.pop(context);
              },
              child: const Text('Aplicar'),
            ),
          ],
        );
      },
    );
  }

  double _aplicarDescuento(double precioActual, Descuento descuento) {
    if (descuento.tipo == 'porcentaje') {
      return precioActual * (1 - descuento.valor / 100);
    } else {
      return precioActual - descuento.valor;
    }
  }

  String _formatearDescuento(Descuento descuento) {
    if (descuento.tipo == 'porcentaje') {
      return '${descuento.valor}% - ${descuento.razon}';
    } else {
      return '\$${descuento.valor} - ${descuento.razon}';
    }
  }
}

class DialogoExtras extends StatefulWidget {
  final ProductoCotizado producto;
  final List<Extra> extrasDisponibles;
  final CalculadorCostos calculador;
  final String subcategoriaId;
  final Function(List<Extra>, double) onExtrasUpdated;

  const DialogoExtras({
    required this.producto,
    required this.extrasDisponibles,
    required this.calculador,
    required this.subcategoriaId,
    required this.onExtrasUpdated,
  });

  @override
  _DialogoExtrasState createState() => _DialogoExtrasState();
}

class _DialogoExtrasState extends State<DialogoExtras> {
  late List<Extra> _extrasActuales;

  @override
  void initState() {
    super.initState();
    _extrasActuales = List.from(widget.producto.extras);
  }

  Future<void> _agregarExtra(Extra extra) async {
    final nuevosExtras = List.of(_extrasActuales)..add(extra);
    final precioNeto = await widget.calculador.calcularPrecioFinal(
      subcategoriaId: widget.subcategoriaId,
      extras: nuevosExtras,
      precioBase: widget.producto.precio,
    );
    
    setState(() {
      _extrasActuales = nuevosExtras;
    });
    
    widget.onExtrasUpdated(nuevosExtras, precioNeto);
  }

  Future<void> _eliminarExtra(Extra extra) async {
    final nuevosExtras = List.of(_extrasActuales)..remove(extra);
    final precioNeto = await widget.calculador.calcularPrecioFinal(
      subcategoriaId: widget.subcategoriaId,
      extras: nuevosExtras,
      precioBase: widget.producto.precio,
    );
    
    setState(() {
      _extrasActuales = nuevosExtras;
    });
    
    widget.onExtrasUpdated(nuevosExtras, precioNeto);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Extras'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Extras actuales del producto
            if (_extrasActuales.isNotEmpty) ...[
              const Text('Extras actuales:', 
                style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: _extrasActuales.map((extra) {
                  return Chip(
                    label: Text('${extra.nombre} (\$${extra.monto})'),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => _eliminarExtra(extra),
                  );
                }).toList(),
              ),
              const Divider(),
            ],
            
            // Lista de extras disponibles
            const Text('Agregar extras:', 
              style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: widget.extrasDisponibles.length,
                itemBuilder: (context, index) {
                  final extra = widget.extrasDisponibles[index];
                  return ListTile(
                    title: Text(extra.nombre),
                    subtitle: Text(
                      extra.unidad == UnidadExtra.pieza
                        ? '\$${extra.monto} (por pieza)'
                        : '${extra.anchoCm}cm x ${extra.largoCm}cm',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _agregarExtra(extra),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, _extrasActuales),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}