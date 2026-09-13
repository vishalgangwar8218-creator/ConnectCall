import 'package:flutter/material.dart';

class CommonButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool outlined;

  const CommonButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.outlined = false,
});

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
    )
        : Text(label, style: const TextStyle(fontWeight: FontWeight.w600));

    if(outlined) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: isLoading
               ? const SizedBox(
              height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.4))
                : Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
      ),
    );
  }
}