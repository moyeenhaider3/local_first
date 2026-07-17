import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:local_first/core/error/failures.dart';
import 'package:local_first/core/theme/design_tokens.dart';

/// Global Error Handler to catch uncaught crashes and provide user-facing error feedback.
class ErrorHandler {
  ErrorHandler._();

  /// Initialize global Flutter error hooks.
  static void init() {
    // Catch framework errors and render a clean, friendly error UI instead of the red screen
    ErrorWidget.builder = (FlutterErrorDetails details) {
      if (kDebugMode) {
        return ErrorWidget(details.exception);
      }
      return const GenericErrorWidget();
    };

    // Log uncaught errors that happen outside the widget tree (e.g. async errors)
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _logError(details.exception, details.stack);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      _logError(error, stack);
      return true;
    };
  }

  /// Maps any error object to a clean, user-friendly string message.
  static String getDisplayMessage(dynamic error) {
    if (error is Failure) {
      return error.message;
    }
    if (error is Exception) {
      final str = error.toString();
      // Clean up Exception: prefix if present
      if (str.startsWith('Exception: ')) {
        return str.substring(11);
      }
      return str;
    }
    return 'An unexpected error occurred. Please try again.';
  }

  /// Displays a user-friendly error snackbar.
  static void showSnackBar(BuildContext context, dynamic error) {
    final message = getDisplayMessage(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: DesignTokens.kSpace8),
            Expanded(
              child: Text(
                message,
                style: DesignTokens.bodySmall.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: DesignTokens.colorDanger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static void _logError(Object error, StackTrace? stack) {
    // In a real app, send to Sentry, Crashlytics, etc.
    debugPrint('[GLOBAL ERROR]: $error\n$stack');
  }
}

/// A sleek, premium widget displayed when a widget crash occurs.
class GenericErrorWidget extends StatelessWidget {
  const GenericErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.colorBgDark,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.kEdgeMargin),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(DesignTokens.kSpace16),
                decoration: BoxDecoration(
                  color: DesignTokens.colorDanger.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: DesignTokens.colorDanger,
                  size: 48,
                ),
              ),
              const SizedBox(height: DesignTokens.kSpace24),
              Text(
                'Something went wrong',
                style: DesignTokens.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignTokens.kSpace8),
              Text(
                'A visual interface error occurred. We have logged this issue and our team is on it.',
                style: DesignTokens.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
