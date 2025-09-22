import 'package:flutter/material.dart';

void main() {
  runApp(const iProcrastinateApp());
}

class iProcrastinateApp extends StatelessWidget {
  const iProcrastinateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iProcrastinate',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('iProcrastinate'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Stop procrastinating and get things done!',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Tasks completed: $_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Complete Task',
        child: const Icon(Icons.check),
      ),
    );
  }
}