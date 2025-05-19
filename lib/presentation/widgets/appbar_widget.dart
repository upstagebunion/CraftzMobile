import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget{
  final Widget title;
  final List<Widget>? actions;
  final Size preferredSize;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
  }) : preferredSize = const Size.fromHeight(kToolbarHeight);
  
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AppBar(
      title: title,
      backgroundColor: colors.primary,
      foregroundColor: colors.onPrimary,
      titleTextStyle: Theme.of(context).textTheme.headlineSmall,
      actions: actions,
    );
  }
}