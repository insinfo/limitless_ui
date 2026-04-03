import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'time-picker-page',
  templateUrl: 'time_picker_page.html',
  styleUrls: ['time_picker_page.css'],
  directives: [
    coreDirectives,
    DemoPageBreadcrumbComponent,
    formDirectives,
    LiTabsComponent,
    LiTabxDirective,
    LiTimePickerComponent,
  ],
)
class TimePickerPageComponent {
  TimePickerPageComponent(this.i18n);

  final DemoI18nService i18n;
  Messages get t => i18n.t;

  Duration? selectedTime = const Duration(hours: 10, minutes: 48);
  Duration? selectedTime24h = const Duration(hours: 18, minutes: 30);
  Duration? reviewTime = const Duration(hours: 12, minutes: 0);
  Duration? disabledTime = const Duration(hours: 21, minutes: 15);

  String get selectedTimeLabel => _formatTime(selectedTime);
  String get selectedTime24hLabel => _formatTime24(selectedTime24h);

  String get reviewTimeLabel => _formatTime(reviewTime);

  String get disabledTimeLabel => _formatTime(disabledTime);

  String _formatTime(Duration? value) {
    if (value == null) {
      return t.pages.timePicker.noneSelected;
    }

    final totalMinutes = value.inMinutes % (24 * 60);
    final normalizedMinutes =
        totalMinutes < 0 ? totalMinutes + (24 * 60) : totalMinutes;
    final hour24 = normalizedMinutes ~/ 60;
    final minute = normalizedMinutes % 60;
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final hourText = hour12.toString().padLeft(2, '0');
    final minuteText = minute.toString().padLeft(2, '0');
    return '$hourText:$minuteText $period';
  }

  String _formatTime24(Duration? value) {
    if (value == null) {
      return t.pages.timePicker.noneSelected;
    }

    final totalMinutes = value.inMinutes % (24 * 60);
    final normalizedMinutes =
        totalMinutes < 0 ? totalMinutes + (24 * 60) : totalMinutes;
    final hour24 = normalizedMinutes ~/ 60;
    final minute = normalizedMinutes % 60;
    final hourText = hour24.toString().padLeft(2, '0');
    final minuteText = minute.toString().padLeft(2, '0');
    return '$hourText:$minuteText';
  }
}
