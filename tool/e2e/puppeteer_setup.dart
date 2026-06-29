import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:puppeteer/puppeteer.dart';

final String exampleBaseUrl = Platform.environment['UI_EXAMPLE_BASE_URL'] ??
    Platform.environment['UI_FRONTEND_BASE_URL'] ??
    'http://localhost:8081';

final bool defaultHeadless =
    (Platform.environment['UI_HEADLESS'] ?? 'true').toLowerCase() == 'true';

final bool runExampleE2e =
    (Platform.environment['RUN_EXAMPLE_E2E'] ?? '').toLowerCase() == 'true';

String? skipExampleE2eReason() {
  if (runExampleE2e) {
    return null;
  }

  return 'Defina RUN_EXAMPLE_E2E=true e sirva example/web para executar os testes E2E via Puppeteer.';
}

Future<Page> setupExampleBrowser({bool? headless}) async {
  final executablePath = Platform.environment['PUPPETEER_EXECUTABLE_PATH'] ??
      Platform.environment['CHROME_EXECUTABLE'];

  final browser = await puppeteer.launch(
    devTools: false,
    headless: headless ?? defaultHeadless,
    executablePath: executablePath != null && executablePath.isNotEmpty
        ? executablePath
        : null,
    noSandboxFlag: true,
    defaultViewport: DeviceViewport(width: 1920, height: 1003),
    ignoreDefaultArgs: const [
      '--enable-automation',
    ],
    args: const [
      '--window-size=1920,1080',
      '--no-sandbox',
      '--disable-dev-shm-usage',
      '--disable-infobars',
      '--disable-search-engine-choice-screen',
      '--disable-features=Translate,AutofillServerCommunication,PasswordManagerOnboarding',
      '--disable-save-password-bubble',
      '--disable-password-manager-reauthentication',
      '--disable-notifications',
      '--disable-popup-blocking',
    ],
  );

  final page = await browser.newPage();
  await page.setViewport(DeviceViewport(width: 1920, height: 1003));
  return page;
}

Future<void> gotoExample(Page page, String route) async {
  final trimmedRoute = route.trim();
  final normalizedRoute = trimmedRoute.startsWith('#/')
      ? trimmedRoute.substring(2)
      : trimmedRoute.startsWith('/')
          ? trimmedRoute.substring(1)
          : trimmedRoute;
  final normalizedBaseUrl = exampleBaseUrl.endsWith('/')
      ? exampleBaseUrl.substring(0, exampleBaseUrl.length - 1)
      : exampleBaseUrl;

  await page.goto(
    '$normalizedBaseUrl/#/$normalizedRoute',
    wait: Until.domContentLoaded,
  );
  await waitForSelectorMatching(page, '.demo-page, .content');
}

Future<void> waitForSelectorMatching(
  Page page,
  String selector, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final stopwatch = Stopwatch()..start();
  while (stopwatch.elapsed < timeout) {
    if (await hasSelector(page, selector, tolerateNavigation: true)) {
      return;
    }
    await aguarde(100);
  }

  throw TimeoutException(
    'Seletor esperado nao encontrado dentro de ${timeout.inSeconds}s: $selector. URL atual: ${page.url}',
  );
}

Future<void> waitForSelectorCountAtLeast(
  Page page,
  String selector,
  int minimum, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final stopwatch = Stopwatch()..start();
  while (stopwatch.elapsed < timeout) {
    final count = await selectorCount(page, selector);
    if (count >= minimum) {
      return;
    }
    await aguarde(100);
  }

  throw TimeoutException(
    'Quantidade esperada nao encontrada dentro de ${timeout.inSeconds}s: $selector >= $minimum. URL atual: ${page.url}',
  );
}

Future<bool> hasSelector(
  Page page,
  String selector, {
  bool tolerateNavigation = false,
}) async {
  try {
    final found = await page.evaluate(
      '(css) => document.querySelector(css) != null',
      args: [selector],
    );
    return found == true;
  } catch (error) {
    if (tolerateNavigation && _isTransientNavigationError(error)) {
      return false;
    }
    rethrow;
  }
}

