import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logging/logging.dart';
import 'package:one_dollar_unistroke_recognizer/one_dollar_unistroke_recognizer.dart';
import 'package:saber/components/canvas/_circle_stroke.dart';
import 'package:saber/components/canvas/_rectangle_stroke.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:sbn/tool_id.dart';

class ShapePen extends Pen {
  ShapePen()
    : super(
        name: t.editor.pens.shapePen,
        sizeMin: 1,
        sizeMax: 25,
        sizeStep: 1,
        icon: shapePenIcon,
        options: stows.lastShapePenOptions.value,
        pressureEnabled: false,
        color: Color(stows.lastShapePenColor.value),
        toolId: .shapePen,
      );

  static final log = Logger('ShapePen');

  static const shapePenIcon = FontAwesomeIcons.shapes;

  static RecognizedUnistroke? detectedShape;
  void _detectShape() {
    detectedShape = Pen.currentStroke?.detectShape();
  }

  /// Runs the unistroke recogniser on [rawStroke] and, if a known regular
  /// shape is detected (line, rectangle, circle), returns a Stroke
  /// containing that shape rendered cleanly with the caller's pen colour
  /// and options. Returns [rawStroke] unchanged otherwise.
  ///
  /// Triangle/star/polyline detection has been intentionally dropped: the
  /// classifier was too unreliable for triangles, and zigzag polylines
  /// kept being mis-rounded into splines.
  ///
  /// Used by the global "shape mode" toggle so any pen can produce shapes
  /// without switching to the dedicated [ShapePen].
  static Stroke recognize(
    Stroke rawStroke, {
    required Color color,
    required bool pressureEnabled,
    required ToolId toolId,
  }) {
    final detected = rawStroke.detectShape();
    if (detected == null || detected.name == null) return rawStroke;
    switch (detected.name!) {
      case DefaultUnistrokeNames.line:
        return rawStroke..convertToLine();
      case DefaultUnistrokeNames.rectangle:
        final rect = detected.convertToRect();
        return RectangleStroke(
          color: color,
          pressureEnabled: pressureEnabled,
          options: rawStroke.options,
          pageIndex: rawStroke.pageIndex,
          page: rawStroke.page,
          toolId: toolId,
          rect: rect,
        );
      case DefaultUnistrokeNames.circle:
        final (center, radius) = detected.convertToCircle();
        return CircleStroke(
          color: color,
          pressureEnabled: pressureEnabled,
          options: rawStroke.options,
          pageIndex: rawStroke.pageIndex,
          page: rawStroke.page,
          toolId: toolId,
          radius: radius,
          center: center,
        );
      case DefaultUnistrokeNames.triangle:
      case DefaultUnistrokeNames.star:
        // Intentionally not handled (unreliable / not desired).
        return rawStroke;
    }
  }

  static Timer? _detectShapeDebouncer;
  static var debounceDuration = getDebounceFromPref();
  static Duration getDebounceFromPref() {
    assert(stows.shapeRecognitionDelay.loaded);
    final ms = stows.shapeRecognitionDelay.value;
    if (ms < 0) {
      return const Duration(hours: 1);
    } else {
      return Duration(milliseconds: ms);
    }
  }

  @override
  void onDragUpdate(Offset position, double? pressure) {
    super.onDragUpdate(position, pressure);

    final isPreviewEnabled = debounceDuration < const Duration(hours: 1);
    final isTimerActive = _detectShapeDebouncer?.isActive ?? false;
    if (isPreviewEnabled && !isTimerActive) {
      _detectShapeDebouncer = Timer(debounceDuration, _detectShape);
    }
  }

  @override
  Stroke? onDragEnd() {
    _detectShapeDebouncer?.cancel();
    _detectShapeDebouncer = null;
    _detectShape();

    final rawStroke = super.onDragEnd();
    if (rawStroke == null) return null;
    assert(rawStroke.options.isComplete == true);

    final detectedShape = ShapePen.detectedShape;
    ShapePen.detectedShape = null;

    if (detectedShape == null) return rawStroke;

    switch (detectedShape.name) {
      case null:
        log.info('Detected unknown shape');
        return rawStroke;
      case DefaultUnistrokeNames.line:
        log.info('Detected line');
        return rawStroke..convertToLine();
      case DefaultUnistrokeNames.rectangle:
        final rect = detectedShape.convertToRect();
        log.info('Detected rectangle: $rect');
        return RectangleStroke(
          color: color,
          pressureEnabled: pressureEnabled,
          options: rawStroke.options,
          pageIndex: rawStroke.pageIndex,
          page: rawStroke.page,
          toolId: toolId,
          rect: rect,
        );
      case DefaultUnistrokeNames.circle:
        final (center, radius) = detectedShape.convertToCircle();
        log.info('Detected circle: c=$center, r=$radius');
        return CircleStroke(
          color: color,
          pressureEnabled: pressureEnabled,
          options: rawStroke.options,
          pageIndex: rawStroke.pageIndex,
          page: rawStroke.page,
          toolId: toolId,
          radius: radius,
          center: center,
        );
      case DefaultUnistrokeNames.triangle:
      case DefaultUnistrokeNames.star:
        // Triangle/star recognition disabled — too unreliable. Return the
        // raw freehand stroke instead.
        return rawStroke;
    }
  }
}
