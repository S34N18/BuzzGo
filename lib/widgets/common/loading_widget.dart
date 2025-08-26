import 'package:flutter/material.dart';
import 'dart:math';

enum LoadingType { circular, linear, dots, pulse }

class LoadingWidget extends StatefulWidget {
  final LoadingType type;
  final String? message;
  final Color? color;
  final double size;
  final bool showMessage;

  const LoadingWidget({
    super.key,
    this.type = LoadingType.circular,
    this.message,
    this.color,
    this.size = 40.0,
    this.showMessage = true,
  });

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loadingColor = widget.color ?? colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLoadingIndicator(loadingColor),
        if (widget.showMessage && widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingIndicator(Color color) {
    switch (widget.type) {
      case LoadingType.circular:
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeWidth: 3,
          ),
        );

      case LoadingType.linear:
        return SizedBox(
          width: widget.size * 2,
          child: LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
            backgroundColor: color.withOpacity(0.2),
          ),
        );

      case LoadingType.dots:
        return _buildDotsIndicator(color);

      case LoadingType.pulse:
        return _buildPulseIndicator(color);
    }
  }

  Widget _buildDotsIndicator(Color color) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animationValue = (_animation.value - delay).clamp(0.0, 1.0);
            final scale = (sin(animationValue * pi) * 0.5 + 0.5).clamp(0.3, 1.0);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.size / 4,
                  height: widget.size / 4,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildPulseIndicator(Color color) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final scale = (sin(_animation.value * 2 * pi) * 0.3 + 0.7);
        final opacity = (sin(_animation.value * 2 * pi) * 0.5 + 0.5);

        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: color.withOpacity(opacity),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event,
              color: Colors.white,
              size: widget.size * 0.5,
            ),
          ),
        );
      },
    );
  }
}

// Convenience widgets
class CircularLoading extends LoadingWidget {
  const CircularLoading({
    super.key,
    super.message,
    super.color,
    super.size = 40.0,
    super.showMessage = true,
  }) : super(type: LoadingType.circular);
}

class LinearLoading extends LoadingWidget {
  const LinearLoading({
    super.key,
    super.message,
    super.color,
    super.size = 40.0,
    super.showMessage = true,
  }) : super(type: LoadingType.linear);
}

class DotsLoading extends LoadingWidget {
  const DotsLoading({
    super.key,
    super.message,
    super.color,
    super.size = 40.0,
    super.showMessage = true,
  }) : super(type: LoadingType.dots);
}

class PulseLoading extends LoadingWidget {
  const PulseLoading({
    super.key,
    super.message,
    super.color,
    super.size = 40.0,
    super.showMessage = true,
  }) : super(type: LoadingType.pulse);
}

// Full screen loading overlay
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;
  final LoadingType type;
  final Color? backgroundColor;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
    this.type = LoadingType.circular,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black.withOpacity(0.5),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: LoadingWidget(
                  type: type,
                  message: message,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Import for sin function
