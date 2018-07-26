import 'dart:async';
import 'package:rxdart/rxdart.dart';

// Playing with concepts & ideas from
// https://medium.com/@quickbirdstudio/app-architecture-mvvm-in-flutter-using-dart-streams-26f6bd6ae4b6
// and mixing with https://github.com/ReactiveX/rxdart

abstract class ViewModel {
  void dispose();
}

abstract class MediaViewModel extends ViewModel {
  // Wrappers to return the latest value in the underlying streams
  String get title;
  PlayState get playState;

  // Wrapper for adding play states to the sink
  set playState(PlayState playState);

  Sink<PlayState> get playStateSink;

  Stream<String> get titleStream;
  Stream<PlayState> get playStateStream;
}

enum PlayState { Playing, Stopped, Paused }

class MediaViewModelImpl extends MediaViewModel {
  final _mediaTitleController = BehaviorSubject<String>();
  final _mediaPlayStateController = BehaviorSubject<PlayState>();

  MediaViewModelImpl(String title) {
    _mediaTitleController.add(title);
    _mediaPlayStateController.add(PlayState.Stopped);
  }

  @override
  String get title => _mediaTitleController.value;

  @override
  PlayState get playState => _mediaPlayStateController.value;

  @override
  Sink<PlayState> get playStateSink => _mediaPlayStateController;

  @override
  set playState(PlayState playState) =>
      _mediaPlayStateController.add(playState);

  @override
  Stream<String> get titleStream => _mediaTitleController.stream;

  @override
  Stream<PlayState> get playStateStream => _mediaPlayStateController.stream;

  @override
  void dispose() {
    _mediaPlayStateController.close();
    _mediaTitleController.close();
  }
}
