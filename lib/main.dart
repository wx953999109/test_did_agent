import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:intl/intl.dart';
import 'package:test_did_agent/DioHelper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo - test D-ID agent'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String agentId = "agt_Rq09A-Xl";

  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  List<MediaDeviceInfo>? _mediaDevicesList;

  bool connect = false;
  late String chatId;
  late String streamId;
  late Map offer;
  late List iceServers;
  late String sessionId;
  RTCPeerConnection? _pc;

  final StreamController _logsController = StreamController<String>();
  Map<String, String> logs = {
    'agent_id': 'agt_Rq09A-Xl',
    'chat_id': '',
    'stream_id': '',
    'ICE gathering status': 'waiting',
    'ICE onIceConnectionState': 'waiting',
    'Peer connection status': 'waiting',
    'Signaling status': 'waiting',
    'Streaming status': 'waiting',
  };

  _printLog({String? key, String? value}) {
    if (key != null && value != null) {
      logs[key] = value;
    }
    String text = '';
    logs.forEach((key, value) {
      text += '【' + key + '】' + value + "\r\n\r\n";
    });
    _logsController.add(text);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Timer.periodic(Duration(milliseconds: 30), (timer) {
      _printLog();
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          // TRY THIS: Try changing the color here to a specific color (to
          // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
          // change color while the other colors stay the same.
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Stack(
          children: [
            //remote video
            const Positioned(left: 0, top: 0, height: 30, child: Text('remote video')),
            Positioned(
                left: 0,
                top: 30,
                width: screenWidth / 2,
                height: screenWidth / 2,
                child: Container(
                  color: Colors.green[200],
                  child: RTCVideoView(
                    _remoteRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                )),

            //local video
            Positioned(left: screenWidth / 2, top: 0, height: 30, child: const Text('local video')),
            Positioned(
                left: screenWidth / 2,
                top: 30,
                width: screenWidth / 2,
                height: screenWidth / 2,
                child: Container(
                    color: Colors.blue[200],
                    child: RTCVideoView(
                      _localRenderer,
                      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    ))),

            //start
            Positioned(
                left: (screenWidth - 200) / 2,
                top: screenWidth / 2 + 30 + 10,
                height: 40,
                width: 200,
                child: connect
                    ? const SizedBox.shrink()
                    : ElevatedButton(
                        onPressed: () {
                          _start();
                        },
                        child: const Text('start'),
                      )),

            //log
            Positioned(
              left: 20,
              top: screenWidth / 2 + 30 + 20,
              child: const Text('log:'),
            ),
            Positioned(
                left: 20,
                top: screenWidth / 2 + 30 + 20 + 40,
                bottom: 20,
                right: 20,
                child: StreamBuilder(
                    stream: _logsController.stream,
                    builder: (context, snapshot) {
                      return Container(
                          decoration: const BoxDecoration(
                            color: Colors.black12,
                          ),
                          child: Text(
                            snapshot.hasData ? snapshot.data : '',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          ));
                    })),
          ],
        ));
  }

  // start method
  _start() async {
    //change ui
    setState(() {
      connect = true;
    });

    logs = {
      'agent_id': 'agt_Rq09A-Xl',
      'chat_id': '',
      'stream_id': '',
      'ICE gathering status': 'processing',
      'ICE onIceConnectionState': 'processing',
      'Peer connection status': 'processing',
      'Signaling status': 'processing',
      'Streaming status': 'processing',
    };

    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    _open_local_camera();

    //1. create a new chat
    await _createChat();

    //2. create session, connect session
    await _createSession();

    //3. send text message
    await _sendTextMessage();
  }

  _open_local_camera() async {
    final mediaConstraints = <String, dynamic>{
      'audio': false,
      'video': {
        'mandatory': {
          'minWidth': '640', // Provide your own width, height and frame rate here
          'minHeight': '480',
          'minFrameRate': '30',
        },
        'facingMode': 'user',
        'optional': [],
      }
    };

    try {
      var stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _mediaDevicesList = await navigator.mediaDevices.enumerateDevices();
      _localStream = stream;
      _localRenderer.srcObject = _localStream;

      if (!mounted) return;

      setState(() {});
    } catch (e) {
      print(e.toString());
    }
  }

  _createChat() async {
    var ret = await DioHelper.post('/agents/$agentId/chat');
    chatId = ret.data['id'];
    _printLog(key: 'chat_id', value: chatId);
    print('ret: $ret');
  }

  _createSession() async {
    var ret = await DioHelper.post('/talks/streams', data: {
      'source_url': 'https://create-images-results.d-id.com/google-oauth2|103654318801296747708/upl_maJhSVoq6l4yNc8XgBSKI/image.png',
    });
    streamId = ret.data['id'];
    offer = ret.data['offer'];
    iceServers = ret.data['ice_servers'];
    sessionId = ret.data['session_id'];
    _printLog(key: 'stream_id', value: streamId);

    _pc = await createPeerConnection({
      'iceServers': iceServers,
      'sdpSemantics': 'unified-plan',
      'encodedInsertableStreams': true
    }, {
      'mandatory': {},
      'optional': [
        {'DtlsSrtpKeyAgreement': false},
      ],
    });

    _pc?.onAddStream = (stream) {
      print('onAddStream');
      if (stream.getVideoTracks().isNotEmpty) {
        print('Remote video stream received');
      } else {
        print('No video track found in the remote stream');
      }
    };

    _pc?.onTrack = (event) {
      print('Received the track: ${event.track.id} ${event.track.kind}');
      if (event.track.kind == 'video' || event.track.kind == 'audio') {
        print('Video track enabled: ${event.track.enabled}');
        _remoteStream = event.streams[0];

        if (!mounted) return;

        setState(() {
          _remoteRenderer.srcObject = _remoteStream;
        });
      }
    };

    RTCDataChannel? dc = await _pc?.createDataChannel('JanusDataChannel', RTCDataChannelInit());
    dc?.onMessage = (RTCDataChannelMessage data) {
      String msg = data.text;
      String msgType = "chat/answer:";
      if (msg.contains(msgType)) {
        msg = Uri.decodeComponent(msg.replaceAll(msgType, ""));
        print('[d-id-msg]' + msg);
        String decodedMsg = msg;
        return decodedMsg;
      }
      if (msg.contains("stream/started")) {
        print('[d-id-msg]' + msg);
      } else {
        print('[d-id-msg]' + msg);
      }
    };

    await _pc?.setRemoteDescription(RTCSessionDescription(offer['sdp'], offer['type']));

    _pc?.onSignalingState = (state) async {
      print('remote pc: onSignalingState($state)');

      _printLog(key: 'Signaling status', value: state.name);
    };

    _pc?.onIceGatheringState = (state) async {
      print('remote pc: onIceGatheringState($state)');

      _printLog(key: 'ICE gathering status', value: state.name);
    };

    _pc?.onConnectionState = (state) async {
      print('remote pc: onConnectionState($state)');

      _printLog(key: 'Peer connection status', value: state.name);
    };

    print('startSession: ${sessionId}');

    var localDescription = await _pc?.createAnswer();
    await _pc?.setLocalDescription(localDescription!);

    _pc?.onIceCandidate = (candidate) async {
      print('Received ICE candidate:' + candidate.toString());
      var ret = await DioHelper.post('/talks/streams/$streamId/ice', data: {
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
        'session_id': sessionId,
      });
      print('submit ICE response: $ret');
    };

    _pc?.onIceConnectionState = (state) async {
      print('remote pc: onIceConnectionState($state)');

      _printLog(key: 'ICE onIceConnectionState', value: state.name);
    };

    //send sdp
    ret = await DioHelper.post('/talks/streams/$streamId/sdp', data: {
      'answer': localDescription?.toMap(),
      'session_id': sessionId,
    });
    print('send sdp response: $ret');
  }

  _sendTextMessage() async {
    var ret = await DioHelper.post(
      '/agents/$agentId/chat/$chatId',
      data: {
        "streamId": streamId,
        "sessionId": sessionId,
        "messages": [
          {
            "role": "user",
            "content": 'hi',
            "created_at": DateTime.now().toString(),
          }
        ]
      },
    );
    print('_sendTextMessage response: $ret');
  }
}
