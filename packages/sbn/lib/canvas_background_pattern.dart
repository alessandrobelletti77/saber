enum CanvasBackgroundPattern {
  /// No background pattern
  none(''),

  /// College ruled paper (ltr): horizontal lines with one
  /// vertical line along the left margin
  collegeLtr('college'),

  /// College ruled paper (rtl): horizontal lines with one
  /// vertical line along the right margin
  collegeRtl('college-rtl'),

  /// Horizontal lines. This is the same as college ruled paper
  /// but without the vertical line
  lined('lined'),

  /// A grid of squares
  grid('grid', requiresClipping: true),

  /// A grid of dots. This is the same as "grid" except it has dots on the
  /// corners instead of the whole square border.
  dots('dots', requiresClipping: true),

  /// Music staffs
  staffs('staffs'),

  /// Music tablature
  ///
  /// Like staffs but with 6 lines instead of 5 (and 5 spaces instead of 4).
  tablature('tablature'),

  /// Cornell notes
  cornell('cornell'),

  /// Engineering "graph paper": a 3-tier grid in light gray.
  /// Thin lines every 1 unit (treated as 1mm), medium every 5 units (5mm),
  /// bold every 10 units (10mm). Spacing scales with `lineHeight` where
  /// `lineHeight` represents 5mm.
  mmGraph('mm-graph', requiresClipping: true),

  /// 5x5mm light gray grid.
  /// Lines every `lineHeight` units (treated as 5mm).
  grid5mm('grid-5mm', requiresClipping: true);

  const CanvasBackgroundPattern(this.name, {this.requiresClipping = false});

  /// The pattern name used for serialization.
  /// Do not display this to the user: instead use [localizedName].
  final String name;

  /// Whether this pattern has elements along the page edges that may need to be
  /// clipped.
  final bool requiresClipping;

  static CanvasBackgroundPattern fromName(String? name) {
    return values.firstWhere(
      (pattern) => pattern.name == name,
      orElse: () => CanvasBackgroundPattern.none,
    );
  }
}
