import 'package:ngforms/ngforms.dart';

import 'indexed_name_directive.dart';
import 'li_auto_click_file_input_directive.dart';
import 'li_disable_browser_autocomplete_directive.dart';
import 'li_editable_text_directive.dart';
import 'li_form_directive.dart';
import 'li_form_validators.dart';
import 'value_accessors/custom_checkbox_control_value_accessor.dart';
import 'value_accessors/custom_number_value_acessor.dart';
import 'value_accessors/custom_select_control_value_acessor.dart';
import 'value_accessors/date_value_accessor.dart';
import 'value_accessors/datetime_value_acessor_diretive.dart';
import 'value_accessors/min_max_diretive.dart';

/// Convenience bundle of generic form directives and value accessors provided
/// by `limitless_ui`.
const List<Type> limitlessFormDirectives = [
  NgControlName,
  NgControlGroup,
  NgFormControl,
  NgModel,
  NgFormModel,
  NgForm,
  DefaultValueAccessor,
  LiNumberValueAccessor,
  LiCheckboxControlValueAccessor,
  RadioControlValueAccessor,
  RequiredValidator,
  MinLengthValidator,
  MaxLengthValidator,
  PatternValidator,
  LiRequiredValidator,
  LiDocumentValidator,
  LiNativeValidationFeedbackDirective,
  LiNgSelectOption,
  LiSelectControlValueAccessor,
  LiDateValueAccessor,
  LiDateTimeValueAccessor,
  LiMinMaxDirective,
  LiIndexedNameDirective,
  LiAutoClickFileInputDirective,
  LiDisableBrowserAutocompleteDirective,
  LiEditableTextDirective,
  LiFormDirective,
  LiFormFieldDirective,
];
