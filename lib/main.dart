import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(BouncingBallGame());
}

class BouncingBallGame extends StatefulWidget {
  @override
  _BouncingBallGameState createState() => _BouncingBallGameState();
}

class _BouncingBallGameState extends State<BouncingBallGame> {
  double _ballX = 0;
  double _ballY = 0;
  double _ballSpeedX = 0.02;
  double _ballSpeedY = 0.03;
  double _ballSize = 30;
  double _playerPaddleX = 0;
  double _aiPaddleX = 0;
  double _paddleWidth = 100;
  double _paddleHeight = 15;
  int _playerScore = 0;
  int _aiScore = 0;
  Timer? _timer;
  Random _random = Random();

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _timer = Timer.periodic(Duration(milliseconds: 16), (timer) {
      setState(() {
        _ballX += _ballSpeedX;
        _ballY += _ballSpeedY;

        if (_ballX <= -1 || _ballX >= 1) {
          _ballSpeedX = -_ballSpeedX;
        }
        if (_ballY <= -1) {
          _ballSpeedY = -_ballSpeedY;
        }

        double playerPaddleLeft = _playerPaddleX - (_paddleWidth / 2) / 200;
        double playerPaddleRight = _playerPaddleX + (_paddleWidth / 2) / 200;
        double aiPaddleLeft = _aiPaddleX - (_paddleWidth / 2) / 200;
        double aiPaddleRight = _aiPaddleX + (_paddleWidth / 2) / 200;

        if (_ballY >= 0.9 && _ballX >= playerPaddleLeft && _ballX <= playerPaddleRight) {
          _ballSpeedY = -_ballSpeedY;
          _playerScore++;
        }

        if (_ballY <= -0.9 && _ballX >= aiPaddleLeft && _ballX <= aiPaddleRight) {
          _ballSpeedY = -_ballSpeedY;
          _aiScore++;
        }

        if (_ballY >= 1) {
          _aiScore++;
          _resetBall();
        }
        if (_ballY <= -1) {
          _playerScore++;
          _resetBall();
        }

        _moveAIPaddle();
      });
    });
  }

  void _resetBall() {
    _ballX = 0;
    _ballY = 0;
    _ballSpeedX = 0.02 * (_random.nextBool() ? 1 : -1);
    _ballSpeedY = 0.03 * (_random.nextBool() ? 1 : -1);
  }

  void _moveAIPaddle() {
    if (_ballSpeedY < 0) {
      if (_random.nextDouble() > 0.4) { // AI가 80% 확률로 반응
        if (_ballX > _aiPaddleX + 0.05) {
          _aiPaddleX += 0.03;
        } else if (_ballX < _aiPaddleX - 0.05) {
          _aiPaddleX -= 0.03;
        }
      }
      _aiPaddleX = _aiPaddleX.clamp(-1.0, 1.0);
    }
  }

  void _movePlayerPaddle(DragUpdateDetails details) {
    setState(() {
      _playerPaddleX += details.primaryDelta! / 200;
      _playerPaddleX = _playerPaddleX.clamp(-1.0, 1.0);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("VORA 볼 미니게임 - Player: $_playerScore | AI: $_aiScore")),
        body: GestureDetector(
          onHorizontalDragUpdate: _movePlayerPaddle,
          child: LayoutBuilder(
            builder: (context, constraints) {
              double screenWidth = constraints.maxWidth;
              double screenHeight = constraints.maxHeight;

              double ballPosX = (screenWidth / 2) + (_ballX * (screenWidth / 2));
              double ballPosY = (screenHeight / 2) + (_ballY * (screenHeight / 2));

              double playerPaddlePosX = (screenWidth / 2) + (_playerPaddleX * (screenWidth / 2));
              double aiPaddlePosX = (screenWidth / 2) + (_aiPaddleX * (screenWidth / 2));

              return Stack(
                children: [
                  Positioned(
                    left: ballPosX - _ballSize / 2,
                    top: ballPosY - _ballSize / 2,
                    child: Container(
                      width: _ballSize,
                      height: _ballSize,
                      decoration: BoxDecoration(
                        color: Color(0xFF583BBF),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: playerPaddlePosX - _paddleWidth / 2,
                    bottom: 20,
                    child: Container(
                      width: _paddleWidth,
                      height: _paddleHeight,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Positioned(
                    left: aiPaddlePosX - _paddleWidth / 2,
                    top: 20,
                    child: Container(
                      width: _paddleWidth,
                      height: _paddleHeight,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}