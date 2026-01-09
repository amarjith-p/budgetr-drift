class FormulaUtils {
  static double evaluateRPN(String expr) {
    expr = expr.replaceAll(' ', '');
    final tokens = _tokenize(expr);
    if (tokens.isEmpty) return 0.0;

    final outputQueue = <String>[];
    final operatorStack = <String>[];
    final precedence = {'+': 1, '-': 1, '*': 2, '/': 2};

    for (var token in tokens) {
      if (double.tryParse(token) != null) {
        outputQueue.add(token);
      } else if (token == '(') {
        operatorStack.add(token);
      } else if (token == ')') {
        while (operatorStack.isNotEmpty && operatorStack.last != '(') {
          outputQueue.add(operatorStack.removeLast());
        }
        if (operatorStack.isNotEmpty) operatorStack.removeLast();
      } else if (precedence.containsKey(token)) {
        while (operatorStack.isNotEmpty &&
            operatorStack.last != '(' &&
            precedence[operatorStack.last]! >= precedence[token]!) {
          outputQueue.add(operatorStack.removeLast());
        }
        operatorStack.add(token);
      }
    }
    while (operatorStack.isNotEmpty) {
      outputQueue.add(operatorStack.removeLast());
    }

    final evalStack = <double>[];
    for (var token in outputQueue) {
      if (double.tryParse(token) != null) {
        evalStack.add(double.parse(token));
      } else {
        if (evalStack.length < 2) return 0.0;
        final b = evalStack.removeLast();
        final a = evalStack.removeLast();
        switch (token) {
          case '+':
            evalStack.add(a + b);
            break;
          case '-':
            evalStack.add(a - b);
            break;
          case '*':
            evalStack.add(a * b);
            break;
          case '/':
            evalStack.add(b == 0 ? 0 : a / b);
            break;
        }
      }
    }
    return evalStack.isNotEmpty ? evalStack.last : 0.0;
  }

  static List<String> _tokenize(String expr) {
    List<String> tokens = [];
    String buffer = '';

    for (int i = 0; i < expr.length; i++) {
      String char = expr[i];
      if ('+-*/()'.contains(char)) {
        if (buffer.isNotEmpty) {
          tokens.add(buffer);
          buffer = '';
        }
        if (char == '-' && (tokens.isEmpty || '+-*/('.contains(tokens.last))) {
          buffer += char;
        } else {
          tokens.add(char);
        }
      } else {
        buffer += char;
      }
    }
    if (buffer.isNotEmpty) tokens.add(buffer);
    return tokens;
  }
}
