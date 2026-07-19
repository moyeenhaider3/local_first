import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A reusable 4-digit numeric code entry widget.
///
/// Features auto-advance to the next field on entry, automatic backspace focus
/// fallback, error shake animation, and success checkmark overlay.
class CodeInputWidget extends StatefulWidget {
  /// Callback triggered whenever the entered code changes.
  final ValueChanged<String>? onChanged;

  /// Callback triggered when all 4 digits are successfully entered.
  final ValueChanged<String>? onCompleted;

  /// Whether the code input cells are interactive.
  final bool enabled;

  /// Creates a [CodeInputWidget].
  const CodeInputWidget({
    super.key,
    this.onChanged,
    this.onCompleted,
    this.enabled = true,
  });

  @override
  State<CodeInputWidget> createState() => CodeInputWidgetState();
}

/// State implementation of [CodeInputWidget], exposing public control methods.
class CodeInputWidgetState extends State<CodeInputWidget>
    with SingleTickerProviderStateMixin {
  /// Focus nodes to manage input field focus sequence.
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  /// Text controllers to retrieve and manage individual digit characters.
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());

  /// Animation controller to power the error shake animation.
  late AnimationController _shakeController;

  /// Offset animation sequence for the shake behavior.
  late Animation<double> _shakeAnimation;

  /// Current visual state tracking.
  bool _hasError = false;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));

    // Setup key listeners on each node to catch backspaces even when text is empty.
    for (int i = 0; i < 4; i++) {
      _focusNodes[i].onKeyEvent = (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace) {
          if (_controllers[i].text.isEmpty && i > 0) {
            _focusNodes[i - 1].requestFocus();
            _controllers[i - 1].clear();
            _updateCode();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      };
    }
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    _shakeController.dispose();
    super.dispose();
  }

  /// Triggers a brief horizontal shake animation and highlights borders in red.
  void triggerError() {
    setState(() {
      _hasError = true;
      _isSuccess = false;
    });
    _shakeController.forward(from: 0.0);
  }

  /// Displays the checkmark overlay and changes border highlights to green.
  void triggerSuccess() {
    setState(() {
      _isSuccess = true;
      _hasError = false;
    });
  }

  /// Resets the widget states and clears all entered digits.
  void reset() {
    setState(() {
      _hasError = false;
      _isSuccess = false;
    });
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  /// Helper to aggregate entered digits and fire callbacks.
  void _updateCode() {
    final code = _controllers.map((c) => c.text).join();
    widget.onChanged?.call(code);
    if (code.length == 4) {
      widget.onCompleted?.call(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeAnimation.value, 0.0),
              child: child,
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              return Container(
                width: 48.0,
                height: 52.0,
                margin: EdgeInsets.symmetric(
                  horizontal: index == 0 ? 0.0 : 4.0,
                ),
                child: TextFormField(
                  enabled: widget.enabled,
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(1),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                        color: _isSuccess
                            ? const Color(0xFF16A34A)
                            : (_hasError
                                ? const Color(0xFFDC2626)
                                : const Color(0xFFCBD5E1)),
                        width: _isSuccess || _hasError ? 2.0 : 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                        color: _isSuccess
                            ? const Color(0xFF16A34A)
                            : (_hasError
                                ? const Color(0xFFDC2626)
                                : const Color(0xFF0D9488)),
                        width: 2.0,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      _hasError = false;
                      if (index < 3) {
                        _focusNodes[index + 1].requestFocus();
                      } else {
                        _focusNodes[index].unfocus();
                      }
                    }
                    _updateCode();
                  },
                ),
              );
            }),
          ),
        ),
        if (_isSuccess)
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: _isSuccess ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle,
                    color: Color(0xFF16A34A),
                    size: 36.0,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
