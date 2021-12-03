import 'package:flutter/material.dart';
import 'widgets/flutter_pin_put.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Activation Code',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
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

  String? code;

  PinPutController pinPutController = PinPutController();

  void onClear() {
    pinPutController.clear();
  }

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
              const SizedBox(height: 50.0),
              MaterialButton(
                onPressed: onClear,
                color: Colors.blue,
                child: const Text('clear'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
