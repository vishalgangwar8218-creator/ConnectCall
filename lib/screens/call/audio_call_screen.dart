import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

class AudioCallScreen extends StatelessWidget {
  final String callID;
  final String userID;
  final String userName;
  final String otherUserName;
  final String? otherUserAvatarUrl;

  const AudioCallScreen({
    super.key,
    required this.callID,
    required this.userID,
    required this.userName,
    required this.otherUserName,
    this.otherUserAvatarUrl,
});

  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
        appID: AppConstants.zegoAppId,
        appSign: AppConstants.zegoAppSign,
        userID: userID,
        userName: userName,
        callID: callID,
        config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()
           ..turnOnMicrophoneWhenJoining = true
           ..turnOnCameraWhenJoining = false
           ..useSpeakerWhenJoining = true
          ..topMenuBar = ZegoCallTopMenuBarConfig(
            isVisible: true,
            title: otherUserName,
          )
          ..duration = ZegoCallDurationConfig(isVisible: true)
          ..bottomMenuBar = ZegoCallBottomMenuBarConfig(
            buttons: [
              ZegoCallMenuBarButtonName.toggleMicrophoneButton,
              ZegoCallMenuBarButtonName.hangUpButton,
              ZegoCallMenuBarButtonName.switchAudioOutputButton,
            ],
           )
           ..avatarBuilder = (context, size, user, extraInfo) {
              return CircleAvatar(
                radius: size.width / 2,
                backgroundColor: AppTheme.primary,
                backgroundImage: otherUserAvatarUrl != null ? NetworkImage(otherUserAvatarUrl!) : null,
                child: otherUserAvatarUrl == null
                  ? Text(
                     otherUserName.isNotEmpty ? otherUserName[0].toUpperCase() : '?',
                     style: const TextStyle(color: Colors.white, fontSize: 32),
                )
                    : null,
              );
           },
    );
  }
}