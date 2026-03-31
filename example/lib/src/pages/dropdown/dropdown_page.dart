import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'dropdown-page',
  templateUrl: 'dropdown_page.html',
  directives: [
    coreDirectives,
    LiTabsComponent,
    LiTabxDirective,
    LiDropdownDirective,
    LiDropdownAnchorDirective,
    LiDropdownToggleDirective,
    LiDropdownMenuDirective,
    LiDropdownItemDirective,
    LiDropdownButtonItemDirective,
  ],
)
class DropdownPageComponent {
  String dropdownState = 'Dropdown: aguardando interação';

  void onOpenChange(bool open) {
    dropdownState = open ? 'Dropdown: menu aberto' : 'Dropdown: menu fechado';
  }
}
