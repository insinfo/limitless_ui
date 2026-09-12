// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/helpers/li_narrated_loading_presentation_test.dart

@TestOn('browser')
library;

import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:test/test.dart';

/// The two faces of the narrated overlay: the card, and the plain veil SALI
/// had before it moved to `limitless_ui` — title, message and track straight
/// on the blurred backdrop, nothing drawn around them.
void main() {
  tearDown(() {
    LiNarratedFullScreenLoading.defaultPresentation =
        LiNarratedLoadingPresentation.card;
    for (final node in html.document
        .querySelectorAll('[data-li-narrated-full-screen-loading]')) {
      node.remove();
    }
  });

  html.Element root() => html.document
      .querySelector('[data-li-narrated-full-screen-loading="true"]')!;

  test('the card is the default: spinner, surface and shadow', () {
    final loading = LiNarratedFullScreenLoading(
      title: 'Gerando PDF',
      messages: const <String>['Preparando...'],
    )..showOnBody();
    addTearDown(loading.hide);

    expect(loading.presentation, LiNarratedLoadingPresentation.card);
    final overlay = root();
    expect(overlay.attributes['data-li-narrated-presentation'], 'card');
    expect(overlay.classes, contains('li-narrated-full-screen-loading--card'));
    expect(
      overlay.querySelector('.li-narrated-full-screen-loading__icon'),
      isNotNull,
    );

    final shell =
        overlay.querySelector('.li-narrated-full-screen-loading__shell')!;
    expect(shell.getComputedStyle().boxShadow, isNot('none'));
    expect(
      shell.getComputedStyle().backgroundColor,
      isNot('rgba(0, 0, 0, 0)'),
    );
  });

  test('plain draws only title, message and track on the backdrop', () {
    final loading = LiNarratedFullScreenLoading(
      title: 'Carregando anexo',
      messages: const <String>['Lendo arquivo selecionado...'],
      presentation: LiNarratedLoadingPresentation.plain,
    )..showOnBody();
    addTearDown(loading.hide);

    final overlay = root();
    expect(overlay.attributes['data-li-narrated-presentation'], 'plain');
    expect(overlay.classes, contains('li-narrated-full-screen-loading--plain'));
    expect(
      overlay.querySelector('.li-narrated-full-screen-loading__icon'),
      isNull,
      reason: 'the veil has no spinner',
    );
    expect(
      overlay.querySelector('.li-narrated-full-screen-loading__title')!.text,
      'Carregando anexo',
    );
    expect(
      overlay.querySelector('.li-narrated-full-screen-loading__message')!.text,
      'Lendo arquivo selecionado...',
    );
    expect(
      overlay.querySelector('.li-narrated-full-screen-loading__track'),
      isNotNull,
    );

    final shell =
        overlay.querySelector('.li-narrated-full-screen-loading__shell')!;
    final style = shell.getComputedStyle();
    expect(style.boxShadow, 'none');
    expect(style.backgroundColor, 'rgba(0, 0, 0, 0)');
    expect(style.borderTopWidth, '0px');
    // The backdrop still veils the page.
    expect(overlay.style.getPropertyValue('backdrop-filter'), contains('blur'));
  });

  test('defaultPresentation sets the face of every overlay built after it',
      () {
    LiNarratedFullScreenLoading.defaultPresentation =
        LiNarratedLoadingPresentation.plain;

    final byDefault = LiNarratedFullScreenLoading.pdfGeneration();
    expect(byDefault.presentation, LiNarratedLoadingPresentation.plain);

    // An explicit choice still wins over the default.
    final explicit = LiNarratedFullScreenLoading.pdfGeneration(
      presentation: LiNarratedLoadingPresentation.card,
    );
    expect(explicit.presentation, LiNarratedLoadingPresentation.card);

    byDefault.showOnBody();
    addTearDown(byDefault.hide);
    expect(root().attributes['data-li-narrated-presentation'], 'plain');
  });

  test('hide() and a second showOnBody() keep the chosen face', () {
    final loading = LiNarratedFullScreenLoading(
      title: 'Enviando',
      messages: const <String>['Um', 'Dois'],
      presentation: LiNarratedLoadingPresentation.plain,
    )..showOnBody();
    addTearDown(loading.hide);

    loading.hide();
    expect(
      html.document.querySelector('[data-li-narrated-full-screen-loading]'),
      isNull,
    );

    loading.showOnBody();
    expect(root().attributes['data-li-narrated-presentation'], 'plain');
  });
}
