import 'package:test/test.dart';

import 'package:flow/media.dart';

void main() {
  test('creates a new MediaViewModel', () {
    final MediaViewModel media = MediaViewModelImpl('My Movie');

    expect(media.title, 'My Movie');
    expect(media.playState, PlayState.Stopped);

    media.titleStream.listen((title) => expect(title, 'My Movie'));
    media.playStateStream.listen((state) => expect(state, PlayState.Stopped));
  });

  test('changes the play state of media', () {
    final MediaViewModel media = MediaViewModelImpl('My Movie');

    expect(media.playState, PlayState.Stopped);

    media.playState = PlayState.Playing;
    expect(media.playState, PlayState.Playing);

    media.playState = PlayState.Paused;
    expect(media.playState, PlayState.Paused);
  });

  test('disposing of media multiple times doesn\'t crash', () {
    final MediaViewModel media = MediaViewModelImpl('My Movie');
    media.dispose();
    media.dispose();
  });
}
