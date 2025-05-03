import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Calculator',
      theme: ThemeData.dark(),
      home: CalculatorPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CalculatorPage extends StatefulWidget {
  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String expression = '';
  String result = '0';
  String? selectedPhoneNumber;

  // Method to handle the contact picking
  Future<void> pickContact() async {
    if (await FlutterContacts.requestPermission()) {
      final contact = await FlutterContacts.openExternalPick();
      if (contact != null && contact.phones.isNotEmpty) {
        String number = contact.phones.first.number;

        // Remove all non-digit characters (e.g. spaces, dashes, etc.)
        number = number.replaceAll(RegExp(r'\D'), '');

        // Remove leading zero if present
        if (number.startsWith('0')) {
          number = number.substring(1);
        }

        setState(() {
          selectedPhoneNumber = number;
        });

        print('Selected phone number: $selectedPhoneNumber');
      } else {
        print('No phone number');
      }
    }
  }

  // Handle calculator button press logic
  void _onPressed(String text) {
    setState(() {
      if (text == 'C') {
        expression = '';
        result = '0';
      } else if (text == '⌫') {
        if (expression.isNotEmpty) {
          expression = expression.substring(0, expression.length - 1);
        }
      } else if (text == '=') {
        if (selectedPhoneNumber != null) {
          result = selectedPhoneNumber!;
        } else {
          try {
            Parser p = Parser();
            Expression exp = p.parse(
              expression.replaceAll('×', '*').replaceAll('÷', '/'),
            );
            ContextModel cm = ContextModel();
            double correctResult = exp.evaluate(EvaluationType.REAL, cm);
            result = correctResult.toString();
          } catch (e) {
            result = 'Error';
          }
        }
      } else {
        expression += text;
      }
    });
  }

  // Build the calculator buttons
  Widget _buildButton(String text, {Color? color}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: GestureDetector(
          onLongPress: () {
            if (text == '=') {
              pickContact(); // Call the pickContact function here
            }
          },
          child: ElevatedButton(
            onPressed: () => _onPressed(text),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(24),
              backgroundColor: color ?? Colors.grey[800],
            ),
            child: Text(text, style: TextStyle(fontSize: 24)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ilker's Calculator")),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.all(24),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    expression,
                    style: TextStyle(fontSize: 32, color: Colors.grey[400]),
                  ),
                  FittedBox(
                    fit:
                        BoxFit
                            .scaleDown, // This will scale down the text to fit the available space
                    child: Text(
                      result,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  _buildButton('7'),
                  _buildButton('8'),
                  _buildButton('9'),
                  _buildButton('÷'),
                ],
              ),
              Row(
                children: [
                  _buildButton('4'),
                  _buildButton('5'),
                  _buildButton('6'),
                  _buildButton('×'),
                ],
              ),
              Row(
                children: [
                  _buildButton('1'),
                  _buildButton('2'),
                  _buildButton('3'),
                  _buildButton('-'),
                ],
              ),
              Row(
                children: [
                  _buildButton('0'),
                  _buildButton('.'),
                  _buildButton('⌫'), // NEW DELETE BUTTON
                  _buildButton('+'),
                ],
              ),
              Row(children: [_buildButton('C'), _buildButton('=')]),
            ],
          ),
        ],
      ),
    );
  }
}
