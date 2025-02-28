import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final List<double> diceProbabilities;
  final Function(List<double>) onSave;

  const SettingsPage({required this.diceProbabilities, required this.onSave, super.key});

  @override
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  late List<TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(6, (index) => TextEditingController());
    for (int i = 0; i < 6; i++) {
      controllers[i].text = (widget.diceProbabilities[i] * 100).toString();
    }
  }

  void saveSettings() {
    bool allValid = true;
    double totalProbability = 0;
    for (var controller in controllers) {
      double value = double.tryParse(controller.text) ?? -1;
      if (value < 0 || value > 100) {
        allValid = false;
        break;
      }
      totalProbability += value;
    }

    if (totalProbability > 100 || totalProbability <= 0) {
      allValid = false;
    }

    if (allValid) {
      List<double> newProbabilities = controllers.map((c) => double.parse(c.text) / 100).toList();
      widget.onSave(newProbabilities);
      Navigator.pop(context);
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Invalid Input'),
            content: Text('Probabilities must be between 0 and 100 and sum up to 100.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Dice Probabilities'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            for (int i = 0; i < 6; i++)
              TextField(
                controller: controllers[i],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Number ${i + 1} (%)'),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveSettings,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
