import 'package:connect_call/core/constants/app_constants.dart';
import 'package:connect_call/core/theme/app_theme.dart';
import 'package:connect_call/firebase_options.dart';
import 'package:connect_call/screens/splash/splash_screen.dart';
import 'package:connect_call/services/auth_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

  runApp(
    ChangeNotifierProvider(
        create: (_) => AuthService(),
        child: const ConnectCallApp(),
    )
  );
}

class ConnectCallApp extends StatefulWidget {
  const  ConnectCallApp({super.key});

  @override
  State<ConnectCallApp> createState() => _ConnectCallAppState();
}

class _ConnectCallAppState extends State<ConnectCallApp> {
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen(_onAuthChanged);
  }

  Future<void> _onAuthChanged(User? user) async {
    if(user != null) {
      await ZegoUIKitPrebuiltCallInvitationService().init(
          appID: AppConstants.zegoAppId,
          appSign: AppConstants.zegoAppSign,
          userID: user.uid,
          userName: user.displayName?.isNotEmpty == true ? user.displayName! : user.email ?? user.uid,
          plugins: [ZegoUIKitSignalingPlugin()],
          requireConfig: (ZegoCallInvitationData data) {
            final config = data.invitees.length > 1
                ? ZegoCallInvitationType.videoCall == data.type
                    ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
                    : ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
                : ZegoCallInvitationType.videoCall == data.type
                    ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
                    : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();
            return config;
          },
      );
    } else {
      await ZegoUIKitPrebuiltCallInvitationService().uninit();
    }
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      navigatorKey: navigatorKey,
      home: const SplashScreen(),
    );
  }
}