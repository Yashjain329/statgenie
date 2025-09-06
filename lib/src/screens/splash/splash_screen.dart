import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _ready = false;
  Timer? _timeout;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _controller = VideoPlayerController.asset('assets/statgenie-logo-video.mp4');
    try {
      await _controller.initialize();
      _controller.setLooping(false);
      // Optional: control volume
      // _controller.setVolume(0.0);
      setState(() => _ready = true);
      unawaited(_controller.play());

      // Go when video ends
      _controller.addListener(() {
        if (_controller.value.isInitialized &&
            !_controller.value.isPlaying &&
            _controller.value.position >= (_controller.value.duration)) {
          _navigateNext();
        }
      });
    } catch (_) {
      // On error, still proceed after fallback timeout
      _navigateNext(delay: const Duration(milliseconds: 800));
      return;
    }

    // Absolute max time in splash (failsafe)
    _timeout = Timer(const Duration(seconds: 6), () {
      if (mounted) _navigateNext();
    });
  }

  Future<void> _navigateNext({Duration? delay}) async {
    _timeout?.cancel();
    if (delay != null) await Future.delayed(delay);
    if (!mounted) return;

    final authed = context.read<AuthProvider>();
    await authed.checkAuthState();
    if (!mounted) return;
    context.go(authed.isAuthenticated ? '/home' : '/auth/login');
  }

  @override
  void dispose() {
    _timeout?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF00BCD4), Color(0xFF00838F)],
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: bg),
        child: SafeArea(
          child: Center(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _ready
                    ? VideoPlayer(_controller)
                    : _fallback(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fallback() {
    // Show logo or a spinner while video initializes
    return Container(
      color: Colors.black26,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.bar_chart_rounded, color: Colors.white, size: 72),
          SizedBox(height: 16),
          CircularProgressIndicator(color: Colors.white),
        ],
      ),
    );
  }
}

// Helper to ignore future
void unawaited(Future<void> f) {}