// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/notification_toast/notification_toast_service_test.dart

@TestOn('browser')
library;

import 'dart:async';
import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:test/test.dart';

void main() {
  test('notify emite onNotify, resolve ícone padrão e remove toast automaticamente',
      () async {
    final service = LiNotificationToastService();
    addTearDown(service.dispose);

    final emitted = <LiNotificationToast>[];
    final subscription = service.onNotify.listen(emitted.add);
    addTearDown(subscription.cancel);

    service.notify(
      'Alteracoes salvas.',
      type: LiNotificationToastColor.success,
      durationSeconds: 0,
    );
    await Future<void>.delayed(Duration.zero);

    expect(service.toasts, hasLength(1));
    expect(emitted, hasLength(1));
    expect(service.toasts.single.message, 'Alteracoes salvas.');
    expect(service.toasts.single.icon, 'check');
    expect(service.toasts.single.bgColor, 'bg-success');
    expect(service.toasts.single.cssDuration, '0s');

    final toast = service.toasts.single;

    await Future<void>.delayed(const Duration(milliseconds: 350));

    expect(toast.toBeDeleted, isTrue);
    expect(toast.cssAnimation, 'toast-fade-out 0.3s ease-out');

    await Future<void>.delayed(const Duration(milliseconds: 350));

    expect(service.toasts, isEmpty);
  });

  test('changes emite quando um toast entra, muda de estado e sai', () async {
    final service = LiNotificationToastService();
    addTearDown(service.dispose);

    var changeCount = 0;
    final subscription = service.changes.listen((_) {
      changeCount += 1;
    });
    addTearDown(subscription.cancel);

    service.notify('Mudanca', durationSeconds: 0);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    await Future<void>.delayed(const Duration(milliseconds: 350));

    expect(changeCount, greaterThanOrEqualTo(3));
  });

  test('add e remove mantem a fila consistente', () async {
    final service = LiNotificationToastService();
    addTearDown(service.dispose);

    service.add(
      LiNotificationToastColor.warning,
      'Atencao',
      'Existe uma pendencia.',
      durationSeconds: 10,
    );
    service.add(
      LiNotificationToastColor.info,
      'Info',
      'Atualizacao disponivel.',
      durationSeconds: 10,
    );

    expect(service.toasts, hasLength(2));
    expect(service.toasts.first.title, 'Info');
    expect(service.toasts.last.title, 'Atencao');

    final warningToast = service.toasts.last;
    service.remove(warningToast);

    expect(service.toasts, hasLength(1));
    expect(service.toasts.single.title, 'Info');
  });

  test('LiNotificationToast toMap e fromMap preservam campos suportados', () {
    final original = LiNotificationToast(
      type: LiNotificationToastColor.indigo,
      title: 'Titulo',
      message: 'Mensagem',
      icon: 'bell',
      durationSeconds: 12,
    )..toBeDeleted = true;

    final restored = LiNotificationToast.fromMap(original.toMap());

    expect(restored.type, LiNotificationToastColor.indigo);
    expect(restored.title, 'Titulo');
    expect(restored.message, 'Mensagem');
    expect(restored.icon, 'bell');
    expect(restored.durationSeconds, 12);
    expect(restored.toBeDeleted, isTrue);
    expect(restored.created.toIso8601String(), original.created.toIso8601String());
  });

  test('LiToastSoundController só toca após interação do usuário', () async {
    var playCount = 0;
    final controller = LiToastSoundController(
      customPlayer: () async {
        playCount += 1;
      },
    );

    await controller.playOnceSafely();
    expect(playCount, 0);

    html.document.body!.dispatchEvent(
      html.MouseEvent('click', canBubble: true),
    );
    await Future<void>.delayed(const Duration(milliseconds: 20));

    await controller.playOnceSafely();
    expect(playCount, 1);
  });
}