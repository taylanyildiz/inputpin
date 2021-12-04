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
  final Function(String? pin)? onChange;

  /// this controller can make clear pin puts.
  /// just call [clear] method.
  final PinPutController? pinController;

  /// Default display box decoration.
  final Decoration initDecoration;

  /// Focus display box decoration.
  /// default {"focusDecoration = initDecoration"}.
  final Decoration? focusDecoration;

  /// If pass where box displasy this [fillDecoration].
  /// default {"fillDecoration = initDecoration"}.
  final Decoration? fillDecoration;

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
    this.pinController,
    this.onChange,
    PinKeyboardType? pinType,
    bool? autoFocus,
    Color? initialColor,
    String hintText = '-',
    TextStyle? textStyle,
    Decoration? initDecoration,
    this.fillDecoration,
    this.focusDecoration,
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
        initDecoration = initDecoration ??
            BoxDecoration(
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 5.0,
                  offset: Offset(0.0, 5.0),
                ),
              ],
              borderRadius: BorderRadius.circular(10.0),
            ),
        textStyle = textStyle ?? const TextStyle(color: Colors.black),
        size = size ?? 60.0,
        space = space ?? 20.0,
        hint = hint ??
            Text(
              hintText,
              style: const TextStyle(color: Colors.white, fontSize: 30.0),
            ),
        super(key: key);

  @override
  State<StatefulWidget> createState() => PinBox.pin();
}
