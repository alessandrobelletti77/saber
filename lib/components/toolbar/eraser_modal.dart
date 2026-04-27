/// 🤖 Generated wholely or partially with Claude Code
library;

import 'package:flutter/material.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/i18n/strings.g.dart';

/// Small modal that opens when the user taps the eraser button a second
/// time (with the eraser already active). Hosts the "keep eraser active"
/// toggle so that the user can choose whether the eraser auto-switches
/// back to the previous tool after each erase action.
class EraserModal extends StatefulWidget {
  const EraserModal({super.key});

  @override
  State<EraserModal> createState() => _EraserModalState();
}

class _EraserModalState extends State<EraserModal> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: stows.disableEraserAfterUse,
      builder: (context, autoDisable, _) {
        final keepActive = !autoDisable;
        return Padding(
          padding: const .symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisSize: .min,
            children: [
              Text(t.editor.eraserOptions.keepActive),
              const SizedBox(width: 8),
              Switch(
                value: keepActive,
                onChanged: (v) {
                  // v=true means "keep active" → auto-disable=false.
                  stows.disableEraserAfterUse.value = !v;
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
