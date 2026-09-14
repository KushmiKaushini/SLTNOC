import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  bool _isSpeechAvailable = false;
  bool _isListening = false;
  String? _currentlySpeakingId;

  bool get isSpeechAvailable => _isSpeechAvailable;
  bool get isListening => _isListening;
  String? get currentlySpeakingId => _currentlySpeakingId;

  Future<void> initialize() async {
    try {
      _isSpeechAvailable = await _speechToText.initialize();
    } catch (e) {
      if (kDebugMode) debugPrint('Speech to text init failed: $e');
      _isSpeechAvailable = false;
    }
  }

  Future<void> toggleListening({
    required void Function(String words) onResult,
    required void Function(bool listening) onStateChange,
  }) async {
    if (_isListening) {
      await _speechToText.stop();
      _isListening = false;
      onStateChange(false);
    } else {
      await _speechToText.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
        },
        listenOptions: SpeechListenOptions(
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
        ),
      );
      _isListening = true;
      onStateChange(true);
    }
  }

  Future<void> speak({
    required String messageId,
    required String text,
    required VoidCallback onSpeakingStateChanged,
  }) async {
    if (_currentlySpeakingId == messageId) {
      await _flutterTts.stop();
      _currentlySpeakingId = null;
      onSpeakingStateChanged();
      return;
    }

    await _flutterTts.stop();

    // Check if message text contains Sinhala characters (Unicode range ඀-෿)
    final RegExp sinhalaRegex = RegExp(r'[඀-෿]');
    if (sinhalaRegex.hasMatch(text)) {
      await _flutterTts.setLanguage("si-LK");
    } else {
      await _flutterTts.setLanguage("en-US");
    }

    _currentlySpeakingId = messageId;
    onSpeakingStateChanged();

    _flutterTts.setCompletionHandler(() {
      _currentlySpeakingId = null;
      onSpeakingStateChanged();
    });

    _flutterTts.setErrorHandler((msg) {
      _currentlySpeakingId = null;
      onSpeakingStateChanged();
    });

    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _speechToText.stop();
    await _flutterTts.stop();
    _isListening = false;
    _currentlySpeakingId = null;
  }
}
