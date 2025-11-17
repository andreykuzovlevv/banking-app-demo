library;

import 'dart:math' as math;
import 'dart:math';

import 'package:banking_app/screens/dashboard/widgets/toggle_modes_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';

// Minimum padding from edges of the segmented control to edges of
// encompassing widget.
const EdgeInsetsGeometry _kHorizontalItemPadding = EdgeInsets.symmetric(
  vertical: 0,
  horizontal: 0,
);

// The corner radius of the segmented control.
const Radius _kCornerRadius = Radius.circular(100);

// Minimum height of the segmented control.
const double _kMinSegmentedControlHeight = 60.0;

const CupertinoDynamicColor _kThumbColor = CupertinoDynamicColor.withBrightness(
  color: Color(0xFFFFFFFF),
  darkColor: Color(0xFF636366),
);

// The minimum scale factor of the thumb, when being pressed on for a sufficient
// amount of time.
const double _kMinThumbScale = 0.9;

// The minimum horizontal distance between the edges of the separator and the
// closest child.
const double _kSegmentMinPadding = 12;

// The threshold value used in hasDraggedTooFar, for checking against the square
// L2 distance from the location of the current drag pointer, to the closest
// vertex of the OverviewToolbar's Rect.
//
// Both the mechanism and the value are speculated.
const double _kTouchYDistanceThreshold = 50.0 * 50.0;

// The minimum opacity of an unselected segment, when the user presses on the
// segment and it starts to fadeout.
//
// Inspected from iOS 17.5 simulator.
const double _kContentPressedMinOpacity = 0.7;

// Inspected from iOS 17.5 simulator.
const double _kFontSize = 15.0;

// Inspected from iOS 17.5 simulator.
const FontWeight _kFontWeight = FontWeight.w500;

// Inspected from iOS 17.5 simulator.
const FontWeight _kHighlightedFontWeight = FontWeight.w600;

// Inspected from iOS 17.5 simulator
const Color _kDisabledContentColor = Color.fromARGB(115, 122, 122, 122);

// Distance content travels during mode transition.
const double _kContentSlideDistance = 20.0;

// The spring animation used when the thumb changes its rect.
final SpringSimulation _kThumbSpringAnimationSimulation = SpringSimulation(
  const SpringDescription(mass: 1, stiffness: 503.551, damping: 44.8799),
  0,
  1,
  0, // Every time a new spring animation starts the previous animation stops.
);

const Duration _kSpringAnimationDuration = Duration(milliseconds: 412);

const Duration _kOpacityAnimationDuration = Duration(milliseconds: 470);

const Duration _kHighlightAnimationDuration = Duration(milliseconds: 200);

class _Segment<T> extends StatefulWidget {
  const _Segment({
    required ValueKey<T> key,
    required this.child,
    required this.pressed,
    required this.highlighted,
    required this.isDragging,
    required this.enabled,
  }) : super(key: key);

  final Widget child;

  final bool pressed;
  final bool highlighted;
  final bool enabled;

  // Whether the thumb of the parent widget (OverviewToolbar)
  // is currently being dragged.
  final bool isDragging;

  bool get shouldFadeoutContent => pressed && !highlighted && enabled;
  bool get shouldScaleContent =>
      pressed && highlighted && isDragging && enabled;

  @override
  _SegmentState<T> createState() => _SegmentState<T>();
}

