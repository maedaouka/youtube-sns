// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // Try running your application with "flutter run". You'll see the
//         // application has a blue toolbar. Then, without quitting the app, try
//         // changing the primarySwatch below to Colors.green and then invoke
//         // "hot reload" (press "r" in the console where you ran "flutter run",
//         // or simply save your changes to "hot reload" in a Flutter IDE).
//         // Notice that the counter didn't reset back to zero; the application
//         // is not restarted.
//         primarySwatch: Colors.blue,
//         // This makes the visual density adapt to the platform that you run
//         // the app on. For desktop platforms, the controls will be smaller and
//         // closer together (more dense) than on mobile platforms.
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: LoginPage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }
//
// class LoginPage extends StatefulWidget {
//   LoginPage({Key key, this.title}) : super(key: key);
//
//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.
//
//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".
//
//   final String title;
//
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage> {
//   int _counter = 0;
//
//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // Here we take the value from the LoginPage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Invoke "debug painting" (press "p" in the console, choose the
//           // "Toggle Debug Paint" action from the Flutter Inspector in Android
//           // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
//           // to see the wireframe for each widget.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headline4,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }


// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Youtube SNS',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.red,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginPage(title: 'Login Page'),
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var youtubeData;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      "https://www.googleapis.com/auth/youtube"
    ]
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<FirebaseUser> _handleSignIn() async {
    GoogleSignInAccount googleCurrentUser = _googleSignIn.currentUser;
    try {
      if (googleCurrentUser == null) googleCurrentUser = await _googleSignIn.signInSilently();
      if (googleCurrentUser == null) googleCurrentUser = await _googleSignIn.signIn();
      if (googleCurrentUser == null) return null;

      GoogleSignInAuthentication googleAuth = await googleCurrentUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
      print("signed in " + user.displayName);
      print("user");
      print(user);
      print("google auth");
      print(googleAuth.accessToken);

      // final url = "https://www.googleapis.com/youtube/v3/videos?id=7lCDEYXw3mM&key=AIzaSyCpPTlS1qzJkCFQ9OJEe7oNGwx4KYoIHEI&part=snippet,contentDetails,statistics,status";
      // final url = "https://www.googleapis.com/youtube/v3/channels?key=AIzaSyCpPTlS1qzJkCFQ9OJEe7oNGwx4KYoIHEI&part=id&id=1";

      //TODO: 不要かどうか別のGoogleアカウントで　確認。 おそらく不要。
      // final response1 = await http.get("https://www.googleapis.com/auth/youtube.force-ssl");

      final url = "https://www.googleapis.com/youtube/v3/channels?part=id,snippet,status&mine=true&access_token="+ googleAuth.accessToken;
      final response = await http.get(url);
      print("レスポンス");
      print(response.body);
      print("Youtube uid");
      // Youtubeチャンネルはこの時点で一個しか取れないので0番目を取得する。
      youtubeData = jsonDecode(response.body)["items"][0];
      print(youtubeData);


      // TODO: LISTENじゃなくてもいい気がする。検討。
      Firestore.instance.collection("users").where("id", isEqualTo: youtubeData["id"]).snapshots().listen((data) {
        print("aaa");
        print(data.documents.length);
        if(data.documents.length == 0) {
          //まだfirestoreにyoutubeアカウントがuserとして登録されていない場合、userを登録。
          Firestore.instance.collection("users").add({
            "name": youtubeData["snippet"]["title"],
            "id": youtubeData["id"],
          });
        }
        for (var document in data.documents) {
          print(document.data);
        }
      });

      final url2 = "https://developers.google.com/apis-explorer/#p/youtube/v3/youtube.subscriptions?part=id,snippet&mySubscribers=true&access_token="+ googleAuth.accessToken;
      final response2 = await http.get(url2);
      print("自分のチャンネル登録者");
      print(response2.body);

      final url3 = "https://developers.google.com/apis-explorer/#p/youtube/v3/youtube.subscriptions.list?part=snippet,contentDetails&mine=true";
      final response3 = await http.get(url3);
      print("自分がチャンネル登録してるチャンネル");
      print(response3.body);

      // Navigator.push(context, MaterialPageRoute(builder: (context) => TestList()));
      final res = await Firestore.instance.collection('users').orderBy('createdAt', descending: true).snapshots().listen((data) {
        // data.documents.forEach(data => print(data));
        for (var document in data.documents) {
          print(document.data);
        }
        print(data.documents);
      });
      print(res.toString());

      return user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  void transitionMyPage(FirebaseUser user) {
    if (user == null) return;

    Navigator.push(context, MaterialPageRoute(builder: (context) =>
        MyPage(userData: user, youtubeUserData: youtubeData)
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: Text('Sign in Google'),
                onPressed: () {
                  _handleSignIn()
                      .then((FirebaseUser user) =>
                      transitionMyPage(user)
                  )
                      .catchError((e) => print(e));
                },
              ),
            ]
        ),
      ),
    );
  }
}

