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
var followListTitleGrobal = {};
var followListPhotoGrobal = {};

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

      //TODO: 不要かどうか別のGoogleアカウントで　確認。 おそらく不要。
      await http.get("https://www.googleapis.com/auth/youtube.force-ssl");

      final myChannnelInfoUrl = "https://www.googleapis.com/youtube/v3/channels?part=id,snippet,status&mine=true&access_token="+ googleAuth.accessToken;
      final myChannnelInfoResponse = await http.get(myChannnelInfoUrl);

      // Youtubeチャンネルはこの時点で一個しか取れないので0番目を取得する。
      youtubeData = jsonDecode(myChannnelInfoResponse.body)["items"][0];

      followListGrobal.add(youtubeData["id"]);
      followListTitleGrobal[youtubeData["id"]] = youtubeData["snippet"]["title"];
      followListPhotoGrobal[youtubeData["id"]] = youtubeData["snippet"]["thumbnails"]["default"]["url"];


      // TODO: LISTENじゃなくてもいい気がする。検討。
      Firestore.instance.collection("users").where("id", isEqualTo: youtubeData["id"]).snapshots().listen((data) {
        if(data.documents.length == 0) {
          //まだfirestoreにyoutubeアカウントがuserとして登録されていない場合、userを登録。
          Firestore.instance.collection("users").add({
            "name": youtubeData["snippet"]["title"],
            "id": youtubeData["id"],
          });
        }
      });

      final url2 = "https://www.googleapis.com/youtube/v3/subscriptions?part=id,snippet&mine=true&maxResults=50&access_token="+ googleAuth.accessToken;
      var response2 = await http.get(url2);

      for (int i = 0; i < 50; i++) {
        var j=0;

        try {
          var followUser = jsonDecode(response2.body)["items"][i+j];

          followListGrobal.add(followUser["snippet"]["resourceId"]["channelId"]);
          followListTitleGrobal[followUser["snippet"]["resourceId"]["channelId"]] = followUser["snippet"]["title"];
          followListPhotoGrobal[followUser["snippet"]["resourceId"]["channelId"]] = followUser["snippet"]["thumbnails"]["default"]["url"];

        } on RangeError catch(e) {
          break;
        }
        if(i==49) {
          j += 50;
          if(j < jsonDecode(response2.body)["pageInfo"]["totalResults"]) {
            response2 = await http.get("https://www.googleapis.com/youtube/v3/subscriptions?part=id,snippet&pageToken="+ jsonDecode(response2.body)["nextPageToken"] +"&mine=true&maxResults=50&access_token="+ googleAuth.accessToken);
            i = 0;
          }
        }

      }
      return user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  void transitionMyPage(FirebaseUser user) {
    if (user == null) return;

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
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
                child: Text('Sign in Youtube'),
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
                child: Text('Sign Out Youtube'),
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

    Firestore.instance.collection("post").orderBy('createdAt', descending: true).snapshots().listen((data) {
      _TimelinePageState.messageList = [];
      messegeListGrobal = [];
      for (var document in data.documents) {
        // もしフォローリストに居るアカウントだったらタイムラインようのリストにメッセージを追加する。
        if (followListGrobal.contains(document.data["userYoutubeId"].toString())) {
          _TimelinePageState.messageList.add(document.data);
          messegeListGrobal.add(document.data);
        }
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
          child: Card(
            child: Column(
              children: <Widget>[
                Container(
                    margin: EdgeInsets.all(10.0),
                    child: ListTile(
                      title: Text(followListTitleGrobal[messegeListGrobal[index]["userYoutubeId"]]),
                      leading: Image.network(followListPhotoGrobal[messageList[index]["userYoutubeId"]]),
                      subtitle: Text(messageList[index]["message"].toString()),
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
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
              CreateMessagePage(user, youtubeUser)));
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
        bottomNavigationBar: Footer(user, youtubeUser)
    );
  }
}