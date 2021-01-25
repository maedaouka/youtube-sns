# youtube-sns

Youtubeアカウントを利用したSNSです。
ログインはfirebaseAuth、データベースはfireStoreを利用しました。

![youtube-sns-gif](https://user-images.githubusercontent.com/29334692/105657418-abffa600-5f07-11eb-9856-b43da6e5354b.gif)

## 構成

firebaseを利用してGoogle(Youtube)認証でログイン

　　　　　↓

取得したYoutubeアカウントでAPIを叩いて、チャンネル登録しているユーザーの一覧を取得

　　　　　↓

チャンネル登録しているユーザーと自分の投稿内容をタイムラインに一覧表示


## 環境構築
flutterAppのインストール
https://flutter.dev/docs/get-started/install

パッケージがプロジェクトに取り込む
```
flutter pub get
```


iosのエミュレーターを起動する場合は、以下も実行。
```
cd ios
pod install
```
