import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'constants.dart';
// Required imports
import 'dart:async';
import 'dart:math';


class Helpers {
  // Date formatting
  static String formatDate(DateTime date, {String? format}) {
    final formatter = DateFormat(format ?? AppConstants.dateFormat);
    return formatter.format(date);
  }

  static String formatTime(DateTime time, {String? format}) {
    final formatter = DateFormat(format ?? AppConstants.timeFormat);
    return formatter.format(time);
  }

  static String formatDateTime(DateTime dateTime, {String? format}) {
    final formatter = DateFormat(format ?? AppConstants.dateTimeFormat);
    return formatter.format(dateTime);
  }

  static String formatEventDate(DateTime startDate, {DateTime? endDate}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final eventDay = DateTime(startDate.year, startDate.month, startDate.day);

    String dateStr;
    if (eventDay == today) {
      dateStr = 'Today';
    } else if (eventDay == tomorrow) {
      dateStr = 'Tomorrow';
    } else if (eventDay.year == now.year) {
      dateStr = DateFormat('MMM d').format(startDate);
    } else {
      dateStr = DateFormat('MMM d, yyyy').format(startDate);
    }

    final timeStr = DateFormat('h:mm a').format(startDate);
    
    if (endDate != null && !isSameDay(startDate, endDate)) {
      final endDateStr = formatEventDate(endDate);
      return '$dateStr at $timeStr - $endDateStr';
    }
    
    return '$dateStr at $timeStr';
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Currency formatting
  static String formatCurrency(double amount, {String currency = 'KES'}) {
    final formatter = NumberFormat.currency(
      symbol: currency == 'KES' ? 'KES ' : '\$ ',
      decimalDigits: amount % 1 == 0 ? 0 : 2,
    );
    return formatter.format(amount);
  }

  static String formatPrice(double price) {
    if (price == 0) {
      return 'FREE';
    }
    return formatCurrency(price);
  }

  // Number formatting
  static String formatNumber(int number) {
    if (number < 1000) {
      return number.toString();
    } else if (number < 1000000) {
      final k = number / 1000;
      return k % 1 == 0 ? '${k.toInt()}K' : '${k.toStringAsFixed(1)}K';
    } else {
      final m = number / 1000000;
      return m % 1 == 0 ? '${m.toInt()}M' : '${m.toStringAsFixed(1)}M';
    }
  }

  static String formatPercentage(double value, {int decimals = 1}) {
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }

  // String utilities
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String capitalizeWords(String text) {
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  static String truncateText(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - suffix.length) + suffix;
  }

  static String removeHtmlTags(String htmlText) {
    final RegExp exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    return htmlText.replaceAll(exp, '');
  }

  // Phone number formatting
  static String formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    String digits = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Handle Kenyan numbers
    if (digits.startsWith('254')) {
      // +254 format
      if (digits.length == 12) {
        return '+254 ${digits.substring(3, 6)} ${digits.substring(6, 9)} ${digits.substring(9)}';
      }
    } else if (digits.startsWith('0')) {
      // 0xxx format
      if (digits.length == 10) {
        return '${digits.substring(0, 4)} ${digits.substring(4, 7)} ${digits.substring(7)}';
      }
    }
    
    return phoneNumber; // Return original if formatting fails
  }

  // URL utilities
  static Future<bool> launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }
      return false;
    } catch (e) {
      debugPrint('Error launching URL: $e');
      return false;
    }
  }

  static Future<bool> launchEmail(String email, {String? subject, String? body}) async {
    String emailUrl = 'mailto:$email';
    
    List<String> params = [];
    if (subject != null) params.add('subject=${Uri.encodeComponent(subject)}');
    if (body != null) params.add('body=${Uri.encodeComponent(body)}');
    
    if (params.isNotEmpty) {
      emailUrl += '?${params.join('&')}';
    }
    
    return await launchURL(emailUrl);
  }

  static Future<bool> launchPhone(String phoneNumber) async {
    return await launchURL('tel:$phoneNumber');
  }

  static Future<bool> launchSMS(String phoneNumber, {String? message}) async {
    String smsUrl = 'sms:$phoneNumber';
    if (message != null) {
      smsUrl += '?body=${Uri.encodeComponent(message)}';
    }
    return await launchURL(smsUrl);
  }

  // Color utilities
  static Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  static Color getContrastColor(Color color) {
    // Calculate luminance
    final luminance = (0.299 * (color.r * 255.0).round() + 0.587 * (color.g * 255.0).round() + 0.114 * (color.b * 255.0).round()) / 255;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  // Distance calculation
  static double calculateDistance(
    double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).round()}m';
    } else if (distanceInKm < 10) {
      return '${distanceInKm.toStringAsFixed(1)}km';
    } else {
      return '${distanceInKm.round()}km';
    }
  }

  // File size formatting
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  // Image utilities
  static bool isValidImageUrl(String url) {
    const imageExtensions = AppConstants.supportedImageFormats;
    return imageExtensions.any((ext) => url.toLowerCase().endsWith('.$ext'));
  }

  static String getImagePlaceholder(String type) {
    switch (type.toLowerCase()) {
      case 'event':
        return AppConstants.defaultEventImage;
      case 'user':
      case 'avatar':
        return AppConstants.defaultUserAvatar;
      case 'category':
        return AppConstants.defaultCategoryIcon;
      default:
        return AppConstants.defaultEventImage;
    }
  }

  // Validation helpers
  static bool isValidEmail(String email) {
    return RegExp(AppConstants.emailRegex).hasMatch(email);
  }

  static bool isValidPhoneNumber(String phone) {
    return RegExp(AppConstants.phoneRegex).hasMatch(phone);
  }

  static bool isValidUrl(String url) {
    return RegExp(AppConstants.urlRegex).hasMatch(url);
  }

  // Device utilities
  static bool isTablet(BuildContext context) {
    final MediaQueryData data = MediaQuery.of(context);
    return data.size.shortestSide >= 600;
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // Snackbar helpers
  static void showSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.green);
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.red);
  }

  static void showWarningSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.orange);
  }

  // Dialog helpers
  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
  }

  // Loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Text(message ?? 'Loading...'),
            ],
          ),
        );
      },
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  // Focus utilities
  static void unfocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  // Debounce utility
  static Timer? _debounceTimer;
  
  static void debounce(VoidCallback callback, {Duration delay = const Duration(milliseconds: 500)}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }
}

