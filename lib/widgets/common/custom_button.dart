import 'package:flutter/material.dart';

enum ButtonType { primary, secondary, outline, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final bool isEnabled;
  final IconData? icon;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.width,
    this.height,
    this.padding,
    this.fontSize,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bool isButtonEnabled = isEnabled && !isLoading && onPressed != null;

    Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getTextColor(colorScheme),
              ),
            ),
          )
        else if (icon != null)
          Icon(
            icon,
            size: fontSize != null ? fontSize! + 2 : 18,
            color: _getTextColor(colorScheme),
          ),
        if ((isLoading || icon != null) && text.isNotEmpty)
          const SizedBox(width: 8),
        if (text.isNotEmpty)
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize ?? 16,
              fontWeight: FontWeight.w600,
              color: _getTextColor(colorScheme),
            ),
          ),
      ],
    );

    Widget button;

    switch (type) {
      case ButtonType.primary:
        button = ElevatedButton(
          onPressed: isButtonEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? colorScheme.primary,
            foregroundColor: textColor ?? colorScheme.onPrimary,
            disabledBackgroundColor: Color.fromRGBO((colorScheme.outline.r * 255.0).round() & 0xff, (colorScheme.outline.g * 255.0).round() & 0xff, (colorScheme.outline.b * 255.0).round() & 0xff, 0.3),
            disabledForegroundColor: Color.fromRGBO((colorScheme.onSurface.r * 255.0).round() & 0xff, (colorScheme.onSurface.g * 255.0).round() & 0xff, (colorScheme.onSurface.b * 255.0).round() & 0xff, 0.38),
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            elevation: isButtonEnabled ? 2 : 0,
          ),
          child: buttonChild,
        );
        break;

      case ButtonType.secondary:
        button = ElevatedButton(
          onPressed: isButtonEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? colorScheme.secondary,
            foregroundColor: textColor ?? colorScheme.onSecondary,
            disabledBackgroundColor: Color.fromRGBO((colorScheme.outline.r * 255.0).round() & 0xff, (colorScheme.outline.g * 255.0).round() & 0xff, (colorScheme.outline.b * 255.0).round() & 0xff, 0.3),
            disabledForegroundColor: Color.fromRGBO((colorScheme.onSurface.r * 255.0).round() & 0xff, (colorScheme.onSurface.g * 255.0).round() & 0xff, (colorScheme.onSurface.b * 255.0).round() & 0xff, 0.38),
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            elevation: isButtonEnabled ? 2 : 0,
          ),
          child: buttonChild,
        );
        break;

      case ButtonType.outline:
        button = OutlinedButton(
          onPressed: isButtonEnabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            foregroundColor: textColor ?? colorScheme.primary,
            disabledForegroundColor: Color.fromRGBO(colorScheme.onSurface.red, colorScheme.onSurface.green, colorScheme.onSurface.blue, 0.38),
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            side: BorderSide(
              color: isButtonEnabled
                  ? (backgroundColor ?? colorScheme.primary)
                  : Color.fromRGBO(colorScheme.outline.red, colorScheme.outline.green, colorScheme.outline.blue, 0.3),
              width: 1.5,
            ),
          ),
          child: buttonChild,
        );
        break;

      case ButtonType.text:
        button = Material(
          child: InkWell(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Container(
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: buttonChild,
            ),
          ),
          child: buttonChild,
        );
        break;
    }

    if (width != null || height != null) {
      return SizedBox(
        width: width,
        height: height,
        child: button,
      );
    }

    return button;
  }

  Color _getTextColor(ColorScheme colorScheme) {
    if (textColor != null) return textColor!;

    switch (type) {
      case ButtonType.primary:
        return backgroundColor != null ? Colors.white : colorScheme.onPrimary;
      case ButtonType.secondary:
        return backgroundColor != null ? Colors.white : colorScheme.onSecondary;
      case ButtonType.outline:
      case ButtonType.text:
        return backgroundColor ?? colorScheme.primary;
    }
  }
}

// Convenience constructors
class PrimaryButton extends CustomButton {
  const PrimaryButton({
    super.key,
    required super.text,
    super.onPressed,
    super.isLoading = false,
    super.isEnabled = true,
    super.icon,
    super.width,
    super.height,
    super.padding,
    super.fontSize,
    super.backgroundColor,
    super.textColor,
    super.borderRadius = 8.0,
  }) : super(type: ButtonType.primary);
}

class SecondaryButton extends CustomButton {
  const SecondaryButton({
    super.key,
    required super.text,
    super.onPressed,
    super.isLoading = false,
    super.isEnabled = true,
    super.icon,
    super.width,
    super.height,
    super.padding,
    super.fontSize,
    super.backgroundColor,
    super.textColor,
    super.borderRadius = 8.0,
  }) : super(type: ButtonType.secondary);
}

class OutlineButton extends CustomButton {
  const OutlineButton({
    super.key,
    required super.text,
    super.onPressed,
    super.isLoading = false,
    super.isEnabled = true,
    super.icon,
    super.width,
    super.height,
    super.padding,
    super.fontSize,
    super.backgroundColor,
    super.textColor,
    super.borderRadius = 8.0,
  }) : super(type: ButtonType.outline);
}

class CustomTextButton extends CustomButton {
  const CustomTextButton({
    super.key,
    required super.text,
    super.onPressed,
    super.isLoading = false,
    super.isEnabled = true,
    super.icon,
    super.width,
    super.height,
    super.padding,
    super.fontSize,
    super.backgroundColor,
    super.textColor,
    super.borderRadius = 8.0,
  }) : super(type: ButtonType.text);
}