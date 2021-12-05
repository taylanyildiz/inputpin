import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pin_put.dart';

const String _rawKeyEvent = "RawKeyDownEvent";

class PinBox extends State<PinPut> with SingleTickerProviderStateMixin {
  /// Animation controller
  late AnimationController controller;

  /// Constructor [PinBox].
  PinBox.pin();

  TextStyle get _style => widget.textStyle;

  int get _length => widget.pinLenght;

  bool get _autoFocus => widget.autoFocus;

  Decoration get _initDecoartion => widget.initDecoration;

  Decoration get _focusDecoration => widget.focusDecoration ?? _initDecoartion;

  Decoration get _fillDecoration => widget.fillDecoration ?? _initDecoartion;

  TextInputType get _keyBoardType => widget.pinType.type;

  List<TextInputFormatter> get _inputFilter => widget.pinType.filter;

  PinPutController? get _pinController => widget.pinController;

  String _text(index) => _textCon[index].text;

  Widget get _hint => widget.hint;

  double get _height => widget.size;

  double get _width => widget.size;

  double get _space => widget.space;

  double get _totalWidth => (_length * _height) + ((_length - 1) * _space);

  final FocusNode _focusNode = FocusNode();

  final List<TextEditingController> _textCon = List.empty(growable: true);

  final List<FocusNode> _focusList = List.empty(growable: true);

  final List _pins = List<String>.empty(growable: true);

  _PinDecoration _decoration(index) => _PinDecoration(
        _focusList[index],
        _textCon[index],
        _focusDecoration,
        _initDecoartion,
        _fillDecoration,
        (index == _length - 1), // is last.
      );

  @override
  void initState() {
    _loadAnimation();
    _loadInputs();
    _pinController?._addListener(() {
      _clearInputs();
      _focusList.first.requestFocus();
      controller.forward();
    });
    super.initState();
  }

  @override
  void dispose() {
    for (var i = 0; i < _length; i++) {
      _textCon[i].dispose();
      _focusList[i].dispose();
    }
    super.dispose();
  }

  void _clearInputs() {
    for (var i = 0; i < _length; i++) {
      _textCon[i].clear();
      _pins[i] = "";
      setState(() {});
    }
  }

  void _loadInputs() {
    for (var i = 0; i < _length; i++) {
      _pins.add("");
      _focusList.add(FocusNode());
      _textCon.add(TextEditingController()
        ..addListener(() {
          setState(() {});
        }));
    }
  }

