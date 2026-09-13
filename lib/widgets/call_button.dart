import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class CallButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const CallButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color
});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (color ?? AppTheme.primary).withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color ?? AppTheme.primary, size: 20),
      ),
    );
  }
}