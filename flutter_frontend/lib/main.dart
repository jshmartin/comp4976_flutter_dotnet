import 'package:flutter/material.dart';
import 'package:signalr_core/signalr_core.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter + SignalR Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'HomePage'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final myController = TextEditingController();
  final userNameController = TextEditingController();

  final serverUrl = 'http://localhost:5000/chatHub';
  late HubConnection hubConnection;

  var messages = <String>[]; // Set of messages

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSignalR();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    userNameController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter your name',
              ),
              controller: userNameController,
            ),
            SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter your message',
              ),
              controller: myController,
            ),
            ElevatedButton(
              onPressed: () async {
                if (hubConnection.state == HubConnectionState.connected) {
                  await hubConnection.invoke('SendMessage', args: <String>[userNameController.text,myController.text]);
                }
              },
              child: const Text('Send'),
            ),
            Container(
              height: 300,
              color: Colors.grey,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return Text(messages[index]);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // When the user presses the button, show an alert dialog containing
        // the text that the user has entered into the text field.
        onPressed: () async {
          hubConnection.state == HubConnectionState.connected
              ? await hubConnection.stop()
              : await hubConnection.start();
        },
        tooltip: 'Send Your Message!',
        child: hubConnection.state == HubConnectionState.disconnected ? const Icon(Icons.play_arrow) : const Icon(Icons.stop),
      ),
    );
  }

  void initSignalR() {
    hubConnection = HubConnectionBuilder().withUrl(serverUrl).build();
    hubConnection.on('ReceiveMessage', (message) {
      var string1 = message![0]?.toString();
      var string2 = message[1]?.toString();
      setState(() {
        messages.add(string1! + ' : ' + string2!);
      });
      print(message);
    });
    hubConnection.start()?.then((value) => print('Connection started'));
  }


}
