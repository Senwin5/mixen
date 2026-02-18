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
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _lookingForController = TextEditingController();

  File? _image;
  bool isLoading = false;
  bool isDarkMode = false;
  bool drink = false;
  bool smoke = false;

  static const forestGreen = Color(0xFF2F855A);

  /// Pick image from gallery or camera
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

  Future<bool> requestGalleryPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdk = androidInfo.version.sdkInt;
      if (sdk >= 33) return await Permission.photos.request().isGranted;
      return await Permission.storage.request().isGranted;
    } else if (Platform.isIOS) {
      return await Permission.photos.request().isGranted;
    }
    return false;
  }

  Future<void> pickImage(ImageSource source) async {
    bool permissionGranted = false;
    if (source == ImageSource.camera) permissionGranted = await Permission.camera.request().isGranted;
    if (source == ImageSource.gallery) permissionGranted = await requestGalleryPermission();

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
          source: source, maxWidth: 800, maxHeight: 800, imageQuality: 80);
      if (picked != null && mounted) setState(() => _image = File(picked.path));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to pick image: $e")));
    }
  }

  /// Submit profile to backend (image + data in one call)
  Future<void> submitProfile() async {
    if (_bioController.text.isEmpty || _ageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all required fields!")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final success = await ApiService.updateProfileWithImage(
        image: _image,
        bio: _bioController.text,
        age: int.tryParse(_ageController.text) ?? 0,
        gender: _genderController.text,
        location: _locationController.text,
        height: int.tryParse(_heightController.text),
        drink: drink,
        smoke: smoke,
        lookingFor: _lookingForController.text,
      );

      if (!success) throw Exception("Profile update failed");

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SwipePage()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    if (mounted) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final Color textFieldColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("Complete Your Profile", style: TextStyle(color: textFieldColor)),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode, color: textFieldColor),
            onPressed: () => setState(() => isDarkMode = !isDarkMode),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Image
              _image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(75),
                      child: Image.file(_image!, width: 150, height: 150, fit: BoxFit.cover),
                    )
                  : Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                          color: Colors.grey, borderRadius: BorderRadius.circular(75))),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: forestGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48)),
                onPressed: pickImageOption,
                child: const Text("Pick Image"),
              ),
              const SizedBox(height: 20),

              // Bio
              TextField(
                controller: _bioController,
                decoration: InputDecoration(
                  labelText: "Bio",
                  labelStyle: TextStyle(color: textFieldColor),
                  enabledBorder:
                      OutlineInputBorder(borderSide: BorderSide(color: textFieldColor)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: textFieldColor, width: 2)),
                ),
                maxLines: 3,
                style: TextStyle(color: textFieldColor),
              ),
              const SizedBox(height: 10),

              // Age
              TextField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: "Age",
                  labelStyle: TextStyle(color: textFieldColor),
                  enabledBorder:
                      OutlineInputBorder(borderSide: BorderSide(color: textFieldColor)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: textFieldColor, width: 2)),
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(color: textFieldColor),
              ),
              const SizedBox(height: 10),

              // Gender
              TextField(
                controller: _genderController,
                decoration: InputDecoration(
                  labelText: "Gender",
                  labelStyle: TextStyle(color: textFieldColor),
                  enabledBorder:
                      OutlineInputBorder(borderSide: BorderSide(color: textFieldColor)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: textFieldColor, width: 2)),
                ),
                style: TextStyle(color: textFieldColor),
              ),
              const SizedBox(height: 10),

              // Location
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: "Location",
                  labelStyle: TextStyle(color: textFieldColor),
                  enabledBorder:
                      OutlineInputBorder(borderSide: BorderSide(color: textFieldColor)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: textFieldColor, width: 2)),
                ),
                style: TextStyle(color: textFieldColor),
              ),
              const SizedBox(height: 10),

              // Height
              TextField(
                controller: _heightController,
                decoration: InputDecoration(
                  labelText: "Height (cm)",
                  labelStyle: TextStyle(color: textFieldColor),
                  enabledBorder:
                      OutlineInputBorder(borderSide: BorderSide(color: textFieldColor)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: textFieldColor, width: 2)),
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(color: textFieldColor),
              ),
              const SizedBox(height: 10),

              // Drink & Smoke switches
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text("Drink"),
                      Switch(
                        value: drink,
                        onChanged: (val) => setState(() => drink = val),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text("Smoke"),
                      Switch(
                        value: smoke,
                        onChanged: (val) => setState(() => smoke = val),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Looking for
              TextField(
                controller: _lookingForController,
                decoration: InputDecoration(
                  labelText: "Looking for",
                  labelStyle: TextStyle(color: textFieldColor),
                  enabledBorder:
                      OutlineInputBorder(borderSide: BorderSide(color: textFieldColor)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: textFieldColor, width: 2)),
                ),
                style: TextStyle(color: textFieldColor),
              ),
              const SizedBox(height: 20),

              // Submit
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: forestGreen,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48)),
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
