import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_test1/config/routes/app_route.dart';
import 'package:toastification/toastification.dart';

class ToastService {
  static final ToastService _instance = ToastService._internal();
  factory ToastService() => _instance;
  ToastService._internal();

  // Constants for consistent styling
  static const double _iconSize = 22.0;
  static const double _fontSize = 14.0;
  static const double _borderRadius = 20.0;
  static const Duration _duration = Duration(seconds: 3);

  // Custom shadow for better depth
  static final List<BoxShadow> _boxShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  void success(
    String message, {
    String? description,
    IconData? icon,
    Color? iconColor,
  }) {
    showToast(
      message,
      ToastificationType.success,
      description: description,
      primaryColor: const Color(0xFF2ECC71),
      backgroundColor: const Color(0xFFEAFAF1),
      foregroundColor: const Color(0xFF1B5E20),
      icon: icon ?? Icons.check_circle_rounded,
      iconColor: iconColor ?? const Color(0xFF2ECC71),
    );
  }

  void error(
    String message, {
    String? description,
    IconData? icon,
    Color? iconColor,
  }) {
    showToast(
      message,
      ToastificationType.error,
      description: description,
      primaryColor: const Color(0xFFE74C3C),
      backgroundColor: const Color(0xFFFDEDED),
      foregroundColor: const Color(0xFFB71C1C),
      icon: icon ?? Icons.error_rounded,
      iconColor: iconColor ?? const Color(0xFFE74C3C),
    );
  }

  void warning(
    String message, {
    String? description,
    IconData? icon,
    Color? iconColor,
  }) {
    showToast(
      message,
      ToastificationType.warning,
      description: description,
      primaryColor: const Color(0xFFF39C12),
      backgroundColor: const Color(0xFFFFF3E0),
      foregroundColor: const Color(0xFFE65100),
      icon: icon ?? Icons.warning_rounded,
      iconColor: iconColor ?? const Color(0xFFF39C12),
    );
  }

  void info(
    String message, {
    String? description,
    IconData? icon,
    Color? iconColor,
  }) {
    showToast(
      message,
      ToastificationType.info,
      description: description,
      primaryColor: const Color(0xFF757575),
      backgroundColor: const Color(0xFFEEEEEE),
      foregroundColor: const Color(0xFF424242),
      icon: icon ?? Icons.info_rounded,
      iconColor: iconColor ?? const Color(0xFF757575),
    );
  }

  void showToast(
    String message,
    ToastificationType type, {
    String? description,
    required Color primaryColor,
    required Color backgroundColor,
    required Color foregroundColor,
    required IconData icon,
    required Color iconColor,
  }) {
    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      toastification.show(
        context: context,
        title: Text(
          message,
          style: TextStyle(
            color: foregroundColor,
            fontSize: _fontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            height: 1.2,
          ),
        ),
        description:
            description != null
                ? Text(
                  description,
                  style: TextStyle(
                    color: foregroundColor.withValues(alpha: 0.8),
                    fontSize: _fontSize - 1,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.2,
                    height: 1.3,
                  ),
                )
                : null,
        type: type,
        style: ToastificationStyle.flat,
        alignment: Alignment.bottomCenter,
        autoCloseDuration: _duration,
        showProgressBar: false,
        primaryColor: primaryColor,
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 8, left: 12, right: 12),
        borderRadius: BorderRadius.circular(_borderRadius),
        boxShadow: _boxShadow,
        icon: Icon(icon, color: iconColor, size: _iconSize),
        dragToClose: true,
        pauseOnHover: true,
        callbacks: ToastificationCallbacks(
          onCloseButtonTap: (toastItem) {
            toastification.dismiss(toastItem);
          },
          onTap: (toastItem) {
            String textToCopy = message;
            if (description != null && description.isNotEmpty) {
              textToCopy = '$message\n$description';
            }
            _copy(context, textToCopy);
          },
        ),
      );
    }
  }

  Future<void> _copy(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('คัดลอกแล้ว')));
    }
  }
}
