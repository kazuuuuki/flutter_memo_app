import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../model/memo.dart';

class AddEditMemoPage extends StatefulWidget {
  //currentMemo変数で新規or編集か判断する
  //「?」はnullが許容される型を表す
  final Memo? currentMemo;
  const AddEditMemoPage({Key? key, this.currentMemo}) : super(key: key);

  @override
  State<AddEditMemoPage> createState() => _AddEditMemoPageState();
}

class _AddEditMemoPageState extends State<AddEditMemoPage> {
  //テキスト入力フィールドからテキストを取得するための宣言
  TextEditingController titleController = TextEditingController();
  TextEditingController detailController = TextEditingController();

  //追加ボタンをタップすると以下が実行
  Future<void> createMemo() async {
    //コレクションという変数がFirebaseの値をもっている
    final memoCollection = FirebaseFirestore.instance.collection('wordMemo');
    await memoCollection.add({
      //テキストフィールドで入力した値を各ドキュメントに加える
      'title': titleController.text,
      'detail': detailController.text,
      'createdDate': Timestamp.now()
    });
  }

  //更新ボタンをタップすると以下が実行
  Future<void> updateMemo() async {
    //FirebaseのDBを参照する
    final doc = FirebaseFirestore.instance
        .collection('wordMemo')
        .doc(widget.currentMemo!.id);
    await doc.update({
      'title': titleController.text,
      'detail': detailController.text,
      'updatedDate': Timestamp.now()
    });
  }

//再ビルド、初期化して再生成
  @override
  void initState() {
    super.initState();
    //currentMemoに値が入ってる時は各controllerに反映
    if (widget.currentMemo != null) {
      //「!」はnullでないことを保証されている変数に使用する
      titleController.text = widget.currentMemo!.title;
      detailController.text = widget.currentMemo!.detail;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.currentMemo == null ? 'メモ追加' : 'メモ編集'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Text('タイトル'),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(left: 10),
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text('詳細'),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextField(
                controller: detailController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(left: 10),
                ),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () async {
                  //メモを作成する処理
                  //currentMemoが空なら新規追加
                  if (widget.currentMemo == null) {
                    await createMemo();
                  } else {
                    await updateMemo();
                  }

                  Navigator.pop(context);
                },
                child: Text(widget.currentMemo == null ? '追加' : '更新'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
