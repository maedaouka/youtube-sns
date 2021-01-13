import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'footer.dart';

var userDataGrobal;
var youtubeUserDataGrobal;
var messegeListGrobal = [];
var followListGrobal = [];

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
  var followListJson;

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

      //TODO: 不要かどうか別のGoogleアカウントで　確認。 おそらく不要。
      // final response1 = await http.get("https://www.googleapis.com/auth/youtube.force-ssl");

      final url = "https://www.googleapis.com/youtube/v3/channels?part=id,snippet,status&mine=true&access_token="+ googleAuth.accessToken;
      final response = await http.get(url);
      print("レスポンス");
      print(response.body);
      print("Youtube uid");
      // Youtubeチャンネルはこの時点で一個しか取れないので0番目を取得する。
      youtubeData = jsonDecode(response.body)["items"][0];
      print(youtubeData.runtimeType);
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

      final url3 = "https://www.googleapis.com/youtube/v3/subscriptions?part=id,snippet&mine=true&maxResults=50&access_token="+ googleAuth.accessToken;
      print("url");
      print(url3);
      final response2 = await http.get(url3);
      print("自分がチャンネル登録してるチャンネル");
      print(followListJson = followListJson);

      var followList = [];
      var i=0;
      for (int i = 0; i < 50; i++) {
        var followUser = jsonDecode(response2.body)["items"][i];
        try {
          followListGrobal.add({"title": followUser["snippet"]["title"], "channelId": followUser["snippet"]["channelId"], "photo": followUser["snippet"]["thumbnails"]["default"]["url"]});
          print(jsonDecode(response2.body)["items"][i]["snippet"]["title"]);
        } on RangeError catch(e) {
          break;
        }
      }
      print(followListGrobal);
      print("３おわ");

      print(youtubeData = jsonDecode(response.body)["items"]);

      // Navigator.push(context, MaterialPageRoute(builder: (context) => TestList()));
      final res = await Firestore.instance.collection('users').orderBy('createdAt', descending: true).snapshots().listen((data) {
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

    print("user");
    print(user);
    print("youtubeData");
    print(youtubeData);
    Navigator.push(context, MaterialPageRoute(builder: (context) =>
        MyPage(userData: user, youtubeUserData: youtubeData[0])
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

    userDataGrobal = userData;
    youtubeUserDataGrobal = youtubeUserData;
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
              Text("@" + this.youtubeUserData['id'],
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
              RaisedButton(
                child: Text('timeline'),
                onPressed: () {
                  var messageList = [];

                  Firestore.instance.collection("post").where("userYoutubeId", isEqualTo: youtubeUserData["id"]).snapshots().listen((data) {
                    print("aaa");
                    print(data.documents.length);
                    for (var document in data.documents) {
                      print(document.data);
                      messageList.add(document.data);
                    }
                  });
                  print(messageList);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => TimelinePage(userData, youtubeUserData, messageList)));
                },
              ),
              RaisedButton(
                child: Text('Sign Out Google'),
                onPressed: () {
                  _handleSignOut().catchError((e) => print(e));
                },
              ),
            ]),
      ),
        bottomNavigationBar: Footer(userData, youtubeUserData),
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
    _CreateMessagePageState.youtubeUser = youtubeUserData;
  }
}

class _CreateMessagePageState extends State<CreateMessagePage> {
  static FirebaseUser user;
  static Map youtubeUser;
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
                Firestore.instance.collection("post").add({
                  "message": _message,
                  "userYoutubeId": youtubeUserId,
                  "createdAt": FieldValue.serverTimestamp()
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
        bottomNavigationBar: Footer(user, youtubeUser)
    );
  }
}

class TimelinePage extends StatefulWidget {

  @override
  _TimelinePageState createState() => new _TimelinePageState();

  TimelinePage(FirebaseUser user, var youtubeUserData, var messageList) {
    _TimelinePageState.user = user;
    _TimelinePageState.youtubeUser = youtubeUserData;
    _TimelinePageState.messageList = messageList;

    print("タイムライン表示");
    Firestore.instance.collection("post").orderBy('createdAt', descending: true).snapshots().listen((data) {
      for (var document in data.documents) {
        print(document.data);
      }
      print(data.documents);
    });
    Firestore.instance.collection("post").where("userYoutubeId", isEqualTo: youtubeUserData["id"]).orderBy('createdAt', descending: true).snapshots().listen((data) {
      _TimelinePageState.messageList = [];
      print("aaa");
      print(data.documents.length);
      for (var document in data.documents) {
        print(document.data);
        _TimelinePageState.messageList.add(document.data);
        messegeListGrobal.add(document.data);
        print(_TimelinePageState.messageList);
      }
    });
  }
}

class _TimelinePageState extends State<TimelinePage> {
  static FirebaseUser user;
  static Map youtubeUser;
  static String youtubeUserId;
  static List messageList = [];

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("タイムライン"),
      ),
      body: ListView(children: List.generate(messageList.length, (index) {
        return InkWell(
          onTap: () {
            print("tap message");
          },
          child: Card(
            child: Column(
              children: <Widget>[
                Container(
                    margin: EdgeInsets.all(10.0),
                    child: ListTile(
                      title: Text(messageList[index]["message"].toString()),
                      leading: Icon(Icons.people),
                      subtitle: Text("@" + messageList[index]["userYoutubeId"].toString()),
                    )
                )
              ],
            ),
          ),
        );
      })
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(context, MaterialPageRoute(builder: (context) =>
              CreateMessagePage(user, youtubeUser)));
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
        bottomNavigationBar: Footer(user, youtubeUser)
    );
  }
}