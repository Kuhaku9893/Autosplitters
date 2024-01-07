# DonutDodo.asl


## 主な機能

Donut Dodo用のAutoplitterです。

カテゴリはSugar Rush SpeedrunとAll Difficultiesに対応しており、Settingsにてモードの切り替えを行います。

### Sugar Rush Speedrun
|自動操作|説明|
|:--|:--|
|自動スタート|IGTがカウント開始した瞬間|
|自動リセット|IGTがリセットされた瞬間|
|自動ラップ|ステージが切り替わった瞬間<br>ネームエントリorゲームオーバー画面になった瞬間|

### All Difficulties
|自動操作|説明|
|:--|:--|
|自動スタート|IGTがリセットされた瞬間<br>ゲーム起動直後などIGTが0の状態だと反応しません|
|自動リセット|IGTがリセットされた瞬間<br>ステージ5でのみ手動でリセットしてください|
|自動ラップ|ステージが切り替わった瞬間<br>ステージ5でのみIGTがリセットされた瞬間<br>タイマーストップは手動で行ってください|


### 設定項目
All Difficulties Modeのチェック
- OFF：Sugar Rush Speedrunモードで動作します。
- ON ：All Difficultiesモードで動作します。


### 対応バージョン
- ver1.39


## aslの使用方法

1. Splits EditorのTitleに「Donut Dodo」と入力します。
1. Activateボタンを押します。

LivesplitにIGTを表示するには、LivesplitのTiming Method設定をGame Timeにする必要があります。

Autosplitter起動時にLivesplitのTiming Method設定がReal Timeだったら、Game Timeに変更するためのダイアログを表示します。
Game Timeに変更したい場合は「はい」を選択してください。


## 既知の不具合・仕様

現状では大きなドーナツを取得した瞬間を検知することができません。<br>
そのため、ステージクリアが確定してから自動ラップ・自動ストップまでに時間差があります。

All Difficultiesモードの仕様
- ゲーム起動直後など、IGTがすでに0の状態では自動スタートは反応しません。
- ステージ5をクリアしてタイトルに戻っても計測を継続する都合上、ステージ5でのみ自動リセットはできないため、ステージ5でのみ手動でリセットしてください。
- タイマーストップは手動で行ってください。


## 連絡先

ブログ：https://soushinsoujin989.blogspot.com/ <br>
Twitter：https://twitter.com/Kuhaku81377446

不具合報告、改善要望などありましたらこちらの連絡先までお願いします。<br>
ただし、不具合や改善に対応する・できるとは限らないことをご了承ください。


## 著作権と利用について

- 本aslの製作者はKuhaku_玖白であり、著作権は製作者にあります。
- 本aslはフリーソフトです。
- 本aslの利用により何らかの損害等が発生しても製作者は責任を負いません。
- 表示テキストの変更など、本aslを自己責任にて改造していただいてもかまいません。
- また、常識の範囲内であれば改造版aslの配布を制限しません。
- ただし改造版aslの配布を行う際は、本aslを元にした改造版であることを明示してください。
