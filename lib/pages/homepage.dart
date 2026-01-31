import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key, this.onNavigate});
  final Function(int)? onNavigate; // optional callback

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDarkMode ? Colors.black : Colors.grey.shade100;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Mixen"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/images/onboard1.png'),
              fit: BoxFit.cover,
              opacity: 0.08,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back 👋",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "What would you like to do today?",
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 1,
                    children: [
                      _buildActionCard(
                        icon: Icons.chat_bubble_outline,
                        title: "Chats",
                        color: Colors.blue,
                        image: 'assets/images/onboard1.png',
                        onTap: () => widget.onNavigate?.call(1),
                      ),
                      _buildActionCard(
                        icon: Icons.explore_outlined,
                        title: "Explore",
                        color: Colors.orange,
                        image: 'assets/images/explore.png',
                        onTap: () => widget.onNavigate?.call(2),
                      ),
                      _buildActionCard(
                        icon: Icons.monetization_on_outlined,
                        title: "Coins",
                        color: Colors.purple,
                        image: 'assets/images/coins.png',
                        onTap: () {},
                      ),
                      _buildActionCard(
                        icon: Icons.person_outline,
                        title: "Profile",
                        color: Colors.green,
                        image: 'assets/images/profile.png',
                        onTap: () => widget.onNavigate?.call(3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    String? image,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
          image: image != null
              ? DecorationImage(
                  image: AssetImage(image),
                  fit: BoxFit.cover,
                  opacity: 0.1,
                  onError: (_, __) {}, // ignore missing image errors
                )
              : null,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 42, color: color),
            const SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
