import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../leaderboard/leaderboard_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int diceNumber = 1;

  int player1Pos = 1;
  int player2Pos = 1;

  bool isPlayer1Turn = true;

  final AudioPlayer _audioPlayer = AudioPlayer();

  /// 🪜 Ladders
  final Map<int, int> ladders = {
    3: 22,
    5: 8,
    11: 26,
    20: 29,
  };

  /// 🐍 Snakes
  final Map<int, int> snakes = {
    27: 1,
    21: 9,
    17: 4,
    19: 7,
  };

  Future<void> rollDice() async {
    await _audioPlayer.play(AssetSource('sounds/dice.mp3'));

    int roll = Random().nextInt(6) + 1;
    int currentPos = isPlayer1Turn ? player1Pos : player2Pos;
    int nextPos = currentPos + roll;

    if (nextPos <= 100) {
      if (ladders.containsKey(nextPos)) {
        nextPos = ladders[nextPos]!;
      } else if (snakes.containsKey(nextPos)) {
        nextPos = snakes[nextPos]!;
      }
    } else {
      nextPos = currentPos;
    }

    setState(() {
      diceNumber = roll;

      if (isPlayer1Turn) {
        player1Pos = nextPos;
      } else {
        player2Pos = nextPos;
      }

      if (nextPos == 100) {
        saveWinner(isPlayer1Turn ? "Player 1" : "Player 2");
        showWinDialog(isPlayer1Turn ? "Player 1" : "Player 2");
      } else {
        isPlayer1Turn = !isPlayer1Turn;
      }
    });
  }

  Future<void> saveWinner(String playerName) async {
    await FirebaseFirestore.instance.collection('leaderboard').add({
      'player': playerName,
      'score': 100,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void showWinDialog(String winner) async {
    await _audioPlayer.play(AssetSource('sounds/win.mp3'));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("🎉 Game Over"),
        content: Text("$winner Wins the Game!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              resetGame();
            },
            child: const Text("Play Again"),
          ),
        ],
      ),
    );
  }

  void resetGame() {
    setState(() {
      player1Pos = 1;
      player2Pos = 1;
      isPlayer1Turn = true;
      diceNumber = 1;
    });
  }

  List<int> generateBoardNumbers() {
    List<int> numbers = [];
    int start = 100;

    for (int row = 0; row < 10; row++) {
      List<int> rowNums = List.generate(10, (i) => start - i);
      if (row.isOdd) rowNums = rowNums.reversed.toList();
      numbers.addAll(rowNums);
      start -= 10;
    }
    return numbers;
  }

  Widget buildCell(int number) {
    bool p1Here = number == player1Pos;
    bool p2Here = number == player2Pos;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        color: Colors.white,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(number.toString(), style: const TextStyle(fontSize: 11)),

          if (snakes.containsKey(number))
            const Align(alignment: Alignment.topRight, child: Text("🐍")),

          if (ladders.containsKey(number))
            const Align(alignment: Alignment.bottomLeft, child: Text("🪜")),

          if (p1Here)
            const Align(
              alignment: Alignment.centerLeft,
              child: CircleAvatar(radius: 6, backgroundColor: Colors.red),
            ),

          if (p2Here)
            const Align(
              alignment: Alignment.centerRight,
              child: CircleAvatar(radius: 6, backgroundColor: Colors.blue),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final boardNumbers = generateBoardNumbers();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Snake & Ladder"),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LeaderboardScreen(),
                ),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          Text(
            isPlayer1Turn ? "Player 1's Turn 🔴" : "Player 2's Turn 🔵",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),
          Text("Dice: $diceNumber", style: const TextStyle(fontSize: 16)),

          ElevatedButton(
            onPressed: rollDice,
            child: const Text("Roll Dice 🎲"),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 10,
              ),
              itemCount: 100,
              itemBuilder: (_, index) {
                return buildCell(boardNumbers[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
