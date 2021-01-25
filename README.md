# youtube-sns

Youtubeアカウントを利用したSNSです。
ログインはfirebaseAuth、データベースはfireStoreを利用しました。

![youtube-sns-gif](https://user-images.githubusercontent.com/29334692/105657418-abffa600-5f07-11eb-9856-b43da6e5354b.gif)

## 構成

firebaseを利用してtwitter認証でログイン

　　　　　↓

ログイン時に取得した情報からtwitterAPIを叩く。（応援相手を入力する際にAPIを叩いてユーザー情報を取得しています。）

　　　　　↓

AWSのAPIGateway　→　AWSのlambda →　QLDBアクセス


lambda のコード

作成
https://github.com/maedaouka/lambda_kosan_syoumei_create

一覧取得
https://github.com/maedaouka/lambda_kosan_syoumei_mylist

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
