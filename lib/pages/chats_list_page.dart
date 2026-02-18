import 'package:flutter/material.dart';
import 'chat_page.dart';

class ChatsListPage extends StatelessWidget {
  const ChatsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Example dummy data
    final matches = [
      {
        "id": 2,
        "username": "Grace",
        "last_message": "Hey, how are you?",
        "online": true
      },
      {
        "id": 5,
        "username": "Michael",
        "last_message": "Let's meet tomorrow!",
        "online": false
      },
    ];

    return ListView.builder(
      itemCount: matches.length,
      itemBuilder: (_, index) {
        final user = matches[index];

        final int userId = user['id'] is int ? user['id'] as int : 0;
        final String username = user['username']?.toString() ?? 'Unknown';
        final String lastMessage = user['last_message']?.toString() ?? '';
        final bool isOnline = user['online'] == true;

        return ListTile(
          leading: Stack(
            children: [
              const CircleAvatar(child: Icon(Icons.person)),
              if (isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            username,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatPage(
                  matchUserId: userId,
                  matchUsername: username,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
