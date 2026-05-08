import 'dart:async';
import 'dart:html';

import 'datatable_models.dart';

/// Emits optional debug instrumentation events.
class DatatableInstrumentationController {
  final StreamController<LiDatatableInstrumentationEvent> _controller =
      StreamController<LiDatatableInstrumentationEvent>.broadcast();

  int _sequence = 0;

  /// Whether instrumentation events should be emitted.
  bool enabled = false;

  /// User-provided label override.
  String label = '';

  /// Event stream exposed by the component.
  Stream<LiDatatableInstrumentationEvent> get stream => _controller.stream;

  /// Emits an event when [enabled] is `true`.
  void emit(
    String stage, {
    required Element rootElement,
    int? elapsedMicroseconds,
    Map<String, Object?> details = const <String, Object?>{},
  }) {
    if (!enabled) {
      return;
    }

    final event = LiDatatableInstrumentationEvent(
      label: _resolveLabel(rootElement),
      stage: stage,
      timestamp: DateTime.now(),
      elapsedMicroseconds: elapsedMicroseconds,
      details: <String, Object?>{
        'seq': ++_sequence,
        ...details,
      },
    );

    if (!_controller.isClosed) {
      _controller.add(event);
    }

    window.console.log(
      '[li-datatable:${event.label}] ${event.formattedMessage}',
    );
  }

  /// Closes the event stream.
  void close() {
    _controller.close();
  }

  String _resolveLabel(Element rootElement) {
    final normalized = label.trim();
    if (normalized.isNotEmpty) {
      return normalized;
    }

    final elementId = rootElement.id.trim();
    if (elementId.isNotEmpty) {
      return elementId;
    }

    return 'datatable';
  }
}
