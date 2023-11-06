import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _url = 'ws://192.168.31.44:8000/ws';
  int _taskId = 0;

  void connectWebSocket() {
    Workmanager().registerOneOffTask((_taskId++).toString(), _url);
  }

  @override
  void initState() {
    super.initState();
    connectWebSocket();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: TextEditingController(text: _url),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter URL',
              ),
              onSubmitted: (value) => setState(() => _url = value),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: connectWebSocket,
        tooltip: 'Reconnect',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
