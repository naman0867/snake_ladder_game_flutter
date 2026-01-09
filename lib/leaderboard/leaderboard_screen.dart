import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../leaderboard/leaderboard_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int playerPosition = 0;
  int diceValue = 1;
  int moves = 0;
  bool gameOver = false;

  final Random random = Random();

  /// Snakes and ladders map
  final Map<int, int> snakesAndLadders = {
    3: 22,   // ladder
    5: 8,    // ladder
    11: 26,  // ladder
    20: 29,  // ladder
    27: 1,   // snake
    21: 9,   // snake
    17: 4,   // snake
    19: 7,   // snake
  };

  void rollDice() async {
    if (gameOver) return;

    setState(() {
      diceValue = random.nextInt(6) + 1;
      moves++;
    });

    int nextPosition = playerPosition + diceValue;

    if (nextPosition <= 30) {
      await Future.delayed(const Duration(milliseconds: 400));

      if (snakesAndLadders.containsKey(nextPosition)) {
        nextPosition = snakesAndLadders[nextPosition]!;
      }

      setState(() {
        playerPosition = nextPosition;
      });

      if (playerPosition == 30) {
        gameOver = true;
        saveScore();
        showWinDialog();
      }
    }
  }

  Future<void> saveScore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('leaderboard').add({
      'email': user.email,
      'score': 100,
      'time': moves,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  void showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("🎉 You Win!"),
        content: Text("Moves taken: $moves"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const LeaderboardScreen(),
                ),
              );
            },
            child: const Text("View Leaderboard"),
          ),
        ],
      ),
    );
  }

  Widget buildBoard() {
    return GridView.builder(
      itemCount: 30,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
      ),
      itemBuilder: (context, index) {
        int cellNumber = 30 - index;
        bool isPlayerHere = cellNumber == playerPosition;

        return Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isPlayerHere ? Colors.green : Colors.blue.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black),
          ),
          child: Center(
            child: Text(
              cellNumber.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isPlayerHere ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Snake & Ladder"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Text(
            "Position: $playerPosition",
            style: const TextStyle(fontSize: 20),
          ),
          Text(
            "Dice: $diceValue",
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),
          Expanded(child: buildBoard()),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: rollDice,
            child: const Text("Roll Dice 🎲"),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
