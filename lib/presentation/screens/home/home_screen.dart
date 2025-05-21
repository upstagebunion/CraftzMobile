import 'package:craftz_app/services/reportes_services.dart';
import 'package:flutter/material.dart';
import '../../widgets/drawer_widget.dart';
import 'package:craftz_app/presentation/widgets/appbar_widget.dart';
import 'package:file_saver/file_saver.dart';
import 'package:open_filex/open_filex.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ReporteService reporteService = ReporteService();
  final FileSaver fileSaver = FileSaver();

  String ventasHoy = '...';
  String ingresosMes = '...';
  String countProductos = '...';
  String countClientes = '...';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final ventas = await reporteService.getVentasHoy();
      final ingresos = await reporteService.getIngresosMes();
      final productos = await reporteService.getConteoProductos();
      final clientes = await reporteService.getConteoClientes();

      setState(() {
        ventasHoy = ventas.toString();
        ingresosMes = '\$${ingresos.toString()}';
        countProductos = productos.toString();
        countClientes = clientes.toString();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        ventasHoy = 'S/I';
        ingresosMes = 'S/I';
        countProductos = 'S/I';
        countClientes = 'S/I';
        isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: ${e.toString()}')),
      );
    }
  }

  Future<void> _generarReporte(String periodo) async {
    try {
      final pdfBytes = await reporteService.obtenerReporteVentas(periodo);
      final file = await fileSaver.saveFile(
        name: 'reporte_ventas_${periodo.toLowerCase()}.pdf',
        bytes: pdfBytes,
        ext: 'pdf',
        mimeType: MimeType.pdf,
      );
      await OpenFilex.open(file);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al generar reporte: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = Theme.of(context).colorScheme;

    

    return Scaffold(
      appBar: CustomAppBar(
        title: const Text('Craftz Admin'),
      ),
      drawer: const CustomDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
                    colors.surface,
                    Colors.grey[50]!,
                    Colors.grey[100]!,
                  ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header con bienvenida
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bienvenido/a',
                        style: theme.textTheme.displayLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Panel de Control Craftz',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
          
                // Cards de métricas (puedes reemplazar con datos reales)
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                    children: [
                      _MetricCard(
                        icon: Icons.shopping_bag,
                        title: 'Ventas Hoy',
                        value: ventasHoy,
                        color: Colors.blue,
                      ),
                      _MetricCard(
                        icon: Icons.monetization_on,
                        title: 'Ingresos',
                        value: ingresosMes,
                        color: Colors.green,
                      ),
                      _MetricCard(
                        icon: Icons.inventory,
                        title: 'Productos',
                        value: countProductos,
                        color: Colors.orange,
                      ),
                      _MetricCard(
                        icon: Icons.people,
                        title: 'Clientes',
                        value: countClientes,
                        color: Colors.purple,
                      ),
                    ],
                  ),
                ),
          
                // Sección de reportes
                Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 16),
                  child: Text(
                    'Generar Reporte de ventass',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colors.primary,
                    ),
                  ),
                ),
          
                // Botones de reportes
                Row(
                  children: [
                    Expanded(
                      child: _ReportButton(
                        label: 'Diario',
                        icon: Icons.calendar_view_day,
                        onPressed: () => _generarReporte('diario'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ReportButton(
                        label: 'Semanal',
                        icon: Icons.calendar_view_week,
                        onPressed: () => _generarReporte('semanal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ReportButton(
                        label: 'Mensual',
                        icon: Icons.calendar_today,
                        onPressed: () => _generarReporte('mensual'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: colors.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _ReportButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: colors.primary,
        backgroundColor: colors.surfaceContainer,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}