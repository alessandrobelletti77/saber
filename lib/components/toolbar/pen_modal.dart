import 'package:flutter/material.dart';
import 'package:saber/components/toolbar/size_picker.dart';
import 'package:saber/data/extensions/axis_extensions.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/_tool.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/data/tools/pencil.dart';
import 'package:saber/i18n/strings.g.dart';

class PenModal extends StatefulWidget {
  const PenModal({super.key, required this.getTool, required this.setTool});

  final Tool Function() getTool;
  final void Function(Pen) setTool;

  @override
  State<PenModal> createState() => _PenModalState();
}

class _PenModalState extends State<PenModal> {
  @override
  Widget build(BuildContext context) {
    final axis = stows.editorToolbarAlignment.value.axis.opposite;
    final Tool currentTool = widget.getTool();
    final Pen currentPen;
    if (currentTool is Pen) {
      currentPen = currentTool;
    } else {
      return const SizedBox();
    }

    return Flex(
      direction: axis,
      mainAxisAlignment: .center,
      children: [
        SizePicker(axis: axis, pen: currentPen),
        if (currentPen is Pencil) ...[
          const SizedBox.square(dimension: 16),
          _HardnessPicker(pencil: currentPen, axis: axis),
        ],
      ],
    );
  }
}

/// Companion to [SizePicker] that lets the user dial the pencil's hardness
/// from 5H (hardest, lightest stroke) to 5B (softest, darkest stroke).
/// Shown alongside the size slider whenever a [Pencil] is active.
class _HardnessPicker extends StatefulWidget {
  const _HardnessPicker({required this.pencil, required this.axis});

  final Pencil pencil;
  final Axis axis;

  @override
  State<_HardnessPicker> createState() => _HardnessPickerState();
}

class _HardnessPickerState extends State<_HardnessPicker> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    return Flex(
      direction: widget.axis,
      mainAxisSize: .min,
      children: [
        Column(
          children: [
            Text(
              t.editor.penOptions.hardness,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.8),
                fontSize: 10,
                height: 1,
              ),
            ),
            Text(Pencil.hardnessLabel(widget.pencil.hardness)),
          ],
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: widget.axis == Axis.horizontal ? 120 : 32,
          height: widget.axis == Axis.vertical ? 120 : 32,
          child: RotatedBox(
            quarterTurns: widget.axis == Axis.horizontal ? 0 : 1,
            child: Slider(
              value: widget.pencil.hardness.toDouble(),
              min: 0,
              max: 10,
              divisions: 10,
              label: Pencil.hardnessLabel(widget.pencil.hardness),
              onChanged: (v) => setState(() {
                widget.pencil.setHardness(v.toInt());
              }),
            ),
          ),
        ),
      ],
    );
  }
}
