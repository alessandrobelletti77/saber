import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/_tool.dart';
import 'package:saber/data/tools/highlighter.dart';
import 'package:saber/data/tools/pencil.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:sbn/tool_id.dart';

class Pen extends Tool {
  @protected
  @visibleForTesting
  Pen({
    required this.name,
    required this.sizeMin,
    required this.sizeMax,
    required this.sizeStep,
    required this.icon,
    required this.options,
    required this.pressureEnabled,
    required this.color,
    required this.toolId,
    this.calligraphicMode = false,
  });

  /// When true, the stroke is drawn with a calligraphic / chisel-tip effect:
  /// horizontal motion produces full-width strokes, vertical motion produces
  /// roughly half-width strokes (and diagonals interpolate). Used by
  /// [Pen.squareTipMarker] to emulate a chisel-tip felt-tip pen.
  final bool calligraphicMode;

  Pen.fountainPen()
    : name = t.editor.pens.fountainPen,
      sizeMin = 1,
      sizeMax = 25,
      sizeStep = 1,
      icon = fountainPenIcon,
      options = stows.lastFountainPenOptions.value,
      pressureEnabled = true,
      color = Color(stows.lastFountainPenColor.value),
      toolId = .fountainPen,
      calligraphicMode = false;

  Pen.ballpointPen()
    : name = t.editor.pens.ballpointPen,
      sizeMin = 1,
      sizeMax = 25,
      sizeStep = 1,
      icon = ballpointPenIcon,
      options = stows.lastBallpointPenOptions.value,
      pressureEnabled = false,
      color = Color(stows.lastBallpointPenColor.value),
      toolId = .ballpointPen,
      calligraphicMode = false;

  /// Round-tip marker — uniform width (no pressure), smooth ends.
  /// Internally re-uses ballpoint persistence keys so the user keeps a single
  /// "marker" colour/size set whether they pick round or square tip.
  Pen.roundTipMarker()
    : name = t.editor.pens.roundTipMarker,
      sizeMin = 1,
      sizeMax = 25,
      sizeStep = 1,
      icon = roundTipMarkerIcon,
      options = stows.lastBallpointPenOptions.value,
      pressureEnabled = false,
      color = Color(stows.lastBallpointPenColor.value),
      toolId = .ballpointPen,
      calligraphicMode = false;

  /// Square-tip marker — chisel-tip pen with directional thickness:
  /// horizontal strokes are full-width, vertical strokes are about half.
  /// Implemented by feeding `perfect_freehand` a synthetic pressure value
  /// computed from the stroke's direction (see [calligraphicMode]).
  Pen.squareTipMarker()
    : name = t.editor.pens.squareTipMarker,
      sizeMin = 1,
      sizeMax = 25,
      sizeStep = 1,
      icon = squareTipMarkerIcon,
      options = stows.lastBallpointPenOptions.value.copyWith(
        smoothing: 0,
        streamline: 0,
      ),
      pressureEnabled = true,
      color = Color(stows.lastBallpointPenColor.value),
      toolId = .ballpointPen,
      calligraphicMode = true;

  final String name;
  final double sizeMin, sizeMax, sizeStep;
  late final int sizeStepsBetweenMinAndMax = ((sizeMax - sizeMin) / sizeStep)
      .round();
  final Object icon;

  @override
  final ToolId toolId;

  static const fountainPenIcon = FontAwesomeIcons.penFancy;
  static const ballpointPenIcon = FontAwesomeIcons.pen;
  static const roundTipMarkerIcon = FontAwesomeIcons.marker;
  // Use a Material Symbols square icon to avoid confusion with the
  // (now-removed) fountain pen, whose nib silhouette looked very similar
  // to FontAwesome's `penNib`.
  static const IconData squareTipMarkerIcon = Symbols.edit_square;

  static Stroke? currentStroke;
  Color color;
  bool pressureEnabled;
  StrokeOptions options;

  static var _currentPen = Pen.roundTipMarker();
  static Pen get currentPen => _currentPen;
  static set currentPen(Pen currentPen) {
    assert(
      currentPen is! Highlighter,
      'Use Highlighter.currentHighlighter instead',
    );
    assert(currentPen is! Pencil, 'Use Pencil.currentPencil instead');
    _currentPen = currentPen;
  }

  void onDragStart(
    Offset position,
    EditorPage page,
    int pageIndex,
    double? pressure,
  ) {
    currentStroke = Stroke(
      color: color,
      pressureEnabled: pressureEnabled,
      options: options.copyWith(isComplete: false),
      pageIndex: pageIndex,
      page: page,
      toolId: toolId,
    );
    onDragUpdate(position, pressure);
  }

  void onDragUpdate(Offset position, double? pressure) {
    if (calligraphicMode &&
        currentStroke != null &&
        currentStroke!.points.isNotEmpty) {
      pressure = _calligraphicPressure(position);
    }
    currentStroke?.addPoint(position, pressure);
  }

  /// Returns a synthetic pressure value (0.5–1.0) based on the direction
  /// of motion from the previous point to [current]:
  /// - horizontal motion → 1.0 (full chisel width)
  /// - vertical motion → 0.5 (chisel thin edge, ~half width)
  /// - diagonals interpolate linearly.
  double? _calligraphicPressure(Offset current) {
    final last = currentStroke!.points.last;
    final dx = (current.dx - last.dx).abs();
    final dy = (current.dy - last.dy).abs();
    final dist = math.sqrt(dx * dx + dy * dy);
    if (dist < 0.5) return null; // negligible motion, reuse previous pressure
    // ratio: 1.0 when motion is fully horizontal, 0.0 when fully vertical
    final ratio = dx / (dx + dy);
    return 0.5 + ratio * 0.5; // map to [0.5, 1.0]
  }

  Stroke? onDragEnd() {
    final stroke = currentStroke;
    currentStroke = null;
    if (stroke == null) return null;

    return stroke
      ..options.isComplete = true
      ..markPolygonNeedsUpdating();
  }

  /// The default stroke options.
  ///
  /// Note that these are different to the default options in [StrokeOptions]
  /// e.g. [StrokeOptions.defaultSize] for historical reasons
  /// (i.e. [StrokeOptions.toJson] does not include default values.)
  static final defaultOptions = StrokeOptions(size: 5);

  static StrokeOptions get fountainPenOptions => defaultOptions.copyWith();
  static StrokeOptions get ballpointPenOptions => defaultOptions.copyWith();
  static StrokeOptions get shapePenOptions =>
      defaultOptions.copyWith(smoothing: 0, streamline: 0);
  static StrokeOptions get highlighterOptions =>
      defaultOptions.copyWith(size: 50);
  static StrokeOptions get pencilOptions => defaultOptions.copyWith(
    streamline: 0.1,
    start: StrokeEndOptions.start(taperEnabled: true, customTaper: 1),
    end: StrokeEndOptions.end(taperEnabled: true, customTaper: 1),
  );
}
