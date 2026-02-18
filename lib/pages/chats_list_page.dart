import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'chat_page.dart';

class ChatsListPage extends StatefulWidget {
  const ChatsListPage({super.key});

  @override
  State<ChatsListPage> createState() => _ChatsListPageState();
}

class _ChatsListPageState extends State<ChatsListPage> {
  List<Map<String, dynamic>> matches = [];
  bool isLoading = false;
  int coins = 0; // 💰 user's coins

  @override
  void initState() {
    super.initState();
    loadMatches();
    loadCoins();
  }

  Future<void> loadMatches() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getMatches(); // ✅ make sure you added this method
      if (!mounted) return;

      setState(() {
        matches = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading matches: $e")),
      );
    }
  }

  Future<void> loadCoins() async {
    try {
      final currentCoins = await ApiService.getCoins();
      if (!mounted) return;
      setState(() {
        coins = currentCoins;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching coins: $e")),
      );
    }
  }

  void openChat(Map<String, dynamic> match) {
    if (coins < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You need at least 3 coins to open a chat."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(
          matchUserId: match['id'],
          matchUsername: match['username'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Matches"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                "💰 $coins",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: matches.length,
              itemBuilder: (_, index) {
                final match = matches[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: match['profile_image'] != null
                        ? NetworkImage(match['profile_image'])
                        : null,
                    child: match['profile_image'] == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(match['username']),
                  subtitle: Text(match['bio'] ?? ''),
                  trailing: const Icon(Icons.chat),
                  onTap: () => openChat(match),
                );
              },
            ),
    );
  }
}
