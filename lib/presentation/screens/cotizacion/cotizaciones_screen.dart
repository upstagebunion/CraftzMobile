import 'package:craftz_app/data/repositories/cotizacion_repositories.dart';
import 'package:craftz_app/providers/cotizaciones_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:craftz_app/presentation/screens/cotizacion/cotizacion_screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:craftz_app/presentation/widgets/appbar_widget.dart';

class ListaCotizacionesScreen extends ConsumerStatefulWidget {
  const ListaCotizacionesScreen({super.key});

  @override
  _ListaCotizacionesScreenState createState() => _ListaCotizacionesScreenState();
}

class _ListaCotizacionesScreenState extends ConsumerState<ListaCotizacionesScreen>{

  @override
  void initState() {
    
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cotizacionesProvider.notifier).cargarCotizaciones();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isLoading = ref.watch(isLoadingCotizaciones);
    late final cotizaciones;

    if (!isLoading) {
      cotizaciones = ref.watch(cotizacionesProvider).cotizaciones;
    }
    
    return Scaffold(
      appBar: CustomAppBar(
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
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : cotizaciones.isEmpty
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
                    onDelete: () => _eliminarCotizacion(ref, cotizacion.id),
                    onConvert: () => _convertirAVenta(ref, cotizacion.id)
                  );
                },
              ),
            ),
    );
  }
  
  void _verCotizacion(BuildContext context, WidgetRef ref, Cotizacion cotizacion) {
    final contextPrincipal = context;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CotizacionScreen(
          cotizacionId: cotizacion.id,
          nuevaCotizacion: false,
          contextPrincipal: contextPrincipal
        ),
      ),
    );
  }

  void _convertirAVenta(WidgetRef ref, String id) async {
    try {
      await ref.read(cotizacionesProvider.notifier).convetirCotizacionAVenta(id);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cotización actualizada exitosamente')
          ),
        );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:  Text('Error al actualizar la cotizacion')
        ),
      );
    }
    
  }
  
  void _eliminarCotizacion(WidgetRef ref, String id) {
    ref.read(cotizacionesProvider.notifier).eliminarCotizacion(id);
  }
  
  void _nuevaCotizacion(BuildContext context, WidgetRef ref) {
    final contextPrincipal = context;
    final Cotizacion cotizacionTemporal = Cotizacion.empty();
    ref.read(cotizacionesProvider.notifier).agregarCotizacionTemp(cotizacionTemporal);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CotizacionScreen(
          cotizacionId: cotizacionTemporal.id,
          nuevaCotizacion: true,
          contextPrincipal: contextPrincipal
        ),
      ),
    );
  }
}

class _CotizacionItem extends StatelessWidget {
  final Cotizacion cotizacion;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onConvert;

  const _CotizacionItem({
    required this.cotizacion,
    required this.onTap,
    required this.onDelete,
    required this.onConvert,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) async {
              onConvert();
            },
            backgroundColor: colors.primary,
            icon: Icons.point_of_sale,
            label: 'Convertir a venta',
          ),
        ]
      ),
      child: Card(
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
                    Expanded(
                      child: Text(
                        'Cotización #${cotizacion.id}',
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                Text('Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(cotizacion.fechaCreacion)}'),
                if (cotizacion.expira.isAfter(DateTime.now()))
                  Text(
                    'Válida hasta: ${DateFormat('dd/MM/yyyy HH:mm').format(cotizacion.expira)}',
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
      ),
    );
  }
}