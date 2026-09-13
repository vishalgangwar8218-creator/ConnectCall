import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import '../../core/constants/app_constants.dart';

class VideoCallScreen extends StatelessWidget {
  final String callID;
  final String userID;
  final String userName;
  final String otherUserName;

  const VideoCallScreen({
    super.key,
    required this.callID,
    required this.userID,
    required this.userName,
    required this.otherUserName,
});

  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
        appID: AppConstants.zegoAppId,
        appSign: AppConstants.zegoAppSign,
        callID: callID,
        userID: userID,
        userName: userName,
        config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
        ..turnOnCameraWhenJoining = true
        ..turnOnMicrophoneWhenJoining = true
        ..useSpeakerWhenJoining = true
        ..topMenuBar = ZegoCallTopMenuBarConfig(
          isVisible: true,
          title: otherUserName,
        )

        ..bottomMenuBar = ZegoCallBottomMenuBarConfig(
          buttons: [
            ZegoCallMenuBarButtonName.toggleMicrophoneButton,
            ZegoCallMenuBarButtonName.toggleCameraButton,
            ZegoCallMenuBarButtonName.switchCameraButton,
            ZegoCallMenuBarButtonName.hangUpButton,
          ],
        ),
    );
  }
}