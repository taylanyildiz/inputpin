import 'dart:developer';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Activation Code',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  String? code ;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(),
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PinPut(
                controller: PinPutController(),
                focusNode: FocusNode(),
                autoFocus: true,
                padding: 20.0,
                height: 70.0,
                onCode: (input) {
                  code = input;
                },
                cursorColor: Colors.green,
                fillColor: Colors.white,
                pinType: PinKeyboardType.number,
                style: TextStyle(
                  color: Colors.black45,
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
              SizedBox(height: 50.0),
              SizedBox(
                width: 200.0,
                child: MaterialButton(
                  onPressed: () {
                    log(code??'empty');
                  },
                  child: Text(
                    'Test',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum PinKeyboardType {
  text,
  name,
  number,
}

class PinPut extends StatefulWidget {
  PinPut({
    Key? key,
    required this.controller,
    required this.onCode,
    this.autoFocus = false,
    this.focusNode,
    this.height = 60.0,
    this.padding = 40.0,
    this.shadow,
    this.pinCount = 4,
    this.runSpace = 10.0,
    this.radius = 4.0,
    this.initialColor = Colors.white,
    this.fillColor = Colors.green,
    this.cursorColor = Colors.black,
    this.pinType = PinKeyboardType.name,
    this.style,
    this.defaultText = '—',
  })  : assert(pinCount != 0),
        super(key: key);
  final PinPutController controller;
  final bool autoFocus;
  final FocusNode? focusNode;
  final int pinCount;
  final Function(String? code) onCode;
  final double height;
  final double padding;
  final double runSpace;
  final double radius;
  final List<BoxShadow>? shadow;
  final Color initialColor;
  final Color fillColor;
  final Color cursorColor;
  final PinKeyboardType pinType;
  final TextStyle? style;
  final String defaultText;

  @override
  _PinPutState createState() => _PinPutState();
}

class _PinPutState extends State<PinPut> {
  final _focusNodes = <FocusNode>[];
  final _textControllers = <TextEditingController>[];
  late List<String> _codeList;
  TextInputType? _keyboardType;
  List<TextInputFormatter>? _inputFormatters;

  @override
  void initState() {
    _codeList = List.generate(widget.pinCount, (index) => '');
    for (var i = 0; i < widget.pinCount; i++) {
      _focusNodes.add(FocusNode());
      _textControllers.add(TextEditingController()
        ..addListener(
          () => setState(() {}),
        ));
    }
    _getKeyboardType();
    if (widget.focusNode != null) {
      _focusNodes[0] = widget.focusNode!;
    }
    widget.controller._addListener(() {
      _focusNodes[0].requestFocus();
      for (var i = 0; i < widget.pinCount; i++) {
        _codeList[i] = '';
        _textControllers[i].text = '';
      }
    });
    super.initState();
  }

  void _getKeyboardType() {
    switch (widget.pinType) {
      case PinKeyboardType.text:
        _keyboardType = TextInputType.text;
        _inputFormatters = [
          FilteringTextInputFormatter.allow(
            RegExp(r'[a-z A-Z 0-9]'),
          )
        ];
        break;
      case PinKeyboardType.name:
        _keyboardType = TextInputType.name;
        _inputFormatters = [
          FilteringTextInputFormatter.allow(
            RegExp(r'[a-z A-Z]'),
          )
        ];
        break;
      case PinKeyboardType.number:
        _keyboardType = TextInputType.number;
        _inputFormatters = [
          FilteringTextInputFormatter.allow(
            RegExp(r'[0-9]'),
          )
        ];
        break;
    }
  }

  @override
  void dispose() {
    for (var i = 0; i < widget.pinCount; i++) {
      _textControllers[i].dispose();
      _focusNodes[i].dispose();
    }
    super.dispose();
  }

  void _listenEvents() {
    String code = '';
    _codeList.forEach((element) {
      code = code + element;
    });
    if (code.isNotEmpty) {
      widget.onCode.call(code);
    } else {
      widget.onCode.call(null);
    }
  }

  void _onKeyListen(RawKeyEvent event) async {
    if (event.runtimeType.toString() == 'RawKeyDownEvent') {
      int index = _focusNodes.indexWhere((element) => element.hasFocus);
      if (index != -1) {
        if (_textControllers[index].text.isEmpty && index != 0) {
          if (event.logicalKey == LogicalKeyboardKey.backspace) {
            _focusNodes[index - 1].requestFocus();
          }
        } else if (_textControllers[index].text.isNotEmpty) {
          if (event.logicalKey != LogicalKeyboardKey.backspace) {
            if (index != widget.pinCount - 1) {
              final eventKey =
                  event.logicalKey.keyLabel.toString().toLowerCase();
              print(eventKey);
              _textControllers[index + 1].text = eventKey;
              _codeList[index + 1] = eventKey;
            }
          } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
            _codeList[index] = '';
          }
        }
      }
    }
    _listenEvents();
  }

  void _onChangeListen(String? input, int index) {
    if (input!.isNotEmpty) {
      if (index != widget.pinCount - 1) {
        _focusNodes[index + 1].requestFocus();
        _codeList[index] = input;
      } else {
        _codeList[index] = input;
      }
      _listenEvents();
    }
  }

  List<Widget> get pinPut => List.generate(
        widget.pinCount,
        (index) => Expanded(
          child: pinBox(index),
        ),
      );

  Widget pinBox(index) => AnimatedContainer(
        height: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: widget.runSpace),
        duration: Duration(milliseconds: 200),
        decoration: boxDecoration(index),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Visibility(
              visible: _textControllers[index].text.isNotEmpty,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
                  child: Container(
                    color: _textControllers[index].text.isEmpty
                        ? widget.initialColor.withOpacity(.1)
                        : null,
                  ),
                ),
              ),
            ),
            pinInput(index),
          ],
        ),
      );

  BoxDecoration? boxDecoration(index) {
    return BoxDecoration(
      border: Border.all(
        width: 1.5,
        color: _focusNodes[index].hasFocus
            ? index != widget.pinCount - 1
                ? widget.cursorColor
                : _textControllers[index].text.isEmpty
                    ? widget.cursorColor
                    : Colors.transparent
            : Colors.transparent,
      ),
      borderRadius: BorderRadius.circular(widget.radius),
      color: _textControllers[index].text.isEmpty
          ? widget.initialColor
          : widget.fillColor,
      boxShadow: widget.shadow ??
          [
            BoxShadow(
              offset: Offset(10.0, 10.0),
              blurRadius: 15.0,
              color: Colors.black26,
            ),
          ],
    );
  }

  Widget pinInput(index) {
    return TextFormField(
      key: ValueKey(index),
      controller: _textControllers[index],
      textAlign: TextAlign.center,
      showCursor: false,
      cursorColor: Colors.black,
      autofocus: index == 0 ? widget.autoFocus : false,
      focusNode: _focusNodes[index],
      keyboardType: _keyboardType,
      maxLength: 1,
      style: TextStyle(
        fontSize: (widget.style?.fontSize ?? 20.0) - widget.runSpace / 2,
        fontWeight: widget.style?.fontWeight ?? FontWeight.w600,
        color: widget.style?.color ?? Colors.black,
      ),
      onChanged: (input) => _onChangeListen(input, index),
      decoration: inputDecoration(index),
      inputFormatters: _inputFormatters,
      enableInteractiveSelection: false,
      autocorrect: false,
      enableSuggestions: false,
    );
  }

  InputDecoration? inputDecoration(index) {
    return InputDecoration(
      counterText: '',
      hintText: _focusNodes[index].hasFocus ? null : widget.defaultText,
      border: inputBorder,
      focusedBorder: inputBorder,
      enabledBorder: inputBorder,
      errorBorder: inputBorder,
      contentPadding: EdgeInsets.zero,
    );
  }

  InputBorder get inputBorder =>
      OutlineInputBorder(borderSide: BorderSide.none);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (event) => _onKeyListen(event),
      child: SizedBox(
        height: widget.height,
        width: width,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.padding),
          child: Row(children: pinPut),
        ),
      ),
    );
  }
}

class PinPutController {
  late Function() _clear;

  void _addListener(Function() clear) {
    _clear = clear;
  }

  void clear() => _clear();
}
