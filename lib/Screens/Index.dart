import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import '../Components/Url.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({Key key}) : super(key: key);
  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  String message;
  String channelId = "1000";
  String channelName = "FLUTTER_NOTIFICATION_CHANNEL";
  String channelDescription = "FLUTTER_NOTIFICATION_CHANNEL_DETAIL";
  FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  sendNotification(title, body) async {
    var bigTextStyleInformation = BigTextStyleInformation('$body',
        htmlFormatBigText: true,
        contentTitle: '$title',
        htmlFormatContentTitle: true,
        summaryText: 'การแจ้งเตือน',
        htmlFormatSummaryText: true);

    var androidPlatformChannelSpecifics = AndroidNotificationDetails('10000',
        'FLUTTER_NOTIFICATION_CHANNEL', 'FLUTTER_NOTIFICATION_CHANNEL_DETAIL',
        importance: Importance.Max,
        priority: Priority.High,
        styleInformation: bigTextStyleInformation);

    var iOSPlatformChannelSpecifics = IOSNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
        0, '$title', '$body', platformChannelSpecifics);
  }

  Future<void> initFirebaseMessaging() async {
    firebaseMessaging.subscribeToTopic("anonymouse");
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage:" + message.toString());
        Map mapNotification = message["notification"];
        String title = mapNotification["title"];
        String body = mapNotification["body"];
        sendNotification(title, body);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        Map mapNotification = message["notification"];
        String title = mapNotification["title"];
        String body = mapNotification["body"];
        sendNotification(title, body);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        Map mapNotification = message["notification"];
        String title = mapNotification["title"];
        String body = mapNotification["body"];
        sendNotification(title, body);
      },
    );

    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });

    var initializationSettingsAndroid =
        AndroidInitializationSettings('launcher_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: (id, title, body, payload) {
      print("onDidReceiveLocalNotification called.");
    });
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (payload) {
      // when user tap on notification.
      print("onSelectNotification called.");
      setState(() {
        message = payload;
      });
    });
  }

  TextEditingController searchController = TextEditingController();
  final flutterWebViewPlugin = FlutterWebviewPlugin();
  int selectedIndex = 0;
  // On destroy stream
  StreamSubscription _onDestroy;
  // On urlChanged stream
  StreamSubscription<String> _onUrlChanged;
  // On urlChanged stream
  StreamSubscription<WebViewStateChanged> _onStateChanged;
  StreamSubscription<WebViewHttpError> _onHttpError;
  StreamSubscription<double> _onProgressChanged;
  StreamSubscription<double> _onScrollYChanged;
  StreamSubscription<double> _onScrollXChanged;
  final _history = [];

  subScriptTo(username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("username = $username");
    await prefs.setString("subscript", username);
    print(prefs.getString("subscript"));
    await initFirebaseMessaging();
  }

  myinit() async {
    await initFirebaseMessaging().then((value) => null);
    _onUrlChanged = flutterWebViewPlugin.onUrlChanged.listen((String url) {
      if (mounted) {
        print("change url:" + url);
        setState(() {
          _history.add('onUrlChanged: $url');
        });
      }
    });

    _onProgressChanged =
        flutterWebViewPlugin.onProgressChanged.listen((double progress) {
      if (mounted) {
        setState(() {
          _history.add('onProgressChanged: $progress');
        });
      }
    });

    _onScrollYChanged =
        flutterWebViewPlugin.onScrollYChanged.listen((double y) {
      if (mounted) {
        setState(() {
          _history.add('Scroll in Y Direction: $y');
        });
      }
    });

    _onScrollXChanged =
        flutterWebViewPlugin.onScrollXChanged.listen((double x) {
      if (mounted) {
        setState(() {
          _history.add('Scroll in X Direction: $x');
        });
      }
    });

    _onStateChanged =
        flutterWebViewPlugin.onStateChanged.listen((WebViewStateChanged state) {
      if (mounted) {
        setState(() {
          _history.add('onStateChanged: ${state.type} ${state.url}');
        });
      }
    });

    _onHttpError =
        flutterWebViewPlugin.onHttpError.listen((WebViewHttpError error) {
      if (mounted) {
        setState(() {
          _history.add('onHttpError: ${error.code} ${error.url}');
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    myinit();
  }

  @override
  void dispose() {
    // Every listener should be canceled, the same should be done with this stream.
    _onDestroy.cancel();
    _onUrlChanged.cancel();
    _onStateChanged.cancel();
    _onHttpError.cancel();
    _onProgressChanged.cancel();
    _onScrollXChanged.cancel();
    _onScrollYChanged.cancel();
    flutterWebViewPlugin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: Scaffold(
            body: WebviewScaffold(
              url: IshopURL.currentUrl,
              mediaPlaybackRequiresUserGesture: false,
              withLocalStorage: true,
              hidden: true,
              initialChild: Container(
                color: Theme.of(context).primaryColor,
                child: const Center(
                  child: Text(
                    'กรุณารอสักครู่...',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.home,
                    color: Colors.green,
                  ),
                  title: Text(
                    'หน้าหลัก',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.book,
                    color: Colors.green,
                  ),
                  title: Text(
                    'โพส',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.info,
                    color: Colors.green,
                  ),
                  title: Text(
                    'เกี่ยวกับ',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],
              currentIndex: selectedIndex,
              selectedItemColor: Colors.amber[800],
              onTap: (url) async {
                flutterWebViewPlugin.show();
                setState(() {
                  selectedIndex = url;
                  IshopURL.currentUrl = IshopURL.urlList[url];
                });
                flutterWebViewPlugin.reloadUrl(IshopURL.currentUrl);
              },
            )),
      ),
    );
  }
}
