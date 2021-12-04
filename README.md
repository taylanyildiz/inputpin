# flutter_input_pin

## usage

```dart
PinPut(
    pinLenght: 4,
    onChange: (input) {
        print(input);
    },
    pinController: pinPutController,
    focusDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.red, width: 2.0),
    ),
    initDecoration: const BoxDecoration(color: Colors.orange),
    fillDecoration: const BoxDecoration(color: Colors.blue),
),
```