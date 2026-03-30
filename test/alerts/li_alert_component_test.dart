// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:html';

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_alert_component_test.template.dart' as ng;

@Component(
  selector: 'test-host',
  template: '''
    <li-alert
      [variant]="variant"
      [solid]="solid"
      [dismissible]="dismissible"
      [(visible)]="visible"
      [roundedPill]="roundedPill"
      [borderless]="borderless"
      [truncated]="truncated"
      [iconMode]="iconMode"
      [iconPosition]="iconPosition"
      [iconClass]="iconClass"
      [alertClass]="alertClass"
      [iconContainerClass]="iconContainerClass"
      (dismissed)="onDismissed()">
      <span class="fw-semibold">Heads up!</span>
      Test alert content.
    </li-alert>
  ''',
  directives: [coreDirectives, LiAlertComponent],
)
class TestHostComponent {
  String variant = 'warning';
  bool solid = false;
  bool dismissible = true;
  bool visible = true;
  bool roundedPill = false;
  bool borderless = false;
  bool truncated = false;
  String iconMode = 'block';
  String iconPosition = 'start';
  String iconClass = 'ph-warning-circle';
  String alertClass = 'shadow-sm';
  String iconContainerClass = '';
  int dismissedCount = 0;

  void onDismissed() {
    dismissedCount += 1;
  }
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<TestHostComponent>(
    ng.TestHostComponentNgFactory,
  );

  test('renderiza classes, conteudo e icone em bloco', () async {
    final fixture = await testBed.create();
    final alert = fixture.rootElement.querySelector('li-alert > div');
    final iconWrapper = alert?.querySelector('.alert-icon');
    final icon = iconWrapper?.querySelector('i');
    final closeButton = alert?.querySelector('button.btn-close');

    expect(alert, isNotNull);
    expect(alert!.classes.contains('alert'), isTrue);
    expect(alert.classes.contains('alert-warning'), isTrue);
    expect(alert.classes.contains('alert-dismissible'), isTrue);
    expect(alert.classes.contains('alert-icon-start'), isTrue);
    expect(alert.classes.contains('shadow-sm'), isTrue);
    expect(alert.classes.contains('show'), isTrue);
    expect(alert.text, contains('Heads up!'));
    expect(alert.text, contains('Test alert content.'));
    expect(iconWrapper, isNotNull);
    expect(iconWrapper!.classes.contains('bg-warning'), isTrue);
    expect(iconWrapper.classes.contains('text-white'), isTrue);
    expect(icon, isNotNull);
    expect(icon!.classes.contains('ph-warning-circle'), isTrue);
    expect(closeButton, isNotNull);
    expect(closeButton!.classes.contains('btn-close-white'), isFalse);
  });

  test('renderiza alerta solido com icone inline ao final', () async {
    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component.variant = 'indigo';
      component.solid = true;
      component.roundedPill = true;
      component.borderless = true;
      component.truncated = true;
      component.iconMode = 'inline';
      component.iconPosition = 'end';
      component.iconClass = 'ph-gear';
    });

    final alert = fixture.rootElement.querySelector('li-alert > div');
    final inlineEndIcon = alert?.querySelector('i.float-end');
    final blockIcon = alert?.querySelector('.alert-icon');
    final closeButton = alert?.querySelector('button.btn-close');

    expect(alert, isNotNull);
    expect(alert!.classes.contains('bg-indigo'), isTrue);
    expect(alert.classes.contains('text-white'), isTrue);
    expect(alert.classes.contains('rounded-pill'), isTrue);
    expect(alert.classes.contains('border-0'), isTrue);
    expect(alert.classes.contains('text-truncate'), isTrue);
    expect(blockIcon, isNull);
    expect(inlineEndIcon, isNotNull);
    expect(inlineEndIcon!.classes.contains('ph-gear'), isTrue);
    expect(inlineEndIcon.classes.contains('ms-2'), isTrue);
    expect(closeButton, isNotNull);
    expect(closeButton!.classes.contains('btn-close-white'), isTrue);
    expect(closeButton.classes.contains('rounded-pill'), isTrue);
  });

  test('clicar em fechar oculta o alerta e emite dismissed', () async {
    final fixture = await testBed.create();
    final host = fixture.assertOnlyInstance;
    final closeButton = fixture.rootElement.querySelector(
      'li-alert button.btn-close',
    );

    expect(closeButton, isNotNull);
    expect(host.visible, isTrue);
    expect(host.dismissedCount, 0);

    await fixture.update((_) {
      (closeButton as ButtonElement).click();
    });

    final alert = fixture.rootElement.querySelector('li-alert > div');

    expect(alert, isNotNull);
    expect(host.visible, isFalse);
    expect(host.dismissedCount, 1);
    expect((alert as HtmlElement).hidden, isTrue);
    expect(alert.classes.contains('show'), isFalse);
  });
}
