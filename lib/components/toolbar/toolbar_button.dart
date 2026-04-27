import 'package:flutter/material.dart';
import 'package:saber/data/dodo_colors.dart';

class ToolbarIconButton extends StatelessWidget {
  const ToolbarIconButton({
    super.key,
    this.tooltip,
    this.selected = false,
    this.enabled = true,
    required this.onPressed,
    required this.padding,
    required this.child,
  });

  final String? tooltip;
  final bool selected;
  final bool enabled;
  final VoidCallback? onPressed;

  final EdgeInsets padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Buttons fill with the same color the AppBar uses in dark mode (the
    // default Material 3 AppBar background = colorScheme.surface) so that
    // controls read consistently as part of the app chrome.
    final unselectedFill = isDark ? colorScheme.surface : Colors.transparent;
    final backgroundColor = WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return unselectedFill;
      }
      if (!states.contains(WidgetState.selected)) {
        return unselectedFill;
      }
      return colorScheme.primary;
    });
    final foregroundColor = WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return colorScheme.onSurface.withValues(alpha: 0.4);
      }
      if (states.contains(WidgetState.selected)) {
        return colorScheme.onPrimary;
      }
      return colorScheme.primary;
    });
    final buttonStyle = ButtonStyle(
      backgroundColor: backgroundColor,
      iconColor: foregroundColor,
      foregroundColor: foregroundColor,
      iconSize: const WidgetStatePropertyAll(20),
      padding: const WidgetStatePropertyAll(EdgeInsets.all(8)),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    return Padding(
      padding: padding,
      child: IconButton.filled(
        style: buttonStyle,
        onPressed: (enabled) ? onPressed : null,
        tooltip: tooltip,
        isSelected: selected,
        icon: child,
      ),
    );
  }
}
