import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ChatPage extends StatefulWidget {
  final int matchUserId;
  final String matchUsername;

  const ChatPage({
    super.key,
    required this.matchUserId,
    required this.matchUsername,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  List<Map<String, dynamic>> messages = [];
  bool isLoading = false;
  int coins = 0; // 💰 user's coins
  static const int chatCost = 3; // ✅ coins per message

  @override
  void initState() {
    super.initState();
    loadMessages();
    loadUserCoins();
  }

  Future<void> loadMessages() async {
    setState(() => isLoading = true);
    try {
      final fetchedMessages =
          await ApiService.getMessages(widget.matchUserId);

      if (!mounted) return;

      setState(() {
        messages = fetchedMessages;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading messages: $e")),
      );
    }
  }

  Future<void> loadUserCoins() async {
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

  // ================= SEND MESSAGE (3 coins) =================
  Future<void> sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    if (coins < chatCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("You need at least $chatCost coins to send a message."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    final result =
        await ApiService.sendMessage(widget.matchUserId, text);

    if (result['success'] == true) {
      _messageController.clear();

      messages.add({'text': text, 'sender': 'me'});

      // ✅ Update coins from backend response
      if (result['remaining_coins'] != null) {
        setState(() {
          coins = result['remaining_coins'];
        });
      }

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Message sent! Coins left: $coins 💰"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? "Not enough coins"),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) setState(() => isLoading = false);
  }

  // ================= START CALL (5 coins) =================
  Future<void> startCall() async {
    final result = await ApiService.startCall(widget.matchUserId);

    if (result['success'] == true) {
      if (result['remaining_coins'] != null) {
        setState(() {
          coins = result['remaining_coins'];
        });
      }

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Call started! Coins left: $coins 💰"),
          backgroundColor: Colors.blue,
        ),
      );
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? "Not enough coins for call"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget buildMessage(Map<String, dynamic> msg) {
    final isMe = msg['sender'] == 'me';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: isMe ? Colors.green[300] : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          msg['text'],
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.matchUsername),
        actions: [
          // 💰 Coins Display
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                "💰 $coins",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),

          // 📞 Call Button (5 coins)
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: startCall,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (_, index) =>
                        buildMessage(messages[messages.length - 1 - index]),
                  ),
          ),

          // ================= INPUT BAR =================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: Colors.grey[200],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Type a message (3 coins)...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.green),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
