import 'package:flutter/material.dart';
import 'pin_put_box.dart';

/// The input [keyboard] type.
/// and includes a filter, for example if you choose number
/// you cannot write a text in [PinPut].
enum PinKeyboardType {
  text,
  name,
  number,
}

class PinPut extends StatefulWidget {
  /// the [pinType] pin keyboard type
  /// just call the [enum] like [PinKeyboardType.text]
  final PinKeyboardType pinType;

  /// this [pin] length.
  final int pinLenght;

  /// The first box in your screen
  /// [request] : [focusNode.requestFocus].
  /// default [false].
  final bool autoFocus;

  /// Inputs text style.
  final TextStyle textStyle;

  /// this function [onChange]
  /// returns each input change
  final Function(String? input)? onChange;

  /// this controller can make clear pin puts.
  /// just call [clear] method.
  final PinPutController? pinPutController;

  /// Default display box decoration.
  final Decoration initDecoration;

  /// Focus display box decoration.
  /// default {"focusDecoration = initDecoration"}.
  final Decoration focusDecoration;

  /// If pass where box displasy this [fillDecoration].
  /// default {"fillDecoration = initDecoration"}.
  final Decoration fillDecoration;

  /// Pinput controller for auto clear.
  final PinPutController? pinController;

  /// Displayed on top of the [InputDecorator.child]
  /// when the input [empty] or not [focus].
  /// Default widget [Text('-')].
  final Widget hint;

  /// this [pinput] size (width - height).
  /// default: [60.0].
  final double size;

  /// this [pinput] space cross.
  /// default : [20.0]
  final double space;

  /// [PinPut] constructor.
  PinPut({
    Key? key,
    required this.pinLenght,
    this.pinPutController,
    this.pinController,
    this.onChange,
    PinKeyboardType? pinType,
    bool? autoFocus,
    Color? initialColor,
    String hintText = '-',
    TextStyle? textStyle,
    Decoration? initDecoration,
    Decoration? fillDecoration,
    Decoration? focusDecoration,
    Widget? hint,
    double? size,
    double? space,
  })  : assert(
          pinLenght > 0,
          'Pinput length cannot less zero',
        ),
        assert(initialColor == null || initDecoration == null),
        assert(initDecoration == null || initDecoration.debugAssertIsValid()),
        pinType = pinType ?? PinKeyboardType.number,
        autoFocus = autoFocus ?? true,
        initDecoration = initDecoration ?? BoxDecoration(color: initialColor),
        fillDecoration = fillDecoration ?? BoxDecoration(color: initialColor),
        focusDecoration = focusDecoration ?? BoxDecoration(color: initialColor),
        textStyle = textStyle ?? const TextStyle(color: Colors.black),
        size = size ?? 60.0,
        space = space ?? 20.0,
        hint = hint ??
            Text(
              hintText,
              style: const TextStyle(color: Colors.black, fontSize: 30.0),
            ),
        super(key: key);

  @override
  State<StatefulWidget> createState() => PinBox.pin();
}