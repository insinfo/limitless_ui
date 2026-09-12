// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/helpers/loading_curtain_yields_to_dialogs_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:test/test.dart';

/// The library's stacking order, and who is responsible for it.
///
/// `LiSimpleLoading` renders above every dialog on purpose: its job is to keep
/// the operator from navigating, clicking a save button twice or opening
/// another modal while an operation runs. A dialog raised while the curtain is
/// up is therefore born underneath it, and with `await` that freezes the page —
/// the `finally` that would hide the curtain only runs once the operator
/// answers, and they cannot answer what they cannot see.
///
/// **The library does not resolve that on the caller's behalf.** A component
/// reaching into another component's state and dismissing it is a side effect
/// nobody asked for, and it would unblock the page in the middle of the very
/// operation the curtain is there to protect. Hiding the curtain where the
/// operation ends is the application's call, and [LiSimpleLoading.hideAll] is
/// the tool for an application that wants to enforce it in one place.
void main() {
  int curtainsOnScreen() =>
      html.document.querySelectorAll('[data-li-simple-loading]').length;

  void closeAnyDialog() {
    for (final node
        in html.document.querySelectorAll('[data-li-simple-dialog]')) {
      node.remove();
    }
    for (final node in html.document.querySelectorAll('.swal2-container')) {
      node.remove();
    }
    for (final node
        in html.document.querySelectorAll('.li-simple-dialog__backdrop')) {
      node.remove();
    }
  }

  tearDown(() {
    LiSimpleLoading.hideAll();
    closeAnyDialog();
  });

  group('LiSimpleLoading.hideAll', () {
    test('hides every mounted curtain and reports how many', () {
      final primeira = LiSimpleLoading()..showOnBody();
      final segunda = LiSimpleLoading()..showOnBody();

      expect(LiSimpleLoading.mountedCount, 2);
      expect(curtainsOnScreen(), 2);

      expect(LiSimpleLoading.hideAll(), 2);
      expect(LiSimpleLoading.mountedCount, 0);
      expect(curtainsOnScreen(), 0);
      expect(primeira.isVisible, isFalse);
      expect(segunda.isVisible, isFalse);
    });

    test('is a no-op when nothing is mounted', () {
      expect(LiSimpleLoading.hideAll(), 0);
    });

    test('hiding one curtain leaves the others alone', () {
      final ficaNoAr = LiSimpleLoading()..showOnBody();
      final sai = LiSimpleLoading()..showOnBody();

      sai.hide();

      expect(LiSimpleLoading.mountedCount, 1);
      expect(ficaNoAr.isVisible, isTrue);
    });
  });

  group('the library leaves the caller curtain alone', () {
    test('showing a dialog leaves a mounted curtain alone', () {
      LiSimpleLoading().showOnBody();

      LiSimpleDialogComponent.showAlert('mensagem de teste');
      SweetAlert.show(title: 'titulo', message: 'mensagem');

      // Deliberate: a component reaching into another component's state and
      // dismissing it is a side effect the caller never asked for, and it would
      // unblock the page in the middle of the very operation the curtain is
      // there to protect. Deciding that a dialog outranks a curtain belongs to
      // the application, which owns both.
      expect(curtainsOnScreen(), 1);
    });
  });
}
