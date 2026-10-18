# 変更履歴（この fork の版）

[English](CHANGELOG.md)

この fork（[Nikque/edax_runner](https://github.com/Nikque/edax_runner)）の版だけを日本語で載せています。元の edax_runner の履歴（5.3.0 以前）は [CHANGELOG.md](CHANGELOG.md) にあります。

## 5.3.0+nikque.10

タグは `v5.3.0-nikque.10` です。

- 修正：**起動のときに読めなかった `data/book.dat`（壊れている・途中で切れている）が、何もない状態から学習した book で置き換えられていた**（5.3.0+nikque.3 から。book を `data/book.dat.saving` に保存してから `data/book.dat` へ名前を変えるため）。名前を変える前に、`data/book.dat.damaged` として残します（libedax の関数 `edax_book_keep_unread_file`、Edax 4.5.5 nikque.16 から）。残せないときは `book.dat` を置き換えず、`learning_list.txt` を変えずに止まります。
- **同じフォルダーで 2 つ目の edax_runner を起動すると、何もせずに止まります**（終了コード 1）。同じフォルダーで 2 つ動かすと、同じ行を同じ book に学習し、互いに保存した book を置き換えていました。edax_runner は、動いている間、フォルダーの `edax_runner.lock` というファイルをつかみます。edax_runner が終わると（強制終了でも）、OS が放します（ファイルはフォルダーに残ります）。
- libedax と `config.ini` を [Edax 4.5.5 nikque.18](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.18) のものにしました（nikque.16・17 の変更を含みます。変更点は Edax の修正一覧にあります）。edax_runner に関係するのは次のとおりです。
  - nikque.16：2回目のクロスチェックで見つかった不具合の修正（壊れた棋譜のファイルや盤面を受け付けない、など）、関数 `edax_book_keep_unread_file`（上）。
  - nikque.17：設定 `book-seed`・`book-reproducible`（`config.ini` にあります。既定の動作は変わりません）。
  - nikque.18：ライブラリに、ビルドしたときのフォルダーが入りません（エラーの文言はファイル名だけ）。
- 以前の Release の Windows の ZIP も、同梱のライブラリのビルドしたときのフォルダーを同じように消しました（ほかは変えていません）。

確認（Windows、1〜2論理CPU）：

- 途中で切れた `data/book.dat`（100,000バイト）と、学習する 1 行：5.3.0+nikque.9 は置き換えました（終了 0、`.damaged` なし）。この版は `data/book.dat.damaged`（同じバイト列）として残し、学習した book を保存しました。
- 1 つ目が同じフォルダーで 24 行を学習している間に 2 つ目を起動：この版では 2 つ目が 0.2 秒で止まり（終了 1）、1 つ目が 24 行を学習。直す前は両方が学習しました（`learned_log.txt` が 35 行）。1 つ目が終わった後も、強制終了の後も、次の起動は学習しました。
- 5.3.0+nikque.9 と同じ 5 種類のリストを、level 6、1スレッド・1局ずつと 2スレッド・`book-store-tasks = auto` で、公開の 5.3.0+nikque.9 と比較：終了コードはすべて 0、10 組中 9 組で book・`learning_list.txt`・`learned_log.txt` が同じ。残る 1 組（`book-randomness` 4 の行を含むリスト）は、どちらの版も 3 回の実行で同じ 3 通りの book になりました（その行の乱数による選択）。
- `dart format`、`dart analyze --fatal-infos --fatal-warnings`、`dart test`（27件）。

## 5.3.0+nikque.9

タグは `v5.3.0-nikque.9` です。

- 修正：**学習リストから学習済みの行を抜いている間に、利用者が保存した学習リストの編集が消えることがあった**（元の edax_runner から）。置き換える直前に、学習リストの大きさと更新時刻が読んだときと同じかを見て、違えば読み直してやり直します（5 回まで）。
- libedax を [Edax 4.5.5 nikque.15](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.15) のものにしました（変更点は Edax の修正一覧にあります）。edax_runner に関係するのは次のとおりです。
  - 大きな book に学習で局面を足し続けたときに、使われなくなったメモリ（読み込んだ book のプールの元の場所）を、学習の合間に放します。
  - Linux・macOS でも、使わないプールの部分を放します。
  - 壊れた book のファイルは読み込みません（これまでは読み込み、使うと異常終了することがありました）。
  - 正しい book での学習・`fix`・`[relativeError absoluteError]` でできる book は同じです。


- **公開後の確認（2026-10-15）**：同じ5.3.0+nikque.9の実行ファイルに nikque.14／15のDLLを入れ、5種類の同じリストを1スレッド・1局ずつ／4スレッド・autoで比較（計10組）。終了コードはすべて0、残る学習リストと学習済み記録は全組バイト一致。棋譜30件・誤差指定・空リストは6組とも正規化したbookが一致。同梱リスト・BOM/CRLF版は4組中2組のbookが一致し、2組は異なりました。同じ新版DLLのBOM/CRLFリストを3回繰り返してもbookが異なり（292／292／290局面）、乱数付きの行を含む比較では完全一致を確認していません。差の原因を版間の変更から完全に切り分けたものではありません。
- 学習済み行を抜く関数の試験用コピーで、リストを読んで保存用ファイルを書いた直後に別の行を追加：旧コードでは追加行が消え、新コードでは読み直して追加行が残り、学習済み記録も1回分だけでした。配布用のソース・実行ファイルに試験用の印は入れていません。

## 5.3.0+nikque.8

タグは `v5.3.0-nikque.8` です。edax_runner そのもの（Dart のコード）は変わりません。

- libedax と `config.ini` を [Edax 4.5.5 nikque.14](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.14) のものにしました（変更点は Edax の修正一覧にあります）。
  - Edax 4.5.5 nikque.14 で変わったのは、book の新しい命令 `book fill2`・`book leaf expand`、`book fill` の範囲の指定、`book leaf-recalculate` から `book leaf recalculate` への名前の変更です。**edax_runner が使う機能（棋譜の学習、`fix`、`[relativeError absoluteError]`）の処理は変わっていません。** Edax 本体とライブラリの版をそろえるための更新です。
  - `config.ini`：`book-leaf-recalculate-rounds` の説明の文を、新しい命令の名前 `book leaf recalculate` にしました（設定は同じです）。

## 5.3.0+nikque.7

タグは `v5.3.0-nikque.7` です。

- 修正：**80手（着手＋パス）を超える行を、「illegal move」として飛ばしていました。** パスが21回以上ある対局でだけ起きます（通常の初期局面からでも、着手60＋パス22＝82手の対局があります）。ふつうの学習リストでは当たりません。
  - 棋譜を同時に学習する場合（`book-store-tasks` が `auto` か2以上）：libedax の中の対局の記録が80手ぶんのままでした（Edax 4.5.5 nikque.13 で修正）。
  - 1局ずつ学習する場合（`book-store-tasks = 1`、`[relativeError absoluteError]` 付きの行）：edax_runner は、行の手を打たせた後で、libedax から手順を読み戻して行と比べていましたが、読み戻せるのは80手までです。読み戻した手順が行の先頭と一致し、盤上の石の数が「4＋行の手の数」なら、全部の手が打てたと判断するようにしました。80手以下の行の判定は変わりません。
- libedax と `config.ini` を [Edax 4.5.5 nikque.13](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.13) のものにしました（詳しくは Edax の修正一覧）。
  - Edax 4.5.5 nikque.13 は、Edax 4.5.5 nikque.10〜12 の変更を点検して見つかった不具合の修正です。edax_runner が使う機能（棋譜の学習、`fix`、`[relativeError absoluteError]`）で変わるのは、上の80手の件と、合法手のない局面（パスの局面）の探索でまれに異常終了する不具合の修正（探索の結果は変わりません）です。**できる book は 5.3.0+nikque.6 と同じです**（`hash-table-size` を19以下の数にしている場合の `[relativeError absoluteError]` を除きます。Edax の README を参照）。
  - `config.ini` に、Edax の新しい設定 `book-leaf-recalculate-rounds` の説明と行が増えました（edax_runner は使いません）。

## 5.3.0+nikque.6

タグは `v5.3.0-nikque.6` です。edax_runner 自身（Dart のコード）は変えていません。

- libedax を [Edax 4.5.5 nikque.12](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.12) のものにしました（詳しくは Edax の修正一覧）。`config.ini` は同じです。
  - Edax 4.5.5 nikque.12 で変わったのは、新しい命令 `book leaf-recalculate`（Leaf の評価値の計算し直し）、book を切り詰める命令（`book subtree`・`book prune`）の速さ、`book` の後ろの語の大文字・小文字です。**edax_runner が使う機能（棋譜の学習、`fix`、`[relativeError absoluteError]`）の処理は変わっていません。** Edax 本体とライブラリの版をそろえるための更新です。

## 5.3.0+nikque.5

タグは `v5.3.0-nikque.5` です。edax_runner 自身（Dart のコード）は変えていません。

- libedax を [Edax 4.5.5 nikque.11](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.11) のものにしました（詳しくは Edax の修正一覧）。`config.ini` は同じです。
  - Edax 4.5.5 nikque.11 で変わったのは、book を切り詰める命令（`book subtree`・`book prune`）と `book correct`・`book enhance` です。**edax_runner が使う機能（棋譜の学習、`fix`、`[relativeError absoluteError]`）の処理は変わっていません。** Edax 本体とライブラリの版をそろえるための更新です。

## 5.3.0+nikque.4

タグは `v5.3.0-nikque.4` です。edax_runner 自身（Dart のコード）は変えていません。

- libedax と `config.ini` を [Edax 4.5.5 nikque.10](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.10) のものにしました（詳しくは Edax の修正一覧）。
  - `fix`（`book fix`）：大きな book で、Link の張り直しが速くなりました（6億6162万局面の book・32スレッドで 153.7秒 → 136.3秒。Edax 本体での計測）。できる book は同じです。
  - `[relativeError absoluteError]`（`book deviate`）：level 18 以下で、1周の展開の対象が多いとき（`n-tasks` の32倍以上。32スレッドなら1,024件以上）は、1スレッドの探索を `n-tasks` 個同時に動かします（これまでは2スレッドの探索を半分の数）。649万局面の book・32スレッドで、60秒に展開できる件数が約1.25倍になりました（Edax 本体での計測）。**できる book は、これまでの `book-expand-tasks = auto` と少し違います**（Edax の README を参照）。対象の少ない周は変わりません。以前の決め方は、`config.ini` に `book-expand-tasks = 16`（`n-tasks` の半分）と書きます。
  - libedax の修正：80手（着手＋パス）を超える対局で記録の外に書き込む、文字列の設定を設定し直すたびに前の文字列が解放されない、`edax_bench` の途中の `edax_stop` でベンチマークが終わらない。edax_runner の学習には影響しません。

## 5.3.0+nikque.3

タグは `v5.3.0-nikque.3` です。

- libedax と `config.ini` を [Edax 4.5.5 nikque.9](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.9) のものにしました。Edax 4.5.5 nikque.8 の総点検で見つかった不具合の修正です（詳しくは Edax の修正一覧）。
  - 複数スレッドの探索の修正：手が探索されないままになるノードができることがありました（結果を誤ることはまれ。元の Edax 4.5.5 からある不具合）。1スレッドの探索は変わりません。
  - 修正：`learning_list.txt` の行が、手の間の空白のために255バイトを超えると、短い手順として学習されることがありました。
  - 修正：起動時に読めなかった book ファイル（壊れている、ほかのプログラムが開いている）が、学習の後で上書きされていました。`book.dat.damaged` として残します。
  - 同時に行う探索のメモリが確保できないとき、終了せずに、同時に行う探索を減らして続けます。
- 多数の棋譜をまとめて学習するのが少し速くなりました：早く終わった対局のスレッドを、まだ対局している探索に足します（level 18 の棋譜128本・32スレッドで 33.6秒 → 30.3秒。Edax 本体での計測。メモリは同じ）。組の終わりのほうの対局の手は、実行ごとに変わることがあります。
- 学習のたびに edax が book を `data/book.dat.store` に保存するのをやめました（Edax 4.5.5 nikque.9 の新しい設定 `book-store-auto-save` を、edax_runner が off にします）。直後に edax_runner が `book.dat` を保存するので、book 全体が2回書かれていました。`data/book.dat.store` は作られなくなります。

- 修正：`book.dat` を保存できなかったとき（ほかのプログラムが `book.dat` を開いている、など）に、それに気づかず、学習した行を `learning_list.txt` から消していました。そのまま edax_runner が終わると、その学習は `book.dat` に残りませんでした。
  - book を別のファイル（`data/book.dat.saving`）に保存させ、保存できたことを確かめてから（libedax に足した、成否を返す関数 `edax_book_save_checked` と、ファイルの確認）`book.dat` と置き換えるようにしました。保存できないときは1秒おきに30回までやり直し、それでも保存できなければ、`learning_list.txt` を変えずに止まります。
- 修正：複数の棋譜を同時に学習するとき（`book-store-tasks` が 2 以上）、`book-randomness` が 128 以上の行（例：`200,F5F6`）が、学習されずに `skipped (illegal move)` と記録されていました。このような行も、ほかの棋譜と一緒に学習します（Edax 4.5.5 nikque.9 の libedax には上限がありません。それより前の libedax では、1局ずつ学習します＝`book-store-tasks = 1` のときと同じ）。
- 同時に学習した棋譜の局面を edax が book に追加できなかったとき（メモリ不足）は、`learning_list.txt` を変えずに止まります（Edax 4.5.5 nikque.9 の libedax が失敗を知らせます。それまでは、学習済みとして行を消していました）。1局ずつの学習、`[relativeError absoluteError]`、`fix` で局面を追加できなかったときも同じです（libedax に足した関数 `edax_book_failed`）。
- 修正：`[relativeError absoluteError]` の数字が 2147483647 より大きいと、別の数字として edax に渡っていました（例：4294967296 は 0）。`too large number` として飛ばします。
- 修正：飛ばした行の最後のバイトが 0x85・0xA0 のとき（Shift_JIS の「あ」など）、`learned_log.txt` に記録するときにそのバイトが落ちていました。
- `scripts/build_edax_runner.sh` は、途中のコマンドが失敗したら止まるようにしました（ライブラリのコピーに失敗しても、最後まで進んで成功として終わっていました）。
- `Create Release` は、その版のタグがすでにあるときは止まるようにしました（同じ版でもう一度動かすと、公開ずみの Release のファイルが置き換わっていました）。
- プルリクエストに自動でラベルを付けるワークフロー（`labeling_pr.yaml`、`.github/labeler.yml`）を消しました（この fork では使いません）。
- 試験を追加しました：学習中に `learning_list.txt` を書き換えた場合（同じ行が複数ある、行が挿入された・移動された・消された）。

## 5.3.0+nikque.2

タグは `v5.3.0-nikque.2` です。

- libedax と `config.ini` を [Edax 4.5.5 nikque.8](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.8) のものにしました。
  - 修正：`book-store-tasks = auto`（既定）のとき、探索する局面が少ない場合や level が高い場合に、`1` より遅くなっていました（1局の学習が、level 24 で13秒のところ26秒、level 21 で4.2秒のところ6.4秒）。同時に行う探索の間でスレッドを分け合うようにし、level 24 で6〜11秒、level 21 で2.0秒になりました。level 18 で1局ずつ30局の学習は、29秒から18秒になりました（`1` では35秒）。（edax のコマンドで測った値です）
  - level 18 の棋譜128本（論理 CPU 32）：37〜39秒 → 35〜36秒。

## 5.3.0+nikque.1

この fork の最初の版です（元は [sensuikan1973/edax_runner](https://github.com/sensuikan1973/edax_runner) の 5.3.0）。タグは `v5.3.0-nikque.1` です。

- edax を、Edax 4.4 から [Edax 4.5.5 (nikque)](https://github.com/Nikque/edax-reversi-AVX) に替えました（libedax の関数は元のものと同じです）。
- libedax を CPU の世代ごと（x86-64 共通、AVX2、AVX-512）にビルドし、edax_runner が、CPU が動かせる中で最も速いものを使うようにしました（Windows、Linux）。
- 設定を、`edax.ini` から Edax 4.5.5 (nikque) の `config.ini` に替えました（`edax.ini` も読みますが、`config.ini` が優先です）。
- `config.ini` の `book-store-tasks` で、複数の棋譜を同時に学習するようにしました（既定の `auto` は `n-tasks` と同じ数。`1` は従来どおり1局ずつ）。
  - `learning_list.txt` の次の「Edax 対 Edax」の行を `book-store-tasks` の数まで同時に対局し、その局面を同時に探索して book に入れます（libedax の `edax_book_store_games` を `dart:ffi` で呼びます）。
  - `learning_list.txt` と `learned_log.txt` は、その組につき1回更新します。
- 修正：`learning_list.txt` に空行があると edax_runner が止まっていました。無視するようにしました。
- 修正：学習できない行（書式が違う、打てない手がある）が、学習済みとして消されていました。警告を出して飛ばし、`learned_log.txt` にコメントとして記録するようにしました。
  - edax は打てない手とその後の手を無視するので、意図しない局面から学習していました。
- 修正：`learning_list.txt` に UTF-8 でないコメント（Shift_JIS など）があると、edax_runner が異常終了していました。
- 修正：`learning_list.txt` の改行コード（CRLF）が LF に書き換えられていました。
- 修正：学習中に `learning_list.txt` を書き換えると、学習した行ではない別の行が消されていました。
- 修正：`fix` の直後に book が保存されていませんでした。
- 修正：`exit` が `learning_list.txt` から消えないので、書き換えないと edax_runner を再開できませんでした。
- 修正：保存中に edax_runner を強制終了すると、`book.dat` や `learning_list.txt` が壊れることがありました。別のファイルに保存してから置き換えるようにしました（`book.dat` は edax が行います）。
- `[0 0]F5F6`、`[ 0 0 ] F5F6`、`2, F5F6` のような書き方を受け付けるようにしました。
- `learning_list.txt` が作業フォルダにないときは、実行ファイルのあるフォルダを使うようにしました。
- `learning_list.txt` の処理を速くし、メモリも少なくしました（バイト列のまま扱い、1行学習するごとに1回だけ読みます）。
