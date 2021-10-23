import 'dart:developer';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Activation Code',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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

  String code = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                log(input!);
              },
              cursorColor: Colors.transparent,
              pinType: PinKeyboardType.name,
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
                  log(code);
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
  final focusNodes = <FocusNode>[];
  final focusLisen = FocusNode();
  final textControllers = <TextEditingController>[];
  late List<String> codeList;
  TextInputType? keyboardType;
  List<TextInputFormatter>? inputFormatters;

  @override
  void initState() {
    codeList = List.generate(widget.pinCount, (index) => '');
    for (var i = 0; i < widget.pinCount; i++) {
      focusNodes.add(FocusNode());
      textControllers.add(TextEditingController()
        ..addListener(() {
          setState(() {});
        }));
    }
    getKeyboardType();
    if (widget.focusNode != null) {
      focusNodes[0] = widget.focusNode!;
    }
    widget.controller._addListener(() {
      focusNodes[0].requestFocus();
      for (var i = 0; i < widget.pinCount; i++) {
        codeList[i] = '';
        textControllers[i].text = '';
      }
    });
    super.initState();
  }

  void getKeyboardType() {
    switch (widget.pinType) {
      case PinKeyboardType.text:
        keyboardType = TextInputType.text;
        inputFormatters = [
          FilteringTextInputFormatter.allow(
            RegExp(r'[a-z A-Z 0-9]'),
          )
        ];
        break;
      case PinKeyboardType.name:
        keyboardType = TextInputType.name;
        inputFormatters = [
          FilteringTextInputFormatter.allow(
            RegExp(r'[a-z A-Z]'),
          )
        ];
        break;
      case PinKeyboardType.number:
        keyboardType = TextInputType.number;
        inputFormatters = [
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
      textControllers[i].dispose();
      focusNodes[i].dispose();
    }
    super.dispose();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  void callBack() {
    String code = '';
    codeList.forEach((element) {
      code = code + element;
    });
    widget.onCode.call(code);
  }

  void onKeyListen(RawKeyEvent event) async {
    if (event.runtimeType.toString() == 'RawKeyDownEvent') {
      int index = focusNodes.indexWhere((element) => element.hasFocus);
      if (index != -1) {
        if (textControllers[index].text.isEmpty && index != 0) {
          if (event.logicalKey == LogicalKeyboardKey.backspace) {
            focusNodes[index - 1].requestFocus();
          }
        } else if (textControllers[index].text.isNotEmpty) {
          if (event.logicalKey != LogicalKeyboardKey.backspace) {
            if (index != widget.pinCount - 1) {
              final eventKey =
                  event.logicalKey.keyLabel.toString().toLowerCase();
              print(eventKey);
              textControllers[index + 1].text = eventKey;
              codeList[index + 1] = eventKey;
            }
          } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
            codeList[index] = '';
          }
        }
      }
    }
    callBack();
  }

  void onChangeListen(String? input, int index) {
    if (input!.isNotEmpty) {
      if (index != widget.pinCount - 1) {
        focusNodes[index + 1].requestFocus();
        codeList[index] = input;
      } else {
        print('ok');
        codeList[index] = input;
      }
      callBack();
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
              visible: focusNodes[index].hasFocus,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    color: textControllers[index].text.isEmpty
                        ? Colors.grey.withOpacity(.3)
                        : Colors.white.withOpacity(.3),
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
        width: 3.0,
        color: focusNodes[index].hasFocus
            ? index != widget.pinCount - 1
                ? widget.cursorColor
                : textControllers[index].text.isEmpty
                    ? widget.cursorColor
                    : Colors.transparent
            : Colors.transparent,
      ),
      borderRadius: BorderRadius.circular(widget.radius),
      color: textControllers[index].text.isEmpty
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

  TextField pinInput(index) {
    return TextField(
      key: ValueKey(index),
      controller: textControllers[index],
      textAlign: TextAlign.center,
      showCursor: false,
      cursorColor: Colors.black,
      autofocus: index == 0 ? widget.autoFocus : false,
      focusNode: focusNodes[index],
      keyboardType: keyboardType,
      maxLength: 1,
      style: TextStyle(
        fontSize: (widget.style?.fontSize ?? 20.0) - widget.runSpace / 2,
        fontWeight: widget.style?.fontWeight ?? FontWeight.w600,
        color: widget.style?.color ?? Colors.black,
      ),
      onChanged: (input) => onChangeListen(input, index),
      decoration: inputDecoration(index),
      inputFormatters: inputFormatters,
      enableInteractiveSelection: false,
      autocorrect: false,
      enableSuggestions: false,
    );
  }

  InputDecoration? inputDecoration(index) {
    return InputDecoration(
      counterText: '',
      hintText: focusNodes[index].hasFocus ? '' : widget.defaultText,
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
      onKey: (event) => onKeyListen(event),
      child: SizedBox(
        height: widget.height,
        width: width,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.padding),
          child: Row(
            children: pinPut,
          ),
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
