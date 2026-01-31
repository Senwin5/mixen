import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../services/api_service.dart';
import 'swipe_page.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  File? _image;
  bool isLoading = false;
  bool isDarkMode = false; // 🌙 dark mode toggle

  static const forestGreen = Color(0xFF2F855A);

  /// Show bottom sheet to choose between Camera and Gallery
  Future<void> pickImageOption() async {
    showModalBottomSheet(
      context: context,
      builder: (_) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Gallery'),
            onTap: () async {
              Navigator.pop(context);
              await pickImage(ImageSource.gallery);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Camera'),
            onTap: () async {
              Navigator.pop(context);
              await pickImage(ImageSource.camera);
            },
          ),
        ],
      ),
    );
  }

  /// Request gallery permission depending on Android version / iOS
  Future<bool> requestGalleryPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdk = androidInfo.version.sdkInt;

      if (sdk >= 33) {
        return await Permission.photos.request().isGranted;
      } else {
        return await Permission.storage.request().isGranted;
      }
    } else if (Platform.isIOS) {
      return await Permission.photos.request().isGranted;
    }
    return false;
  }

  /// Pick image from camera or gallery with proper permissions
  Future<void> pickImage(ImageSource source) async {
    bool permissionGranted = false;

    if (source == ImageSource.camera) {
      permissionGranted = await Permission.camera.request().isGranted;
    } else if (source == ImageSource.gallery) {
      permissionGranted = await requestGalleryPermission();
    }

    if (!permissionGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permission denied! Cannot pick image.")),
      );
      return;
    }

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (picked != null && mounted) {
        setState(() => _image = File(picked.path));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to pick image: $e")));
    }
  }

  /// Submit profile with image, bio, and age
  Future<void> submitProfile() async {
    if (_image == null ||
        _bioController.text.isEmpty ||
        _ageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields and pick an image!")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final success = await ApiService.uploadProfileImage(_image!);
      if (!success) throw Exception("Image upload failed");

      final updateSuccess = await ApiService.updateProfile(
        bio: _bioController.text,
        age: int.tryParse(_ageController.text) ?? 0,
      );
      if (!updateSuccess) throw Exception("Profile update failed");

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SwipePage()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    if (mounted) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isDarkMode ? Colors.black : const Color(0xFFF3FDE3);
    final Color textFieldColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          "Complete Your Profile",
          style: TextStyle(color: textFieldColor),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: textFieldColor,
            ),
            onPressed: () => setState(() => isDarkMode = !isDarkMode),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(75),
                      child: Image.file(
                        _image!,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(75),
                      ),
                    ),
              const SizedBox(height: 12),

              // ✅ Pick Image Button (white text always)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: forestGreen,
                  foregroundColor: Colors.white, // white text
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: pickImageOption,
                child: const Text("Pick Image"),
              ),

              const SizedBox(height: 20),

              // Bio TextField (text changes based on dark/light mode)
              TextField(
                controller: _bioController,
                decoration: InputDecoration(
                  labelText: "Bio",
                  labelStyle: TextStyle(color: textFieldColor),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: textFieldColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: textFieldColor, width: 2),
                  ),
                ),
                maxLines: 3,
                style: TextStyle(color: textFieldColor),
              ),

              const SizedBox(height: 10),

              // Age TextField (text changes based on dark/light mode)
              TextField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: "Age",
                  labelStyle: TextStyle(color: textFieldColor),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: textFieldColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: textFieldColor, width: 2),
                  ),
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(color: textFieldColor),
              ),

              const SizedBox(height: 20),

              // ✅ Submit Button (white text always)
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: forestGreen,
                        foregroundColor: Colors.white, // white text
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      onPressed: submitProfile,
                      child: const Text("Submit"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
