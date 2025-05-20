import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../config/api_config.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;

  const AudioPlayerWidget({
    Key? key,
    required this.audioUrl,
  }) : super(key: key);

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    try {
      // Configure the audio session
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());

      // Set up the audio source with a fixed URL
      final audioSource = AudioSource.uri(
        Uri.parse('${ApiConfig.baseUrl}/api/audio/tts_output.wav'),
        headers: {
          'Cache-Control': 'no-cache',
          'Pragma': 'no-cache',
        },
      );

      // Set the audio source
      await _audioPlayer.setAudioSource(audioSource);

      // Listen to player state changes
      _audioPlayer.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
            _isLoading = state.processingState == ProcessingState.loading ||
                        state.processingState == ProcessingState.buffering;
          });
        }
      });

      // Listen to errors
      _audioPlayer.playbackEventStream.listen(
        (event) {},
        onError: (Object e, StackTrace stackTrace) {
          if (mounted) {
            setState(() {
              _errorMessage = 'Error playing audio: $e';
            });
          }
        },
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error initializing audio player: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        // Reload the audio source before playing
        final audioSource = AudioSource.uri(
          Uri.parse('${ApiConfig.baseUrl}/api/audio/tts_output.wav'),
          headers: {
            'Cache-Control': 'no-cache',
            'Pragma': 'no-cache',
          },
        );
        await _audioPlayer.setAudioSource(audioSource);
        await _audioPlayer.play();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error toggling playback: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: _isLoading ? null : _togglePlayPause,
              ),
              if (_isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ],
      ),
    );
  }
} 