class _SegmentState<T> extends State<_Segment<T>>
    with TickerProviderStateMixin<_Segment<T>> {
  late final AnimationController highlightPressScaleController;
  late Animation<double> highlightPressScaleAnimation;

  @override
  void initState() {
    super.initState();
    highlightPressScaleController = AnimationController(
      duration: _kOpacityAnimationDuration,
      value: widget.shouldScaleContent ? 1 : 0,
      vsync: this,
    );

    highlightPressScaleAnimation = highlightPressScaleController.drive(
      Tween<double>(begin: 1.0, end: _kMinThumbScale),
    );
  }

  @override
  void didUpdateWidget(_Segment<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(oldWidget.key == widget.key);

    if (oldWidget.shouldScaleContent != widget.shouldScaleContent) {
      highlightPressScaleAnimation = highlightPressScaleController.drive(
        Tween<double>(
          begin: highlightPressScaleAnimation.value,
          end: widget.shouldScaleContent ? _kMinThumbScale : 1.0,
        ),
      );
      highlightPressScaleController.animateWith(
        _kThumbSpringAnimationSimulation,
      );
    }
  }

  @override
  void dispose() {
    highlightPressScaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MetaData(
      // Expand the hitTest area of this widget.
      behavior: HitTestBehavior.opaque,
      child: IndexedStack(
        alignment: Alignment.center,
        children: <Widget>[
          AnimatedOpacity(
            opacity: widget.shouldFadeoutContent
                ? _kContentPressedMinOpacity
                : 1,
            duration: _kOpacityAnimationDuration,
            curve: Curves.ease,
            child: AnimatedDefaultTextStyle(
              style: DefaultTextStyle.of(context).style.merge(
                TextStyle(
                  fontWeight: widget.highlighted
                      ? _kHighlightedFontWeight
                      : _kFontWeight,
                  fontSize: _kFontSize,
                  color: widget.enabled
                      ? (widget.highlighted
                            ? CupertinoDynamicColor.resolve(
                                CupertinoColors.label,
                                context,
                              )
                            : CupertinoDynamicColor.resolve(
                                CupertinoColors.secondaryLabel,
                                context,
                              ))
                      : _kDisabledContentColor,
                ),
              ),
              duration: _kHighlightAnimationDuration,
              curve: Curves.ease,
              child: ScaleTransition(
                alignment: Alignment.center,
                scale: highlightPressScaleAnimation,
                child: widget.child,
              ),
            ),
          ),
          // The entire widget will assume the size of this widget, so when a
          // segment's "highlight" animation plays the size of the parent stays
          // the same and will always be greater than equal to that of the
          // visible child (at index 0), to keep the size of the entire
          // SegmentedControl widget consistent throughout the animation.
          DefaultTextStyle.merge(
            style: const TextStyle(
              fontWeight: _kHighlightedFontWeight,
              fontSize: _kFontSize,
            ),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

class _ActionSegment extends StatelessWidget {
  const _ActionSegment({
    super.key,
    required this.child,
    required this.onPressed,
  });

  final Widget child;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      onTap: onPressed,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Center(
          child: DefaultTextStyle.merge(
            style: const TextStyle(
              fontWeight: _kHighlightedFontWeight,
              fontSize: _kFontSize,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class OverviewToolbar<T extends Object> extends StatefulWidget {
  OverviewToolbar({
    super.key,
    required this.children,
    required this.onValueChanged,
    this.disabledChildren = const <Never>{},
    this.groupValue,
    required this.actionOne,
    required this.onActionOne,
    required this.actionTwo,
    required this.onActionTwo,
    this.thumbColor = _kThumbColor,
    this.padding = _kHorizontalItemPadding,
    this.backgroundColor = CupertinoColors.tertiarySystemFill,
    this.proportionalWidth = false,
    this.onModeChanged,
  }) : assert(children.length >= 2),
       assert(
         groupValue == null || children.keys.contains(groupValue),
         'The groupValue must be either null or one of the keys in the children map.',
       );

  /// The identifying keys and corresponding widget values in the
  /// segmented control.
  ///
  /// This attribute must be an ordered [Map] such as a [LinkedHashMap]. Each
  /// widget is typically a single-line [Text] widget or an [Icon] widget.
  ///
  /// The map must have more than one entry.
  final Map<T, Widget> children;

  /// The set of identifying keys that correspond to the segments that should be
  /// disabled.
  ///
  /// Disabled children cannot be selected by dragging, but they can be selected
  /// programmatically. For example, if the [groupValue] is set to a disabled
  /// segment, the segment is still selected but the segment content looks disabled.
  ///
  /// If an enabled segment is selected by dragging gesture and becomes disabled
  /// before dragging finishes, [onValueChanged] will be triggered when finger is
  /// released and the disabled segment is selected.
  ///
  /// By default, all segments are selectable.
  final Set<T> disabledChildren;

  /// The identifier of the widget that is currently selected.
  ///
  /// This must be one of the keys in the [Map] of [children].
  /// If this attribute is null, no widget will be initially selected.
  final T? groupValue;

  /// The callback that is called when a new option is tapped.
  ///
  final ValueChanged<T?> onValueChanged;

  final Widget actionOne;
  final VoidCallback onActionOne;

  final Widget actionTwo;
  final VoidCallback onActionTwo;

  /// The color used to paint the rounded rect behind the [children] and the separators.
  ///
  /// The default value is [CupertinoColors.tertiarySystemFill]. The background
  /// will not be painted if null is specified.
  final Color backgroundColor;

  /// Determine whether segments have proportional widths based on their content.
  ///
  /// If false, all segments will have the same width, determined by the longest
  /// segment. If true, each segment's width will be determined by its individual
  /// content.
  ///
  /// If the max width of parent constraints is smaller than the width that the
  /// segmented control needs, The segment widths will scale down proportionally
  /// to ensure the segment control fits within the boundaries; similarly, if
  /// the min width of parent constraints is larger, the segment width will scales
  /// up to meet the min width requirement.
  ///
  /// Defaults to false.
  final bool proportionalWidth;

  final ValueChanged<ViewMode>? onModeChanged;

  /// The color used to paint the interior of the thumb that appears behind the
  /// currently selected item.
  ///
  /// The default value is a [CupertinoDynamicColor] that appears white in light
  /// mode and becomes a gray color in dark mode.
  final Color thumbColor;

  /// The amount of space by which to inset the [children].
  ///
  /// Defaults to `EdgeInsets.symmetric(vertical: 2, horizontal: 3)`.
  final EdgeInsetsGeometry padding;

  @override
  State<OverviewToolbar<T>> createState() => _SegmentedControlState<T>();
}

class _SegmentedControlState<T extends Object> extends State<OverviewToolbar<T>>
    with TickerProviderStateMixin<OverviewToolbar<T>> {
  ViewMode viewMode = ViewMode.currency;

  late final AnimationController transitionController = AnimationController(
    duration: const Duration(milliseconds: 500),
    value: 0,
    vsync: this,
  );

  late final Animation<double> viewTransition = CurvedAnimation(
    parent: transitionController,
    curve: Curves.easeInOut,
  );

  late final AnimationController thumbController = AnimationController(
    duration: _kSpringAnimationDuration,
    value: 0,
    vsync: this,
  );
  Animatable<Rect?>? thumbAnimatable;

  late final AnimationController thumbScaleController = AnimationController(
    duration: _kSpringAnimationDuration,
    value: 0,
    vsync: this,
  );
  late Animation<double> thumbScaleAnimation = thumbScaleController.drive(
    Tween<double>(begin: 1, end: _kMinThumbScale),
  );

  final TapGestureRecognizer tap = TapGestureRecognizer();
  final HorizontalDragGestureRecognizer drag =
      HorizontalDragGestureRecognizer();
  final LongPressGestureRecognizer longPress = LongPressGestureRecognizer();
  final GlobalKey segmentedControlRenderWidgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    // If the long press or horizontal drag recognizer gets accepted, we know for
    // sure the gesture is meant for the segmented control. Hand everything to
    // the drag gesture recognizer.
    final GestureArenaTeam team = GestureArenaTeam();
    longPress.team = team;
    drag.team = team;
    team.captain = drag;

    drag
      ..onDown = onDown
      ..onUpdate = onUpdate
      ..onEnd = onEnd
      ..onCancel = onCancel;

    tap.onTapUp = onTapUp;

    // Empty callback to enable the long press recognizer.
    longPress.onLongPress = () {};

    highlighted = widget.groupValue;
  }

  @override
  void didUpdateWidget(OverviewToolbar<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Temporarily ignore highlight changes from the widget when the thumb is
    // being dragged. When the drag gesture finishes the widget will be forced
    // to build (see the onEnd method), and didUpdateWidget will be called again.
    if (!isThumbDragging && highlighted != widget.groupValue) {
      thumbController.animateWith(_kThumbSpringAnimationSimulation);
      thumbAnimatable = null;
      highlighted = widget.groupValue;
    }
  }

  @override
  void dispose() {
    thumbScaleController.dispose();
    thumbController.dispose();

    drag.dispose();
    tap.dispose();
    longPress.dispose();

    super.dispose();
  }

  // Whether the current drag gesture started on a selected segment. When this
  // flag is false, the `onUpdate` method does not update `highlighted`.
  // Otherwise the thumb can be dragged around in an ongoing drag gesture.
  bool? _startedOnSelectedSegment;

  // Whether the current drag gesture started on a disabled segment. When this
  // flag is true, drag gestures will be ignored.
  bool _startedOnDisabledSegment = false;

  // Whether an ongoing horizontal drag gesture that started on the thumb is
  // present. When true, defer/ignore changes to the `highlighted` variable
  // from other sources (except for semantics) until the gesture ends, preventing
  // them from interfering with the active drag gesture.
  bool get isThumbDragging =>
      (_startedOnSelectedSegment ?? false) && !_startedOnDisabledSegment;

  bool get _segmentsInteractive => transitionController.isDismissed;

  // Converts local coordinate to segments.
  T segmentForXPosition(double dx) {
    final BuildContext currentContext =
        segmentedControlRenderWidgetKey.currentContext!;
    final _RenderSegmentedControl<T> renderBox =
        currentContext.findRenderObject()! as _RenderSegmentedControl<T>;

    final int numOfChildren = widget.children.length;
    assert(renderBox.hasSize);
    assert(numOfChildren >= 2);

    int segmentIndex = renderBox.getClosestSegmentIndex(dx);
    switch (Directionality.of(context)) {
      case TextDirection.ltr:
        break;
      case TextDirection.rtl:
        segmentIndex = numOfChildren - 1 - segmentIndex;
    }
    return widget.children.keys.elementAt(segmentIndex);
  }

  bool _hasDraggedTooFar(DragUpdateDetails details) {
    final RenderBox renderBox = context.findRenderObject()! as RenderBox;
    assert(renderBox.hasSize);
    final Size size = renderBox.size;
    final Offset offCenter =
        details.localPosition - Offset(size.width / 2, size.height / 2);
    final double l2 =
        math.pow(math.max(0.0, offCenter.dx.abs() - size.width / 2), 2) +
                math.pow(math.max(0.0, offCenter.dy.abs() - size.height / 2), 2)
            as double;
    return l2 > _kTouchYDistanceThreshold;
  }

  // The thumb shrinks when the user presses on it, and starts expanding when
  // the user lets go.
  // This animation must be synced with the segment scale animation (see the
  // _Segment widget) to make the overall animation look natural when the thumb
  // is not sliding.
  void _playThumbScaleAnimation({required bool isExpanding}) {
    thumbScaleAnimation = thumbScaleController.drive(
      Tween<double>(
        begin: thumbScaleAnimation.value,
        end: isExpanding ? 1 : _kMinThumbScale,
      ),
    );
    thumbScaleController.animateWith(_kThumbSpringAnimationSimulation);
  }

  void _handleModeChanged(ViewMode mode) {
    if (viewMode == mode) {
      return;
    }

    setState(() {
      viewMode = mode;
    });

    widget.onModeChanged?.call(mode);

    if (mode == ViewMode.activity) {
      transitionController.forward();
    } else {
      transitionController.reverse();
    }
  }

  void onHighlightChangedByGesture(T newValue) {
    if (highlighted == newValue) {
      return;
    }

    setState(() {
      highlighted = newValue;
    });
    thumbController.animateWith(_kThumbSpringAnimationSimulation);
    thumbAnimatable = null;
  }

  void onPressedChangedByGesture(T? newValue) {
    if (pressed != newValue) {
      setState(() {
        pressed = newValue;
      });
    }
  }

  void onTapUp(TapUpDetails details) {
    if (!_segmentsInteractive) {
      return;
    }
    // No gesture should interfere with an ongoing thumb drag.
    if (isThumbDragging) {
      return;
    }
    final T segment = segmentForXPosition(details.localPosition.dx);
    onPressedChangedByGesture(null);
    if (segment != widget.groupValue &&
        !widget.disabledChildren.contains(segment)) {
      widget.onValueChanged(segment);
    }
  }

  void onDown(DragDownDetails details) {
    if (!_segmentsInteractive) {
      return;
    }
    final T touchDownSegment = segmentForXPosition(details.localPosition.dx);
    _startedOnSelectedSegment = touchDownSegment == highlighted;
    _startedOnDisabledSegment = widget.disabledChildren.contains(
      touchDownSegment,
    );
    if (widget.disabledChildren.contains(touchDownSegment)) {
      return;
    }
    onPressedChangedByGesture(touchDownSegment);

    if (isThumbDragging) {
      _playThumbScaleAnimation(isExpanding: false);
    }
  }

  void onUpdate(DragUpdateDetails details) {
    if (!_segmentsInteractive) {
      return;
    }
    // If drag gesture starts on disabled segment, no update needed.
    if (_startedOnDisabledSegment) {
      return;
    }

    // If drag gesture starts on enabled segment and dragging on disabled segment,
    // no update needed.
    final T touchDownSegment = segmentForXPosition(details.localPosition.dx);
    if (widget.disabledChildren.contains(touchDownSegment)) {
      return;
    }
    if (isThumbDragging) {
      onPressedChangedByGesture(touchDownSegment);
      onHighlightChangedByGesture(touchDownSegment);
    } else {
      final T? segment = _hasDraggedTooFar(details)
          ? null
          : segmentForXPosition(details.localPosition.dx);
      onPressedChangedByGesture(segment);
    }
  }

  void onEnd(DragEndDetails details) {
    if (!_segmentsInteractive) {
      onPressedChangedByGesture(null);
      _startedOnSelectedSegment = null;
      return;
    }
    final T? pressed = this.pressed;
    if (isThumbDragging) {
      _playThumbScaleAnimation(isExpanding: true);
      if (highlighted != widget.groupValue) {
        widget.onValueChanged(highlighted);
      }
    } else if (pressed != null) {
      onHighlightChangedByGesture(pressed);
      assert(pressed == highlighted);
      if (highlighted != widget.groupValue) {
        widget.onValueChanged(highlighted);
      }
    }

    onPressedChangedByGesture(null);
    _startedOnSelectedSegment = null;
  }

  void onCancel() {
    if (!_segmentsInteractive) {
      onPressedChangedByGesture(null);
      _startedOnSelectedSegment = null;
      return;
    }
    if (isThumbDragging) {
      _playThumbScaleAnimation(isExpanding: true);
    }
    onPressedChangedByGesture(null);
    _startedOnSelectedSegment = null;
  }

  // The segment the sliding thumb is currently located at, or animating to. It
  // may have a different value from widget.groupValue, since this widget does
  // not report a selection change via `onValueChanged` until the user stops
  // interacting with the widget (onTapUp). For example, the user can drag the
  // thumb around, and the `onValueChanged` callback will not be invoked until
  // the thumb is let go.
  T? highlighted;

  // The segment the user is currently pressing.
  T? pressed;

  @override
  Widget build(BuildContext context) {
    assert(widget.children.length >= 2);
    List<Widget> segmentChildren = <Widget>[];
    // bool isPreviousSegmentHighlighted = false;

    int index = 0;
    int? highlightedIndex;
    for (final MapEntry<T, Widget> entry in widget.children.entries) {
      final bool isHighlighted = highlighted == entry.key;
      if (isHighlighted) {
        highlightedIndex = index;
      }

      segmentChildren.add(
        Semantics(
          button: true,
          onTap: () {
            if (widget.disabledChildren.contains(entry.key)) {
              return;
            }
            widget.onValueChanged(entry.key);
          },
          inMutuallyExclusiveGroup: true,
          selected: widget.groupValue == entry.key,
          child: MouseRegion(
            cursor: kIsWeb ? SystemMouseCursors.click : MouseCursor.defer,
            child: _Segment<T>(
              key: ValueKey<T>(entry.key),
              highlighted: isHighlighted,
              pressed: pressed == entry.key,
              isDragging: isThumbDragging,
              enabled: !widget.disabledChildren.contains(entry.key),
              child: entry.value,
            ),
          ),
        ),
      );

      index += 1;
      // isPreviousSegmentHighlighted = isHighlighted;
    }

    assert((highlightedIndex == null) == (highlighted == null));

    switch (Directionality.of(context)) {
      case TextDirection.ltr:
        break;
      case TextDirection.rtl:
        segmentChildren = segmentChildren.reversed.toList(growable: false);
        if (highlightedIndex != null) {
          highlightedIndex = index - 1 - highlightedIndex;
        }
    }

    final List<Widget> actionChildren = <Widget>[
      _ActionSegment(
        key: const ValueKey<String>('action_one'),
        onPressed: widget.onActionOne,
        child: widget.actionOne,
      ),
      _ActionSegment(
        key: const ValueKey<String>('action_two'),
        onPressed: widget.onActionTwo,
        child: widget.actionTwo,
      ),
    ];

    final List<Widget> renderChildren = <Widget>[
      ...segmentChildren,
      ...actionChildren,
    ];

    return Padding(
      padding: widget.padding,
      child: Row(
        children: [
          Expanded(
            child: AnimatedBuilder(
              animation: thumbScaleController,
              builder: (BuildContext context, Widget? child) {
                return _SegmentedControlRenderWidget<T>(
                  key: segmentedControlRenderWidgetKey,
                  highlightedIndex: highlightedIndex,
                  thumbColor: CupertinoDynamicColor.resolve(
                    widget.thumbColor,
                    context,
                  ),
                  backgroundColor: widget.backgroundColor,
                  thumbScale: thumbScaleAnimation.value,
                  proportionalWidth: widget.proportionalWidth,
                  state: this,
                  segmentChildCount: segmentChildren.length,
                  children: renderChildren,
                );
              },
            ),
          ),
          SizedBox(width: 8),
          ToggleModesButton(
            backgroundColor: widget.backgroundColor,
            size: _kMinSegmentedControlHeight,
            onModeChanged: _handleModeChanged,
          ),
        ],
      ),
    );
  }
}

class _SegmentedControlRenderWidget<T extends Object>
    extends MultiChildRenderObjectWidget {
  const _SegmentedControlRenderWidget({
    super.key,
    super.children,
    required this.highlightedIndex,
    required this.thumbColor,
    required this.backgroundColor,
    required this.thumbScale,
    required this.proportionalWidth,
    required this.state,
    required this.segmentChildCount,
  });

  final int? highlightedIndex;
  final Color thumbColor;
  final Color backgroundColor;
  final double thumbScale;
  final bool proportionalWidth;
  final _SegmentedControlState<T> state;
  final int segmentChildCount;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderSegmentedControl<T>(
      highlightedIndex: highlightedIndex,
      thumbColor: thumbColor,
      backgroundColor: backgroundColor,
      thumbScale: thumbScale,
      proportionalWidth: proportionalWidth,
      state: state,
      segmentChildCount: segmentChildCount,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSegmentedControl<T> renderObject,
  ) {
    assert(renderObject.state == state);
    renderObject
      ..thumbColor = thumbColor
      ..backgroundColor = backgroundColor
      ..thumbScale = thumbScale
      ..highlightedIndex = highlightedIndex
      ..proportionalWidth = proportionalWidth
      ..segmentChildCount = segmentChildCount;
  }
}

class _SegmentedControlContainerBoxParentData
    extends ContainerBoxParentData<RenderBox> {}

// The behavior of a UISegmentedControl as observed on iOS 13.1:
//
// 1. Tap up inside events will set the current selected index to the index of the
//    segment at the tap up location instantaneously (there might be animation but
//    the index change seems to happen before animation finishes), unless the tap
//    down event from the same touch event didn't happen within the segmented
//    control, in which case the touch event will be ignored entirely (will be
//    referring to these touch events as invalid touch events below).
//
// 2. A valid tap up event will also trigger the sliding CASpringAnimation (even
//    when it lands on the current segment), starting from the current `frame`
//    of the thumb. The previous sliding animation, if still playing, will be
//    removed and its velocity reset to 0. The sliding animation has a fixed
//    duration, regardless of the distance or transform.
//
// 3. When the sliding animation plays two other animations take place. In one animation
//    the content of the current segment gradually becomes "highlighted", turning the
//    font weight to semibold (CABasicAnimation, timingFunction = default, duration = 0.2).
//    The other is the separator fadein/fadeout animation (duration = 0.41).
//
// 4. A tap down event on the segment pointed to by the current selected
//    index will trigger a CABasicAnimation that shrinks the thumb to 95% of its
//    original size, even if the sliding animation is still playing. The
///   corresponding tap up event inverts the process (eyeballed).
//
// 5. A tap down event on other segments will trigger a CABasicAnimation
//    (timingFunction = default, duration = 0.47.) that fades out the content
//    from its current alpha, eventually reducing the alpha of that segment to
//    20% unless interrupted by a tap up event or the pointer moves out of the
//    region (either outside of the segmented control's vicinity or to a
//    different segment). The reverse animation has the same duration and timing
//    function.
class _RenderSegmentedControl<T extends Object> extends RenderBox
    with
        ContainerRenderObjectMixin<
          RenderBox,
          ContainerBoxParentData<RenderBox>
        >,
        RenderBoxContainerDefaultsMixin<
          RenderBox,
          ContainerBoxParentData<RenderBox>
        > {
  _RenderSegmentedControl({
    required int? highlightedIndex,
    required Color thumbColor,
    required Color backgroundColor,
    required double thumbScale,
    required bool proportionalWidth,
    required int segmentChildCount,
    required this.state,
  }) : _highlightedIndex = highlightedIndex,
       _thumbColor = thumbColor,
       _backgroundColor = backgroundColor,
       _thumbScale = thumbScale,
       _proportionalWidth = proportionalWidth,
       _segmentChildCount = segmentChildCount;

  final _SegmentedControlState<T> state;

  // The current **Unscaled** Thumb Rect in this RenderBox's coordinate space.
  Rect? currentThumbRect;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    state.thumbController.addListener(markNeedsPaint);
    state.transitionController.addListener(_handleTransitionChanged);
  }

  @override
  void detach() {
    state.thumbController.removeListener(markNeedsPaint);
    state.transitionController.removeListener(_handleTransitionChanged);
    super.detach();
  }

  void _handleTransitionChanged() {
    if (!attached) {
      return;
    }
    markNeedsPaint();
  }

  double get thumbScale => _thumbScale;
  double _thumbScale;
  set thumbScale(double value) {
    if (_thumbScale == value) {
      return;
    }

    _thumbScale = value;
    if (state.highlighted != null) {
      markNeedsPaint();
    }
  }

  int? get highlightedIndex => _highlightedIndex;
  int? _highlightedIndex;
  set highlightedIndex(int? value) {
    if (_highlightedIndex == value) {
      return;
    }

    _highlightedIndex = value;
    markNeedsPaint();
  }

  Color get thumbColor => _thumbColor;
  Color _thumbColor;
  set thumbColor(Color value) {
    if (_thumbColor == value) {
      return;
    }
    _thumbColor = value;
    markNeedsPaint();
  }

  Color get backgroundColor => _backgroundColor;
  Color _backgroundColor;
  set backgroundColor(Color value) {
    if (_backgroundColor == value) {
      return;
    }
    _backgroundColor = value;
    markNeedsPaint();
  }

  bool get proportionalWidth => _proportionalWidth;
  bool _proportionalWidth;
  set proportionalWidth(bool value) {
    if (_proportionalWidth == value) {
      return;
    }
    _proportionalWidth = value;
    markNeedsLayout();
  }

  double get transitionValue => state.viewTransition.value;

  int get segmentChildCount => _segmentChildCount;
  int _segmentChildCount;
  set segmentChildCount(int value) {
    if (_segmentChildCount == value) {
      return;
    }
    _segmentChildCount = value;
    markNeedsLayout();
  }

  int get _actionChildCount => math.max(childCount - segmentChildCount, 0);

  Iterable<RenderBox> _segmentChildren() sync* {
    RenderBox? child = firstChild;
    int index = 0;
    while (child != null && index < segmentChildCount) {
      yield child;
      child = childAfter(child);
      index++;
    }
  }

  Iterable<RenderBox> _actionChildren() sync* {
    RenderBox? child = firstChild;
    int index = 0;
    while (child != null) {
      if (index >= segmentChildCount) {
        yield child;
      }
      child = childAfter(child);
      index++;
    }
  }

  double _sumList(List<double> values) {
    double total = 0;
    for (final double value in values) {
      total += value;
    }
    return total;
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    // No gesture should interfere with an ongoing thumb drag.
    if (event is PointerDownEvent &&
        !state.isThumbDragging &&
        state.transitionController.isDismissed) {
      state.tap.addPointer(event);
      state.longPress.addPointer(event);
      state.drag.addPointer(event);
    }
  }

  int getClosestSegmentIndex(double dx) {
    int index = 0;
    for (final RenderBox child in _segmentChildren()) {
      final _SegmentedControlContainerBoxParentData childParentData =
          child.parentData! as _SegmentedControlContainerBoxParentData;
      final double clampX = clampDouble(
        dx,
        childParentData.offset.dx,
        child.size.width + childParentData.offset.dx,
      );

      if (dx <= clampX) {
        break;
      }

      index++;
    }

    final int segmentCount = segmentChildCount;
    // When the thumb is dragging out of bounds, the return result must be
    // smaller than segment count.
    return min(index, segmentCount - 1);
  }

  // RenderBox? childAfter(RenderBox child) {
  //   final RenderBox? nextChild = childAfter(child);
  //   return nextChild == null ? null : childAfter(nextChild);
  // }

  @override
  double computeMinIntrinsicWidth(double height) {
    double maxMinChildWidth = 0;
    for (final RenderBox child in _segmentChildren()) {
      final double childWidth = child.getMinIntrinsicWidth(height);
      maxMinChildWidth = math.max(maxMinChildWidth, childWidth);
    }
    return (maxMinChildWidth + 2 * _kSegmentMinPadding) * segmentChildCount;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    double maxMaxChildWidth = 0;
    for (final RenderBox child in _segmentChildren()) {
      final double childWidth = child.getMaxIntrinsicWidth(height);
      maxMaxChildWidth = math.max(maxMaxChildWidth, childWidth);
    }
    return (maxMaxChildWidth + 2 * _kSegmentMinPadding) * segmentChildCount;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    double maxMinChildHeight = _kMinSegmentedControlHeight;
    for (final RenderBox child in _segmentChildren()) {
      final double childHeight = child.getMinIntrinsicHeight(width);
      maxMinChildHeight = math.max(maxMinChildHeight, childHeight);
    }
    return maxMinChildHeight;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    double maxMaxChildHeight = _kMinSegmentedControlHeight;
    for (final RenderBox child in _segmentChildren()) {
      final double childHeight = child.getMaxIntrinsicHeight(width);
      maxMaxChildHeight = math.max(maxMaxChildHeight, childHeight);
    }
    return maxMaxChildHeight;
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToHighestActualBaseline(baseline);
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _SegmentedControlContainerBoxParentData) {
      child.parentData = _SegmentedControlContainerBoxParentData();
    }
  }

  double _getMaxSegmentChildHeight(double childWidth) {
    double maxHeight = _kMinSegmentedControlHeight;
    for (final RenderBox child in _segmentChildren()) {
      final double boxHeight = child.getMaxIntrinsicHeight(childWidth);
      maxHeight = math.max(maxHeight, boxHeight);
    }
    return maxHeight;
  }

  List<double> _getSegmentChildWidths(BoxConstraints constraints) {
    if (segmentChildCount == 0) {
      return <double>[];
    }

    // Use all available width and distribute it across segments
    final double availableWidth = constraints.maxWidth.isFinite
        ? constraints.maxWidth
        : constraints.minWidth;
    final double segmentWidth = availableWidth / segmentChildCount;

    if (!proportionalWidth) {
      return List<double>.filled(segmentChildCount, segmentWidth);
    }

    // For proportional width, calculate intrinsic widths first
    final List<double> segmentWidths = <double>[];
    for (final RenderBox child in _segmentChildren()) {
      final double childWidth =
          child.getMaxIntrinsicWidth(double.infinity) + 2 * _kSegmentMinPadding;
      segmentWidths.add(childWidth);
    }

    final double totalIntrinsicWidth = _sumList(segmentWidths);

    // Scale to fit available width
    if (totalIntrinsicWidth > 0) {
      final double scale = availableWidth / totalIntrinsicWidth;
      for (int i = 0; i < segmentWidths.length; i++) {
        segmentWidths[i] = segmentWidths[i] * scale;
      }
    } else {
      // Fallback to equal distribution
      return List<double>.filled(segmentChildCount, segmentWidth);
    }

    return segmentWidths;
  }

  Size _computeOverallSize(BoxConstraints constraints) {
    final double maxChildHeight = _getMaxSegmentChildHeight(
      constraints.maxWidth.isFinite
          ? constraints.maxWidth
          : constraints.minWidth,
    );
    // Use all available width
    final double totalWidth = constraints.maxWidth.isFinite
        ? constraints.maxWidth
        : constraints.minWidth;
    return constraints.constrain(Size(totalWidth, maxChildHeight));
  }

  @override
  double? computeDryBaseline(
    covariant BoxConstraints constraints,
    TextBaseline baseline,
  ) {
    final List<double> segmentWidths = _getSegmentChildWidths(constraints);
    final double childHeight = _getMaxSegmentChildHeight(
      constraints.maxWidth.isFinite
          ? constraints.maxWidth
          : constraints.minWidth,
    );

    int index = 0;
    BaselineOffset baselineOffset = BaselineOffset.noBaseline;
    for (final RenderBox child in _segmentChildren()) {
      final BoxConstraints childConstraints = BoxConstraints.tight(
        Size(segmentWidths[index], childHeight),
      );
      baselineOffset = baselineOffset.minOf(
        BaselineOffset(child.getDryBaseline(childConstraints, baseline)),
      );

      index++;
    }

    return baselineOffset.offset;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _computeOverallSize(constraints);
  }

  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    final List<double> segmentWidths = _getSegmentChildWidths(constraints);

    final double segmentHeight = _getMaxSegmentChildHeight(double.infinity);

    RenderBox? child = firstChild;
    int index = 0;
    double start = 0;
    while (child != null && index < segmentChildCount) {
      final BoxConstraints childConstraints = BoxConstraints.tight(
        Size(segmentWidths[index], segmentHeight),
      );
      child.layout(childConstraints, parentUsesSize: true);
      final _SegmentedControlContainerBoxParentData childParentData =
          child.parentData! as _SegmentedControlContainerBoxParentData;
      childParentData.offset = Offset(start, 0);
      start += child.size.width;

      child = childAfter(child);
      index += 1;
    }

    size = _computeOverallSize(constraints);

    if (_actionChildCount > 0) {
      // Position actions at leftmost and rightmost edges
      final List<RenderBox> actionList = _actionChildren().toList();
      if (actionList.length == 2) {
        // First action at leftmost (0)
        final RenderBox firstAction = actionList[0];
        final double firstActionWidth = math.min(
          firstAction.getMaxIntrinsicWidth(double.infinity) +
              2 * _kSegmentMinPadding,
          size.width / 2, // Don't exceed half width
        );
        final BoxConstraints firstActionConstraints = BoxConstraints.tight(
          Size(firstActionWidth, size.height),
        );
        firstAction.layout(firstActionConstraints, parentUsesSize: true);
        final _SegmentedControlContainerBoxParentData firstActionParentData =
            firstAction.parentData! as _SegmentedControlContainerBoxParentData;
        firstActionParentData.offset = Offset(0, 0);

        // Last action at rightmost, centered in the square background
        final RenderBox lastAction = actionList[1];
        final double lastActionWidth = math.min(
          lastAction.getMaxIntrinsicWidth(double.infinity) +
              2 * _kSegmentMinPadding,
          size.width / 2, // Don't exceed half width
        );
        final BoxConstraints lastActionConstraints = BoxConstraints.tight(
          Size(lastActionWidth, size.height),
        );
        lastAction.layout(lastActionConstraints, parentUsesSize: true);
        final _SegmentedControlContainerBoxParentData lastActionParentData =
            lastAction.parentData! as _SegmentedControlContainerBoxParentData;
        // Center the action within the square background at the right edge
        final double squareSize = size.height;
        final double actionCenterX = size.width - squareSize / 2;
        lastActionParentData.offset = Offset(
          actionCenterX - lastActionWidth / 2,
          0,
        );
      } else {
        // Fallback for other cases (shouldn't happen with 2 actions)
        double left = 0;
        double right = size.width;
        while (child != null) {
          final RenderBox? nextChild = childAfter(child);
          final bool isLastAction = nextChild == null;
          final double desiredWidth = math.min(
            child.getMaxIntrinsicWidth(double.infinity) +
                2 * _kSegmentMinPadding,
            size.width,
          );
          final double remainingWidth = math.max(right - left, 0);
          final double actionWidth = math.min(desiredWidth, remainingWidth);
          final BoxConstraints actionConstraints = BoxConstraints.tight(
            Size(actionWidth, size.height),
          );
          child.layout(actionConstraints, parentUsesSize: true);
          final _SegmentedControlContainerBoxParentData childParentData =
              child.parentData! as _SegmentedControlContainerBoxParentData;
          if (isLastAction) {
            // Center the last action within the square background at the right edge
            final double squareSize = size.height;
            final double actionCenterX = size.width - squareSize / 2;
            childParentData.offset = Offset(actionCenterX - actionWidth / 2, 0);
          } else {
            childParentData.offset = Offset(left, 0);
            left += actionWidth;
          }
          child = nextChild;
        }
      }
    }
  }

  // This method is used to convert the original unscaled thumb rect painted in
  // the previous frame, to a Rect that is within the valid boundary defined by
  // the child segments.
  //
  // The overall size does not include that of the thumb. That is, if the thumb
  // is located at the first or the last segment, the thumb can get cut off if
  // one of the values in _kThumbInsets is positive.
  Rect? moveThumbRectInBound(Rect? thumbRect, List<RenderBox> children) {
    assert(hasSize);
    assert(children.length >= 2);
    if (thumbRect == null) {
      return null;
    }

    final Offset firstChildOffset =
        (children.first.parentData! as _SegmentedControlContainerBoxParentData)
            .offset;
    final double leftMost = firstChildOffset.dx;
    final double rightMost =
        (children.last.parentData! as _SegmentedControlContainerBoxParentData)
            .offset
            .dx +
        children.last.size.width;
    assert(rightMost > leftMost);

    // Ignore the horizontal position and the height of `thumbRect`, and
    // calculates them from `children`.
    return Rect.fromLTRB(
      math.max(thumbRect.left, leftMost),
      firstChildOffset.dy,
      math.min(thumbRect.right, rightMost),
      firstChildOffset.dy + children.first.size.height,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final List<RenderBox> segmentChildren = _segmentChildren().toList(
      growable: false,
    );
    final List<RenderBox> actionChildren = _actionChildren().toList(
      growable: false,
    );
    final List<RenderBox> allChildren = <RenderBox>[
      ...segmentChildren,
      ...actionChildren,
    ];

    final Rect backgroundRect = Offset.zero & size;
    Rect resolvedBackgroundRect = backgroundRect;
    if (actionChildren.isNotEmpty) {
      final RenderBox backgroundTarget = actionChildren.last;
      final double squareSize = backgroundTarget.size.height;
      // Position the square at the right edge
      final Rect actionBackgroundRect = Rect.fromLTWH(
        size.width - squareSize,
        0,
        squareSize,
        squareSize,
      );
      resolvedBackgroundRect =
          Rect.lerp(backgroundRect, actionBackgroundRect, transitionValue) ??
          backgroundRect;
    }
    _paintBackground(context, offset, resolvedBackgroundRect);

    final double segmentPhase = clampDouble(transitionValue * 2, 0, 1);
    final double actionPhase = clampDouble((transitionValue - 0.5) * 2, 0, 1);
    final double segmentOpacity = 1 - segmentPhase;
    final double actionOpacity = actionPhase;
    final Offset segmentTranslation = Offset(
      segmentPhase * _kContentSlideDistance,
      0,
    );
    final Offset actionTranslation = Offset(
      -(1 - actionPhase) * _kContentSlideDistance,
      0,
    );

    final int? highlightedChildIndex = highlightedIndex;
    // Paint thumb if there's a highlighted segment.
    if (highlightedChildIndex != null &&
        highlightedChildIndex < segmentChildren.length) {
      final RenderBox selectedChild = segmentChildren[highlightedChildIndex];

      final _SegmentedControlContainerBoxParentData childParentData =
          selectedChild.parentData! as _SegmentedControlContainerBoxParentData;
      final Rect segmentThumbRect = childParentData.offset & selectedChild.size;
      Rect? actionThumbRect;
      if (actionChildren.isNotEmpty) {
        final RenderBox actionThumbChild = actionChildren.first;
        final _SegmentedControlContainerBoxParentData actionParentData =
            actionThumbChild.parentData!
                as _SegmentedControlContainerBoxParentData;
        actionThumbRect = actionParentData.offset & actionThumbChild.size;
      }
      final Rect targetThumbRect = actionThumbRect == null
          ? segmentThumbRect
          : (Rect.lerp(segmentThumbRect, actionThumbRect, transitionValue) ??
                segmentThumbRect);
      final List<RenderBox> thumbBounds = allChildren;

      // Update thumb animation's tween, in case the end rect changed (e.g., a
      // new segment is added during the animation).
      if (state.thumbController.isAnimating) {
        final Animatable<Rect?>? thumbTween = state.thumbAnimatable;
        if (thumbTween == null) {
          // This is the first frame of the animation.
          final Rect startingRect =
              moveThumbRectInBound(currentThumbRect, thumbBounds) ??
              targetThumbRect;
          state.thumbAnimatable = RectTween(
            begin: startingRect,
            end: targetThumbRect,
          );
        } else if (targetThumbRect != thumbTween.transform(1)) {
          // The thumbTween of the running sliding animation needs updating,
          // without restarting the animation.
          final Rect startingRect =
              moveThumbRectInBound(currentThumbRect, thumbBounds) ??
              targetThumbRect;
          state.thumbAnimatable = RectTween(
            begin: startingRect,
            end: targetThumbRect,
          ).chain(CurveTween(curve: Interval(state.thumbController.value, 1)));
        }
      } else {
        state.thumbAnimatable = null;
      }

      final Rect unscaledThumbRect =
          state.thumbAnimatable?.evaluate(state.thumbController) ??
          targetThumbRect;
      currentThumbRect = unscaledThumbRect;

      final Rect thumbRect = Rect.fromCenter(
        center: unscaledThumbRect.center,
        width: unscaledThumbRect.width * thumbScale,
        height: unscaledThumbRect.height * thumbScale,
      );

      _paintThumb(context, offset, thumbRect);
    } else {
      currentThumbRect = null;
    }

    void paintGroup(List<RenderBox> group, double opacity, Offset translation) {
      if (opacity <= 0) {
        return;
      }
      for (final RenderBox child in group) {
        _paintChildWithOpacity(context, offset, child, opacity, translation);
      }
    }

    final bool segmentsOnTop = segmentOpacity >= actionOpacity;
    if (segmentsOnTop) {
      paintGroup(actionChildren, actionOpacity, actionTranslation);
      paintGroup(segmentChildren, segmentOpacity, segmentTranslation);
    } else {
      paintGroup(segmentChildren, segmentOpacity, segmentTranslation);
      paintGroup(actionChildren, actionOpacity, actionTranslation);
    }
  }

  void _paintChildWithOpacity(
    PaintingContext context,
    Offset offset,
    RenderBox child,
    double opacity,
    Offset translation,
  ) {
    if (opacity <= 0) {
      return;
    }
    final _SegmentedControlContainerBoxParentData childParentData =
        child.parentData! as _SegmentedControlContainerBoxParentData;
    final Offset childOffset = childParentData.offset + offset + translation;
    if (opacity >= 1) {
      context.paintChild(child, childOffset);
      return;
    }
    context.pushOpacity(childOffset, (opacity * 255).round().clamp(0, 255), (
      PaintingContext context,
      Offset paintOffset,
    ) {
      context.paintChild(child, paintOffset);
    });
  }

  void _paintThumb(PaintingContext context, Offset offset, Rect thumbRect) {
    final RRect thumbShape = RRect.fromRectAndRadius(
      thumbRect.shift(offset),
      _kCornerRadius,
    );
    // Interpolate thumb color from normal thumbColor to backgroundColor during transition
    final Color interpolatedThumbColor =
        Color.lerp(thumbColor, backgroundColor, transitionValue) ?? thumbColor;

    context.canvas.drawRRect(
      thumbShape,
      Paint()..color = interpolatedThumbColor,
    );
  }

  void _paintBackground(
    PaintingContext context,
    Offset offset,
    Rect backgroundRect,
  ) {
    final RRect thumbShape = RRect.fromRectAndRadius(
      backgroundRect.shift(offset),
      _kCornerRadius,
    );

    context.canvas.drawRRect(thumbShape, Paint()..color = backgroundColor);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    bool hitGroup(List<RenderBox> children, double opacity) {
      if (opacity <= 0) {
        return false;
      }
      for (int index = children.length - 1; index >= 0; index--) {
        final RenderBox child = children[index];
        final _SegmentedControlContainerBoxParentData childParentData =
            child.parentData! as _SegmentedControlContainerBoxParentData;
        if ((childParentData.offset & child.size).contains(position)) {
          final bool isHit = result.addWithPaintOffset(
            offset: childParentData.offset,
            position: position,
            hitTest: (BoxHitTestResult result, Offset localOffset) {
              assert(localOffset == position - childParentData.offset);
              return child.hitTest(result, position: localOffset);
            },
          );
          if (isHit) {
            return true;
          }
        }
      }
      return false;
    }

    final List<RenderBox> segmentChildren = _segmentChildren().toList(
      growable: false,
    );
    final List<RenderBox> actionChildren = _actionChildren().toList(
      growable: false,
    );

    final double segmentOpacity = clampDouble(1 - transitionValue, 0, 1);
    final double actionOpacity = clampDouble(transitionValue, 0, 1);

    final bool segmentsOnTop = segmentOpacity >= actionOpacity;
    final List<RenderBox> topGroup = segmentsOnTop
        ? segmentChildren
        : actionChildren;
    final List<RenderBox> bottomGroup = segmentsOnTop
        ? actionChildren
        : segmentChildren;
    final double topOpacity = segmentsOnTop ? segmentOpacity : actionOpacity;
    final double bottomOpacity = segmentsOnTop ? actionOpacity : segmentOpacity;

    if (hitGroup(topGroup, topOpacity)) {
      return true;
    }
    return hitGroup(bottomGroup, bottomOpacity);
  }
}
