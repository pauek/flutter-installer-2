import 'package:console/console.dart';

abstract class Step<T> {
  final List<Step> _steps;
  CursorPosition? _pos;
  Step([List<Step>? steps]) : _steps = steps ?? [];

  int get numInputSteps => 0;
  List<Step> get steps => _steps;

  CursorPosition setPos(CursorPosition p) {
    _pos = p;
    for (int i = 0; i < steps.length; i++) {
      steps[i].setPos(CursorPosition(p.column, p.row));
    }
    return CursorPosition(p.column + 2, p.row + 1);
  }

  show(String msg) {
    if (_pos == null) {
      throw "Step hasn't been positioned";
    }
    Console.moveCursor(row: _pos!.row, column: _pos!.column);
    Console.write(msg + " " * (Console.columns - _pos!.column - msg.length));
    Console.moveCursor(row: _pos!.row, column: _pos!.column);
  }

  Future<T> run();
}

abstract class SinglePriorStep<T, P> extends Step<T> {
  SinglePriorStep([super.steps]);

  @override
  int get numInputSteps => 1;

  @override
  CursorPosition setPos(CursorPosition p) {
    return super.setPos(p);
  }

  Future get input {
    if (_steps.isEmpty) {
      throw "Attempted to run null priorStep";
    }
    return _steps[0].run();
  }
}

class Parallel extends Step {
  Parallel(List<Step> steps) : super(steps);

  Future<List> get inputs {
    return Future.wait(
      steps.map((step) => step.run()),
    );
  }

  @override
  Future<List> run() async => await inputs;

  @override
  CursorPosition setPos(CursorPosition p) {
    super.setPos(p);
    int row = p.row;
    for (int i = 0; i < steps.length; i++) {
      final next = steps[i].setPos(CursorPosition(p.column, row));
      row = next.row;
    }
    return CursorPosition(p.column, row);
  }
}

class Chain extends Step {
  final String name;
  Chain(this.name, List<Step> inputSteps) : super(inputSteps) {
    if (steps.isEmpty) {
      throw "Chain with no inputs";
    }
    for (int i = 1; i < steps.length; i++) {
      final step = steps[i];
      if (i == 0 && step.numInputSteps != 0) {
        throw "First step in Chain must have 0 inputs";
      }
      if (i > 0 && step.numInputSteps > 1) {
        throw "Second to last steps in Chain must have at most 1 input";
      }
    }

    // Set up chain
    for (int i = 1; i < steps.length; i++) {
      steps[i]._steps.add(steps[i - 1]);
    }
  }

  @override
  Future run() async {
    show("$name: ");
    try {
      final result = await steps.last.run();
      if (result != null) {
        show("$name: success.");
      }
      return result;
    } catch (e) {
      show("$name: $e");
    }
    return null;
  }

  @override
  CursorPosition setPos(CursorPosition p) {
    final next = super.setPos(p);
    for (int i = 0; i < steps.length; i++) {
      steps[i].setPos(CursorPosition(p.column + name.length + 2, p.row));
    }
    return next;
  }
}
