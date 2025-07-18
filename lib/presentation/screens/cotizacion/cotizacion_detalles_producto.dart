import 'package:craftz_app/data/models/cotizacion/extra_cotizado_model.dart';
import 'package:craftz_app/data/repositories/catalogo_productos_repositorie.dart' hide Color;
import 'package:craftz_app/data/models/catalogo_productos/color_model.dart' as MyColor;
import 'package:craftz_app/providers/categories_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/cotizacion_repositories.dart';
import '../../../providers/cotizaciones_provider.dart';
import 'package:craftz_app/core/utils/calculadorCosto.dart';

class DetallesProductoBottomSheet extends ConsumerStatefulWidget {
  final Producto producto;
  final String cotizacionId;

  const DetallesProductoBottomSheet({required this.producto, required this.cotizacionId});

  @override
  ConsumerState<DetallesProductoBottomSheet> createState() => DetallesProductoBottomSheetState();
}

class DetallesProductoBottomSheetState extends ConsumerState<DetallesProductoBottomSheet> {
  int cantidad = 1;
  Variante? varianteSeleccionada;
  Calidad? calidadSeleccionada;
  MyColor.Color? colorSeleccionado;
  Talla? tallaSeleccionada;
  List<ExtraCotizado> extrasSeleccionados = [];

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    // Obtener la subcategoría usando el método del notifier
    final subcategoria = ref.read(categoriesProvider.notifier).getSubcategoria(widget.producto);
    
    // Si no encontramos la subcategoría, usamos valores por defecto
    final usaTallas = subcategoria?.usaTallas ?? false;
    final usaCalidades = widget.producto.configVariantes.usaCalidad;
    final usaVariantes = widget.producto.configVariantes.usaVariante;

