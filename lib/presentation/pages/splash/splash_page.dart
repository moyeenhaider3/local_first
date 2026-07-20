import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:local_first/core/di/service_locator.dart';
import 'package:local_first/data/models/app_update_status.dart';
import 'package:local_first/data/repositories/settings_repository.dart';
import 'package:local_first/presentation/widgets/common/update_dialog.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  static const Duration _splashDuration = Duration(milliseconds: 1600);
  static const Duration _updateTimeout = Duration(seconds: 5);

  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  bool _launchFlowStarted = false;
  bool _routingCompleted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startLaunchFlow();
    });
  }

  Future<void> _startLaunchFlow() async {
    if (_launchFlowStarted) {
      return;
    }
    setState(() {
      _launchFlowStarted = true;
    });

    await Future<void>.delayed(_splashDuration);
    if (!mounted) {
      return;
    }

    final updateStatus = await _loadUpdateStatus();
    if (!mounted) {
      return;
    }

    if (updateStatus == null || !updateStatus.updateAvailable) {
      _continueToApp();
      return;
    }

    if (updateStatus.forceUpdate) {
      await _showForceUpdateDialog(updateStatus);
      return;
    }

    final action = await UpdateDialog.show(context, updateStatus);
    if (!mounted) {
      return;
    }

    if (action == UpdateDialogAction.later) {
      _continueToApp();
    }
  }

  Future<AppUpdateStatus?> _loadUpdateStatus() async {
    try {
      return await sl<SettingsRepository>().checkForAppUpdate().timeout(
        _updateTimeout,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _showForceUpdateDialog(AppUpdateStatus status) async {
    await UpdateDialog.show(context, status);
  }

  void _continueToApp() {
    if (_routingCompleted) {
      return;
    }
    setState(() {
      _routingCompleted = true;
    });
    final user = FirebaseAuth.instance.currentUser;
    context.go(user == null ? '/' : '/home');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              Color(0xFF0F172A),
              Color(0xFF1E293B),
              Color(0xFF334155),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.home_work_rounded,
                  size: 72,
                  color: theme.colorScheme.onPrimary,
                ),
                const SizedBox(height: 20),
                Text(
                  'Local First',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
