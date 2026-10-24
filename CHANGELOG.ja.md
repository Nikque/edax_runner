# 変更履歴（この fork の版）

[English](CHANGELOG.md)

この fork（[Nikque/edax_runner](https://github.com/Nikque/edax_runner)）の版だけを日本語で載せています。元の edax_runner の履歴（5.3.0 以前）は [CHANGELOG.md](CHANGELOG.md) にあります。テストと実測の記録は [docs/validation/changelog.ja.md](docs/validation/changelog.ja.md) にあります。

## 5.3.0+nikque.11

同梱の libedax を Edax 4.5.5 nikque.22 に更新した版です。edax_runner の動作と学習の結果は変わりません。タグは `v5.3.0-nikque.11`、libedax：[Edax 4.5.5 nikque.22](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.22)。

**変更**

- libedax を Edax 4.5.5 nikque.22 のものにしました。nikque.19〜22 の変更を含みます（Edax の修正一覧：[nikque.19](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/RELEASE-NOTES.ja.md#v455-nikque19)・[nikque.20](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/RELEASE-NOTES.ja.md#v455-nikque20)・[nikque.21](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/RELEASE-NOTES.ja.md#v455-nikque21)・[nikque.22](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/RELEASE-NOTES.ja.md#v455-nikque22)）。
- nikque.19〜22 で増えたのは Edax のテキストのコマンド（book の解析のコマンド、`book findline`、`book reduce`・`book reducecount` と設定 `book-reduce-*`）です。edax_runner はこれらを使いません。

**互換性**

- edax_runner が使う libedax の関数とその働き、`config.ini`・`eval.dat` は nikque.18（5.3.0+nikque.10）と同じです。
- 探索と book の結果は nikque.18 と同じです。
- 新しい設定は `config.ini` に書かなくても既定の値で動きます。`config.ini` を書き換える必要はありません。

**未確認**：速さとメモリ、Linux・macOS の実機での動作。

[検証記録](docs/validation/changelog.ja.md#530nikque11)

---

## 5.3.0+nikque.10

起動のときに読めなかった `data/book.dat` を消さずに残すようにし、同じフォルダーで edax_runner を 2 つ同時に動かせないようにしました。タグは `v5.3.0-nikque.10`、libedax：[Edax 4.5.5 nikque.18](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.18)。

**変更**

- 同じフォルダーで 2 つ目の edax_runner を起動すると、何もせずに止まります（終了コード 1）。これまでは、2 つが同じ行を同じ book に学習し、互いに保存した book を置き換えていました。
- edax_runner は、動いている間、フォルダーの `edax_runner.lock` というファイルをつかみます。edax_runner が終わると（強制終了でも）、OS が放します。ファイルはフォルダーに残ります。
- libedax と `config.ini` を Edax 4.5.5 nikque.18 のものにしました。nikque.16・17 の変更を含みます（Edax の修正一覧：[nikque.16](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/RELEASE-NOTES.ja.md#v455-nikque16)・[nikque.17](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/RELEASE-NOTES.ja.md#v455-nikque17)・[nikque.18](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/RELEASE-NOTES.ja.md#v455-nikque18)）。edax_runner に関係するのは次のとおりです。
  - nikque.16：2 回目のクロスチェックで見つかった不具合の修正（壊れた棋譜のファイルや盤面を受け付けない、など）と、関数 `edax_book_keep_unread_file`。
  - nikque.17：設定 `book-seed`・`book-reproducible`（`config.ini` にあります）。
  - nikque.18：ライブラリに、ビルドしたときのフォルダーが入りません（エラーの文言はファイル名だけ）。
- 以前の Release の Windows の ZIP も、同梱のライブラリから、ビルドしたときのフォルダーを同じように消しました（ほかは変えていません）。

**不具合の修正**

- 起動のときに読めなかった `data/book.dat`（壊れている・途中で切れている）が、何もない状態から学習した book で置き換えられていました（5.3.0+nikque.3 から。book を `data/book.dat.saving` に保存してから `data/book.dat` へ名前を変えるため）。→ 名前を変える前に、`data/book.dat.damaged` として残します（libedax の関数 `edax_book_keep_unread_file`、Edax 4.5.5 nikque.16 から）。残せないときは `book.dat` を置き換えず、`learning_list.txt` を変えずに止まります。

**互換性**

- `book-seed`・`book-reproducible` の既定の動作は、これまでと同じです。
- 同じフォルダーで edax_runner を 2 つ同時に動かすことはできなくなりました。

**未確認**：`book-store-tasks = 1` で 5.3.0+nikque.9 より遅くなったかどうか（測定の揺れの中で、まだ言い切れません）。

[検証記録](docs/validation/changelog.ja.md#530nikque10)

---

## 5.3.0+nikque.9

学習中に保存した学習リストの編集が消えることがある不具合を直し、libedax を更新しました。タグは `v5.3.0-nikque.9`、libedax：[Edax 4.5.5 nikque.15](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.15)（[修正一覧](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/RELEASE-NOTES.ja.md#v455-nikque15)）。

**変更**

- 大きな book に学習で局面を足し続けたときに、使われなくなったメモリ（読み込んだ book のプールの元の場所）を、学習の合間に解放します（libedax）。
- Linux・macOS でも、使わないプールの部分を解放します（libedax）。

**不具合の修正**

- 学習リストから学習済みの行を抜いている間に、利用者が保存した学習リストの編集が消えることがありました（元の edax_runner から）。→ 置き換える直前に、学習リストの大きさと更新時刻が読んだときと同じかを確かめ、違えば読み直してやり直します（5 回まで）。
- 壊れた book のファイルを読み込み、使うと異常終了することがありました（libedax）。→ 読み込みません。

**互換性**

- 正しい book での学習・`fix`・`[relativeError absoluteError]` でできる book は同じです。

**未確認**：乱数付きの行を含むリストで、できる book が nikque.14 の libedax のときと完全に同じかどうか（公開後の確認で差の原因を切り分けていません）。

[検証記録](docs/validation/changelog.ja.md#530nikque9)

---

## 5.3.0+nikque.8

Edax 本体とライブラリの版をそろえるための更新です。edax_runner そのもの（Dart のコード）は変わりません。タグは `v5.3.0-nikque.8`、libedax：[Edax 4.5.5 nikque.14](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.14)（[修正一覧](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/RELEASE-NOTES.ja.md#v455-nikque14)）。

**変更**

- libedax と `config.ini` を Edax 4.5.5 nikque.14 のものにしました。Edax で変わったのは、book の新しいコマンド `book fill2`・`book leaf expand`、`book fill` の範囲の指定、`book leaf-recalculate` から `book leaf recalculate` への名前の変更です。
- `config.ini`：`book-leaf-recalculate-rounds` の説明の文を、新しいコマンドの名前 `book leaf recalculate` にしました（設定は同じです）。

**互換性**

- edax_runner が使う機能（棋譜の学習、`fix`、`[relativeError absoluteError]`）の処理は変わっていません。

---

## 5.3.0+nikque.7

80 手（着手＋パス）を超える行が学習されなかった不具合を直しました。タグは `v5.3.0-nikque.7`、libedax：[Edax 4.5.5 nikque.13](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.13)（[修正一覧](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/RELEASE-NOTES.ja.md#v455-nikque13)）。

**変更**

- libedax と `config.ini` を Edax 4.5.5 nikque.13 のものにしました。nikque.10〜12 の変更を点検して見つかった不具合の修正です。
- `config.ini` に、Edax の新しい設定 `book-leaf-recalculate-rounds` の説明と行が増えました（edax_runner は使いません）。

**不具合の修正**

- 80 手（着手＋パス）を超える行を、「illegal move」として飛ばしていました。パスが 21 回以上ある対局でだけ起きます（通常の初期局面からでも、着手 60＋パス 22＝82 手の対局があります）。ふつうの学習リストでは当たりません。
  - 棋譜を同時に学習する場合（`book-store-tasks` が `auto` か 2 以上）：libedax の中の対局の記録が 80 手ぶんのままでした。→ Edax 4.5.5 nikque.13 で直りました。
  - 1 局ずつ学習する場合（`book-store-tasks = 1`、`[relativeError absoluteError]` 付きの行）：edax_runner は打った手順を libedax から読み戻して行と比べますが、読み戻せるのは 80 手までです。→ 読み戻した手順が行の先頭と一致し、盤上の石の数が「4＋行の手の数」なら、全部の手が打てたと判断します。80 手以下の行の判定は変わりません。
- 合法手のない局面（パスの局面）の探索で、まれに異常終了していました。→ 直しました（libedax。探索の結果は変わりません）。

**互換性**

- できる book は 5.3.0+nikque.6 と同じです。例外は、`hash-table-size` を 19 以下の数にしている場合の `[relativeError absoluteError]` です（[Edax の修正一覧 nikque.13](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/RELEASE-NOTES.ja.md#v455-nikque13) を参照）。

---

## 5.3.0+nikque.6

Edax 本体とライブラリの版をそろえるための更新です。edax_runner 自身（Dart のコード）は変えていません。タグは `v5.3.0-nikque.6`、libedax：[Edax 4.5.5 nikque.12](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.12)（[修正一覧](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/RELEASE-NOTES.ja.md#v455-nikque12)）。

**変更**

- libedax を Edax 4.5.5 nikque.12 のものにしました。Edax で変わったのは、新しいコマンド `book leaf-recalculate`（Leaf の評価値の計算し直し）、book を切り詰めるコマンド（`book subtree`・`book prune`）の速さ、`book` の後ろの語の大文字・小文字です。

**互換性**

- edax_runner が使う機能（棋譜の学習、`fix`、`[relativeError absoluteError]`）の処理は変わっていません。
- `config.ini` は同じです。

---

## 5.3.0+nikque.5

Edax 本体とライブラリの版をそろえるための更新です。edax_runner 自身（Dart のコード）は変えていません。タグは `v5.3.0-nikque.5`、libedax：[Edax 4.5.5 nikque.11](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.11)（[修正一覧](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/RELEASE-NOTES.ja.md#v455-nikque11)）。

**変更**

- libedax を Edax 4.5.5 nikque.11 のものにしました。Edax で変わったのは、book を切り詰めるコマンド（`book subtree`・`book prune`）と `book correct`・`book enhance` です。

**互換性**

- edax_runner が使う機能（棋譜の学習、`fix`、`[relativeError absoluteError]`）の処理は変わっていません。
- `config.ini` は同じです。

---

## 5.3.0+nikque.4

大きな book での `fix` と、`[relativeError absoluteError]` の展開が速くなりました。edax_runner 自身（Dart のコード）は変えていません。タグは `v5.3.0-nikque.4`、libedax：[Edax 4.5.5 nikque.10](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.10)（[修正一覧](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/RELEASE-NOTES.ja.md#v455-nikque10)）。

**変更**

- libedax と `config.ini` を Edax 4.5.5 nikque.10 のものにしました。
- `fix`（`book fix`）：大きな book で、Link の張り直しが速くなりました（6億6162万局面の book・32 スレッドで 153.7 秒 → 136.3 秒。Edax 本体での計測）。
- `[relativeError absoluteError]`（`book deviate`）：level 18 以下で、1 周の展開の対象が多いとき（`n-tasks` の 32 倍以上。32 スレッドなら 1,024 件以上）は、1 スレッドの探索を `n-tasks` 個同時に動かします（これまでは 2 スレッドの探索を半分の数）。649万局面の book・32 スレッドで、60 秒に展開できる件数が約 1.25 倍になりました（Edax 本体での計測）。対象の少ない周は変わりません。

**不具合の修正**

- libedax の不具合を直しました。edax_runner の学習には影響しません。
  - 80 手（着手＋パス）を超える対局で、記録の外に書き込んでいました。
  - 文字列の設定を設定し直すたびに、前の文字列が解放されませんでした。
  - `edax_bench` の途中の `edax_stop` で、ベンチマークが終わりませんでした。

**互換性**

- `fix` でできる book は同じです。
- `[relativeError absoluteError]` でできる book は、これまでの `book-expand-tasks = auto` と少し違います（[Edax の修正一覧 nikque.10](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/RELEASE-NOTES.ja.md#v455-nikque10) を参照）。以前の決め方にするには、`config.ini` に `book-expand-tasks = 16`（`n-tasks` の半分）と書きます。

---

## 5.3.0+nikque.3

book の保存に失敗したときや、メモリが足りないときに、学習していない行を学習リストから消さないようにしました。Edax 4.5.5 nikque.8 の総点検で見つかった不具合も直しています。タグは `v5.3.0-nikque.3`、libedax：[Edax 4.5.5 nikque.9](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.9)（[修正一覧](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/RELEASE-NOTES.ja.md#v455-nikque9)）。

**変更**

- libedax と `config.ini` を Edax 4.5.5 nikque.9 のものにしました。
- 多数の棋譜をまとめて学習するのが少し速くなりました。早く終わった対局のスレッドを、まだ対局している探索に足します（level 18 の棋譜 128 本・32 スレッドで 33.6 秒 → 30.3 秒。Edax 本体での計測。メモリは同じ）。
- 同時に行う探索のメモリが確保できないとき、終了せずに、同時に行う探索を減らして続けます。
- 学習のたびに edax が book を `data/book.dat.store` に保存するのをやめました（Edax 4.5.5 nikque.9 の新しい設定 `book-store-auto-save` を、edax_runner が off にします）。直後に edax_runner が `book.dat` を保存するので、book 全体が 2 回書かれていました。
- 開発・配布まわり：
  - `scripts/build_edax_runner.sh` は、途中のコマンドが失敗したら止まります（ライブラリのコピーに失敗しても、最後まで進んで成功として終わっていました）。
  - `Create Release` は、その版のタグがすでにあるときは止まります（同じ版でもう一度動かすと、公開ずみの Release のファイルが置き換わっていました）。
  - プルリクエストに自動でラベルを付けるワークフロー（`labeling_pr.yaml`、`.github/labeler.yml`）を消しました（この fork では使いません）。
  - テストを追加しました：学習中に `learning_list.txt` を書き換えた場合（同じ行が複数ある、行が挿入された・移動された・消された）。

**不具合の修正**

- `book.dat` を保存できなかったとき（ほかのプログラムが `book.dat` を開いている、など）に、それに気づかず、学習した行を `learning_list.txt` から消していました。そのまま終わると、その学習は `book.dat` に残りませんでした。→ book を別のファイル（`data/book.dat.saving`）に保存させ、保存できたことを確かめてから（libedax に足した、成否を返す関数 `edax_book_save_checked` と、ファイルの確認）`book.dat` と置き換えます。保存できないときは 1 秒おきに 30 回までやり直し、それでも保存できなければ、`learning_list.txt` を変えずに止まります。
- 同時に学習した棋譜の局面を book に追加できなかったとき（メモリ不足）も、学習済みとして行を消していました。→ `learning_list.txt` を変えずに止まります（Edax 4.5.5 nikque.9 の libedax が失敗を知らせます）。1 局ずつの学習、`[relativeError absoluteError]`、`fix` で局面を追加できなかったときも同じです（libedax に足した関数 `edax_book_failed`）。
- 複数スレッドの探索で、手が探索されないままになるノードができることがありました（結果を誤ることはまれ。元の Edax 4.5.5 からある不具合）。
- `learning_list.txt` の行が、手の間の空白のために 255 バイトを超えると、短い手順として学習されることがありました。
- 起動時に読めなかった book ファイル（壊れている、ほかのプログラムが開いている）が、学習の後で上書きされていました。→ `book.dat.damaged` として残します。
- 複数の棋譜を同時に学習するとき（`book-store-tasks` が 2 以上）、`book-randomness` が 128 以上の行（例：`200,F5F6`）が、学習されずに `skipped (illegal move)` と記録されていました。→ ほかの棋譜と一緒に学習します。
- `[relativeError absoluteError]` の数字が 2147483647 より大きいと、別の数字として edax に渡っていました（例：4294967296 は 0）。→ `too large number` として飛ばします。
- 飛ばした行の最後のバイトが 0x85・0xA0 のとき（Shift_JIS の「あ」など）、`learned_log.txt` に記録するときにそのバイトが落ちていました。

**互換性**

- 1 スレッドの探索は変わりません。
- まとめて学習するとき、組の終わりのほうの対局の手は、実行ごとに変わることがあります。
- `data/book.dat.store` は作られなくなります。
- `book-randomness` が 128 以上の行：Edax 4.5.5 nikque.9 の libedax には上限がありません。それより前の libedax では、1 局ずつ学習します（`book-store-tasks = 1` のときと同じ）。

**注意**：起動時に読めなかった `data/book.dat` は、この版から 5.3.0+nikque.9 まで、学習した book で置き換えられていました（`data/book.dat.saving` から名前を変えるため）。5.3.0+nikque.10 で直しました。

---

## 5.3.0+nikque.2

既定の `book-store-tasks = auto` が、`1` より遅くなる場合があった問題を直しました。タグは `v5.3.0-nikque.2`、libedax：[Edax 4.5.5 nikque.8](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.8)（[修正一覧](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/RELEASE-NOTES.ja.md#v455-nikque8)）。

**変更**

- libedax と `config.ini` を Edax 4.5.5 nikque.8 のものにしました。
- level 18 の棋譜 128 本（論理 CPU 32）：37〜39 秒 → 35〜36 秒。

**不具合の修正**

- `book-store-tasks = auto`（既定）のとき、探索する局面が少ない場合や level が高い場合に、`1` より遅くなっていました（1 局の学習が、level 24 で 13 秒のところ 26 秒、level 21 で 4.2 秒のところ 6.4 秒）。→ 同時に行う探索の間でスレッドを分け合うようにし、level 24 で 6〜11 秒、level 21 で 2.0 秒になりました。level 18 で 1 局ずつ 30 局の学習は、29 秒から 18 秒になりました（`1` では 35 秒）。（edax のコマンドで測った値です）

**互換性**：この版の記録には書いていません。Edax 側の互換性は [Edax の修正一覧 nikque.8](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/RELEASE-NOTES.ja.md#v455-nikque8) にあります。

---

## 5.3.0+nikque.1

この fork の最初の版です（元は [sensuikan1973/edax_runner](https://github.com/sensuikan1973/edax_runner) の 5.3.0）。edax を Edax 4.5.5 (nikque) に替え、複数の棋譜を同時に学習できるようにし、学習リストの扱いの不具合を直しました。タグは `v5.3.0-nikque.1`、libedax：[Edax 4.5.5 (nikque)](https://github.com/Nikque/edax-reversi-AVX)。

**変更**

- edax を、Edax 4.4 から Edax 4.5.5 (nikque) に替えました。
- libedax を CPU の世代ごと（x86-64 共通、AVX2、AVX-512）にビルドし、edax_runner が、CPU が動かせる中で最も速いものを使うようにしました（Windows、Linux）。
- 設定を、`edax.ini` から Edax 4.5.5 (nikque) の `config.ini` に替えました。
- `config.ini` の `book-store-tasks` で、複数の棋譜を同時に学習するようにしました（既定の `auto` は `n-tasks` と同じ数。`1` は従来どおり 1 局ずつ）。
  - `learning_list.txt` の次の「Edax 対 Edax」の行を `book-store-tasks` の数まで同時に対局し、その局面を同時に探索して book に入れます（libedax の `edax_book_store_games` を `dart:ffi` で呼びます）。
  - `learning_list.txt` と `learned_log.txt` は、その組につき 1 回更新します。
- `[0 0]F5F6`、`[ 0 0 ] F5F6`、`2, F5F6` のような書き方を受け付けるようにしました。
- `learning_list.txt` が作業フォルダーにないときは、実行ファイルのあるフォルダーを使うようにしました。
- `learning_list.txt` の処理を速くし、メモリも少なくしました（バイト列のまま扱い、1 行学習するごとに 1 回だけ読みます）。

**不具合の修正**

- `learning_list.txt` に空行があると edax_runner が止まっていました。→ 無視します。
- 学習できない行（書式が違う、打てない手がある）が、学習済みとして消されていました。edax は打てない手とその後の手を無視するので、意図しない局面から学習していました。→ 警告を出して飛ばし、`learned_log.txt` にコメントとして記録します。
- `learning_list.txt` に UTF-8 でないコメント（Shift_JIS など）があると、edax_runner が異常終了していました。
- `learning_list.txt` の改行コード（CRLF）が LF に書き換えられていました。
- 学習中に `learning_list.txt` を書き換えると、学習した行ではない別の行が消されていました。
- `fix` の直後に book が保存されていませんでした。
- `exit` が `learning_list.txt` から消えないので、書き換えないと edax_runner を再開できませんでした。
- 保存中に edax_runner を強制終了すると、`book.dat` や `learning_list.txt` が壊れることがありました。→ 別のファイルに保存してから置き換えます（`book.dat` は edax が行います）。

**互換性**

- libedax の関数は元のものと同じです。
- `edax.ini` も読みますが、`config.ini` が優先です。
- 既定の `book-store-tasks = auto` では、複数の棋譜を同時に学習します。従来どおり 1 局ずつにするには `1` にします。
