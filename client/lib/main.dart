import 'dart:async';

import 'package:client/my_ja_bytes_source.dart';
import 'package:client/myHomePage.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    print('Task: $task');
    print('Data: $inputData');

    Completer<bool> completer = Completer<bool>();
    WebSocketChannel channel = WebSocketChannel.connect(Uri.parse(task));
    final player = AudioPlayer();

    channel.stream.listen(
      (dynamic bytes) async {
        try {
          await player.setAudioSource(MyJABytesSource(bytes));
          player.processingStateStream.listen((ProcessingState state) {
            if (state == ProcessingState.ready) {
              // player.pause();
              print('ready');
              player.play();
            }
          });
        } catch (e) {
          // Handle exception when setting the audio source
          completer.complete(false);
        }
      },
      // When the WebSocket is done, complete the completer with true.
      onDone: () => completer.complete(true),
      // If there's an error, complete the completer with false.
      onError: (error) => completer.complete(false),
      // Passing a cancelOnError as true means the subscription is automatically canceled
      // when the first error event is delivered.
      cancelOnError: true,
    );

    // The `executeTask` must return a future.
    // The completer's future will complete when the WebSocket is done or an error occurs.
    return completer.future;
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TG Listener',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Telegram listener'),
    );
  }
}