Future<int> selectorCount(Page page, String selector) async {
  final count = await page.evaluate(
    '(css) => document.querySelectorAll(css).length',
    args: [selector],
  );
  return count is num ? count.toInt() : 0;
}

Future<void> clickFirstVisible(
  Page page,
  String selector, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  await clickVisibleAt(page, selector, 0, timeout: timeout);
}

Future<void> clickVisibleAt(
  Page page,
  String selector,
  int index, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final stopwatch = Stopwatch()..start();
  Object? lastError;

  while (stopwatch.elapsed < timeout) {
    final handles = await page.$$(selector);
    ElementHandle? target;
    var visibleIndex = -1;

    try {
      for (final handle in handles) {
        final visible = await handle.evaluate<bool>(
          r'''(item) => {
            if (item.disabled || item.getAttribute('aria-disabled') === 'true') {
              return false;
            }
            const rect = item.getBoundingClientRect();
            const style = window.getComputedStyle(item);
            return rect.width > 0 &&
              rect.height > 0 &&
              style.display !== 'none' &&
              style.visibility !== 'hidden' &&
              style.pointerEvents !== 'none';
          }''',
        );

        if (visible == true) {
          visibleIndex++;
          if (visibleIndex == index) {
            target = handle;
            break;
          }
        }
      }

      if (target != null) {
        await target.evaluate(
          r'''(item) => item.scrollIntoView({
            block: 'center',
            inline: 'nearest',
            behavior: 'instant'
          })''',
        );
        await aguarde(50);
        await target.click(delay: const Duration(milliseconds: 25));
        await aguarde(150);
        return;
      }
    } catch (error) {
      lastError = error;
      if (!_isTransientNavigationError(error)) {
        await aguarde(100);
      }
    } finally {
      for (final handle in handles) {
        await handle.dispose();
      }
    }

    await aguarde(100);
  }

  throw TimeoutException(
    'Elemento visivel nao encontrado para clique real dentro de ${timeout.inSeconds}s: $selector na posicao $index. Ultimo erro: $lastError. URL atual: ${page.url}',
  );
}

Future<void> dragFirstVisibleBy(
  Page page,
  String selector, {
  required num deltaX,
  num deltaY = 0,
  Duration timeout = const Duration(seconds: 10),
  int steps = 12,
}) async {
  await dragVisibleBy(
    page,
    selector,
    0,
    deltaX: deltaX,
    deltaY: deltaY,
    timeout: timeout,
    steps: steps,
  );
}

Future<void> dragVisibleBy(
  Page page,
  String selector,
  int index, {
  required num deltaX,
  num deltaY = 0,
  Duration timeout = const Duration(seconds: 10),
  int steps = 12,
}) async {
  final stopwatch = Stopwatch()..start();
  Object? lastError;

  while (stopwatch.elapsed < timeout) {
    final handles = await page.$$(selector);
    ElementHandle? target;
    Map<dynamic, dynamic>? targetRect;
    var visibleIndex = -1;

    try {
      for (final handle in handles) {
        final rect = await _visibleElementRect(handle);
        if (rect != null) {
          visibleIndex++;
          if (visibleIndex == index) {
            target = handle;
            targetRect = rect;
            break;
          }
        }
      }

      if (target != null && targetRect != null) {
        await target.evaluate(
          r'''(item) => item.scrollIntoView({
            block: 'center',
            inline: 'nearest',
            behavior: 'instant'
          })''',
        );
        await aguarde(50);

        targetRect = await _visibleElementRect(target);
        if (targetRect == null) {
          await aguarde(100);
          continue;
        }

        final x =
            _number(targetRect['left']) + _number(targetRect['width']) / 2;
        final y =
            _number(targetRect['top']) + _number(targetRect['height']) / 2;
        await page.mouse.move(math.Point<num>(x, y));
        await page.mouse.down();
        await page.mouse.move(
          math.Point<num>(x + deltaX, y + deltaY),
          steps: steps,
        );
        await page.mouse.up();
        await aguarde(200);
        return;
      }
    } catch (error) {
      lastError = error;
      if (!_isTransientNavigationError(error)) {
        await aguarde(100);
      }
    } finally {
      for (final handle in handles) {
        await handle.dispose();
      }
    }

    await aguarde(100);
  }

  throw TimeoutException(
    'Elemento visivel nao encontrado para arrastar dentro de ${timeout.inSeconds}s: $selector na posicao $index. Ultimo erro: $lastError. URL atual: ${page.url}',
  );
}

