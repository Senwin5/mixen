import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UploadProfileImagePage extends StatefulWidget {
  const UploadProfileImagePage({super.key});

  @override
  State<UploadProfileImagePage> createState() => _UploadProfileImagePageState();
}

class _UploadProfileImagePageState extends State<UploadProfileImagePage> {
  File? _image;
  bool isLoading = false;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<void> uploadImage() async {
    if (_image == null) return;

    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse("http://10.0.2.2:8000/api/upload-profile-images/"),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

    final response = await request.send();
    setState(() => isLoading = false);

    if (response.statusCode == 201) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image uploaded successfully!")),
      );
      // ignore: use_build_context_synchronously
      Navigator.pop(context); // Go back to previous page
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: ${response.statusCode}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color forestGreen = Color(0xFF2F855A);
    const Color backgroundColor = Color(0xFFF3FDE3); // match other pages

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: forestGreen,
        title: const Text("Upload Profile Image"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: forestGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size(150, 48),
              ),
              onPressed: pickImage,
              child: const Text("Pick Image"),
            ),
            const SizedBox(height: 10),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: forestGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(150, 48),
                    ),
                    onPressed: uploadImage,
                    child: const Text("Upload"),
                  ),
          ],
        ),
      ),
    );
  }
}
