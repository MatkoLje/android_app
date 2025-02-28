// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names
import 'dart:math';
import 'package:flutter/material.dart';
import 'settings.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.red,
          appBar: AppBar(
            title: Center(
              child: Text(
                'Dicee',
                style: TextStyle(
                  fontFamily: 'Pacifico',
                  fontSize: 36.0,
                ),
              ),
            ),
          ),
          body: DicePage(),
        ),
      ),
    ),
  );
}

class DicePage extends StatefulWidget {
  const DicePage({super.key});

  @override
  State<DicePage> createState() => DicePageState();
}

class DicePageState extends State<DicePage> {
  int leftDiceNumber = 1;
  int rightDiceNumber = 1;
  List<Player> players = [
    Player(name: "Player 1", score: 0),
    Player(name: "Player 2", score: 0),
  ];
  int currentPlayerIndex = 0;

  // Default probabilities for each dice face (1/6 for each face)
  List<double> diceProbabilities = List.filled(6, 1 / 6);

  void changeDiceFace() {
    setState(() {
      leftDiceNumber = getWeightedRandomDiceNumber();
      rightDiceNumber = getWeightedRandomDiceNumber();
      players[currentPlayerIndex].score += leftDiceNumber + rightDiceNumber;
      currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    });
  }

  int getWeightedRandomDiceNumber() {
    double randomValue = Random().nextDouble();
    double cumulativeProbability = 0.0;
    for (int i = 0; i < diceProbabilities.length; i++) {
      cumulativeProbability += diceProbabilities[i];
      if (randomValue < cumulativeProbability) {
        return i + 1;
      }
    }
    return 6; // Fallback to 6 if something goes wrong
  }

  void resetGame() {
    setState(() {
      leftDiceNumber = 1;
      rightDiceNumber = 1;
      for (var player in players) {
        player.score = 0;
      }
      currentPlayerIndex = 0;
    });
  }

  void addPlayer(String name) {
    setState(() {
      players.add(Player(name: name, score: 0));
    });
  }

  Widget resetButton() {
    return IconButton(
      icon: Icon(Icons.refresh),
      onPressed: resetGame,
      color: Colors.white,
    );
  }

  void removePlayer(Player player) {
    setState(() {
      if (players.length > 2) {
        players.remove(player);
        // Adjust currentPlayerIndex if needed
        if (currentPlayerIndex >= players.length) {
          currentPlayerIndex--;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 0),
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              for (var player in players)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${player.name}: ${player.score}",
                        style: TextStyle(
                          fontFamily: 'Pacifico',
                          fontSize: 28.0,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => removePlayer(player),
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              SizedBox(
                height: 20.0,
              ),
              Text(
                "Current Player: ${players[currentPlayerIndex].name}",
                style: TextStyle(
                  fontFamily: 'Pacifico',
                  fontSize: 28.0,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: IconButton(
                      onPressed: changeDiceFace,
                      icon: Image.asset(
                        'images/dice$leftDiceNumber.png', // Adjust path based on your image names
                        width: 100.0,
                        height: 100.0,
                      ),
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      onPressed: changeDiceFace,
                      icon: Image.asset(
                        'images/dice$rightDiceNumber.png', // Adjust path based on your image names
                        width: 100.0,
                        height: 100.0,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                    onPressed: () async {
                      String? playerName = await _displayAddPlayerDialog(context);
                      if (playerName != null && playerName.isNotEmpty) {
                        addPlayer(playerName);
                      }
                    },
                    child: Text(
                      "Add Player",
                      style: TextStyle(
                        fontFamily: 'Pacifico',
                        fontSize: 28.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsPage(
                        diceProbabilities: diceProbabilities,
                        onSave: (newProbabilities) {
                          setState(() {
                            diceProbabilities = newProbabilities;
                          });
                        },
                      ),
                    ),
                  );
                },
                child: Text(
                  "Set Dice Probabilities",
                  style: TextStyle(
                    fontFamily: 'Pacifico',
                    fontSize: 28.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.center,
            child: resetButton(),
          ),
        ],
      ),
    );
  }

  Future<String?> _displayAddPlayerDialog(BuildContext context) async {
    TextEditingController playerNameController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Player'),
          content: TextField(
            controller: playerNameController,
            decoration: InputDecoration(hintText: "Enter player name"),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, playerNameController.text);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class Player {
  String name;
  int score;

  Player({required this.name, required this.score});
}