  void _loadAnimation() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reset();
        }
      });
  }

  void _onChangeList() {
    String code = '';
    for (var element in _pins) {
      code = code + element;
    }
    widget.onChange?.call(code);
  }

  void _onChanged(String? input, int index) {
    if (input != null) {
      if (input.isNotEmpty) {
        if (index != _length - 1) {
          _focusList[index + 1].requestFocus();
        }
        _pins[index] = input;
      } else {
        _pins[index] = "";
      }
      _onChangeList();
    }
  }

  void _onKeyListen(RawKeyEvent event) {
    if (event.runtimeType.toString() == _rawKeyEvent) {
      int index = _focusList.indexWhere((element) => element.hasFocus);
      if (index != -1) {
        if (_text(index).isEmpty) {
          if (event.logicalKey == LogicalKeyboardKey.backspace) {
            if (index != 0) {
              _focusList[index - 1].requestFocus();
            }
          }
        } else {
          if (event.logicalKey != LogicalKeyboardKey.backspace) {
            if (index != _length - 1) {
              final eventKey = event.logicalKey.keyLabel.toString();
              _textCon[index + 1].text = eventKey;
              _pins[index + 1] = eventKey;
            }
          } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
            _pins[index] = '';
          }
        }
      }
    }
    _onChangeList();
  }

  Widget _box(index) {
    return Padding(
      padding: EdgeInsets.only(left: index == 0 ? 0.0 : _space),
      child: SizedBox(
        height: _height,
        width: _width,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              decoration: controller.isAnimating
                  ? _focusDecoration
                  : _decoration(index).decoration,
            ),
            inputs(index),
            displayHint(index)
          ],
        ),
      ),
    );
  }

  Widget inputs(int index) {
    return TextFormField(
      controller: _textCon[index],
      focusNode: _focusList[index],
      onChanged: (input) => _onChanged(input, index),
      autofocus: index == 0 ? _autoFocus : false,
      maxLength: 1,
      maxLines: 1,
      inputFormatters: _inputFilter,
      keyboardType: _keyBoardType,
      autocorrect: false,
      showCursor: false,
      textAlign: TextAlign.center,
      style: _style,
      enableSuggestions: false,
      decoration: const InputDecoration(
        filled: true,
        fillColor: Colors.transparent,
        counterText: "",
        errorStyle: TextStyle(fontSize: 0.0),
        counterStyle: TextStyle(fontSize: 0.0),
        border: OutlineInputBorder(borderSide: BorderSide.none),
        errorBorder: OutlineInputBorder(borderSide: BorderSide.none),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget displayHint(index) {
    final inputsControl = !_focusList[index].hasFocus && _text(index).isEmpty;
    return Visibility(
      visible: inputsControl && !controller.isAnimating,
      child: _hint,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..translate(
                  15.0 * sin(2 * 3 * pi / 2 * controller.value),
                ),
              child: RawKeyboardListener(
                focusNode: _focusNode,
                onKey: _onKeyListen,
                child: SizedBox(
                  width: _totalWidth,
                  height: _height,
                  child: Row(
                    children: List.generate(
                      _length,
                      (index) => _box(index),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class PinPutController {
  VoidCallback? _clear;

  void _addListener(VoidCallback clear) {
    _clear = clear;
  }

  /// [pinInputs] clear.
  void clear() => _clear?.call();
}

extension GetInputType on PinKeyboardType {
  TextInputType get type {
    TextInputType inputType = TextInputType.text;
    switch (this) {
      case PinKeyboardType.text:
        inputType = TextInputType.text;
        break;
      case PinKeyboardType.name:
        inputType = TextInputType.name;
        break;
      case PinKeyboardType.number:
        inputType = TextInputType.number;
        break;
    }
    return inputType;
  }
}

extension GetFilter on PinKeyboardType {
  List<TextInputFormatter> get filter {
    List<TextInputFormatter> inputFormatters = [
      FilteringTextInputFormatter.allow(
        RegExp(r'[a-z A-Z 0-9]'),
      )
    ];
    switch (this) {
      case PinKeyboardType.text:
        inputFormatters = [
          FilteringTextInputFormatter.allow(
            RegExp(r'[a-z A-Z 0-9]'),
          )
        ];
        break;
      case PinKeyboardType.name:
        inputFormatters = [
          FilteringTextInputFormatter.allow(
            RegExp(r'[a-z A-Z]'),
          )
        ];
        break;
      case PinKeyboardType.number:
        inputFormatters = [
          FilteringTextInputFormatter.allow(
            RegExp(r'[0-9]'),
          )
        ];
        break;
    }
    return inputFormatters;
  }
}

extension _Border on _PinDecoration {
  Decoration get decoration {
    if (textController.text.isEmpty && focusNode.hasFocus) {
      return focusDecoration;
    }
    if (textController.text.isNotEmpty && !focusNode.hasFocus) {
      return fillDecoration;
    }
    if (textController.text.isEmpty && !focusNode.hasFocus) {
      return initDecoration;
    }
    if (textController.text.isNotEmpty && focusNode.hasFocus && isLast) {
      return fillDecoration;
    }
    if (textController.text.isNotEmpty && focusNode.hasFocus) {
      return focusDecoration;
    }
    return initDecoration;
  }
}

class _PinDecoration {
  _PinDecoration(
    this.focusNode,
    this.textController,
    this.focusDecoration,
    this.initDecoration,
    this.fillDecoration,
    this.isLast,
  );
  final FocusNode focusNode;
  final TextEditingController textController;
  final Decoration focusDecoration;
  final Decoration initDecoration;
  final Decoration fillDecoration;
  final bool isLast;
}
