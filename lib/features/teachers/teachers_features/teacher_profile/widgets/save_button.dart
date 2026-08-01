import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

class SaveProfileButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const SaveProfileButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final bool isMobile = width < 600;
    final bool isTablet = width >= 600 && width < 1000;

    final double buttonHeight = isMobile
        ? 54
        : isTablet
            ? 58
            : 60;

    final double fontSize = isMobile
        ? 15
        : isTablet
            ? 16
            : 17;

    final double iconSize = isMobile
        ? 20
        : 22;

    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),

        icon: isLoading
            ? SizedBox(
                width: iconSize,
                height: iconSize,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Icon(
                Icons.save,
                size: iconSize,
              ),

        label: Text(
          isLoading
              ? "Saving..."
              : "Save Changes",
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}