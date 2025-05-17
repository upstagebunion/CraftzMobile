import 'package:craftz_app/data/repositories/cotizacion_repositories.dart';
import 'package:craftz_app/providers/cotizaciones_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:craftz_app/presentation/screens/cotizacion/cotizacion_screen.dart';

class ListaCotizacionesScreen extends ConsumerWidget {
  const ListaCotizacionesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cotizaciones = ref.watch(cotizacionesProvider).cotizaciones;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Cotizaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(cotizacionesProvider.notifier).cargarCotizaciones(),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _nuevaCotizacion(context, ref),
          ),
        ],
      ),
      body: cotizaciones.isEmpty
          ? const Center(child: Text('No hay cotizaciones'))
          : RefreshIndicator(
              onRefresh: () => ref.read(cotizacionesProvider.notifier).cargarCotizaciones(),
              child: ListView.builder(
                itemCount: cotizaciones.length,
                itemBuilder: (context, index) {
                  final cotizacion = cotizaciones[index];
                  return _CotizacionItem(
                    cotizacion: cotizacion,
                    onTap: () => _verCotizacion(context, ref, cotizacion),
                    onEdit: () => _editarCotizacion(context, ref, cotizacion),
                    onDelete: () => _eliminarCotizacion(ref, cotizacion.id!),
                  );
                },
              ),
            ),
    );
  }
  
  void _verCotizacion(BuildContext context, WidgetRef ref, Cotizacion cotizacion) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CotizacionScreen(
          cotizacionId: cotizacion.id,
          nuevaCotizacion: false,
        ),
      ),
    );
  }
  
  Widget? _editarCotizacion(BuildContext context, WidgetRef ref, Cotizacion cotizacion) {
    return null;
  }
  
  Widget? _eliminarCotizacion(WidgetRef ref, String s) {
    return null;
  }
  
  void _nuevaCotizacion(BuildContext context, WidgetRef ref) {
    final Cotizacion cotizacionTemporal = Cotizacion.empty();
    ref.read(cotizacionesProvider.notifier).agregarCotizacion(cotizacionTemporal);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CotizacionScreen(
          cotizacionId: cotizacionTemporal.id,
          nuevaCotizacion: true,
        ),
      ),
    );
  }

  

  // ... Métodos _nuevaCotizacion, _editarCotizacion, _eliminarCotizacion, _verCotizacion ...
}

class _CotizacionItem extends StatelessWidget {
  final Cotizacion cotizacion;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CotizacionItem({
    required this.cotizacion,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cotización #${cotizacion.id}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: onEdit,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Cliente: ${cotizacion.clienteNombre ?? 'Sin cliente'}'),
              Text('Productos: ${cotizacion.productos.length}'),
              Text('Total: \$${cotizacion.total.toStringAsFixed(2)}'),
              Text('Fecha: ${cotizacion.fechaCreacion}'),
              if (cotizacion.expira.isAfter(DateTime.now()))
                Text(
                  'Válida hasta: ${cotizacion.expira}',
                  style: const TextStyle(color: Colors.green),
                )
              else
                Text(
                  'Expirada',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        ),
      ),
    );
  }
}