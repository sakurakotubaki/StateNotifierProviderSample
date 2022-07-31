// グローバルに呼び出すプロバイダーを定義
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// タイトルを入れるプロバイダー
final titleProvider = StateProvider<String>((ref) {
  return '';
});
// メッセージを入れるプロバイダー
final messageProvider = StateProvider<String>((ref) {
  return '';
});
// FireStoreの'posts'コレクションのすべてのドキュメントを取得するプロバイダー。初回に全件分、あとは変更があるたびStreamに通知される。
final firebasePostsProvider = StreamProvider.autoDispose((_) {
  return FirebaseFirestore.instance.collection('posts').snapshots();
});
