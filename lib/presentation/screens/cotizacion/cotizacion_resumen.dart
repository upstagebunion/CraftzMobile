import 'package:craftz_app/data/repositories/cotizacion_repositories.dart';
import 'package:craftz_app/providers/cotizaciones_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResumenCotizacion extends ConsumerWidget {
  final String cotizacionId;
  final contextPrincipal;

  ResumenCotizacion({
    required this.cotizacionId,
    required this.contextPrincipal,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    late final cotizacion;
    cotizacion = ref.watch(
      cotizacionesProvider.select(
        (state) => state.cotizaciones.firstWhere(
          (c) => c.id == cotizacionId,
          orElse: null
        ),
      ),
    );

    final subTotal = cotizacion.subTotal;
    final total = cotizacion.total;

    return cotizacion == null 
    ? const SizedBox.shrink()
    : Container(
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
                  onPressed: cotizacion.cliente == '' ? null : () => _guardarCotizacion(ref, context, cotizacionId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    disabledBackgroundColor: Colors.grey[400],
                    padding: EdgeInsets.symmetric(horizontal: 20.0)
                  ),
                  child: const Text('Guardar Cotización', style: TextStyle(fontWeight: FontWeight.w600)),
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
                  cotizacion.id,
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

    final bool esLocal = cotizacionId.contains('temp');
    
    try {
      Navigator.pop(context);
      esLocal
      ? await ref.read(cotizacionesProvider.notifier).agregarCotizacion(cotizacion)
      : await ref.read(cotizacionesProvider.notifier).actualizarCotizacion(cotizacion);
      
      if (contextPrincipal.mounted) {
        ScaffoldMessenger.of(contextPrincipal).showSnackBar(
          SnackBar(
            content: esLocal
            ? Text('Cotización guardada exitosamente')
            : Text('Cotización Actualizada exitosamente')
          ),
        );
      }
    } catch (e) {
      if (contextPrincipal.mounted) {
        ScaffoldMessenger.of(contextPrincipal).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }
}