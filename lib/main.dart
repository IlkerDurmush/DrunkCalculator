import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

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

  void _onPressed(String text) {
    setState(() {
      if (text == 'C') {
        expression = '';
        result = '0';
      } else if (text == '=') {
        try {
          Parser p = Parser();
          Expression exp = p.parse(
            expression.replaceAll('×', '*').replaceAll('÷', '/'),
          );
          ContextModel cm = ContextModel();
          double correctResult = exp.evaluate(EvaluationType.REAL, cm);

          // Intentionally corrupt the result:
          double fakeResult =
              correctResult + (5 - (correctResult % 10)); // Add random offset
          result = fakeResult.toStringAsFixed(2);
        } catch (e) {
          result = 'Error';
        }
      } else {
        expression += text;
      }
    });
  }

  Widget _buildButton(String text, {Color? color}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          onPressed: () => _onPressed(text),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.all(24),
            backgroundColor: color ?? Colors.grey[800],
          ),
          child: Text(text, style: TextStyle(fontSize: 24)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calculator')),
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
                  Text(
                    result,
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
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
                  _buildButton('C'),
                  _buildButton('+'),
                ],
              ),
              Row(children: [_buildButton('=')]),
            ],
          ),
        ],
      ),
    );
  }
}
