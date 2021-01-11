import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'main.dart';

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
  // _Footer createState() => ;


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
    _bottomNavigationBarItems.add(_UpdateActiveState(0));
    for ( var i = 1; i < _footerItemNames.length; i++) {
      _bottomNavigationBarItems.add(_UpdateDeactiveState(i));
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
      _bottomNavigationBarItems[_selectedIndex] = _UpdateDeactiveState(_selectedIndex);
      _bottomNavigationBarItems[index] = _UpdateActiveState(index);
      _selectedIndex = index;

      print(_selectedIndex);

      if(_selectedIndex == 0) {
        print("ユーザーデータ");
        print(userData);
        print("Youtubeユーザーデータ");
        print(youtubeUserData);
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => MyPage(userData: userDataGrobal, youtubeUserData: youtubeUserDataGrobal)));
      } else if(_selectedIndex == 1) {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => TimelinePage(userDataGrobal, youtubeUserDataGrobal, messegeListGrobal)));
      }
      print(_selectedIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed, // これを書かないと3つまでしか表示されない
      items: _bottomNavigationBarItems,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
    );
  }
}