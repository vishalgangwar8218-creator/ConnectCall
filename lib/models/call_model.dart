import 'package:cloud_firestore/cloud_firestore.dart';

class CallModel {
  final String id;
  final String callerId;
  final String callerName;
  final String calleeId;
  final String calleeName;
  final String callType;
  final String status;
  final int durationSeconds;
  final DateTime timestamp;

  CallModel({
    required this.id,
    required this.callerId,
    required this.callerName,
    required this.calleeId,
    required this.calleeName,
    required this.callType,
    required this.status,
    required this.durationSeconds,
    required this.timestamp,
});

  factory CallModel.fromMap(String id, Map<String, dynamic> map) {
    return CallModel(
        id: id,
        callerId: map['callerId'] ?? '',
        callerName: map['callerName'] ?? '',
        calleeId: map['calleeId'] ?? '',
        calleeName: map['calleeName'] ?? '',
        callType: map['callType'] ?? 'audio',
        status: map['status'] ?? 'ended',
        durationSeconds: map['durationSeconds'] ?? 0,
        timestamp: (map['timestamp'] is Timestamp)
            ? (map['timestamp'] as Timestamp).toDate()
            : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'callerId': callerId,
      'callerName': callerName,
      'calleeName': calleeName,
      'calleeId': calleeId,
      'status': status,
      'durationSeconds': durationSeconds,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  String get formattedDuration {
    if (status == 'missed' || status == 'rejected') return status[0].toUpperCase() + status.substring(1);
    final m = (durationSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (durationSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}