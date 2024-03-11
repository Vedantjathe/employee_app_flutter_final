import 'package:flutter/material.dart';

import 'custom_widgets/loading_overlay.dart';

class DummyScreen extends StatefulWidget {
  const DummyScreen({super.key});

  @override
  State<DummyScreen> createState() => _DummyScreenState();
}

class _DummyScreenState extends State<DummyScreen> {
  late Future<int> loadedFut = _getData();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            loadedFut = _getData();
          });
        },
      ),
      body: FutureBuilder(
          future: loadedFut,
          builder: (context, snapshot) {
            return Stack(
              children: [
                Visibility(
                    visible: snapshot.connectionState != ConnectionState.done,
                    child: const LoadingOverlay()),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Center(
                        child: Text('Data: ${snapshot.data ?? 'No Data'}'),
                      )
                    ],
                  ),
                ),
              ],
            );
          }),
    );
  }

  int i = 1;

  Future<int> _getData() async {
    await Future.delayed(Duration(seconds: 2));

    return i++;
  }
}
