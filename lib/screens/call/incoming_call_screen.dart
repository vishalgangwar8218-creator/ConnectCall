import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class IncomingCallScreen extends StatelessWidget {
  final String callerName;
  final String? callerAvtarUrl;
  final bool isVideoCall;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const IncomingCallScreen({
    super.key,
    required this.callerName,
    required this.isVideoCall,
    required this.onAccept,
    required this.onDecline,
    this.callerAvtarUrl,
});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              children: [
                const Spacer(),
                Text(
                  isVideoCall ? 'Incoming Video Call' : 'Incoming Audio Call',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 24),
                CircleAvatar(
                  radius: 56,
                  backgroundColor: Colors.white24,
                  backgroundImage: callerAvtarUrl != null ? NetworkImage(callerAvtarUrl!) : null,
                  child: callerAvtarUrl == null
                    ? Text(
                      callerName.isNotEmpty ? callerName[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontSize: 40),
                  )
                      : null,
                ),
                const SizedBox(height: 20),
                Text(
                  callerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _CallActionButton(
                      icon: Icons.call_end,
                      color: AppTheme.danger,
                      label: 'Decline',
                      onTap: onDecline,
                    ),
                    _CallActionButton(
                      icon: Icons.call,
                      color: AppTheme.secondary,
                      label: 'Accept',
                      onTap: onAccept,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          )
      ),
    );
  }
}

class _CallActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _CallActionButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(36),
          child: CircleAvatar(
            radius: 32,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 30),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}