class MyPage extends StatefulWidget {
  FirebaseUser userData;
  var youtubeUserData;

  MyPage({Key key, this.userData, this.youtubeUserData}) : super(key: key);

  @override
  _MyPageState createState() => _MyPageState(userData, youtubeUserData);
}

class _MyPageState extends State<MyPage> {
  FirebaseUser userData;
  var youtubeUserData;
  String name = "";
  String email;
  String photoUrl;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  _MyPageState(FirebaseUser userData, youtubeUserData) {
    this.userData = userData;
    this.youtubeUserData = youtubeUserData;
    this.name = userData.displayName;
    this.email = userData.email;
    this.photoUrl = userData.photoUrl;
  }

  Future<void> _handleSignOut() async {
    await FirebaseAuth.instance.signOut();
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      print(e);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ユーザー情報表示"),
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.network(this.photoUrl),
              Text(this.name,
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
              Text("@" + this.youtubeUserData["id"],
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
              RaisedButton(
                child: Text('Sign Out Google'),
                onPressed: () {
                  _handleSignOut().catchError((e) => print(e));
                },
              ),
            ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(context, MaterialPageRoute(builder: (context) => CreateMessagePage(userData, youtubeUserData)));
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      )
    );
  }
}

class CreateMessagePage extends StatefulWidget {
  @override
  _CreateMessagePageState createState() => new _CreateMessagePageState();

  CreateMessagePage(FirebaseUser user, var youtubeUserData) {
    _CreateMessagePageState.user = user;
    _CreateMessagePageState.youtubeUserId = youtubeUserData["id"];
  }
}

class _CreateMessagePageState extends State<CreateMessagePage> {
  static FirebaseUser user;
  static String youtubeUserId;
  static String _message;

  void _handleMessage(String e) {
    setState(() {
      _message = e;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("メッセージ投稿"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text("投稿内容",
                style: TextStyle(
                  color: Colors.grey
                )),
            new TextField(
              enabled: true,
              maxLength: 10,
              maxLengthEnforced: false,
              style: TextStyle(color: Colors.blueGrey),
              cursorColor: Colors.red,
              // decoration: InputDecoration(
              //   enabledBorder: OutlineInputBorder(
              //     borderSide: BorderSide(
              //       color: Colors.red,
              //     ),
              //   ),
              // ),
              obscureText: false,
              maxLines: 1,
              onChanged: _handleMessage,
            ),
            RaisedButton(
              child: Text(
                  "投稿する",
                style: TextStyle(
                  color: Colors.white
                ),
              ),
              color: Colors.red,
              shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              onPressed: () {
                // Future createCertificate() async {
                //   _toName = await twitterUserShow(token, secret, _toName);
                //   final url = "https://eca9kh6oqe.execute-api.ap-northeast-1.amazonaws.com/default/kosan_syoumei_create?device=$_deviceId&from_name=$_fromName&to_name=$_toName&memo=$_memo";
                //   await http.get(url);
                // }
                // createCertificate()
                Firestore.instance.collection("post").add({
                  "message": _message,
                  "userYoutubeId": youtubeUserId,
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

//
// class TestList extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: Firestore.instance.collection('users').snapshots(),
//       builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//         if (snapshot.hasError)
//           return new Text('Error: ${snapshot.error}');
//         switch (snapshot.connectionState) {
//           case ConnectionState.waiting: return new Text('Loading...');
//           default:
//             return new ListView(
//               children: snapshot.data.documents.map((DocumentSnapshot document) {
//                 return new ListTile(
//                   title: new Text("aa"),
//                   subtitle: new Text("bb∂ß"),
//                 );
//               }).toList(),
//             );
//         }
//       },
//     );
//   }
// }