import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  LeaderboardScreen({super.key});

  final List<Map<String, dynamic>> leaderboard = [
    {"player": "Player 1", "wins": 3},
    {"player": "Player 2", "wins": 2},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leaderboard"),
      ),
      body: ListView.builder(
        itemCount: leaderboard.length,
        itemBuilder: (context, index) {
          final data = leaderboard[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                child: Text("${index + 1}"),
              ),
              title: Text(data["player"]),
              subtitle: Text("Wins: ${data["wins"]}"),
            ),
          );
        },
      ),
    );
  }
}
