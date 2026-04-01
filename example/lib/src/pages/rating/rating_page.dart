import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'rating-page',
  templateUrl: 'rating_page.html',
  styleUrls: ['rating_page.css'],
  directives: [
    coreDirectives,
    formDirectives,
    LiRatingComponent,
  ],
)
class RatingPageComponent {
  num productRating = 4;
  num serviceRating = 2;
  num readonlyRating = 3.5;
  num disabledRating = 4;
  num hoverPreview = 0;

  String get hoverLabel =>
      hoverPreview <= 0 ? 'Passe o mouse nas estrelas.' : 'Preview: $hoverPreview';
}