Future<String?> attributeValue(
  Page page,
  String selector,
  String attribute,
) async {
  final value = await page.evaluate(
    '(css, attribute) => document.querySelector(css)?.getAttribute(attribute)',
    args: [selector, attribute],
  );
  return value?.toString();
}

Future<String?> attributeValueAt(
  Page page,
  String selector,
  int index,
  String attribute,
) async {
  final value = await page.evaluate(
    r'''(css, index, attribute) => {
      const elements = [...document.querySelectorAll(css)].filter((item) => {
        const rect = item.getBoundingClientRect();
        const style = window.getComputedStyle(item);
        return rect.width > 0 &&
          rect.height > 0 &&
          style.display !== 'none' &&
          style.visibility !== 'hidden';
      });
      return elements[index]?.getAttribute(attribute);
    }''',
    args: [selector, index, attribute],
  );
  return value?.toString();
}

Future<String?> waitForAttributeMatching(
  Page page,
  String selector,
  String attribute,
  bool Function(String? value) matches, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final stopwatch = Stopwatch()..start();
  String? lastValue;
  while (stopwatch.elapsed < timeout) {
    lastValue = await attributeValue(page, selector, attribute);
    if (matches(lastValue)) {
      return lastValue;
    }
    await aguarde(100);
  }

  throw TimeoutException(
    'Atributo esperado nao encontrado dentro de ${timeout.inSeconds}s: $selector@$attribute. Ultimo valor: $lastValue. URL atual: ${page.url}',
  );
}

Future<String?> waitForAttributeAtMatching(
  Page page,
  String selector,
  int index,
  String attribute,
  bool Function(String? value) matches, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final stopwatch = Stopwatch()..start();
  String? lastValue;
  while (stopwatch.elapsed < timeout) {
    lastValue = await attributeValueAt(page, selector, index, attribute);
    if (matches(lastValue)) {
      return lastValue;
    }
    await aguarde(100);
  }

  throw TimeoutException(
    'Atributo esperado nao encontrado dentro de ${timeout.inSeconds}s: $selector[$index]@$attribute. Ultimo valor: $lastValue. URL atual: ${page.url}',
  );
}

Future<void> aguarde([int milliseconds = 300]) {
  return Future<void>.delayed(Duration(milliseconds: milliseconds));
}

Future<Map<dynamic, dynamic>?> _visibleElementRect(ElementHandle handle) async {
  final rect = await handle.evaluate<dynamic>(
    r'''(item) => {
      if (item.disabled || item.getAttribute('aria-disabled') === 'true') {
        return null;
      }
      const rect = item.getBoundingClientRect();
      const style = window.getComputedStyle(item);
      if (rect.width <= 0 ||
          rect.height <= 0 ||
          style.display === 'none' ||
          style.visibility === 'hidden' ||
          style.pointerEvents === 'none') {
        return null;
      }
      return {
        left: rect.left,
        top: rect.top,
        width: rect.width,
        height: rect.height
      };
    }''',
  );
  return rect is Map ? rect : null;
}

num _number(dynamic value) {
  if (value is num) {
    return value;
  }
  return num.parse(value.toString());
}

bool _isTransientNavigationError(Object error) {
  final message = error.toString();
  return message.contains('Execution context was destroyed') ||
      message.contains('Cannot find context with specified id');
}
