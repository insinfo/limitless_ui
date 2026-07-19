/// Transitional `dart:html` → `package:web` facade used by limitless_ui 3.x.
///
/// It reexports the canonical browser API together with the small adapters
/// that still preserve behavior needed by the migration. Consumers need one
/// import only; aliases that keep legacy names are transitional.
library;

export 'package:web/web.dart'
    hide
        MutationObserver,
        ResizeObserver,
        IntersectionObserver,
        NodeGlue,
        TouchListConvert,
        createCanvasElement,
        createIFrameElement,
        createAudioElement,
        querySelector,
        EventGlue,
        HtmlElement,
        ImageElement,
        CanvasElement,
        AudioElement,
        VideoElement,
        CssStyleDeclaration;
export 'src/web_compat/web_compat.dart';
