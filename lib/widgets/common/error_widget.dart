import 'package:flutter/material.dart';

enum ErrorType { general, network, notFound, permission, server }

class CustomErrorWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final ErrorType type;
  final VoidCallback? onRetry;
  final String? retryButtonText;
  final IconData? icon;
  final Color? iconColor;
  final bool showIcon;

  const CustomErrorWidget({
    super.key,
    this.title,
    this.message,
    this.type = ErrorType.general,
    this.onRetry,
    this.retryButtonText,
    this.icon,
    this.iconColor,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Icon(
                icon ?? _getErrorIcon(),
                size: 80,
                color: iconColor ?? _getErrorColor(colorScheme),
              ),
              const SizedBox(height: 24),
            ],
            Text(
              title ?? _getErrorTitle(),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message ?? _getErrorMessage(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryButtonText ?? 'Try Again'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getErrorIcon() {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.notFound:
        return Icons.search_off;
      case ErrorType.permission:
        return Icons.lock;
      case ErrorType.server:
        return Icons.error;
      case ErrorType.general:
      default:
        return Icons.error_outline;
    }
  }

  Color _getErrorColor(ColorScheme colorScheme) {
    switch (type) {
      case ErrorType.network:
        return Colors.orange;
      case ErrorType.notFound:
        return Colors.grey;
      case ErrorType.permission:
        return Colors.red;
      case ErrorType.server:
        return Colors.deepOrange;
      case ErrorType.general:
      default:
        return colorScheme.error;
    }
  }

  String _getErrorTitle() {
    switch (type) {
      case ErrorType.network:
        return 'No Internet Connection';
      case ErrorType.notFound:
        return 'Nothing Found';
      case ErrorType.permission:
        return 'Permission Denied';
      case ErrorType.server:
        return 'Server Error';
      case ErrorType.general:
      default:
        return 'Something Went Wrong';
    }
  }

  String _getErrorMessage() {
    switch (type) {
      case ErrorType.network:
        return 'Please check your internet connection and try again.';
      case ErrorType.notFound:
        return 'We couldn\'t find what you\'re looking for. Try adjusting your search or filters.';
      case ErrorType.permission:
        return 'You don\'t have permission to access this content. Please contact support if you think this is an error.';
      case ErrorType.server:
        return 'Our servers are experiencing issues. Please try again later.';
      case ErrorType.general:
      default:
        return 'An unexpected error occurred. Please try again or contact support if the problem persists.';
    }
  }
}

// Convenience widgets for specific error types
class NetworkErrorWidget extends CustomErrorWidget {
  const NetworkErrorWidget({
    super.key,
    super.title,
    super.message,
    super.onRetry,
    super.retryButtonText,
    super.icon,
    super.iconColor,
    super.showIcon = true,
  }) : super(type: ErrorType.network);
}

class NotFoundErrorWidget extends CustomErrorWidget {
  const NotFoundErrorWidget({
    super.key,
    super.title,
    super.message,
    super.onRetry,
    super.retryButtonText,
    super.icon,
    super.iconColor,
    super.showIcon = true,
  }) : super(type: ErrorType.notFound);
}

class PermissionErrorWidget extends CustomErrorWidget {
  const PermissionErrorWidget({
    super.key,
    super.title,
    super.message,
    super.onRetry,
    super.retryButtonText,
    super.icon,
    super.iconColor,
    super.showIcon = true,
  }) : super(type: ErrorType.permission);
}

class ServerErrorWidget extends CustomErrorWidget {
  const ServerErrorWidget({
    super.key,
    super.title,
    super.message,
    super.onRetry,
    super.retryButtonText,
    super.icon,
    super.iconColor,
    super.showIcon = true,
  }) : super(type: ErrorType.server);
}

// Error boundary widget
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(_error!, _stackTrace);
      }
      return CustomErrorWidget(
        title: 'Application Error',
        message: 'An unexpected error occurred in the application.',
        onRetry: () {
          setState(() {
            _error = null;
            _stackTrace = null;
          });
        },
      );
    }

    return widget.child;
  }

  void _handleError(Object error, StackTrace stackTrace) {
    setState(() {
      _error = error;
      _stackTrace = stackTrace;
    });
  }
}

// Snackbar error helper
class ErrorSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    ErrorType type = ErrorType.general,
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getErrorIcon(type),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) ...[
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    message,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: _getErrorColor(type, colorScheme),
        duration: duration,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  static IconData _getErrorIcon(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.notFound:
        return Icons.search_off;
      case ErrorType.permission:
        return Icons.lock;
      case ErrorType.server:
        return Icons.error;
      case ErrorType.general:
      default:
        return Icons.error_outline;
    }
  }

  static Color _getErrorColor(ErrorType type, ColorScheme colorScheme) {
    switch (type) {
      case ErrorType.network:
        return Colors.orange;
      case ErrorType.notFound:
        return Colors.grey[700]!;
      case ErrorType.permission:
        return Colors.red;
      case ErrorType.server:
        return Colors.deepOrange;
      case ErrorType.general:
      default:
        return colorScheme.error;
    }
  }
}