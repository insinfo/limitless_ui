import 'dart:async';
import 'dart:html' show Event;

import 'package:ngdart/angular.dart';

const liWizardDirectives = <Object>[
  LiWizardComponent,
  LiWizardStepComponent,
];

class LiWizardStepChange {
  LiWizardStepChange({
    required this.previousIndex,
    required this.currentIndex,
    required this.previousStep,
    required this.currentStep,
  });

  final int previousIndex;
  final int currentIndex;
  final LiWizardStepComponent previousStep;
  final LiWizardStepComponent currentStep;
}

class LiWizardStepHeaderContext {
  LiWizardStepHeaderContext({
    required this.step,
    required this.index,
    required this.displayIndex,
  });

  final LiWizardStepComponent step;
  final int index;
  final int displayIndex;
  bool isCurrent = false;
  bool isDone = false;
  bool hasError = false;
  bool isDisabled = false;
}

class LiWizardActionsContext {
  LiWizardActionsContext({
    required this.goPrevious,
    required this.goNext,
    required this.finish,
  });

  final Future<void> Function() goPrevious;
  final Future<void> Function() goNext;
  final Future<void> Function() finish;
  bool hasPrevious = false;
  bool isLastStep = false;
  int activeIndex = 0;
  int stepCount = 0;
  String previousLabel = 'Previous';
  String nextLabel = 'Next';
  String finishLabel = 'Finish';
  String previousButtonClass = 'btn btn-light';
  String nextButtonClass = 'btn btn-primary';
  String finishButtonClass = 'btn btn-primary';
}

