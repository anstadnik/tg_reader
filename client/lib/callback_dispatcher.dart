import 'dart:async';
import 'package:client/my_custom_source.dart';
import 'package:just_audio/just_audio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) =>
      streamListener(WebSocketChannel.connect(Uri.parse(task)).stream)
          .then((_) => false));
}

Future<void> streamListener(Stream<dynamic> stream) async {
  final player = AudioPlayer();
  await for (var bytes in stream) {
    await player.setAudioSource(MyCustomSource(bytes));
    player.processingStateStream.listen((ProcessingState state) {
      if (state == ProcessingState.ready) {
        player.play();
      }
    });
  }
}
