import 'package:limitless_ui/src/components/progress/progress_bar_component.dart';
import 'package:limitless_ui/src/components/progress/progress_component.dart';
import 'package:test/test.dart';

void main() {
  group('LiProgressBarComponent', () {
    test('inherits range and visual options from parent progress', () {
      final parent = LiProgressComponent()
        ..min = 0
        ..max = 200
        ..striped = true
        ..animated = true;
      final bar = LiProgressBarComponent()
        ..parent = parent
        ..value = 50;

      expect(bar.resolvedMin, 0);
      expect(bar.resolvedMax, 200);
      expect(bar.resolvedStriped, isTrue);
      expect(bar.resolvedAnimated, isTrue);
      expect(bar.widthPercent, 25);
      expect(bar.ariaValueNow, '50');
    });

    test('clamps current value inside the configured range', () {
      final bar = LiProgressBarComponent()
        ..min = 10
        ..max = 60
        ..value = 100;

      expect(bar.normalizedValue, 60);
      expect(bar.widthPercent, 100);
      expect(bar.ariaValueMax, '60');
    });

    test('renders automatic labels when requested', () {
      final bar = LiProgressBarComponent()
        ..value = 85
        ..showValueLabel = true;

      expect(bar.resolvedLabel, '85%');
      expect(bar.hasLabel, isTrue);
    });
  });
}