    if (!usaVariantes) {
      varianteSeleccionada = widget.producto.variantes![0];
      if (!usaCalidades) {
        calidadSeleccionada = varianteSeleccionada!.calidades[0];
      }
    }

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            Text(
              widget.producto.nombre,
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Selector de variante (si tiene)
            if (usaVariantes)
              _buildVarianteSelector(),
            
            if (usaCalidades && varianteSeleccionada != null && varianteSeleccionada!.calidades.isNotEmpty)
              _buildCalidadSelector(),
            
            // Selector de color (si tiene)
            if ((varianteSeleccionada != null && calidadSeleccionada != null && calidadSeleccionada!.colores.isNotEmpty))
              _buildColorSelector(usaTallas),
            
            // Selector de talla (si la subcategoría usa tallas)
            if (usaTallas)
              if (colorSeleccionado?.tallas?.isNotEmpty ?? false)
                _buildTallaSelector(),
            
            // Selector de cantidad
            _buildCantidadSelector(),
      
            if(_tieneSeleccionCompleta(usaTallas))
              _buildStockVerification(usaTallas),
      
            const Spacer(),
              
            // Botón para agregar
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:colors.primary,
                foregroundColor: colors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10)
              ),
              onPressed: _puedeAgregar(usaTallas) ? () => _agregarProducto(ref) : null,
              child: const Text('Agregar a cotización'),
            ),
          ],
        ),
      ),
    );
  }

  bool _tieneSeleccionCompleta(bool usaTallas) {
    if (widget.producto.configVariantes.usaVariante && varianteSeleccionada == null) return false;
    if (widget.producto.configVariantes.usaCalidad && calidadSeleccionada == null) return false;
    if (colorSeleccionado == null) return false;
    if (usaTallas && tallaSeleccionada == null) return false;
    return true;
  }

  bool _puedeAgregar(bool usaTallas) {
    return _tieneSeleccionCompleta(usaTallas);
  }

  Future<void> _agregarProducto(WidgetRef ref) async {
    final CalculadorCostos calculador = CalculadorCostos(ref);
    // Obtener la subcategoría nuevamente para asegurarnos de tener los datos más recientes
    final subcategoria = ref.read(categoriesProvider.notifier).getSubcategoria(widget.producto);
    final usaTallas = subcategoria?.usaTallas ?? false;

    // Calcular precio base
    double precioBase = 0;
    if (usaTallas && tallaSeleccionada != null) {
      precioBase = tallaSeleccionada!.costo;
    } else if (colorSeleccionado != null) {
      precioBase = colorSeleccionado!.costo ?? 0;
    }

    final precioNeto = await calculador.calcularPrecioFinal(subcategoriaId: widget.producto.subcategoria, extras: extrasSeleccionados, precioBase: precioBase);

    final productoCotizado = ProductoCotizado(
      productoRef: widget.producto.id,
      producto: ProductoCotizadoInfo(
        nombre: widget.producto.nombre,
        descripcion: widget.producto.descripcion,
      ),
      variante: varianteSeleccionada != null
          ? VarianteCotizada(
              id: varianteSeleccionada!.id,
              variante: varianteSeleccionada!.variante,
            )
          : null,
      calidad: calidadSeleccionada != null
        ? CalidadCotizada(
            id: calidadSeleccionada!.id,
            calidad: calidadSeleccionada!.calidad,
          )
        : null,
      color: colorSeleccionado != null
          ? ColorCotizado(
              id: colorSeleccionado!.id,
              color: colorSeleccionado!.color,
              codigoHex: colorSeleccionado!.codigoHex,
            )
          : null,
      talla: tallaSeleccionada != null
          ? TallaCotizada(
              id: tallaSeleccionada!.id,
              talla: tallaSeleccionada!.talla ?? tallaSeleccionada!.codigo,
              codigo: tallaSeleccionada!.codigo,
            )
          : null,
      subcategoriaId: widget.producto.subcategoria,
      extras: extrasSeleccionados,
      cantidad: cantidad,
      precioBase: precioBase,
      precio: precioNeto,
      precioFinal: precioNeto * cantidad,
    );

    ref.read(cotizacionesProvider.notifier).agregarProductoACotizacion(widget.cotizacionId, productoCotizado);
    Navigator.pop(context);
  }

  Widget _buildVarianteSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<Variante>(
        decoration: InputDecoration(
          labelText: 'Variante',
          border: OutlineInputBorder(),
        ),
        value: varianteSeleccionada,
        items: widget.producto.variantes!.map((variante) {
          return DropdownMenuItem(
            value: variante,
            child: Text(
              variante.variante ?? 'Variante única',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }).toList(),
        onChanged: (variante) {
          setState(() {
            varianteSeleccionada = variante;
            calidadSeleccionada = null;
            colorSeleccionado = null;
            tallaSeleccionada = null;
          });
        },
      ),
    );
  }

  Widget _buildCalidadSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<Calidad>(
        decoration: InputDecoration(
          labelText: 'Calidad',
          border: OutlineInputBorder(),
        ),
        value: calidadSeleccionada,
        items: varianteSeleccionada!.calidades.map((calidad) {
          return DropdownMenuItem(
            value: calidad,
            child: Text(
              calidad.calidad ?? 'Calidad estándar',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }).toList(),
        onChanged: (calidad) {
          setState(() {
            calidadSeleccionada = calidad;
            colorSeleccionado = null;
            tallaSeleccionada = null;
          });
        },
      ),
    );
  }

   Widget _buildColorSelector(bool usaTallas) {
    final colores = calidadSeleccionada!.colores;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<MyColor.Color>(
        decoration: InputDecoration(
          labelText: 'Color',
          border: OutlineInputBorder(),
          isDense: true,
        ),
        value: colorSeleccionado,
        selectedItemBuilder: (BuildContext context) {
          return colores.map((color) {
            return DropdownMenuItem(
              value: color,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Color(int.parse(color.codigoHex.replaceFirst('#', '0xff'))),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Text(
                        color.color,
                        style: Theme.of(context).textTheme.bodyLarge,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,  
                      ),
                    ],
                  )
                ],
              )
            );
          }).toList();
        },
        items: colores.map((color) {
          return DropdownMenuItem(
            value: color,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Color(int.parse(color.codigoHex.replaceFirst('#', '0xff'))),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Text(
                      color.color,
                      style: Theme.of(context).textTheme.bodyLarge,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,  
                    ),
                  ],
                ),
                if(!usaTallas)
                  Text(
                    'Stock: ${color.stock}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
            )
          );
        }).toList(),
        onChanged: (color) {
          setState(() {
            colorSeleccionado = color;
            tallaSeleccionada = null;
          });
        },
      ),
    );
  }

  Widget _buildTallaSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<Talla>(
        decoration: InputDecoration(
          labelText: 'Talla',
          border: OutlineInputBorder(),
        ),
        value: tallaSeleccionada,
        selectedItemBuilder: (BuildContext context) {
          return colorSeleccionado!.tallas!.map((talla) {
            return DropdownMenuItem(
              value: talla,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    talla.talla ?? talla.codigo,
                    style: Theme.of(context).textTheme.bodyLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }).toList();
        },
        items: colorSeleccionado!.tallas!.map((talla) {
          return DropdownMenuItem(
            value: talla,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  talla.talla ?? talla.codigo,
                  style: Theme.of(context).textTheme.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Stock: ${talla.stock}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (talla) {
          setState(() => tallaSeleccionada = talla);
        },
      ),
    );
  }

  Widget _buildCantidadSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: () {
              if (cantidad > 1) {
                setState(() => cantidad--);
              }
            },
          ),
          Container(
            width: 60,
            child: Text(
              '$cantidad',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => setState(() => cantidad++),
          ),
        ],
      ),
    );
  }

  Widget _buildStockVerification(bool usaTallas) {
    final stockDisponible = usaTallas 
        ? tallaSeleccionada!.stock 
        : colorSeleccionado!.stock ?? 0;
    final bajoStock = stockDisponible < cantidad;
    final sinStock = stockDisponible <= 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Text(
            sinStock ? 'SIN STOCK DISPONIBLE' : 
            bajoStock ? 'STOCK BAJO' : 'EN STOCK',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: sinStock ? Colors.red : bajoStock ? Colors.orange : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Disponibles: $stockDisponible',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (bajoStock && !sinStock)
            Text(
              'La cantidad solicitada supera el stock disponible',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.orange,
              ),
            ),
        ],
      ),
    );
  }
}