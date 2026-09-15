# ISUCON13 PHP練習の参考資料集

確認日: 2026-09-16。公式仕様と、実際に参加した本人の記事を中心に選定した。記事中のスコアは当時の構成での結果であり、今回のDocker/AWS構成の目標点にはしない。

## 読む順番

最初に **R1 → R3 → R4** を読む。R2の具体的な解法は、自分でログを取って仮説を立ててから該当箇所を読むと練習になる。DNSで困ったらR6・R7を追加する。全記事を読み終えるまで実装を始めない、という進め方にはしない。

| ID | 資料 | 種別・対象 | 今回の練習で拾う点 |
|---|---|---|---|
| R1 | [ISUPipe アプリケーションマニュアル](https://github.com/isucon/isucon13/blob/main/docs/isupipe.md)・[当日マニュアル](https://github.com/isucon/isucon13/blob/main/docs/cautionary_note.md) | 公式・全言語 | 変更してよい範囲、アイコン更新、DNS、初期化。最適化の前に仕様を確認する |
| R2 | [ISUCON13 問題の解説と講評](https://isucon.net/archives/58001272.html)（2023-11-30、追記あり） | 公式解説 | インデックス、アイコン、N+1、DNSを俯瞰する。提示された解法を、自分のログと照らし合わせる |
| R3 | [ISUCON13 初参加 やったことまとめ](https://zenn.dev/sakojun/articles/20231212-isucon13)（2023-12-12） | ご指定の記事・インフラ/DB担当の参加記 | 計測・解析・改善・再計測の流れと準備。DB分離やDNSで詰まった経験から、疎通の切り分けを学ぶ |
| R4 | [ISUCON13、メンタイココアの思い出](https://asumikam.com/entry/2023/11/26/001508)（2023-11-26） | **PHPで参加した本人の記事** | PHPのLivecomment/ReactionのN+1、配信検索、統計クエリという具体的な改善対象。今回のコードへ対応付けやすい |
| R5 | [ISUCON13 に初参加した (49位、35,524点)](https://fohte.net/blog/posts/2023-11-29-isucon13)（2023-11-29） | 参加記・準備と改善の時系列 | 計測基盤、N+1、アイコン配信の取り組み。外部APMの料金も振り返っており、個人練習では無料のログ解析から始める判断材料になる |
| R6 | [ISUCON 13 参加記 (白金動物園)](https://diary.sorah.jp/2023/11/28/isucon13)（2023-11-28） | 経験者の参加記・DNS発展編 | DNSサーバーを変える判断と登録処理の待ち時間。PowerDNSの置換を最初の必須課題にはせず、改善の副作用も読む |
| R7 | [isucon13に参加しました](https://www.saity.dev/posts/isucon13_result/) | 参加記・練習と振り返り | SSH、ベンチ、ログ、Git運用を予行練習する意義。HTTP/SQLだけでなくDNSを見る視点を補う |
| R8 | [matsuu/aws-isucon: isucon13](https://github.com/matsuu/aws-isucon/tree/main/isucon13) | AWS構築用README・Packer | AMIを使う場合の代案。ドメインが `.u.isucon.local` に変更されている点に注意。現在のComposeへ手順をそのまま混ぜない |
| R9 | [alp: Access Log Profiler](https://github.com/tkuchiki/alp) | ツール作者のREADME | nginxのログ形式、URLの集約、総時間・平均・分位点の比較。導入時点のREADMEに合わせる |
| R10 | [pt-query-digest](https://docs.percona.com/percona-toolkit/pt-query-digest.html) | Percona公式マニュアル | MySQL slow logの集計。頻度と合計負荷から、改善するSQLを選ぶ |

記事はそれぞれの担当範囲と当日の状況を反映した一次体験談。特定の変更が全環境で同じ効果を出すことを示す比較実験ではない。Goや他言語の記事は、コードを移植するよりSQLと処理構造の考え方をPHPへ適用する。

## AWSの費用と運用を確認する資料

| 資料 | 確認すること |
|---|---|
| [EC2 On-Demand料金](https://aws.amazon.com/ec2/pricing/on-demand/)・[Pricing Calculator](https://calculator.aws/) | 東京、Linux、インスタンスタイプ、稼働時間。ロードマップの仮単価を作成直前に置き換える |
| [EBS料金](https://aws.amazon.com/ebs/pricing/) | gp3の容量と保持期間、追加IOPS/スループット、snapshot |
| [VPC料金](https://aws.amazon.com/vpc/pricing/) | public IPv4は使用中・未使用とも課金対象。確認時点で$0.005/IP-h |
| [EC2インスタンスの状態と課金](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-lifecycle.html) | stoppedでもEBS等の料金は残ること |
| [AWS Budgets](https://docs.aws.amazon.com/cost-management/latest/userguide/budgets-managing-costs.html) | 予算通知と更新の遅延。通知と強制停止は別に設計する |
| [Spot Instance interruptions](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-interruptions.html) | 割引と引き換えに中断がある。再現できる環境を先に作る |
| [T系Unlimited mode](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/burstable-performance-instances-unlimited-mode.html) | CPU高負荷時の追加課金とクレジット。安い時間単価だけで選ばない |

## 読書を実験につなげるメモ

各記事から拾う内容は3つまでに絞る。

1. 自分の計測結果と一致する問題は何か。
2. PHPのどの関数/SQL/設定に対応するか。
3. 変更後の正しさと改善効果をどう確かめるか。

記入したら [練習記録テンプレート](practice-log-template.md) へ移し、1件ずつ試す。実行する日程は [2週間ロードマップ](practice-roadmap.md) を参照。
