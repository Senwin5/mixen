import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
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

  /// Fully working pickImage function
  Future<void> pickImage() async {
    bool permissionGranted = false;

    if (Platform.isAndroid) {
      // Android 13+ needs photos permission
      if (await Permission.photos.isGranted) {
        permissionGranted = true;
      } 
      // Android <13 fallback storage permission
      else if (await Permission.storage.isGranted) {
        permissionGranted = true;
      } 
      // Request permissions if not granted
      else {
        if (await Permission.photos.request().isGranted) {
          permissionGranted = true;
        } else if (await Permission.storage.request().isGranted) {
          permissionGranted = true;
        }
      }
    } else if (Platform.isIOS) {
      // iOS needs photos permission
      if (await Permission.photos.isGranted) {
        permissionGranted = true;
      } else if (await Permission.photos.request().isGranted) {
        permissionGranted = true;
      }
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
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null && mounted) {
        setState(() => _image = File(picked.path));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to pick image: $e")),
      );
    }
  }

  Future<void> submitProfile() async {
    if (_image == null || _bioController.text.isEmpty || _ageController.text.isEmpty) {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    if (mounted) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complete Your Profile")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _image != null
                  ? Image.file(_image!, width: 150, height: 150, fit: BoxFit.cover)
                  : Container(width: 150, height: 150, color: Colors.grey),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: pickImage, child: const Text("Pick Image")),
              const SizedBox(height: 20),
              TextField(
                controller: _bioController,
                decoration: const InputDecoration(labelText: "Bio"),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: "Age"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(onPressed: submitProfile, child: const Text("Submit")),
            ],
          ),
        ),
      ),
    );
  }
}
