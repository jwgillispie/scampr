import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NatureAudioService {
  static final NatureAudioService _instance = NatureAudioService._internal();
  factory NatureAudioService() => _instance;
  NatureAudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isEnabled = true;
  double _volume = 0.3;
  String _currentTrack = 'forest_ambience';
  
  static const String _enabledKey = 'nature_audio_enabled';
  static const String _volumeKey = 'nature_audio_volume';
  static const String _trackKey = 'nature_audio_track';

  // Nature sound tracks
  static const Map<String, String> _natureTracks = {
    'forest_ambience': 'assets/sounds/forest_ambience.mp3',
    'bird_songs': 'assets/sounds/bird_songs.mp3',
    'wind_leaves': 'assets/sounds/wind_leaves.mp3',
    'stream_water': 'assets/sounds/stream_water.mp3',
    'rain_forest': 'assets/sounds/rain_forest.mp3',
    'crickets_night': 'assets/sounds/crickets_night.mp3',
    'owl_hooting': 'assets/sounds/owl_hooting.mp3',
    'campfire': 'assets/sounds/campfire.mp3',
  };

  // Initialize the service
  Future<void> initialize() async {
    try {
      await _loadSettings();
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(_volume);
      
      if (_isEnabled) {
        await playNatureSound(_currentTrack);
      }
    } catch (e) {
      print('AudioPlayer initialization failed: $e');
      _isEnabled = false;
    }
  }

  // Load settings from shared preferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool(_enabledKey) ?? true;
    _volume = prefs.getDouble(_volumeKey) ?? 0.3;
    _currentTrack = prefs.getString(_trackKey) ?? 'forest_ambience';
  }

  // Save settings to shared preferences
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, _isEnabled);
    await prefs.setDouble(_volumeKey, _volume);
    await prefs.setString(_trackKey, _currentTrack);
  }

  // Play nature sound
  Future<void> playNatureSound(String trackName) async {
    if (!_isEnabled) return;
    
    final trackPath = _natureTracks[trackName];
    if (trackPath == null) return;
    
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(trackPath.replaceFirst('assets/', '')));
      _isPlaying = true;
      _currentTrack = trackName;
      await _saveSettings();
    } catch (e) {
      // Handle error silently or log for debugging
      print('Error playing nature sound: $e');
      _isEnabled = false;
    }
  }

  // Stop nature sound
  Future<void> stopNatureSound() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
    } catch (e) {
      print('Error stopping nature sound: $e');
    }
  }

  // Pause nature sound
  Future<void> pauseNatureSound() async {
    try {
      await _audioPlayer.pause();
      _isPlaying = false;
    } catch (e) {
      print('Error pausing nature sound: $e');
    }
  }

  // Resume nature sound
  Future<void> resumeNatureSound() async {
    try {
      await _audioPlayer.resume();
      _isPlaying = true;
    } catch (e) {
      print('Error resuming nature sound: $e');
    }
  }

  // Set volume
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    try {
      await _audioPlayer.setVolume(_volume);
      await _saveSettings();
    } catch (e) {
      print('Error setting volume: $e');
    }
  }

  // Enable/disable nature audio
  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    
    if (enabled && !_isPlaying) {
      await playNatureSound(_currentTrack);
    } else if (!enabled && _isPlaying) {
      await stopNatureSound();
    }
    
    await _saveSettings();
  }

  // Play UI sound effects
  Future<void> playUISound(String soundName) async {
    if (!_isEnabled) return;
    
    final soundMap = {
      'button_tap': 'assets/sounds/button_tap.mp3',
      'success': 'assets/sounds/success.mp3',
      'error': 'assets/sounds/error.mp3',
      'notification': 'assets/sounds/notification.mp3',
      'swipe': 'assets/sounds/swipe.mp3',
      'pop': 'assets/sounds/pop.mp3',
      'tree_found': 'assets/sounds/tree_found.mp3',
      'climb_complete': 'assets/sounds/climb_complete.mp3',
    };
    
    final soundPath = soundMap[soundName];
    if (soundPath == null) return;
    
    try {
      final effectPlayer = AudioPlayer();
      await effectPlayer.setVolume(_volume * 0.5); // Lower volume for UI sounds
      await effectPlayer.play(AssetSource(soundPath.replaceFirst('assets/', '')));
      await effectPlayer.setReleaseMode(ReleaseMode.release);
    } catch (e) {
      print('Error playing UI sound: $e');
      _isEnabled = false;
    }
  }

  // Add haptic feedback for enhanced nature feel
  Future<void> playHapticFeedback(HapticFeedbackType type) async {
    if (!_isEnabled) return;
    
    switch (type) {
      case HapticFeedbackType.light:
        await HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.medium:
        await HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        await HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.vibrate:
        await HapticFeedback.vibrate();
        break;
    }
  }

  // Get available nature tracks
  List<String> getAvailableTracks() {
    return _natureTracks.keys.toList();
  }

  // Get track display name
  String getTrackDisplayName(String trackName) {
    switch (trackName) {
      case 'forest_ambience':
        return 'Forest Ambience';
      case 'bird_songs':
        return 'Bird Songs';
      case 'wind_leaves':
        return 'Wind Through Leaves';
      case 'stream_water':
        return 'Flowing Stream';
      case 'rain_forest':
        return 'Forest Rain';
      case 'crickets_night':
        return 'Night Crickets';
      case 'owl_hooting':
        return 'Owl Hooting';
      case 'campfire':
        return 'Campfire Crackling';
      default:
        return trackName;
    }
  }

  // Getters
  bool get isEnabled => _isEnabled;
  bool get isPlaying => _isPlaying;
  double get volume => _volume;
  String get currentTrack => _currentTrack;

  // Dispose
  Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
    } catch (e) {
      print('Error disposing audio player: $e');
    }
  }
}

enum HapticFeedbackType {
  light,
  medium,
  heavy,
  vibrate,
}