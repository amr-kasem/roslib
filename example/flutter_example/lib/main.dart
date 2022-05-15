import 'package:flutter/material.dart';
import 'package:roslib/roslib.dart';

void main() {
  runApp(ExampleApp());
}

class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roslib Example',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Ros ros;
  Topic chatter;
  ActionClient _client;
  @override
  void initState() {
    ros = Ros(url: 'ws://0.0.0.0:9090');
    chatter = Topic(
      ros: ros,
      name: '/chatter',
      type: "std_msgs/String",
      reconnectOnClose: true,
      queueLength: 10,
      queueSize: 10,
    );
    _client = ActionClient(
      ros: ros,
      serverName: 'fibonacci',
      actionName: 'FibonacciAction',
      packageName: 'actionlib_tutorials',
    );
    initConnection();
    super.initState();
  }

  void initConnection() async {
    await ros.connect();
    await chatter.subscribe();
    // await _client.connect();
    setState(() {});
  }

  void destroyConnection() async {
    await chatter.unsubscribe();
    await ros.close();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Roslib Example'),
      ),
      body: FutureBuilder(
        future: _client.connect(),
        builder: (context, dataSnapshot) {
          return dataSnapshot.connectionState == ConnectionState.waiting
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : dataSnapshot.hasData
                  ? StreamBuilder<Object>(
                      stream: ros.statusStream,
                      builder: (context, snapshot) {
                        return Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              StreamBuilder(
                                stream: _client.feedback,
                                builder: (context2, snapshot2) {
                                  if (snapshot2.hasData) {
                                    return Text('${snapshot2.data}');
                                  } else {
                                    return Text('data not available');
                                  }
                                },
                              ),
                              StreamBuilder(
                                stream: _client.status,
                                builder: (context2, snapshot3) {
                                  if (snapshot3.hasData) {
                                    print(snapshot3.data);
                                    return Text('${snapshot3.data}');
                                  } else {
                                    return Text('data not available');
                                  }
                                },
                              ),
                              ActionChip(
                                label: Text('Send Goal'),
                                backgroundColor:
                                    snapshot.data == Status.CONNECTED
                                        ? Colors.green[300]
                                        : Colors.grey[300],
                                onPressed: snapshot.data == Status.CONNECTED
                                    ? null
                                    : () {
                                        _client.setGoal(goal: {'order': 20});
                                      },
                              ),
                              ActionChip(
                                label: Text('Cancel'),
                                backgroundColor:
                                    snapshot.data == Status.CONNECTED
                                        ? Colors.green[300]
                                        : Colors.grey[300],
                                onPressed: () {
                                  _client.cancel();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text('Error'),
                    );
        },
      ),
    );
  }
}
