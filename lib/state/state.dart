import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// データ型は同じにしないと例外処理が発生する
// なので、dynamicで統一した。document.idが使えないため!
final postStateProvider = StateNotifierProvider<PostState, dynamic>((ref) {
  return PostState();
});

class PostState extends StateNotifier<dynamic> {
  PostState() : super('');
  // メソッドに_をつけてしまうと読み込めなくなるので、つけない
  // addPostといった感じで描く!
  void addPost(dynamic title, dynamic message) async {
    await FirebaseFirestore.instance
        .collection('posts')
        .add({'title': title, 'message': message});
  }

  void deletePost(dynamic document) async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(document.id)
        .delete();
  }
}
