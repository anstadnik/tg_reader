import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';

const String emulatorUrl = "ws://10.0.2.2:8000/ws";
const String localNetUrl = "ws://192.168.31.44:8000/ws";

class URLConnect extends StatefulWidget {
  const URLConnect({super.key});

  @override
  State<URLConnect> createState() => _URLConnectState();
}


class _URLConnectState extends State<URLConnect> {
  String _url = emulatorUrl;
  int _taskId = 0;
  bool _urlPings = false;

  Future<void> connectWebSocket() async {
    Workmanager().cancelAll();

    final response =
        await http.head(Uri.parse(_url).replace(scheme: "http", path: "docs"));
    if (response.statusCode == 200) {
      setState(() => _urlPings = true);
      Workmanager().registerOneOffTask((_taskId++).toString(), _url);
    } else {
      setState(() => _urlPings = false);
    }
  }

  @override
  void initState() {
    super.initState();
    connectWebSocket();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.displaySmall,
            children: [
              TextSpan(
                  text: _urlPings ? "URL is pinging" : "URL is not pinging"),
              WidgetSpan(
                child: Icon(
                  size: 40,
                  _urlPings ? Icons.check_circle : Icons.cancel,
                  color: _urlPings ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ActionChip(
              label: const Text("Emulator URL"),
              onPressed: () => setState(() => _url = emulatorUrl),
            ),
            ActionChip(
              label: const Text("Local net example URL"),
              onPressed: () => setState(() => _url = localNetUrl),
            ),
          ],
        ),
        const Spacer(),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton.extended(
              onPressed: connectWebSocket,
              label: const Text("Connect"),
              icon: const Icon(Icons.link),
            ),
          ),
        ),
      ],
    );
  }
}

