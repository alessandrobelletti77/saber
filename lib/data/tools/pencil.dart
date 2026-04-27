import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/i18n/strings.g.dart';

class Pencil extends Pen {
  Pencil()
    : hardness = stows.lastPencilHardness.value,
      super(
        name: t.editor.pens.pencil,
        sizeMin: 1,
        sizeMax: 15,
        sizeStep: 1,
        icon: pencilIcon,
        options: stows.lastPencilOptions.value,
        pressureEnabled: true,
        color: _applyHardness(
          Color(stows.lastPencilColor.value),
          stows.lastPencilHardness.value,
        ),
        toolId: .pencil,
      );

  /// Pencil hardness: 0 = 5H (hardest), 5 = HB, 10 = 5B (softest).
  /// Affects the stroke alpha — harder pencils leave lighter marks.
  int hardness;

  /// Updates this pencil's hardness in-place and refreshes its rendering
  /// colour. Persisted to [stows.lastPencilHardness] so the value sticks
  /// across app launches.
  void setHardness(int newHardness) {
    hardness = newHardness;
    stows.lastPencilHardness.value = newHardness;
    color = _applyHardness(Color(stows.lastPencilColor.value), newHardness);
  }

  /// Maps the integer [hardness] (0–10) to an alpha factor (0.3–1.0) and
  /// returns [base] tinted with that alpha. Ignores [base]'s original alpha
  /// because the hardness value is the user's chosen opacity in this fork.
  static Color _applyHardness(Color base, int hardness) {
    final clamped = hardness.clamp(0, 10);
    final alpha = 0.3 + clamped * 0.07; // 0.3 at 5H, ~0.65 at HB, 1.0 at 5B
    return base.withValues(alpha: alpha);
  }

  /// Human-readable hardness label (5H, 4H, …, HB, …, 4B, 5B).
  static String hardnessLabel(int h) {
    if (h == 5) return 'HB';
    if (h < 5) {
      final n = 5 - h;
      return n == 1 ? 'H' : '${n}H';
    }
    final n = h - 5;
    return n == 1 ? 'B' : '${n}B';
  }

  static var currentPencil = Pencil();

  static const pencilIcon = FontAwesomeIcons.pencil;
}
