import 'package:flutter/material.dart';
import '../../../data/repositories/cotizacion_repositories.dart';

class ProductoTile extends StatefulWidget {
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

class __ProductoTileState extends State<ProductoTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(widget.producto.producto.nombre),
            subtitle: Text(
              '${widget.producto.cantidad} x \$${widget.producto.precioFinal / widget.producto.cantidad} = \$${widget.producto.precioFinal}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.discount),
                  onPressed: _mostrarDialogoDescuento,
                ),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    if (widget.producto.cantidad > 1) {
                      widget.onUpdate(widget.producto.copyWith(
                        cantidad: widget.producto.cantidad - 1,
                        precioFinal: (widget.producto.precioFinal - widget.producto.precio),
                      ));
                    }
                  },
                ),
                Text('${widget.producto.cantidad}'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    widget.onUpdate(widget.producto.copyWith(
                      cantidad: widget.producto.cantidad + 1,
                      precioFinal: (widget.producto.precioFinal + widget.producto.precio),
                    ));
                  },
                ),
              ],
            ),
            onTap: () => setState(() => _expanded = !_expanded),
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