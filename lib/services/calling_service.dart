import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import '../core/constants/app_constants.dart';
import '../models/call_model.dart';

class CallingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> startCall({
    required String calleeId,
    required String calleeName,
    required bool isVideoCall,
}) async {
    await ZegoUIKitPrebuiltCallInvitationService().send(
        invitees: [ZegoCallUser(calleeId, calleeName)],
        isVideoCall: isVideoCall
    );
  }

  Future<void> logCall({
    required String calleeId,
    required String calleeName,
    required String callType,
    required String status,
    required int durationSeconds,
}) async {
    final me = FirebaseAuth.instance.currentUser;
    if (me == null) return;

    final call = CallModel(
        id: '',
        callerId: me.uid,
        callerName: me.displayName ?? 'Me',
        calleeId: calleeId,
        calleeName: calleeName,
        callType: callType,
        status: status,
        durationSeconds: durationSeconds,
        timestamp: DateTime.now(),
    );

    await _firestore
        .collection(AppConstants.callsCollection)
        .add(call.toMap());
  }

  Stream<List<CallModel>> streamHistory() {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    return _firestore
        .collection(AppConstants.callsCollection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => CallModel.fromMap(d.id, d.data()))
            .where((c) => c.callerId == myUid || c.calleeId == myUid)
            .toList()
    );
  }
}