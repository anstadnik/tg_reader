import 'package:client/MyJABytesSource.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
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
  bool _channelReady = false;
  // List<int>? _lastData;
  // List<int>? _lastData;
  String _status = "Pending";

  void connectWebSocket() {
    // _channel = WebSocketChannel.connect(Uri.parse(_url));
    // try {
    _channel = WebSocketChannel.connect(Uri.parse(_url));
    // } catch (e) {
    //   print("ERROR!");
    //   print(e);
    // }
    _channel.ready.then((value) => setState(() => _channelReady = true));
  }

  @override
  void initState() {
    super.initState();
    connectWebSocket();
    _channel.stream.listen(
      (dynamic bytes) async {
        final player = AudioPlayer();
        await player.setAudioSource(MyJABytesSource(bytes));
        player.processingStateStream.listen((ProcessingState state) {
          if (state == ProcessingState.ready) {
            setState(() => _status = "Ready");
            player.pause();
            player.play();
            setState(() => _status = "Playing");
          } else if (state == ProcessingState.completed) {
            setState(() => _status = "Completed");
          }
        });
      },
      onDone: () => setState(() => _channelReady = false),
      onError: (error) => setState(() => _channelReady = false),
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
              onSubmitted: (value) => setState(() => _url = value),
            ),
          ),
          Text((_channelReady && (_channel.closeCode == null))
              ? 'Connected'
              : 'Not connected'),
          // Text((_lastData == null).toString()),
          Text(_status),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(connectWebSocket),
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
