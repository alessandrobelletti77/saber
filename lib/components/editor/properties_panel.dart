/// 🤖 Generated wholely or partially with Claude Code
library;

import 'package:flutter/material.dart';
import 'package:saber/data/tools/_tool.dart';
import 'package:saber/data/tools/eraser.dart';
import 'package:saber/data/tools/highlighter.dart';
import 'package:saber/data/tools/laser_pointer.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/data/tools/pencil.dart';
import 'package:saber/data/tools/select.dart';
import 'package:saber/i18n/strings.g.dart';

/// A side panel that surfaces the active tool's (or selection's) editable
/// properties — color, size, pressure, etc. — in a single place.
///
/// Toggled by `stows.editorPropertiesPanelOpen` via a toolbar button.
class PropertiesPanel extends StatelessWidget {
  const PropertiesPanel({super.key, required this.currentTool});

  /// Width of the panel when expanded.
  static const double width = 280;

  final Tool currentTool;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(
          left: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const .all(16),
          children: [
            Text(
              t.editor.properties.title,
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildToolSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildToolSection(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (currentTool is Pen && currentTool is! Pencil && currentTool is! Highlighter) {
      final pen = currentTool as Pen;
      return _PenPropertiesSection(pen: pen);
    } else if (currentTool is Pencil) {
      return _PenPropertiesSection(pen: Pencil.currentPencil);
    } else if (currentTool is Highlighter) {
      return _PenPropertiesSection(pen: Highlighter.currentHighlighter);
    } else if (currentTool is Eraser) {
      return Text(
        t.editor.properties.eraserActive,
        style: textTheme.bodyMedium,
      );
    } else if (currentTool is Select) {
      return Text(
        t.editor.properties.selectActive,
        style: textTheme.bodyMedium,
      );
    } else if (currentTool is LaserPointer) {
      return Text(
        t.editor.properties.laserActive,
        style: textTheme.bodyMedium,
      );
    } else {
      return Text(
        t.editor.properties.noTool,
        style: textTheme.bodyMedium,
      );
    }
  }
}

class _PenPropertiesSection extends StatelessWidget {
  const _PenPropertiesSection({required this.pen});

  final Pen pen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tool name
        Text(pen.name, style: textTheme.titleMedium),
        const SizedBox(height: 12),

        // Color swatch
        Row(
          children: [
            Text(
              t.editor.properties.color,
              style: textTheme.labelLarge,
            ),
            const SizedBox(width: 12),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: pen.color,
                shape: .circle,
                border: Border.all(color: theme.colorScheme.outline, width: 1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Size readout
        Row(
          children: [
            Text(
              t.editor.properties.size,
              style: textTheme.labelLarge,
            ),
            const SizedBox(width: 12),
            Text(
              pen.options.size.toStringAsFixed(1),
              style: textTheme.bodyLarge,
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Pressure readout
        Row(
          children: [
            Text(
              t.editor.properties.pressure,
              style: textTheme.labelLarge,
            ),
            const SizedBox(width: 12),
            Icon(
              pen.pressureEnabled
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              size: 20,
              color: pen.pressureEnabled
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Hint about advanced properties
        Container(
          padding: const .all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: .circular(8),
          ),
          child: Text(
            t.editor.properties.advancedHint,
            style: textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
