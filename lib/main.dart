import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1E1E2C),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFB74D), // orange accent
          secondary: Color(0xFF26C6DA), // cyan accent
        ),
        fontFamily: 'Roboto',
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _expression = '';
  String _result = '0';

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'AC') {
        _expression = '';
        _result = '0';
      } else if (value == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (value == '=') {
        _calculateResult();
      } else {
        // Prevent adding two operators in a row
        if (_isOperator(value) &&
            (_expression.isEmpty ||
                _isOperator(_expression[_expression.length - 1]))) {
          return;
        }
        _expression += value;
      }
    });
  }

  bool _isOperator(String ch) {
    return ch == '+' || ch == '-' || ch == '×' || ch == '÷' || ch == '%';
  }

  void _calculateResult() {
    if (_expression.isEmpty) return;

    String exp = _expression.replaceAll('×', '*').replaceAll('÷', '/');

    try {
      final tokens = _tokenize(exp);
      final value = _evaluateTokens(tokens);
      _result = value.toString();
    } catch (_) {
      _result = 'Error';
    }
  }

  List<String> _tokenize(String exp) {
    final tokens = <String>[];
    final buffer = StringBuffer();

    for (int i = 0; i < exp.length; i++) {
      final ch = exp[i];
      if ('+-*/%'.contains(ch)) {
        if (buffer.isNotEmpty) {
          tokens.add(buffer.toString());
          buffer.clear();
        }
        tokens.add(ch);
      } else {
        buffer.write(ch);
      }
    }
    if (buffer.isNotEmpty) {
      tokens.add(buffer.toString());
    }
    return tokens;
  }

  double _evaluateTokens(List<String> tokens) {
    if (tokens.isEmpty) return 0;

    double current = double.parse(tokens[0]);

    for (int i = 1; i < tokens.length; i += 2) {
      final op = tokens[i];
      final next = double.parse(tokens[i + 1]);

      switch (op) {
        case '+':
          current += next;
          break;
        case '-':
          current -= next;
          break;
        case '*':
          current *= next;
          break;
        case '/':
          current /= next;
          break;
        case '%':
          current %= next;
          break;
      }
    }
    if (current == current.roundToDouble()) {
      return current.roundToDouble();
    }
    return current;
  }

  @override
  Widget build(BuildContext context) {
    const buttonTexts = [
      'AC',
      '⌫',
      '%',
      '÷',
      '7',
      '8',
      '9',
      '×',
      '4',
      '5',
      '6',
      '-',
      '1',
      '2',
      '3',
      '+',
      '00',
      '0',
      '.',
      '=',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    _expression,
                    style: const TextStyle(fontSize: 26, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _result,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF25253A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: buttonTexts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final text = buttonTexts[index];
                final isOperatorBtn = '÷×-+%='.contains(text);
                final isSpecial = text == 'AC' || text == '⌫';

                Color bgColor = const Color(0xFF2F2F45);
                Color fgColor = Colors.white;

                if (isOperatorBtn) {
                  bgColor = const Color(0xFFFFB74D);
                  fgColor = Colors.black;
                } else if (isSpecial) {
                  bgColor = const Color(0xFF4DB6AC);
                  fgColor = Colors.black;
                }

                return _CalcButton(
                  text: text,
                  backgroundColor: bgColor,
                  foregroundColor: fgColor,
                  onTap: () => _onButtonPressed(text),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CalcButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  const _CalcButton({
    required this.text,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                offset: const Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: foregroundColor,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
