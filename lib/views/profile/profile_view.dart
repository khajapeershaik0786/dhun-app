import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/repositories/profile_repository.dart';
import '../widgets/primary_button.dart';
import '../widgets/profile_avatar.dart';

/// Profile page: change photo (camera / gallery) and edit name & email.
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final TextEditingController _first;
  late final TextEditingController _last;
  late final TextEditingController _email;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final p = context.read<ProfileRepository>();
    _first = TextEditingController(text: p.firstName);
    _last = TextEditingController(text: p.lastName);
    _email = TextEditingController(text: p.email);
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final x = await _picker.pickImage(
          source: source, maxWidth: 1024, imageQuality: 85);
      if (x != null && mounted) {
        await context.read<ProfileRepository>().setPhoto(x.path);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the camera/gallery')),
        );
      }
    }
  }

  void _showPhotoSheet() {
    final profile = context.read<ProfileRepository>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.photo_camera, color: AppColors.text),
              title: const Text('Take photo'),
              onTap: () {
                Navigator.pop(sheet);
                _pick(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.text),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(sheet);
                _pick(ImageSource.gallery);
              },
            ),
            if (profile.photoFile != null)
              ListTile(
                leading: const Icon(Icons.delete_outline,
                    color: Color(0xFFEF4444)),
                title: const Text('Remove photo',
                    style: TextStyle(color: Color(0xFFEF4444))),
                onTap: () {
                  Navigator.pop(sheet);
                  profile.removePhoto();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    await context.read<ProfileRepository>().saveDetails(
          firstName: _first.text.trim(),
          lastName: _last.text.trim(),
          email: _email.text.trim(),
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved')),
      );
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileRepository>();

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Edit profile',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
        children: [
          Center(
            child: GestureDetector(
              onTap: _showPhotoSheet,
              child: Stack(
                children: [
                  ProfileAvatar(profile: profile, size: 120),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.bg, width: 3),
                      ),
                      child: const Icon(Icons.photo_camera,
                          color: AppColors.onAccent, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: _showPhotoSheet,
              child: const Text('Change photo',
                  style: TextStyle(
                      color: AppColors.accent, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 10),
          _Field(label: 'First name', controller: _first, hint: 'Ananya'),
          const SizedBox(height: 14),
          _Field(label: 'Last name', controller: _last, hint: 'Rao'),
          const SizedBox(height: 14),
          _Field(
            label: 'Email',
            controller: _email,
            hint: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 26),
          PrimaryButton(label: 'Save changes', onPressed: _save),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(color: AppColors.text),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textFaint),
            filled: true,
            fillColor: AppColors.surface,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
