import 'package:limitless_ui/src/components/alerts/alert_component.dart';
import 'package:test/test.dart';

void main() {
  group('LiAlertComponent', () {
    test('resolves default bordered alert classes and block icon styling', () {
      final alert = LiAlertComponent()
        ..variant = 'info'
        ..dismissible = true
        ..iconMode = 'block'
        ..iconClass = 'ph-info';

      expect(alert.resolvedAlertClasses, contains('alert'));
      expect(alert.resolvedAlertClasses, contains('alert-info'));
      expect(alert.resolvedAlertClasses, contains('alert-dismissible'));
      expect(alert.resolvedAlertClasses, contains('alert-icon-start'));
      expect(alert.resolvedBlockIconClasses, contains('alert-icon'));
      expect(alert.resolvedBlockIconClasses, contains('bg-info'));
      expect(alert.resolvedBlockIconClasses, contains('text-white'));
      expect(alert.resolvedCloseButtonClasses, equals('btn-close'));
    });

    test('resolves solid inline end icon styling and white close button', () {
      final alert = LiAlertComponent()
        ..variant = 'indigo'
        ..solid = true
        ..dismissible = true
        ..roundedPill = true
        ..iconMode = 'inline'
        ..iconPosition = 'end'
        ..iconClass = 'ph-gear';

      expect(alert.resolvedAlertClasses, contains('bg-indigo'));
      expect(alert.resolvedAlertClasses, contains('text-white'));
      expect(alert.resolvedAlertClasses, contains('rounded-pill'));
      expect(alert.showInlineEndIcon, isTrue);
      expect(alert.resolvedInlineEndIconClasses, contains('float-end'));
      expect(alert.resolvedCloseButtonClasses, contains('btn-close-white'));
      expect(alert.resolvedCloseButtonClasses, contains('rounded-pill'));
    });

    test('dismiss and show update visibility streams', () {
      final alert = LiAlertComponent()..visible = true;
      final visibilityValues = <bool>[];
      var dismissedCount = 0;

      alert.visibleChange.listen(visibilityValues.add);
      alert.dismissed.listen((_) {
        dismissedCount += 1;
      });

      alert.dismiss();
      alert.show();

      expect(alert.visible, isTrue);
      expect(visibilityValues, equals(<bool>[false, true]));
      expect(dismissedCount, equals(1));
    });

    test('custom icon container classes override the defaults', () {
      final alert = LiAlertComponent()
        ..solid = true
        ..roundedPill = true
        ..iconMode = 'block'
        ..iconClass = 'ph-warning-circle'
        ..iconContainerClass = 'bg-black bg-opacity-20 shadow-sm';

      expect(alert.resolvedBlockIconClasses, contains('shadow-sm'));
      expect(alert.resolvedBlockIconClasses, contains('rounded-pill'));
      expect(alert.resolvedBlockIconClasses, isNot(contains('bg-primary')));
    });
  });
}
