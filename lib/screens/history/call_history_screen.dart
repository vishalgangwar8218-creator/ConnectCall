import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../models/call_model.dart';
import '../../services/calling_service.dart';

class CallHistoryScreen extends StatelessWidget {
  const CallHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    final callingService = CallingService();

    return StreamBuilder<List<CallModel>>(
        stream: callingService.streamHistory(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if(snapshot.hasError) {
            return Center(child: Text('Failed to load call history: ${snapshot.error}'));
          }
          final calls = snapshot.data ?? [];
          if (calls.isEmpty) {
            return const Center(child: Text('No calls yet'));
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemCount: calls.length,
            itemBuilder: (context, i) {
              final call = calls[i];
              final isOutgoing = call.callerId == myUid;
              final otherName = isOutgoing ? call.calleeName : call.callerName;
              final missed = call.status == 'missed' || call.status == 'rejected';

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primary.withOpacity(0.15),
                  child: Icon(call.callType == 'video' ? Icons.videocam : Icons.call, color: AppTheme.primary),
                ),
                title: Text(otherName, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Row(children: [
                  Icon(isOutgoing ? Icons.call_made : Icons.call_received, size: 14, color: missed ? AppTheme.danger : Colors.grey),
                  const SizedBox(width: 4),
                  Text(DateFormat('MMM d, h:mm a').format(call.timestamp), style: TextStyle(color: missed ? AppTheme.danger : Colors.grey)),
                ]),
                trailing: Text(call.formattedDuration, style: TextStyle(color: missed ? AppTheme.danger : Colors.black87)),
              );
            },

          );
        }
    );
  }
}