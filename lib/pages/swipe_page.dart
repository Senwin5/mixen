import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:mixen/services/api_service.dart';
import 'upload_profile_image_page.dart'; // ✅ Import the upload page

class SwipePage extends StatefulWidget {
  const SwipePage({super.key});

  @override
  State<SwipePage> createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    setState(() => isLoading = true);
    try {
      final fetchedUsers = await ApiService.getSwipeUsers();
      if (!mounted) return;

      setState(() {
        users = fetchedUsers;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading users: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _likeUser(Map<String, dynamic> user) async {
    final result = await ApiService.likeUser(user['id']);
    if (!mounted) return;

    if (result['matched'] == true) {
      _showSnack("It's a match with ${user['username']} ❤️");
    } else if (result['success'] == true) {
      _showSnack("You liked ${user['username']} 💖");
    }
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.pinkAccent,
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 6),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: user['profile_image'] != null
                  ? Image.network(
                      user['profile_image'],
                      fit: BoxFit.cover,
                    )
                  : Container(color: Colors.grey.shade300),
            ),

            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      // ignore: deprecated_member_use
                      Colors.black.withOpacity(0.85),
                    ],
                  ),
                ),
              ),
            ),

            // User info
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${user['username'] ?? "Unknown"}, ${user['age'] ?? 'N/A'}",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    user['bio'] ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Button to go to Upload Profile Image page
  Widget _uploadButton() {
    return ElevatedButton(
      onPressed: () async {
        // Go to UploadProfileImagePage and wait for result
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UploadProfileImagePage()),
        );

        // After returning, reload the users so the new profile image shows
        loadUsers();
      },
      child: const Text("Upload/Change Profile Image"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Discover"),
        centerTitle: true,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _uploadButton(), // Button in the AppBar
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
              ? const Center(child: Text("No users found 😢"))
              : Swiper(
                  itemCount: users.length,
                  itemBuilder: (context, index) =>
                      _buildUserCard(users[index]),
                  layout: SwiperLayout.STACK,
                  itemWidth: MediaQuery.of(context).size.width * 0.9,
                  itemHeight: MediaQuery.of(context).size.height * 0.7,
                  scrollDirection: Axis.vertical,
                  onIndexChanged: (index) async {
                    if (index > 0) {
                      await _likeUser(users[index - 1]);
                    }
                  },
                ),
    );
  }
}
