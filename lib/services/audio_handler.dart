import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

/// Custom AudioHandler that manages Surah Al-Baqarah playback as a
/// foreground media service with notification controls.
class QuranAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  QuranAudioHandler() {
    // Broadcast player state changes to the system
    // Using listen+add instead of pipe to avoid stream conflicts on stop()
    _player.playbackEventStream.map(_transformEvent).listen((state) {
      playbackState.add(state);
    });
  }

  /// Loads and plays the Surah from the given URL.
  Future<void> playFromUrl(String url, String reciterName) async {
    try {
      // Set the media item metadata for the notification
      mediaItem.add(
        MediaItem(
          id: url,
          album: 'القرآن الكريم',
          title: 'سورة البقرة',
          artist: reciterName,
          duration: const Duration(hours: 2), // Approximate
        ),
      );

      await _player.setUrl(url);
      _player.play(); // Do not await, as it blocks until playback finishes
    } catch (e) {
      // If online fails, the caller should handle fallback
      rethrow;
    }
  }

  /// Play from a local file path.
  Future<void> playFromFile(String filePath, String reciterName) async {
    mediaItem.add(
      MediaItem(
        id: filePath,
        album: 'القرآن الكريم',
        title: 'سورة البقرة',
        artist: reciterName,
        duration: const Duration(hours: 2),
      ),
    );

    await _player.setFilePath(filePath);
    _player.play(); // Do not await
  }

  @override
  Future<void> play() async {
    _player.play(); // Do not await
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  /// Whether audio is currently playing.
  bool get isPlaying => _player.playing;

  /// Stream that emits when playback completes.
  Stream<ProcessingState> get processingStateStream =>
      _player.processingStateStream;

  /// Current position stream.
  Stream<Duration> get positionStream => _player.positionStream;

  /// Duration of current audio.
  Duration? get duration => _player.duration;

  /// Set playback volume (0.0 to 1.0).
  Future<void> setVolume(double volume) => _player.setVolume(volume);

  /// Transform JustAudio events into AudioService PlaybackState.
  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.rewind,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.fastForward,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
