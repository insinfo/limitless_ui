import 'package:ngdart/angular.dart';

import 'progress_component.dart';

/// Limitless/Bootstrap progress bar.
@Component(
  selector: 'li-progress-bar',
  templateUrl: 'progress_bar_component.html',
  styleUrls: ['progress_bar_component.css'],
  directives: [coreDirectives],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiProgressBarComponent {
  LiProgressComponent? parent;

  /// Current value represented by this bar.
  @Input()
  num value = 0;

  /// Optional bar-specific minimum value.
  @Input()
  num? min;

  /// Optional bar-specific maximum value.
  @Input()
  num? max;

  /// Enables striped styling for this specific bar.
  @Input()
  bool? striped;

  /// Enables animated stripes for this specific bar.
  @Input()
  bool? animated;

  /// Optional text label rendered inside the bar.
  @Input()
  String? label;

  /// Renders the resolved percentage as text when no explicit label is set.
  @Input()
  bool showValueLabel = false;

  @HostBinding('class.progress-bar')
  bool hostProgressBarClass = true;

  @HostBinding('class.progress-bar-striped')
  bool get hostStripedClass => resolvedStriped;

  @HostBinding('class.progress-bar-animated')
  bool get hostAnimatedClass => resolvedAnimated;

  @HostBinding('attr.role')
  String hostRole = 'progressbar';

  @HostBinding('attr.aria-valuenow')
  String get ariaValueNow => _formatNumber(normalizedValue);

  @HostBinding('attr.aria-valuemin')
  String get ariaValueMin => _formatNumber(resolvedMin);

  @HostBinding('attr.aria-valuemax')
  String get ariaValueMax => _formatNumber(resolvedMax);

  @HostBinding('style.width')
  String get hostWidth => '${widthPercent.toStringAsFixed(2)}%';

  num get resolvedMin => min ?? parent?.min ?? 0;

  num get resolvedMax => max ?? parent?.max ?? 100;

  bool get resolvedStriped => striped ?? parent?.striped ?? false;

  bool get resolvedAnimated => animated ?? parent?.animated ?? false;

  num get normalizedMax {
    final currentMin = resolvedMin;
    final currentMax = resolvedMax;
    if (currentMax <= currentMin) {
      return currentMin + 1;
    }

    return currentMax;
  }

  num get normalizedValue {
    final currentMin = resolvedMin;
    final currentMax = normalizedMax;
    final currentValue = value;
    if (currentValue < currentMin) {
      return currentMin;
    }
    if (currentValue > currentMax) {
      return currentMax;
    }
    return currentValue;
  }

  double get widthPercent {
    final currentMin = resolvedMin.toDouble();
    final currentMax = normalizedMax.toDouble();
    final range = currentMax - currentMin;
    if (range <= 0) {
      return 0;
    }

    final progress = (normalizedValue.toDouble() - currentMin) / range;
    return (progress * 100).clamp(0, 100).toDouble();
  }

  bool get hasLabel => resolvedLabel != null;

  String? get resolvedLabel {
    final currentLabel = label?.trim();
    if (currentLabel != null && currentLabel.isNotEmpty) {
      return currentLabel;
    }

    if (!showValueLabel) {
      return null;
    }

    return '${widthPercent.round()}%';
  }

  String _formatNumber(num number) {
    if (number == number.roundToDouble()) {
      return number.toInt().toString();
    }

    return number.toString();
  }
}