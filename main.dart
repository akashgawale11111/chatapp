import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const SnakeGameApp());
}

class SnakeGameApp extends StatelessWidget {
  const SnakeGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game',
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.dark,
      ),
      home: const SnakeGameScreen(),
    );
  }
}

class SnakeGameScreen extends StatefulWidget {
  const SnakeGameScreen({super.key});

  @override
  State<SnakeGameScreen> createState() => _SnakeGameScreenState();
}

class _SnakeGameScreenState extends State<SnakeGameScreen> {
  static const int gridSize = 20;
  static const double cellSize = 20.0;
  
  List<Offset> snake = [const Offset(5, 5)];
  Offset food = const Offset(10, 10);
  Offset direction = const Offset(1, 0);
  Timer? gameTimer;
  int score = 0;
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    setState(() {
      snake = [const Offset(5, 5)];
      direction = const Offset(1, 0);
      score = 0;
      isGameOver = false;
      placeFood();
    });

    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      moveSnake();
    });
  }

  void placeFood() {
    final random = Random();
    do {
      food = Offset(
        random.nextInt(gridSize).toDouble(),
        random.nextInt(gridSize).toDouble(),
      );
    } while (snake.contains(food));
  }

  void moveSnake() {
    setState(() {
      final newHead = Offset(
        (snake.first.dx + direction.dx) % gridSize,
        (snake.first.dy + direction.dy) % gridSize,
      );

      if (snake.contains(newHead)) {
        gameOver();
        return;
      }

      snake.insert(0, newHead);

      if (newHead == food) {
        score += 1;
        placeFood();
      } else {
        snake.removeLast();
      }
    });
  }

  void gameOver() {
    gameTimer?.cancel();
    setState(() {
      isGameOver = true;
    });
  }

  void onKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      setState(() {
        if (event.logicalKey == LogicalKeyboardKey.arrowUp && direction.dy != 1) {
          direction = const Offset(0, -1);
        } else if (event.logicalKey == LogicalKeyboardKey.arrowDown && direction.dy != -1) {
          direction = const Offset(0, 1);
        } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft && direction.dx != 1) {
          direction = const Offset(-1, 0);
        } else if (event.logicalKey == LogicalKeyboardKey.arrowRight && direction.dx != -1) {
          direction = const Offset(1, 0);
        }
      });
    }
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: onKeyEvent,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Snake Game - Score: $score'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: gridSize * cellSize,
                height: gridSize * cellSize,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                ),
                child: CustomPaint(
                  painter: SnakeGamePainter(
                    snake: snake,
                    food: food,
                    cellSize: cellSize,
                  ),
                ),
              ),
              if (isGameOver)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text(
                        'Game Over!',
                        style: TextStyle(fontSize: 24),
                      ),
                      ElevatedButton(
                        onPressed: startGame,
                        child: const Text('Restart Game'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SnakeGamePainter extends CustomPainter {
  final List<Offset> snake;
  final Offset food;
  final double cellSize;

  SnakeGamePainter({
    required this.snake,
    required this.food,
    required this.cellSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint snakePaint = Paint()..color = Colors.green;
    final Paint foodPaint = Paint()..color = Colors.red;

    // Draw snake
    for (final part in snake) {
      canvas.drawRect(
        Rect.fromLTWH(
          part.dx * cellSize,
          part.dy * cellSize,
          cellSize - 1,
          cellSize - 1,
        ),
        snakePaint,
      );
    }

    // Draw food
    canvas.drawRect(
      Rect.fromLTWH(
        food.dx * cellSize,
        food.dy * cellSize,
        cellSize - 1,
        cellSize - 1,
      ),
      foodPaint,
    );
  }

  @override
  bool shouldRepaint(SnakeGamePainter oldDelegate) => true;
}
