import 'package:ngdart/angular.dart';

import 'progress_bar_component.dart';

/// Public directives used by the progress component suite.
const liProgressDirectives = <Object>[
  LiProgressComponent,
  LiProgressBarComponent,
];

/// Limitless/Bootstrap progress container.
@Component(
  selector: 'li-progress',
  templateUrl: 'progress_component.html',
  styleUrls: ['progress_component.css'],
  directives: [coreDirectives, LiProgressBarComponent],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiProgressComponent implements AfterContentInit {
  @ContentChildren(LiProgressBarComponent)
  List<LiProgressBarComponent> bars = <LiProgressBarComponent>[];

  /// Minimum value used by child bars when they don't define their own range.
  @Input()
  num min = 0;

  /// Maximum value used by child bars when they don't define their own range.
  @Input()
  num max = 100;

  /// Applies Limitless/Bootstrap rounded-pill styling to the track.
  @Input()
  bool rounded = false;

  /// Enables striped styling for all bars that don't override it locally.
  @Input()
  bool striped = false;

  /// Enables animated stripes for all bars that don't override it locally.
  @Input()
  bool animated = false;

  /// Custom CSS height for the progress track, e.g. 0.375rem or 24px.
  @Input()
  String? height;

  @HostBinding('class.progress')
  bool hostProgressClass = true;

  @HostBinding('class.rounded-pill')
  bool get hostRoundedClass => rounded;

  @HostBinding('style.height')
  String? get hostHeight => _normalizedHeight;

  String? get _normalizedHeight {
    final currentHeight = height?.trim();
    if (currentHeight == null || currentHeight.isEmpty) {
      return null;
    }

    return currentHeight;
  }

  @override
  void ngAfterContentInit() {
    for (final bar in bars) {
      bar.parent = this;
    }
  }
}