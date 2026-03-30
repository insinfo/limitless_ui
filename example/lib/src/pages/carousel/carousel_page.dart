import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'carousel-page',
  templateUrl: 'carousel_page.html',
  styleUrls: ['carousel_page.css'],
  directives: [
    coreDirectives,
    LiTabsComponent,
    LiTabxDirective,
    LiCarouselComponent,
    LiCarouselCaptionComponent,
    LiCarouselItemComponent,
  ],
)
class CarouselPageComponent {
  CarouselPageComponent(this.i18n);

  final DemoI18nService i18n;
  Messages get t => i18n.t;
}
