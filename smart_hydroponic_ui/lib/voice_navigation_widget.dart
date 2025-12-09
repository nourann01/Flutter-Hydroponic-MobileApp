import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class VoiceNavigationWidget extends StatefulWidget {
  const VoiceNavigationWidget({Key? key}) : super(key: key);

  @override
  State<VoiceNavigationWidget> createState() => _VoiceNavigationWidgetState();
}

class _VoiceNavigationWidgetState extends State<VoiceNavigationWidget>
    with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isInitialized = false;
  String _recognizedText = '';
  late AnimationController _animationController;

  // Navigation routes mapping
  final Map<String, String> _navigationRoutes = {
    'dashboard': '/dashboard',
    'home': '/dashboard',
    'sensors': '/sensors',
    'sensor': '/sensors',
    'analytics': '/analytics',
    'analytic': '/analytics',
    'control panel': '/control-panel',
    'control': '/control-panel',
    'alerts': '/alerts',
    'alert': '/alerts',
    'notification': '/alerts',
    'notifications': '/alerts',
    'settings': '/settings',
    'setting': '/settings',
    'login': '/login',
    'register': '/register',
    'sign in': '/login',
    'sign up': '/register',
  };

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    try {
      // Request microphone permission
      var status = await Permission.microphone.request();

      if (status.isGranted) {
        bool available = await _speech.initialize(
          onError: (error) {
            print('Speech recognition error: ${error.errorMsg}');
            setState(() => _isListening = false);
            _animationController.stop();
          },
          onStatus: (status) {
            print('Speech recognition status: $status');
            if (status == 'done' || status == 'notListening') {
              setState(() => _isListening = false);
              _animationController.stop();
            }
          },
        );

        setState(() {
          _isInitialized = available;
        });

        if (!available) {
          _showSnackBar('Speech recognition not available', isError: true);
        }
      } else {
        _showSnackBar('Microphone permission denied', isError: true);
      }
    } catch (e) {
      print('Error initializing speech: $e');
      _showSnackBar('Failed to initialize speech recognition', isError: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _listen() async {
    if (!_isInitialized) {
      _showSnackBar('Speech recognition not initialized', isError: true);
      await _initializeSpeech();
      return;
    }

    if (!_isListening) {
      try {
        setState(() => _isListening = true);
        _animationController.repeat(reverse: true);

        await _speech.listen(
          onResult: (result) {
            setState(() {
              _recognizedText = result.recognizedWords.toLowerCase();
            });
            print('Recognized: $_recognizedText');

            // Process voice command when finalized
            if (result.finalResult) {
              _processVoiceCommand(_recognizedText);
            }
          },
          listenFor: const Duration(seconds: 10),
          pauseFor: const Duration(seconds: 3),
          cancelOnError: true,
          listenMode: stt.ListenMode.confirmation,
        );
      } catch (e) {
        print('Error starting listening: $e');
        setState(() => _isListening = false);
        _animationController.stop();
        _showSnackBar('Failed to start listening', isError: true);
      }
    } else {
      setState(() => _isListening = false);
      _animationController.stop();
      await _speech.stop();
    }
  }

  void _processVoiceCommand(String command) {
    print('Processing command: $command');

    // Check for "go to" command
    if (command.contains('go to') || command.contains('goto')) {
      String destination = command
          .replaceAll('go to', '')
          .replaceAll('goto', '')
          .trim();
      _navigateToDestination(destination);
    } else if (command.contains('open')) {
      String destination = command.replaceAll('open', '').trim();
      _navigateToDestination(destination);
    } else {
      // Try direct navigation without "go to" or "open"
      _navigateToDestination(command);
    }
  }

  void _navigateToDestination(String destination) {
    String? route;
    String matchedKey = '';

    // Find matching route
    for (var entry in _navigationRoutes.entries) {
      if (destination.contains(entry.key)) {
        route = entry.value;
        matchedKey = entry.key;
        break;
      }
    }

    if (route != null && mounted) {
      _showSnackBar('Opening $matchedKey...');

      // Small delay for better UX
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pushNamed(context, route!).catchError((error) {
            _showSnackBar('Could not navigate to $matchedKey', isError: true);
            return null;
          });
        }
      });
    } else {
      _showSnackBar('Unknown command: $destination', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError
              ? Colors.red.shade600
              : Colors.green.shade600,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _listen,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: _isListening
                ? [Colors.red.shade400, Colors.red.shade600]
                : [Colors.white, Colors.white],
          ),
          boxShadow: [
            BoxShadow(
              color: (_isListening ? Colors.red : Colors.white).withOpacity(
                0.3,
              ),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Animated pulse effect when listening
            if (_isListening)
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Container(
                    width: 48 + (_animationController.value * 16),
                    height: 48 + (_animationController.value * 16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.red.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                  );
                },
              ),
            // Microphone icon
            Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: _isListening ? Colors.white : Colors.green.shade700,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
