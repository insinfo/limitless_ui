import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'scrollspy-page',
  templateUrl: 'scrollspy_page.html',
  styleUrls: ['scrollspy_page.css'],
  directives: [
    coreDirectives,
    LiTabsComponent,
    LiTabxDirective,
    LiScrollSpyDirective,
    LiScrollSpyFragmentDirective,
    LiScrollSpyItemDirective,
    LiScrollSpyMenuDirective,
  ],
)
class ScrollspyPageComponent {
  @ViewChild('demoSpy')
  LiScrollSpyDirective? demoSpy;

  String activeSection = 'overview';

  void onActiveChange(String fragment) {
    activeSection = fragment.isEmpty ? 'overview' : fragment;
  }

  void scrollToFragment(String fragment) {
    demoSpy?.scrollTo(fragment,
        options: const LiScrollToOptions(behavior: 'auto'));
  }
}
