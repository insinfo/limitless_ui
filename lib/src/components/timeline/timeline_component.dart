import 'package:ngdart/angular.dart';

const liTimelineDirectives = <Object>[
  LiTimelineComponent,
  LiTimelineItemComponent,
  LiTimelineDateComponent,
  LiTimelineContentDirective,
  LiTimelineIconDirective,
  LiTimelineTimeDirective,
];

@Directive(selector: '[liTimelineContent]')
class LiTimelineContentDirective {}

@Directive(selector: '[liTimelineIcon]')
class LiTimelineIconDirective {}

@Directive(selector: '[liTimelineTime]')
class LiTimelineTimeDirective {}

@Component(
  selector: 'li-timeline',
  templateUrl: 'timeline_component.html',
  styleUrls: ['timeline_component.css'],
  directives: [coreDirectives],
  encapsulation: ViewEncapsulation.none,
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiTimelineComponent {
  @Input()
  String mode = 'start';

  @Input()
  String timelineClass = '';

  @Input()
  String lineColor = '';

  @Input()
  String lineWidth = '';

  @Input()
  String iconSize = '';

  @Input()
  String iconBackground = '';

  @Input()
  String contentPaddingX = '';

  @HostBinding('class')
  String get hostClass => _joinClasses(<String>[
        'timeline',
        resolvedModeClass,
        timelineClass,
      ]);

  @HostBinding('style.--timeline-line-color')
  String? get hostLineColor => _styleValue(lineColor);

  @HostBinding('style.--timeline-line-width')
  String? get hostLineWidth => _styleValue(lineWidth);

  @HostBinding('style.--timeline-icon-size')
  String? get hostIconSize => _styleValue(iconSize);

  @HostBinding('style.--timeline-icon-bg')
  String? get hostIconBackground => _styleValue(iconBackground);

  @HostBinding('style.--timeline-content-padding-x')
  String? get hostContentPaddingX => _styleValue(contentPaddingX);

  bool get isCentered => resolvedModeClass == 'timeline-center';

  String get resolvedModeClass {
    switch (mode.trim().toLowerCase()) {
      case 'start':
      case 'left':
      case 'end':
      case 'right':
        return mode.trim().toLowerCase() == 'end' ||
                mode.trim().toLowerCase() == 'right'
            ? 'timeline-end'
            : 'timeline-start';
      case 'center':
      case 'centered':
        return 'timeline-center';
      default:
        return 'timeline-start';
    }
  }

  String? _styleValue(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

@Component(
  selector: 'li-timeline-date',
  template: '<ng-content></ng-content>',
  styleUrls: ['timeline_component.css'],
  encapsulation: ViewEncapsulation.none,
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiTimelineDateComponent {
  LiTimelineDateComponent([@Host() @Optional() this.timeline]);

  final LiTimelineComponent? timeline;

  @Input()
  String dateClass = '';

  @HostBinding('class')
  String get hostClass => _joinClasses(<String>[
        'timeline-date',
        'text-muted',
        dateClass,
      ]);

  @HostBinding('style.text-align')
  String? get hostTextAlign {
    if (_isStartTimeline) {
      return 'left';
    }
    if (_isEndTimeline) {
      return 'right';
    }
    return null;
  }

  @HostBinding('style.padding')
  String? get hostPadding => _hasEdgeAlignedLayout ? '0' : null;

  @HostBinding('style.padding-top')
  String? get hostPaddingTop => _hasEdgeAlignedLayout ? '0.5rem' : null;

  @HostBinding('style.padding-bottom')
  String? get hostPaddingBottom => _hasEdgeAlignedLayout ? '0.5rem' : null;

  @HostBinding('style.padding-left')
  String? get hostPaddingLeft => _isStartTimeline ? '0.5rem' : null;

  @HostBinding('style.padding-right')
  String? get hostPaddingRight => _isEndTimeline ? '0.5rem' : null;

  bool get _hasEdgeAlignedLayout => _isStartTimeline || _isEndTimeline;

  bool get _isStartTimeline => timeline?.resolvedModeClass == 'timeline-start';

  bool get _isEndTimeline => timeline?.resolvedModeClass == 'timeline-end';
}

@Component(
  selector: 'li-timeline-item',
  templateUrl: 'timeline_item_component.html',
  styleUrls: ['timeline_component.css'],
  directives: [coreDirectives],
  encapsulation: ViewEncapsulation.none,
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiTimelineItemComponent {
  LiTimelineItemComponent([@Host() @Optional() this.timeline]);

  final LiTimelineComponent? timeline;

  @ContentChild(LiTimelineContentDirective)
  LiTimelineContentDirective? projectedContent;

  @ContentChild(LiTimelineIconDirective)
  LiTimelineIconDirective? projectedIcon;

  @ContentChild(LiTimelineTimeDirective)
  LiTimelineTimeDirective? projectedTime;

  @Input()
  String alignment = 'start';

  @Input()
  String rowClass = '';

  @Input()
  String contentClass = '';

  @Input()
  String cardClass = '';

  @Input()
  bool card = true;

  @Input()
  String title = '';

  @Input()
  String subtitle = '';

  @Input()
  String description = '';

  @Input()
  String timeLabel = '';

  @Input()
  String iconClass = '';

  @Input()
  String iconContainerClass = '';

  @Input()
  String iconImageUrl = '';

  @Input()
  String iconImageAlt = '';

  @Input()
  String iconText = '';

  @HostBinding('class')
  String get hostClass => _joinClasses(<String>[
        'timeline-row',
        if (_shouldApplyCenteredAlignment) resolvedAlignmentClass,
        rowClass,
      ]);

  bool get hasProjectedContent => projectedContent != null;

  bool get hasProjectedIcon => projectedIcon != null;

  bool get hasProjectedTime => projectedTime != null;

  bool get hasTime => hasProjectedTime || timeLabel.trim().isNotEmpty;

  bool get hasDefaultContent =>
      title.trim().isNotEmpty ||
      subtitle.trim().isNotEmpty ||
      description.trim().isNotEmpty;

  bool get shouldRenderDefaultCard => !hasProjectedContent && card && hasDefaultContent;

  bool get shouldRenderDefaultPlain =>
      !hasProjectedContent && !card && hasDefaultContent;

  bool get hasIconImage => iconImageUrl.trim().isNotEmpty;

  bool get hasIconClass => iconClass.trim().isNotEmpty;

  bool get hasIconText => iconText.trim().isNotEmpty;

  bool get shouldRenderDefaultIcon =>
      !hasProjectedIcon && (hasIconImage || hasIconClass || hasIconText);

  String get resolvedAlignmentClass {
    switch (alignment.trim().toLowerCase()) {
      case 'end':
      case 'right':
        return 'timeline-row-end';
      case 'full':
      case 'center':
        return 'timeline-row-full';
      default:
        return 'timeline-row-start';
    }
  }

  String get resolvedCardClass => _joinClasses(<String>[
        'card',
        cardClass,
      ]);

  String get resolvedPlainClass => _joinClasses(<String>[
        'li-timeline-item__plain',
        contentClass,
      ]);

  String get resolvedCardBodyClass => _joinClasses(<String>[
        'card-body',
        contentClass,
      ]);

  String get resolvedIconInnerClass {
    return _joinClasses(<String>[
      'li-timeline-item__icon-inner',
      iconContainerClass,
    ]);
  }

  String get resolvedIconImageAlt {
    final customAlt = iconImageAlt.trim();
    if (customAlt.isNotEmpty) {
      return customAlt;
    }

    final label = title.trim();
    if (label.isNotEmpty) {
      return label;
    }

    return 'Timeline item icon';
  }

  bool get _shouldApplyCenteredAlignment => timeline?.isCentered ?? false;
}

String _joinClasses(List<String> values) {
  return values
      .expand((value) => value.trim().split(RegExp(r'\s+')))
      .where((value) => value.isNotEmpty)
      .join(' ');
}