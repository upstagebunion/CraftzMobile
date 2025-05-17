import 'package:craftz_app/data/repositories/cotizacion_repositories.dart';
import 'package:craftz_app/providers/cotizaciones_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResumenCotizacion extends ConsumerWidget {
  final String cotizacionId;

  ResumenCotizacion({
    required this.cotizacionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cotizacion = ref.watch(
      cotizacionesProvider.select(
        (state) => state.cotizaciones.firstWhere(
          (c) => c.id == cotizacionId
        ),
      ),
    );
    final subTotal = cotizacion.subTotal;
    final total = cotizacion.total;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal:'),
              Text('\$$subTotal'),
            ],
          ),
          if (cotizacion.descuentoGlobal != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Descuento global (${cotizacion.descuentoGlobal!.razon}):'),
                Text(
                  cotizacion.descuentoGlobal!.tipo == 'porcentaje'
                      ? '-${cotizacion.descuentoGlobal!.valor}%'
                      : '-\$${cotizacion.descuentoGlobal!.valor}',
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('\$$total', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _mostrarDialogoDescuentoGlobal(context, ref, cotizacionId),
                  child: const Text('Descuento Global'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _guardarCotizacion(ref, context, cotizacionId),
                  child: const Text('Guardar Cotización'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoDescuentoGlobal(BuildContext context, WidgetRef ref, String cotizacionId) {
    final cotizacion = ref.watch(
      cotizacionesProvider.select(
        (state) => state.cotizaciones.firstWhere(
          (c) => c.id == cotizacionId
        ),
      ),
    );
    String razon = cotizacion.descuentoGlobal?.razon ?? '';
    String tipo = cotizacion.descuentoGlobal?.tipo ?? 'porcentaje';
    double valor = cotizacion.descuentoGlobal?.valor ?? 0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Descuento Global'),
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
                final newDescuento = Descuento(razon: razon, tipo: tipo, valor: valor);
                ref.read(cotizacionesProvider.notifier).aplicarDescuentoGlobalACotizacion(
                  cotizacion.id!,
                  newDescuento
                );
                Navigator.pop(context);
              },
              child: const Text('Aplicar'),
            ),
          ],
        );
      },
    );
  }

  void _guardarCotizacion(WidgetRef ref, BuildContext context, String cotizacionId) async {
      final cotizacion = ref.read(
        cotizacionesProvider).cotizaciones.firstWhere(
          (c) => c.id == cotizacionId,
        );
    if (cotizacion.productos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega al menos un producto')),
      );
      return;
    }
    
    try {
      //await ref.read(cotizacionesProvider.notifier).actualizarCotizacion();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cotización guardada exitosamente')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }
}