import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memo_test/pages/add_edit_memo_page.dart';
import 'package:memo_test/pages/memo_detail_page.dart';

import '../model/memo.dart';

class TopPage extends StatefulWidget {
  const TopPage({super.key, required this.title});

  final String title;

  @override
  State<TopPage> createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  final memoCollection = FirebaseFirestore.instance.collection('wordMemo');

  //Firebaseに接続し、指定されたIDに対応するドキュメントを表すdoc変数を作成
  Future<void> deleteMemo(String id) async {
    final doc = FirebaseFirestore.instance.collection('wordMemo').doc(id);
    //Firebaseに格納されているドキュメントを削除
    await doc.delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('flutte×Firebase'),
      ),
      body: StreamBuilder<QuerySnapshot>(
          //FirestoreDBからリアルタイムでデータ取得
          stream: memoCollection
              .orderBy('createdDate', descending: true) //更新順に並べる
              .snapshots(),
          builder: (context, snapshot) {
            //streamがデータ読み込み中の時、ローディング表示をする
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            //memoCollectionにデータがない場合の表示
            if (!snapshot.hasData) {
              return const Center(
                child: Text('データがありません'),
              );
            }
            //ここまで読み込まれる時はデータがある前提
            final docs = snapshot.data!.docs;
            return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  //Mapクラスはキーと値のペアを格納するためのコレクションクラス
                  //<String,dyanamic>は文字列がキーとなり、その値が未知であることを指す
                  Map<String, dynamic> data =
                      docs[index].data() as Map<String, dynamic>;
                  final Memo fetchMemo = Memo(
                    id: docs[index].id,
                    title: data['title'],
                    detail: data['detail'],
                    createdDate: data['createdDate'],
                    updatedDate: data['updatedDate'],
                  );
                  return ListTile(
                    title: Text(fetchMemo.title),
                    trailing: IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              //SafeAreaは画面の端にある領域を考慮して配置
                              return SafeArea(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      onTap: () {
                                        Navigator.pop(context);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  AddEditMemoPage(
                                                    currentMemo: fetchMemo,
                                                  )),
                                        );
                                      },
                                      leading: const Icon(Icons.edit),
                                      title: const Text('編集'),
                                    ),
                                    ListTile(
                                      onTap: () async {
                                        await deleteMemo(fetchMemo.id);
                                        //現在表示されている画面を閉じる
                                        Navigator.pop(context);
                                      },
                                      leading: const Icon(Icons.delete),
                                      title: const Text('削除'),
                                    ),
                                  ],
                                ),
                              );
                            });
                      },
                      icon: const Icon(Icons.edit),
                    ),
                    onTap: () {
                      //確認画面に遷移する記述を書く
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MemoDetailPage(fetchMemo)),
                      );
                    },
                  );
                });
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddEditMemoPage()));
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
