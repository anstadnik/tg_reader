import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _url = 'ws://192.168.31.44:8000/ws';
  late WebSocketChannel _channel;
  final List<(String, int)> _messages = [];
  int _messagesKey = 0;

  void clear() {
    setState(() {
      _messages.clear();
      _messagesKey = 0;
    });
  }

  void add(String message) {
    setState(() {
      _messages.add((message, _messagesKey));
      _messagesKey++;
    });
  }

  @override
  void initState() {
    super.initState();
    _channel = WebSocketChannel.connect(Uri.parse(_url));
    _channel.stream.listen(
      (dynamic message) => add(message.toString()),
      onDone: () => clear(),
      onError: (error) => clear(),
    );
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
              onSubmitted: (value) {
                setState(() => _url = value);
              },
            ),
          ),
          FutureBuilder(
            future: _channel.ready,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(
                  _channel.closeCode == null
                      ? 'Connected'
                      : 'Disconnected (${_channel.closeCode} , ${_channel.closeReason})',
                  style: TextStyle(
                    color:
                        _channel.closeCode == null ? Colors.green : Colors.red,
                  ),
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return const Text('Connecting...');
              }
            },
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              return Dismissible(
                key: Key(_messages[index].$2.toString()),
                onDismissed: (direction) {
                  setState(() => _messages.removeAt(index));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text("Message dismissed: ${_messages[index]} $index"),
                    ),
                  );
                },
                background: Container(
                  color: Colors.red,
                  child: const Icon(Icons.delete),
                ),
                child: Card(
                  child: ListTile(
                    title: const Text("Message"),
                    subtitle: Text(_messages[index].$1),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _channel = WebSocketChannel.connect(
              Uri.parse(_url),
            );
          });
        },
        tooltip: 'Reconnect',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }
}
