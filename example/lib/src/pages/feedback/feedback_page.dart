import 'package:limitless_ui_example/limitless_ui_example.dart';
@Component(
  selector: 'feedback-page',
  templateUrl: 'feedback_page.html',
  styleUrls: ['feedback_page.css'],
  directives: [
    coreDirectives,
    LiTabsComponent,
    LiTabxDirective,
    LiAlertComponent,
    LiProgressComponent,
    LiProgressBarComponent,
  ],
)
class FeedbackPageComponent {
  bool releaseAlertVisible = true;

  void restoreReleaseAlert() {
    releaseAlertVisible = true;
  }

  void dismissReleaseAlert() {
    releaseAlertVisible = false;
  }
}
