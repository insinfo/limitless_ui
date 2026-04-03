// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/wizard/li_wizard_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:async';
import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_wizard_component_test.template.dart' as ng;

@Component(
  selector: 'wizard-test-host',
  template: '''
    <li-wizard
      #wizard
      [(activeIndex)]="activeIndexModel"
      [beforeChange]="beforeChange"
      [beforeFinish]="beforeFinish"
      (stepChange)="handleStepChange(
        \$event,
      )"
      (finish)="handleFinish(
        \$event,
      )">
      <li-wizard-step title="Account" [error]="!allowAdvanceFromFirst">
        <div id="step-account">Account body</div>
      </li-wizard-step>

      <li-wizard-step title="Profile">
        <div id="step-profile">Profile body</div>
      </li-wizard-step>

      <li-wizard-step title="Review">
        <div id="step-review">Review body</div>
      </li-wizard-step>
    </li-wizard>
  ''',
  directives: [coreDirectives, liWizardDirectives],
)
class WizardTestHostComponent {
  @ViewChild('wizard')
  LiWizardComponent? wizard;

  int activeIndexModel = 0;
  bool allowAdvanceFromFirst = false;
  bool allowFinishEvent = false;
  int finishCount = 0;
  int lastFinishedIndex = -1;
  int stepChangeCount = 0;
  int lastPreviousIndex = -1;
  int lastCurrentIndex = -1;

  FutureOr<bool> beforeChange(int currentIndex, int targetIndex) {
    if (currentIndex == 0 && targetIndex > currentIndex) {
      return allowAdvanceFromFirst;
    }
    return true;
  }

  FutureOr<bool> beforeFinish(int currentIndex) {
    return allowFinishEvent;
  }

  void handleStepChange(LiWizardStepChange change) {
    stepChangeCount += 1;
    lastPreviousIndex = change.previousIndex;
    lastCurrentIndex = change.currentIndex;
  }

  void handleFinish(int index) {
    finishCount += 1;
    lastFinishedIndex = index;
  }
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<WizardTestHostComponent>(
    ng.WizardTestHostComponentNgFactory,
  );

  test('navigates between steps and allows returning to a visited step',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    expect(_currentStepItem(fixture.rootElement)?.text, contains('Account'));
    expect(_currentBody(fixture.rootElement)?.querySelector('#step-account'),
        isNotNull);

    await fixture.update((component) {
      component.allowAdvanceFromFirst = true;
    });
    await _settle(fixture);

    await fixture.update((_) {
      _findButtonByText(fixture.rootElement, 'Next')!
          .dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.activeIndexModel, 1);
    expect(host.stepChangeCount, 1);
    expect(host.lastPreviousIndex, 0);
    expect(host.lastCurrentIndex, 1);
    expect(
        fixture.rootElement.querySelectorAll('.steps li.done'), hasLength(1));
    expect(_pseudoContent(fixture.rootElement, '.steps li.done .number'),
        contains('\\ea30'));
    expect(_currentStepItem(fixture.rootElement)?.text, contains('Profile'));

    await fixture.update((_) {
      _findStepLinkByText(fixture.rootElement, 'Account')!
          .dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.activeIndexModel, 0);
    expect(host.stepChangeCount, 2);
    expect(host.lastPreviousIndex, 1);
    expect(host.lastCurrentIndex, 0);
    expect(_currentStepItem(fixture.rootElement)?.text, contains('Account'));
  });

  test('blocks forward navigation while validation rejects the change',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    await fixture.update((_) {
      _findButtonByText(fixture.rootElement, 'Next')!
          .dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.activeIndexModel, 0);
    expect(host.stepChangeCount, 0);
    expect(fixture.rootElement.querySelector('.steps li.current.error'),
        isNotNull);
    expect(_currentBody(fixture.rootElement)?.querySelector('#step-account'),
        isNotNull);
    expect(_currentBody(fixture.rootElement)?.querySelector('#step-profile'),
        isNull);
  });

  test('emits finish only after beforeFinish allows completion', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    await fixture.update((component) {
      component.allowAdvanceFromFirst = true;
    });
    await _settle(fixture);

    await fixture.update((_) {
      _findButtonByText(fixture.rootElement, 'Next')!
          .dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    await fixture.update((_) {
      _findButtonByText(fixture.rootElement, 'Next')!
          .dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.activeIndexModel, 2);
    expect(_findButtonByText(fixture.rootElement, 'Finish'), isNotNull);

    await fixture.update((_) {
      _findButtonByText(fixture.rootElement, 'Finish')!
          .dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.finishCount, 0);

    await fixture.update((component) {
      component.allowFinishEvent = true;
    });
    await _settle(fixture);

    await fixture.update((_) {
      _findButtonByText(fixture.rootElement, 'Finish')!
          .dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.finishCount, 1);
    expect(host.lastFinishedIndex, 2);
  });
}

html.Element? _currentStepItem(html.Element root) {
  return root.querySelector('.steps li.current');
}

html.Element? _currentBody(html.Element root) {
  return root.querySelector('.content .body.current');
}

html.ButtonElement? _findButtonByText(html.Element root, String text) {
  for (final element in root.querySelectorAll('button')) {
    if ((element.text ?? '').trim() == text) {
      return element as html.ButtonElement;
    }
  }
  return null;
}

html.AnchorElement? _findStepLinkByText(html.Element root, String text) {
  for (final element in root.querySelectorAll('.steps a')) {
    if ((element.text ?? '').contains(text)) {
      return element as html.AnchorElement;
    }
  }
  return null;
}

String _pseudoContent(html.Element root, String selector) {
  final element = root.querySelector(selector);
  if (element == null) {
    return '';
  }

  final content = element.getComputedStyle('::after').content;
  if (content.length >= 2 && content.startsWith('"') && content.endsWith('"')) {
    final unquoted = content.substring(1, content.length - 1);
    if (unquoted.runes.length == 1) {
      final codepoint = unquoted.runes.first.toRadixString(16).padLeft(4, '0');
      return '\\$codepoint';
    }
  }

  return content;
}

Future<void> _settle(NgTestFixture<WizardTestHostComponent> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
  await fixture.update((_) {});
}
