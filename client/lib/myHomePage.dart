import 'package:flutter/material.dart';
import 'package:client/url_connect.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

const String emulatorUrl = "ws://10.0.2.2:8000/ws";
const String localNetUrl = "ws://192.168.31.44:8000/ws";

class _MyHomePageState extends State<MyHomePage> {
  int currentPageIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Telegram listener"),
      ),
      bottomNavigationBar: NavigationBar(
        animationDuration: const Duration(milliseconds: 2000),
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() => currentPageIndex = index);
          _pageController.animateToPage(index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.link), label: 'Connect'),
          NavigationDestination(
              icon: Icon(Icons.settings), label: 'Change server handlers'),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => currentPageIndex = index),
        children: const [URLConnect(), ServerHandlers()],
      ),
    );
  }
}

class ServerHandlers extends StatefulWidget {
  const ServerHandlers({super.key});

  @override
  State<ServerHandlers> createState() => _ServerHandlersState();
}

class _ServerHandlersState extends State<ServerHandlers> {
  List<String> handlers = [];

  Future<void> loadHandlers() async {
    handlers = await getHandlers();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Text("WTF");
  }
}