@Component(
  selector: 'li-wizard-step',
  template: '<ng-content></ng-content>',
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiWizardStepComponent {
  LiWizardStepComponent(this._changeDetectorRef);

  final ChangeDetectorRef _changeDetectorRef;

  @HostBinding('class.body')
  bool bodyClass = true;

  @HostBinding('class.current')
  bool current = false;

  @HostBinding('class.done')
  bool done = false;

  @HostBinding('class.error')
  bool get hasErrorClass => error;

  @HostBinding('attr.aria-hidden')
  String get ariaHidden => current ? 'false' : 'true';

  @HostBinding('style.display')
  String get displayStyle => current ? 'block' : 'none';

  @Input()
  String title = '';

  @Input()
  String? subtitle;

  @Input()
  TemplateRef? headerTemplate;

  bool get hasSubtitle => subtitle != null && subtitle!.isNotEmpty;

  @Input()
  bool disabled = false;

  @Input()
  bool error = false;

  void syncState({
    required bool isCurrent,
    required bool isDone,
  }) {
    if (current == isCurrent && done == isDone) {
      return;
    }

    current = isCurrent;
    done = isDone;
    _changeDetectorRef.markForCheck();
  }
}

// based in cdn/Vendor/limitless/4.0/bs4/Template/layout_1/LTR/default/full/form_wizard.html
@Component(
  selector: 'li-wizard',
  templateUrl: 'wizard_component.html',
  styleUrls: ['wizard_component.css'],
  directives: [coreDirectives],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiWizardComponent implements AfterContentInit, OnDestroy {
  LiWizardComponent(this._changeDetectorRef);

  final ChangeDetectorRef _changeDetectorRef;
  final List<LiWizardStepHeaderContext> _stepHeaderContexts =
      <LiWizardStepHeaderContext>[];
  late final LiWizardActionsContext _actionsContext = LiWizardActionsContext(
    goPrevious: goPrevious,
    goNext: goNext,
    finish: onFinishAction,
  );
  final StreamController<int> _activeIndexChangeController =
      StreamController<int>.broadcast();
  final StreamController<LiWizardStepChange> _stepChangeController =
      StreamController<LiWizardStepChange>.broadcast();
  final StreamController<int> _finishController =
      StreamController<int>.broadcast();

  @HostBinding('class.wizard')
  bool wizardClass = true;

  @HostBinding('style.display')
  String hostDisplay = 'block';

  @ContentChildren(LiWizardStepComponent)
  List<LiWizardStepComponent> steps = <LiWizardStepComponent>[];

  @Input()
  bool linear = true;

  @Input()
  bool allowStepClick = true;

  @Input()
  bool showActions = true;

  @Input()
  String previousLabel = 'Previous';

  @Input()
  String nextLabel = 'Next';

  @Input()
  String finishLabel = 'Finish';

  @Input()
  String previousButtonClass = 'btn btn-light';

  @Input()
  String nextButtonClass = 'btn btn-primary';

  @Input()
  String finishButtonClass = 'btn btn-primary';

  @Input()
  TemplateRef? actionsTemplate;

  @Input()
  FutureOr<bool> Function(int currentIndex, int targetIndex)? beforeChange;

  @Input()
  FutureOr<bool> Function(int currentIndex)? beforeFinish;

  int _activeIndex = 0;
  int _requestedActiveIndex = 0;
  int _furthestReachedIndex = 0;
  bool _contentReady = false;
  bool _isFinished = false;

  @Input()
  set activeIndex(int value) {
    _requestedActiveIndex = value;
    if (!_contentReady || steps.isEmpty) {
      return;
    }

    final resolvedIndex = _resolveIndex(value);
    _isFinished = false;
    _furthestReachedIndex = resolvedIndex > _furthestReachedIndex
        ? resolvedIndex
        : _furthestReachedIndex;
    _setActiveIndex(resolvedIndex, emit: false);
  }

  int get activeIndex => _activeIndex;

  List<LiWizardStepHeaderContext> get stepHeaderContexts => _stepHeaderContexts;

  LiWizardActionsContext get actionsContext => _actionsContext;

  bool get hasSteps => steps.isNotEmpty;

  bool get hasPrevious => _findSelectableIndex(_activeIndex - 1, -1) != null;

  bool get isLastStep => _findSelectableIndex(_activeIndex + 1, 1) == null;

  @Output()
  Stream<int> get activeIndexChange => _activeIndexChangeController.stream;

  @Output()
  Stream<LiWizardStepChange> get stepChange => _stepChangeController.stream;

  @Output()
  Stream<int> get finish => _finishController.stream;

  @override
  void ngAfterContentInit() {
    _contentReady = true;
    if (steps.isEmpty) {
      return;
    }

    final initialIndex = _resolveIndex(_requestedActiveIndex);
    _activeIndex = initialIndex;
    _furthestReachedIndex = initialIndex;
    _syncStepStates();
  }

  Future<void> handleStepClick(int index, Event event) async {
    event.preventDefault();
    if (!allowStepClick || !_canOpenStep(index)) {
      return;
    }

    await goToIndex(index);
  }

  Future<void> goPrevious() async {
    final targetIndex = _findSelectableIndex(_activeIndex - 1, -1);
    if (targetIndex == null) {
      return;
    }

    await goToIndex(targetIndex);
  }

  Future<void> goNext() async {
    final targetIndex = _findSelectableIndex(_activeIndex + 1, 1);
    if (targetIndex == null) {
      await onFinishAction();
      return;
    }

    await goToIndex(targetIndex);
  }

  Future<void> onFinishAction() async {
    if (!hasSteps) {
      return;
    }

    final beforeFinishCallback = beforeFinish;
    if (beforeFinishCallback != null) {
      final allowed = await beforeFinishCallback(_activeIndex);
      if (!allowed) {
        return;
      }
    }

    _isFinished = true;
    _syncStepStates();
    _finishController.add(_activeIndex);
  }

  Future<void> goToIndex(int targetIndex) async {
    if (!hasSteps || targetIndex == _activeIndex) {
      return;
    }

    if (targetIndex < 0 || targetIndex >= steps.length) {
      return;
    }

    if (!_canOpenStep(targetIndex)) {
      return;
    }

    final beforeChangeCallback = beforeChange;
    if (beforeChangeCallback != null) {
      final allowed = await beforeChangeCallback(_activeIndex, targetIndex);
      if (!allowed) {
        _syncStepStates();
        return;
      }
    }

    if (targetIndex > _furthestReachedIndex) {
      _furthestReachedIndex = targetIndex;
    }

    _setActiveIndex(targetIndex);
  }

  bool _canOpenStep(int index) {
    if (index < 0 || index >= steps.length) {
      return false;
    }

    if (steps[index].disabled) {
      return false;
    }

    if (!linear) {
      return true;
    }

    return index <= (_furthestReachedIndex + 1);
  }

  int _resolveIndex(int requestedIndex) {
    if (steps.isEmpty) {
      return 0;
    }

    final clampedIndex = requestedIndex < 0
        ? 0
        : (requestedIndex >= steps.length ? steps.length - 1 : requestedIndex);
    if (!steps[clampedIndex].disabled) {
      return clampedIndex;
    }

    return _findSelectableIndex(clampedIndex, 1) ??
        _findSelectableIndex(clampedIndex, -1) ??
        0;
  }

  int? _findSelectableIndex(int startIndex, int direction) {
    var index = startIndex;
    while (index >= 0 && index < steps.length) {
      if (!steps[index].disabled) {
        return index;
      }
      index += direction;
    }

    return null;
  }

  void _setActiveIndex(int nextIndex, {bool emit = true}) {
    if (!hasSteps) {
      return;
    }

    _isFinished = false;
    final previousIndex = _activeIndex;
    final previousStep = steps[previousIndex];
    _activeIndex = nextIndex;
    _syncStepStates();

    if (!emit || previousIndex == nextIndex) {
      return;
    }

    final currentStep = steps[nextIndex];
    _activeIndexChangeController.add(nextIndex);
    _stepChangeController.add(
      LiWizardStepChange(
        previousIndex: previousIndex,
        currentIndex: nextIndex,
        previousStep: previousStep,
        currentStep: currentStep,
      ),
    );
  }

  void _syncStepStates() {
    _syncStepHeaderContexts();
    _syncActionsContext();

    for (var index = 0; index < steps.length; index++) {
      steps[index].syncState(
        isCurrent: index == _activeIndex,
        isDone: index < _activeIndex,
      );
    }

    _changeDetectorRef.markForCheck();
  }

  void _syncStepHeaderContexts() {
    if (_stepHeaderContexts.length != steps.length ||
        _stepHeaderContexts.any(
          (context) => !identical(steps[context.index], context.step),
        )) {
      _stepHeaderContexts
        ..clear()
        ..addAll(
          List<LiWizardStepHeaderContext>.generate(
            steps.length,
            (index) => LiWizardStepHeaderContext(
              step: steps[index],
              index: index,
              displayIndex: index + 1,
            ),
          ),
        );
    }

    for (var index = 0; index < steps.length; index++) {
      final context = _stepHeaderContexts[index];
      final step = steps[index];
      context.isCurrent = index == _activeIndex;
      context.isDone =
          index < _activeIndex || (_isFinished && index == _activeIndex);
      context.hasError = step.error;
      context.isDisabled = step.disabled;
    }
  }

  void _syncActionsContext() {
    _actionsContext
      ..hasPrevious = hasPrevious
      ..isLastStep = isLastStep
      ..activeIndex = _activeIndex
      ..stepCount = steps.length
      ..previousLabel = previousLabel
      ..nextLabel = nextLabel
      ..finishLabel = finishLabel
      ..previousButtonClass = previousButtonClass
      ..nextButtonClass = nextButtonClass
      ..finishButtonClass = finishButtonClass;
  }

  @override
  void ngOnDestroy() {
    _activeIndexChangeController.close();
    _stepChangeController.close();
    _finishController.close();
  }
}
