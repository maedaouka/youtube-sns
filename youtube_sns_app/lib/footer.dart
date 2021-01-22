import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'main.dart';

var footerSelectedIndexGlobal = 0;
class Footer extends StatefulWidget{
  FirebaseUser userData;
  var youtubeUserData;
  _Footer _footer;

  Footer(FirebaseUser userData, Map youtubeUserData);
  setNewData(userData, youtubeUserData) {
    _Footer(userData, youtubeUserData);
  }

  @override
  _Footer createState() => _Footer(userData, youtubeUserData);

  updateData(FirebaseUser userData, Map youtubeUserData) {
    _footer.setState(() {
      this.userData = userData;
      this.youtubeUserData = youtubeUserData;
    });
  }
}

class _Footer extends State<Footer> {
  FirebaseUser userData;
  Map youtubeUserData;
  int _selectedIndex = 0;
  final _bottomNavigationBarItems =  <BottomNavigationBarItem>[];

  _Footer(userData, youtubeUserData) {
    print("代入する時のユーザーデータ");
    print(userData);
    print(youtubeUserData);
    this.userData = userData;
    this.youtubeUserData = youtubeUserData;
  }

  // アイコン情報
  static const _footerIcons = [
    Icons.person,
    Icons.access_time,
  ];

  // アイコン文字列
  static const _footerItemNames = [
    'マイページ',
    'タイムライン',
  ];

  @override
  void initState() {
    super.initState();

    for ( var i = 0; i < _footerItemNames.length; i++) {
      if(i == footerSelectedIndexGlobal) {
        _bottomNavigationBarItems.add(_UpdateActiveState(i));
      } else {
        _bottomNavigationBarItems.add(_UpdateDeactiveState(i));
      }
    }
  }


  /// インデックスのアイテムをアクティベートする
  BottomNavigationBarItem _UpdateActiveState(int index) {
    return BottomNavigationBarItem(
        icon: Icon(
          _footerIcons[index],
          color: Colors.black87,
        ),
        title: Text(
          _footerItemNames[index],
          style: TextStyle(
            color: Colors.black87,
          ),
        )
    );
  }

  /// インデックスのアイテムをディアクティベートする
  BottomNavigationBarItem _UpdateDeactiveState(int index) {
    return BottomNavigationBarItem(
        icon: Icon(
          _footerIcons[index],
          color: Colors.black26,
        ),
        title: Text(
          _footerItemNames[index],
          style: TextStyle(
            color: Colors.black26,
          ),
        )
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _bottomNavigationBarItems[index] = _UpdateActiveState(index);
      footerSelectedIndexGlobal = index;

      print(footerSelectedIndexGlobal);

      if(footerSelectedIndexGlobal == 0) {
        print("ユーザーデータ");
        print(userData);
        print("Youtubeユーザーデータ");
        print(youtubeUserData);
        // Navigator.pop(context);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyPage(userData: userDataGrobal, youtubeUserData: youtubeUserDataGrobal)));
      } else if(footerSelectedIndexGlobal == 1) {
        // Navigator.pop(context);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TimelinePage(userDataGrobal, youtubeUserDataGrobal, messegeListGrobal)));
      }
      print(footerSelectedIndexGlobal);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed, // これを書かないと3つまでしか表示されない
      items: _bottomNavigationBarItems,
      currentIndex: footerSelectedIndexGlobal,
      onTap: _onItemTapped,
    );
  }
}