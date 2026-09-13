import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../widgets/common_button.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _userService = UserService();
  final _picker = ImagePicker();
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isUploadingPhoto = false;
  String? _photoUrl;
  final _nameController = TextEditingController();

  Future<void> _pickAndUploadPhoto() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final picked = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                if (context.mounted) Navigator.pop(context, file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a Photo'),
              onTap: () async {
                final file = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                if (context.mounted) Navigator.pop(context, file);
              },
            ),
          ],
        ),
      ),
    );

    if (picked == null) return;

    setState(() => _isUploadingPhoto = true);
    try {
      final url = await _userService.uploadProfilePhoto(user.uid, File(picked.path));
      await _userService.updateProfile(user.uid, photoUrl: url);
      if (!mounted) return;
      setState(() {
        _photoUrl = url;
        _isUploadingPhoto = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingPhoto = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not upload photo: $e')),
      );
    }
  }

  Future<void> _saveName(String uid) async {
    setState(() => _isSaving = true);
    await _userService.updateProfile(uid, name: _nameController.text.trim());
    await FirebaseAuth.instance.currentUser?.updateDisplayName(_nameController.text.trim());
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _isEditing = false;
    });
  }

  Future<void> _logout() async {
    await context.read<AuthService>().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
  }
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    _photoUrl ??= user?.photoURL;
    _nameController.text = user?.displayName ?? '';

    return SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppTheme.primary.withOpacity(0.15),
                    backgroundImage: _photoUrl != null ? NetworkImage(_photoUrl!) : null,
                    child: _photoUrl == null
                        ? Text(
                      (user?.displayName?.isNotEmpty ?? false) ? user!.displayName![0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 32, color: AppTheme.primary, fontWeight: FontWeight.bold),
                    )
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: InkWell(
                      onTap: _isUploadingPhoto ? null : _pickAndUploadPhoto,
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                        child: _isUploadingPhoto
                            ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                            : const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if(_isEditing)
              TextField(controller: _nameController, textAlign: TextAlign.center, decoration: const InputDecoration(labelText: 'Name'))
            else
              Text(user?.displayName ?? 'No name set', textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(user?.email ?? '', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            const Center(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                CircleAvatar(radius: 4, backgroundColor: AppTheme.secondary),
                SizedBox(width: 6),
                Text('Online'),
              ]),
            ),
            const SizedBox(height: 32),
            if (_isEditing)
              CommonButton(label: 'Save', isLoading: _isSaving, onPressed: () => _saveName(user!.uid))
            else
              CommonButton(label: 'Edit Profile', outlined: true, onPressed: () => setState(() => _isEditing = true)),
            const SizedBox(height: 12),
            CommonButton(label: 'Logout', onPressed: _logout),
          ],
        )
    );
  }
}