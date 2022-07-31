import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hook_tutorial/firebase_options.dart';
import 'package:hook_tutorial/provider/controller.dart';
import 'package:hook_tutorial/state/state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// // タイトルを入れるプロバイダー
// final titleProvider = StateProvider<String>((ref) {
//   return '';
// });
// // メッセージを入れるプロバイダー
// final messageProvider = StateProvider<String>((ref) {
//   return '';
// });
// // FireStoreの'posts'コレクションのすべてのドキュメントを取得するプロバイダー。初回に全件分、あとは変更があるたびStreamに通知される。
// final firebasePostsProvider = StreamProvider.autoDispose((_) {
//   return FirebaseFirestore.instance.collection('posts').snapshots();
// });

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PostPage(),
    );
  }
}

class PostPage extends HookConsumerWidget {
  const PostPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = ref.watch(titleProvider);
    final message = ref.watch(messageProvider);
    final AsyncValue<QuerySnapshot> firebasePosts =
        ref.watch(firebasePostsProvider);

    // flutter_hooksのコード
    final titleController = useTextEditingController(text: title);
    final messageController = useTextEditingController(text: message);

    return Scaffold(
      appBar: AppBar(
        title: const Text('POST'),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              // controller: useTextEditingController(text: title),
              controller: titleController,
              onChanged: (value) {
                print('🔍titleをデバッグ: $value');
                ref.watch(titleProvider.notifier).state = value;
              },
            ),
            TextFormField(
              // controller: useTextEditingController(text: message),
              controller: messageController,
              onChanged: (value) {
                print('🔍messageをデバッグ: $value');
                ref.watch(messageProvider.notifier).state = value;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: () async {
                  // await FirebaseFirestore.instance
                  //     .collection('posts')
                  //     .add({'title': title, 'message': message});
                  // 追加するメソッドを呼び出す
                  ref.read(postStateProvider.notifier).addPost(title, message);
                },
                child: Text('送信')),
            firebasePosts.when(
              // データがあった（データはqueryの中にある）
              data: (QuerySnapshot query) {
                // post内のドキュメントをリストで表示する
                return Expanded(
                  child: ListView(
                    // post内のドキュメント１件ずつをCard枠を付けたListTileのListとしてListViewのchildrenとする
                    children: query.docs.map((document) {
                      return Card(
                        child: ListTile(
                          // postで送った内容を表示する
                          title: Text(document['title']),
                          subtitle: Text(document['message']),
                          // postで保存した内容を削除する
                          trailing: IconButton(
                            onPressed: () async {
                              // await FirebaseFirestore.instance
                              //     .collection('posts')
                              //     .doc(document.id)
                              //     .delete();
                              // 削除するメソッドを呼び出す
                              ref
                                  .read(postStateProvider.notifier)
                                  .deletePost(document);
                            },
                            icon: const Icon(Icons.delete),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },

              // データの読み込み中（FireStoreではあまり発生しない）
              loading: () {
                return const Text('Loading');
              },

              // エラー（例外発生）時
              error: (e, stackTrace) {
                return Text('error: $e');
              },
            )
          ],
        ),
      ),
    );
  }
}
