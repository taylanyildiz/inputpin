# flutter_input_pin

<img src="https://user-images.githubusercontent.com/37551474/144706274-c876125d-4fa5-4d33-b439-bf1136bee724.gif" width="200"/>

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
