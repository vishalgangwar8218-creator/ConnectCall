import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../models/user_model.dart';
import '../../services/calling_service.dart';
import '../../services/user_service.dart';
import '../../widgets/user_tile.dart';

class ContactsScreen extends StatefulWidget{
  const ContactsScreen({super.key});
  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final _userService = UserService();
  final _callingService = CallingService();
  String _query = '';

  Future<bool> _ensureCallPermissions({required bool isVideo}) async {
    final statuses = await[
      Permission.microphone,
      if(isVideo) Permission.camera,
    ].request();

    final allGranted = statuses.values.every((s) => s.isGranted);
    if (allGranted) return true;

    final permanentlyDenied = statuses.values.any((s) => s.isPermanentlyDenied);
    if (!mounted) return false;

    if(permanentlyDenied) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Permission required'),
            content: Text('Please enable ${isVideo ? 'camera and microphone' : 'microphone'} access from app settings to start this call.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    openAppSettings();
                  },
                  child: const Text('Open Settings'),
              ),
            ],
          )
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${isVideo ? 'Camera and microphone' : 'Microphone'} permission is needed to call.')),
      );
    }

    return false;
  }

  Future<void> _startCall(UserModel user, {required bool isVideo}) async {
    if(!user.isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${user.name} is offline right now.')));
      return;
    }
    final granted = await _ensureCallPermissions(isVideo: isVideo);
    if(!granted) return;

    try {
      await _callingService.startCall(calleeId: user.id, calleeName: user.name, isVideoCall: isVideo);
    } catch(e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not start call: $e')));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            decoration: const InputDecoration(hintText: 'Search people...', prefixIcon: (Icon(Icons.search))),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Expanded(
            child: StreamBuilder<List<UserModel>>(
                stream: _userService.streamContacts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Failed to load contacts: ${snapshot.error}'));
                  }
                  final users = _userService.filterByName(snapshot.data ?? [], _query);
                  if (users.isEmpty) {
                    return const Center(child: Text('No contacts found'));
                  }
                  return ListView.builder(
                    itemCount: users.length,
                      itemBuilder: (context, i) {
                      final user = users[i];
                      return UserTile(
                        user: user,
                        onAudioCall: () => _startCall(user, isVideo: false),
                        onVideoCall: () => _startCall(user, isVideo: true),
                      );
                      },
                  );
                },
            ),
        ),
      ],
    );
  }
}