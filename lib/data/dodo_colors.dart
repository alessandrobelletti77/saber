/// 🤖 Generated wholely or partially with Claude Code
library;

import 'package:flutter/material.dart';

/// Centralised DODO NOTES brand colors.
///
/// Used by [SaberTheme] for the dark-mode scaffold background, by the editor
/// for its working-area background, and by toolbar/bottom-sheet buttons for
/// their fill so the whole UI shares a single, intentional palette.
abstract class DodoColors {
  /// The "program" color: scaffold background everywhere outside the editor's
  /// working area. Also used as the fill for toolbar/bottom-sheet buttons so
  /// they read as part of the program chrome.
  static const Color programDark = Color(0xFF465166);

  /// The "working area" color: scaffold background inside the editor — a
  /// noticeably lighter shade of [programDark] so the canvas chrome stands
  /// apart visually from the rest of the app.
  static const Color editorWorkArea = Color(0xFF63728F);
}
