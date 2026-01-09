import 'dart:math';
import 'package:flutter/material.dart';
import '../leaderboard/leaderboard_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int dice = 1;
  int currentPlayer = 1;
  int p1Pos = 1;
  int p2Pos = 1;
  bool isRolling = false;

  final Random _random = Random();

  // 🐍 Snakes
  final Map<int, int> snakes = {
    99: 54,
    95: 75,
    92: 88,
    87: 24,
    64: 60,
    62: 19,
    54: 34,
    49: 11,
  };

  // 🪜 Ladders
  final Map<int, int> ladders = {
    2: 38,
    7: 14,
    8: 31,
    15: 26,
    21: 42,
    28: 84,
    36: 44,
    51: 67,
    71: 91,
    78: 98,
  };

  // 🎲 Dice roll with animation
  Future<void> rollDice() async {
    if (isRolling) return;

    setState(() => isRolling = true);

    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 80));
      setState(() {
        dice = _random.nextInt(6) + 1;
      });
    }

    int newPos =
        (currentPlayer == 1 ? p1Pos : p2Pos) + dice;

    if (newPos > 100) {
      setState(() {
        currentPlayer = currentPlayer == 1 ? 2 : 1;
        isRolling = false;
      });
      return;
    }

    if (ladders.containsKey(newPos)) {
      newPos = ladders[newPos]!;
    } else if (snakes.containsKey(newPos)) {
      newPos = snakes[newPos]!;
    }

    setState(() {
      if (currentPlayer == 1) {
        p1Pos = newPos;
        if (p1Pos == 100) {
          _showWinDialog("Player 1");
          return;
        }
      } else {
        p2Pos = newPos;
        if (p2Pos == 100) {
          _showWinDialog("Player 2");
          return;
        }
      }

      currentPlayer = currentPlayer == 1 ? 2 : 1;
      isRolling = false;
    });
  }

  // 🏁 Win dialog
  void _showWinDialog(String winner) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("🎉 Game Over"),
        content: Text("$winner wins the game!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              resetGame();
            },
            child: const Text("Play Again"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LeaderboardScreen(),
                ),
              );
              resetGame(); // ✅ critical fix
            },
            child: const Text("Leaderboard"),
          ),
        ],
      ),
    );
  }

  // 🔄 Reset game state
  void resetGame() {
    setState(() {
      p1Pos = 1;
      p2Pos = 1;
      dice = 1;
      currentPlayer = 1;
      isRolling = false;
    });
  }

  // 🎨 Tile color logic
  Color tileColor(int number) {
    if (number == p1Pos && number == p2Pos) return Colors.purple;
    if (number == p1Pos) return Colors.green;
    if (number == p2Pos) return Colors.red;
    if (ladders.containsKey(number)) return Colors.lightGreen;
    if (snakes.containsKey(number)) return Colors.orange;
    return Colors.blue.shade200;
  }

  // 🧾 Tile label
  String tileText(int number) {
    if (number == p1Pos && number == p2Pos) return "P1&P2";
    if (number == p1Pos) return "P1";
    if (number == p2Pos) return "P2";
    if (ladders.containsKey(number)) return "⬆$number";
    if (snakes.containsKey(number)) return "⬇$number";
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Snake & Ladder (100 Board)"),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LeaderboardScreen(),
                ),
              );
              resetGame(); // ✅ fixes roll issue
            },
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Text(
            "Player $currentPlayer's Turn",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Text(
              "🎲 $dice",
              key: ValueKey(dice),
              style: const TextStyle(fontSize: 28),
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: 100,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 10,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemBuilder: (_, index) {
                int number = 100 - index;
                return Container(
                  decoration: BoxDecoration(
                    color: tileColor(number),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      tileText(number),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ElevatedButton(
              onPressed: isRolling ? null : rollDice,
              child: const Text("Roll Dice 🎲"),
            ),
          ),
        ],
      ),
    );
  }
}
