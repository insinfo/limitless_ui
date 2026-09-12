// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/sweet_alert/sweet_alert_popover_test.dart
@TestOn('browser')
@Timeout(Duration(seconds: 30))
library;

import 'dart:async';
import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:test/test.dart';

/// Veio do SALI junto com o componente, em 11/09/2026: a biblioteca tinha o
/// `SweetAlertPopover` mas nao cobria o `showPopover`.
void main() {
  tearDown(() {
    html.document.querySelector('#popover441630')?.remove();
    html.document.body!.classes.removeAll(<String>[
      'swal2-toast-shown',
      'swal2-shown',
    ]);
  });

  test('exibe e fecha por clique no popover', () async {
    final target = html.ButtonElement()
      ..text = 'target'
      ..style.position = 'fixed'
      ..style.left = '40px'
      ..style.top = '40px';
    html.document.body!.append(target);

    SweetAlertPopover.showPopover(
      target,
      'Mensagem',
      title: 'Titulo',
      timeout: null,
    );

    await Future<void>.delayed(const Duration(milliseconds: 50));

    final popover = html.document.querySelector('#popover441630');
    expect(popover, isNotNull);
    expect(popover!.text, contains('Titulo'));
    expect(popover.text, contains('Mensagem'));

    popover.click();
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(html.document.querySelector('#popover441630'), isNull);
    target.remove();
  });
}
