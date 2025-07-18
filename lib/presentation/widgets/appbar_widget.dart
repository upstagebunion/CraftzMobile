import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget{
  final Widget title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
  });

  @override
  Size get preferredSize {
    // Altura base del AppBar (kToolbarHeight)
    double height = kToolbarHeight;
    
    // Si hay un bottom, sumamos su altura preferida
    if (bottom != null) {
      height += bottom!.preferredSize.height;
    }
    
    return Size.fromHeight(height);
  }
  
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AppBar(
      title: title,
      backgroundColor: colors.primary,
      foregroundColor: colors.onPrimary,
      titleTextStyle: Theme.of(context).textTheme.headlineSmall,
      actions: actions,
      bottom: bottom,
    );
  }
}