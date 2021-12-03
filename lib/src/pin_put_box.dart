import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pin_put.dart';

const String _rawKeyEvent = "RawKeyDownEvent";

class PinBox extends State<PinPut> with SingleTickerProviderStateMixin {
  /// Animation controller
  late AnimationController controller;
  late Animation<double> animation;

  /// Constructor [PinBox].
  PinBox.pin();

  int get length => widget.pinLenght;

  bool get autoFocus => widget.autoFocus;

  Decoration get initDecoartion => widget.initDecoration;

  Decoration get focusDecoration => widget.focusDecoration;

  Decoration get fillDecoration => widget.fillDecoration;

  List textConList = List<TextEditingController>.empty(growable: true);

  List focusList = List<FocusNode>.empty(growable: true);

  FocusNode get focusNode => widget.focusNode ?? focusList.first;

  TextInputType get keyBoardType => widget.pinType.type;

  List<TextInputFormatter> get inputFilter => widget.pinType.filter;

  PinPutController? get pinController => widget.pinController;

  String text(index) => textConList[index].text;

  Widget get hint => widget.hint;

  _FocusNodeController _focusNodeController(index) => _FocusNodeController(
        focusList[index],
        textConList[index],
        focusDecoration,
        initDecoartion,
        fillDecoration,
        index == length - 1,
      );

  double get height => 70.0;

  double get space => 20.0;

  double get width => (length * height) + ((length - 1) * space);

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    _loadAnimation();
    _loadInputs();
    pinController?._addListener(() {
      _clearInputs();
      focusList.first.requestFocus();
      controller.forward();
    });
    super.initState();
  }

  @override
  void dispose() {
    for (var i = 0; i < length; i++) {
      textConList[i].dispose();
      focusList[i].dispose();
    }
    super.dispose();
  }

  void _clearInputs() {
    for (TextEditingController inputs in textConList) {
      inputs.clear();
    }
  }

  void _loadInputs() {
    for (var i = 0; i < length; i++) {
      focusList.add(FocusNode());
      textConList.add(TextEditingController()
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

  void onChanged(String? input, int index) {
    if (input != null) {
      if (input.isNotEmpty) {
        if (index != length - 1) {
          focusList[index + 1].requestFocus();
        }
      }
    }
  }

  void onKeyListen(RawKeyEvent event) {
    if (event.runtimeType.toString() == _rawKeyEvent) {
      int index = focusList.indexWhere((element) => element.hasFocus);
      if (index != -1) {
        if (text(index).isEmpty && index != 0) {
          if (event.logicalKey == LogicalKeyboardKey.backspace) {
            focusList[index - 1].requestFocus();
          }
        }
      }
    }
  }

  Widget boxDecorated(index) {
    return Padding(
      padding: EdgeInsets.only(left: index == 0 ? 0.0 : space),
      child: SizedBox(
        height: height,
        width: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            decoration: controller.isAnimating
                ? focusDecoration
                : _focusNodeController(index).decoration,
            child: Stack(
              alignment: Alignment.center,
              children: [inputs(index), displayHint(index)],
            ),
          ),
        ),
      ),
    );
  }

  Widget inputs(int index) {
    return TextFormField(
      controller: textConList[index],
      autofocus: index == 0 ? autoFocus : false,
      focusNode: focusList[index],
      onChanged: (input) => onChanged(input, index),
      maxLength: 1,
      maxLines: 1,
      autocorrect: false,
      inputFormatters: inputFilter,
      keyboardType: keyBoardType,
      showCursor: false,
      textAlign: TextAlign.center,
      decoration: const InputDecoration(
        filled: true,
        fillColor: Colors.transparent,
        counterText: "",
        counterStyle: TextStyle(fontSize: 0.0),
        border: OutlineInputBorder(borderSide: BorderSide.none),
        errorBorder: OutlineInputBorder(),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget displayHint(index) {
    return Visibility(
      visible: !focusList[index].hasFocus &&
          textConList[index].text.isEmpty &&
          !controller.isAnimating,
      child: hint,
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
                  ..translate(15.0 * sin(2 * 3 * pi / 2 * controller.value)),
                child: RawKeyboardListener(
                  focusNode: _focusNode,
                  onKey: onKeyListen,
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: Row(
                      children: List.generate(
                        length,
                        (index) => boxDecorated(index),
                      ),
                    ),
                  ),
                ),
              );
            });
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

extension Border on _FocusNodeController {
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

class _FocusNodeController {
  _FocusNodeController(
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
