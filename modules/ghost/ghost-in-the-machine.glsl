// ============================================================================
//  ghost-in-the-machine.glsl — Pi lifecycle face for Ghostty
//
//  Draws an animated ASCII-dot face behind terminal content. The package
//  generates one forced-state variant for idle, thinking, working, done, and
//  error. Ghostty selects them through a reloaded custom-shader config path.
//
//  Derived from https://github.com/isoden/claude-terminal-face (MIT).
//  See ../README.md, ../NOTICE, and ../LICENSE for attribution.
// ============================================================================

// ---- tunables --------------------------------------------------------------
// CELL: 顔を描く仮想 ASCII セル（px）。実際の端末セルより細かい 8×17 grid を
// 使い、小さい sidebar face でも目・口・状態 decoration の形を保つ。
const vec2  CELL      = vec2(8.0, 17.0);
const float FACE_SIZE = 0.126;             // 画面高に対する比（旧 0.14 から 10% 縮小）
const float FACE_Y_FROM_TOP = 0.40;         // 顔中心の上端からの位置（画面高比）
const float FACE_LEFT_GAP = 0.001;          // 最も左の描画点と画面左端の最小距離（画面幅比）
const float FACE_BOUND_X = 1.25;            // drift/decorations 込みの顔空間左半径
const float SIDEBAR_COLS = 29.0;            // herdr 展開サイドバーの幅（列）
const float SIDEBAR_CELL_WIDTH = 16.0;      // sidebar 配置用の実セル幅（dense grid とは独立）
const vec3  FACE_COL  = vec3(0.36, 0.88, 0.79); // 通常時の顔色（idle パレットアンカーも兼ねる）
const vec3  ERR_COL   = vec3(0.95, 0.36, 0.42); // 失敗時の顔色（err パレットアンカーも兼ねる）
const vec3  THINK_COL = vec3(0.94, 0.76, 0.29); // 考える顔（調査/プランニング中）
const vec3  WORK_COL  = vec3(0.24, 0.44, 0.88); // 集中顔（実装中）
const vec3  DONE_COL  = vec3(0.55, 0.83, 0.28); // ドヤ顔（完了）
const float GAIN      = 0.30;              // 明るさ。上げすぎると本文が読みにくい
const float GAZE      = 0.07;              // 視線追従の強さ（0 で固定）
const float IDLE_AT   = 4.0;               // SMILE → IDLE (秒)
const float SLEEP_AT  = 22.0;              // IDLE → SLEEP (秒)
const float ERR_EASE  = 0.35;              // 表情が崩れるまでの時間 (秒)
const float CURSOR_Y_FLIP = 1.0;           // 視線が上下逆なら -1.0
const float NOISE     = 0.05;
// -1 = OSC cursor-color auto detection; 0..4 = idle/think/work/done/err.
// scripts/generate-variants.sh replaces this exact line for Pi path-swap variants.
const int FORCED_STATE = -1;
// ---- legacy OSC state palette tuning ---------------------------------------
// 2026-07-12: 5色パレット（idle/think/work/done/err）間の最小ペア距離二乗は
// 約 0.16（THINK_COL - DONE_COL 間）。STATE_GATE_HI はこれより十分小さい値
// にして、パレット間の通常の遷移中に誤って idle へフォールバックしないよう
// にする。spec.md §9 参照。
const float STATE_SOFT    = 0.03;  // 状態境界のシャープさ。小さいほど切替が急峻
const float STATE_GATE_LO = 0.02;  // 5色いずれからも遠い→idleへフォールバック開始（距離二乗）
const float STATE_GATE_HI = 0.08;  // 完全に idle 側へ倒れる距離二乗
// 2026-07-12 実機検証: Ghostty の fragCoord.y は Shadertoy/OpenGL 規約（下原点・上向き正）
// と逆で、上原点・下向き正。想定と逆だと顔が丸ごと上下反転する（目と口が入れ替わる）。
// 1.0 = Ghostty の実際の挙動（上原点）。将来 Ghostty 側で規約が標準化された場合は
// 0.0 に切り替える。
const float TOPDOWN_Y  = 1.0;
// ----------------------------------------------------------------------------

const float EX = 0.46;
const float EY = -0.30;
const float TH = 0.052;

float luma(vec3 c) { return dot(c, vec3(0.2126, 0.7152, 0.0722)); }
float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float distSq(vec3 a, vec3 b) { vec3 d = a - b; return dot(d, d); }

// ---- SDF primitives --------------------------------------------------------
float sdBox(vec2 p, vec2 c, vec2 b, float r, float rot) {
    vec2 d = p - c;
    float s = sin(rot), co = cos(rot);
    d = vec2(d.x * co - d.y * s, d.x * s + d.y * co);
    vec2 q = abs(d) - b + r;
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

float sdCircle(vec2 p, vec2 c, float r) { return length(p - c) - r; }

float sdArc(vec2 p, vec2 c, float r, float th, float ac, float ap) {
    vec2 d = p - c;
    float len = length(d);
    float a = mod(atan(d.y, d.x) - ac + 3.14159265, 6.28318531) - 3.14159265;
    if (abs(a) <= ap) return abs(len - r) - th;
    vec2 e = c + vec2(cos(ac + ap), sin(ac + ap)) * r;
    vec2 f = c + vec2(cos(ac - ap), sin(ac - ap)) * r;
    return min(length(p - e), length(p - f)) - th;
}

// SDF 距離 → 輝度（コア + 外向きブルーム）。spec.md §1.2 の式を関数化したもので、
// 顔本体（mainImage）と状態デコレーションが同じ質感になるよう共有する。
float fieldLum(float d) {
    return smoothstep(0.035, -0.015, d) + exp(-max(d, 0.0) * 9.0) * 0.45;
}

// ---- easing ----------------------------------------------------------------
// smoothstep（対称 ease-in-out）だけでは「慣性」や「弾み」が表現できないため、
// 意図に応じて使い分ける（2026-07-14 アニメーション磨き込みで導入）:
//   backOut   = 勢いよく立ち上がり、行き過ぎてから戻る（ポップ/フォロースルー）
//   backInOut = 出発時に一瞬逆へ沈み（アンティシペーション）、到着で行き過ぎて
//               戻る（オーバーシュート）。行き過ぎ量は移動量の約 10%（s=1.70158 時）
float backOut(float x, float s) {
    float u = x - 1.0;
    return 1.0 + (s + 1.0) * u * u * u + s * u * u;
}
float backInOut(float x, float s) {
    float k = s * 1.525;
    float u = 2.0 * x - 2.0;
    return x < 0.5
        ? 2.0 * x * x * ((k + 1.0) * 2.0 * x - k)
        : (u * u * ((k + 1.0) * u + k) + 2.0) * 0.5;
}

// ---- 生体モーション（浮遊・呼吸・視線）--------------------------------------
// 経緯:
//   2026-07-13 単純な上下呼吸では「浮遊感」が弱い → 多重 sin ドリフトへ増強。
//   2026-07-14 「ダイナミックさ」の要望でバンク傾き + 呼吸スケールを追加。
//   2026-07-14 「本当に生きているような動き」の要望で生体寄りに再設計:
//     - ドリフトを sin 合成 → 値ノイズへ。sin 合成は数分眺めると同じ軌道の
//       繰り返しが知覚されて機械に見える。ノイズは厳密な周期を持たない
//     - 呼吸を対称 sin → 「吸気は速く・呼気は遅く・休止あり」の非対称
//       サイクルへ（実在の安静呼吸のリズム）
//     - 自律サッカード（gazeWander）: 生体の目は静止しない

// 1D 値ノイズ（およそ -1..1、典型振幅は ±0.5 程度）。seed で独立な系列を作る。
float vnoise(float t, float seed) {
    float i = floor(t), f = fract(t);
    float u = f * f * (3.0 - 2.0 * f);
    return mix(hash(vec2(i, seed)), hash(vec2(i + 1.0, seed)), u) * 2.0 - 1.0;
}

// 顔全体のドリフト位置。低周波（大きな漂い）+ 高周波（微細な揺らぎ）の2オクターブ。
// t の純関数として切り出すのは、傾き計算（有限差分）から再利用するため
// （qmarkPos の lean と同じ手法）。振幅の上限は sin 版と同等に抑えてあり、
// 目(±0.46)や画面端との位置関係は従来の検証済み範囲に収まる。
vec2 faceDrift(float t) {
    return vec2(
        vnoise(t * 0.21, 1.7) * 0.055 + vnoise(t * 0.90, 4.2) * 0.013,
        vnoise(t * 0.26, 2.9) * 0.075 + vnoise(t * 1.10, 6.4) * 0.015
    );
}

// 呼吸フェーズ（0=呼気末 → 1=吸気末）。吸気(0〜0.32) → 息を止める(〜0.42) →
// ゆっくり呼気(〜0.86) → 休止(〜1.0)。等速 sin だと機械のポンプに見える。
float breathPhase(float t) {
    float f = fract(t / 3.6);
    return smoothstep(0.0, 0.32, f) - smoothstep(0.42, 0.86, f);
}

// 自律的な視線移動。数秒の固視ごとに次の注視点へ視線を移す。
// タイミングは区間ごとに hash で揺らす（blink と同じステートレス手法）。
// 2026-07-14: 当初は実際のサッカード（≈0.12s の高速跳躍 + backOut の
// オーバーシュート）を模したが、「目がガクンと動く」とのフィードバック。
// ASCII 格子では速い移動が複数セルの瞬間ジャンプに量子化されるため、
// 眼球のない記号的な目に高速眼球運動を持ち込むのは不適と判断。
// ≈0.5s の ease-in-out（行き過ぎなし）で「視線をゆっくり移す」動きに変更。
// 区間境界の連続性: 区間 i の終端は gazeTarget(i)、区間 i+1 の始端も
// gazeTarget((i+1)-1) = gazeTarget(i) なので跳ばない。
vec2 gazeTarget(float i) {
    return (vec2(hash(vec2(i, 3.7)), hash(vec2(i, 9.1))) - 0.5) * vec2(0.16, 0.10);
}
vec2 gazeWander(float t) {
    const float P = 2.3;  // 固視区間の長さ（秒）
    float i  = floor(t / P);
    float f  = fract(t / P);
    float at = 0.15 + hash(vec2(i, 5.3)) * 0.55;  // 区間内の移動開始タイミング
    float m  = smoothstep(at, at + 0.22, f);      // 0.22 * 2.3s ≈ 0.5s かけて移動
    // 第2項は固視微動: 固視中も完全静止させない。振幅 0.006 は目の
    // 半径(0.115)に対し十分小さく、ASCII 格子では輝度のゆらぎとして現れる。
    return mix(gazeTarget(i - 1.0), gazeTarget(i), m)
         + vec2(vnoise(t * 1.7, 12.3), vnoise(t * 1.9, 15.8)) * 0.006;
}

// ---- parts -----------------------------------------------------------------
float arcEye(vec2 p, float sx, vec2 g) {
    return sdArc(p, vec2(sx * EX + g.x, EY + 0.09 + g.y), 0.155, TH, -1.5707963, 1.15);
}
float slitEye(vec2 p, float sx, vec2 g, float rot) {  // 眉尻が下がった目
    return sdBox(p, vec2(sx * EX + g.x, EY + 0.03 + g.y), vec2(0.17, 0.035), 0.03, sx * rot);
}
float closedEye(vec2 p, float sx, vec2 g) {
    return sdBox(p, vec2(sx * EX + g.x, EY + 0.02 + g.y), vec2(0.16, 0.018), 0.018, 0.0);
}
float smileMouth(vec2 p, float w) {
    return sdArc(p, vec2(0.0, 0.05), w, TH, 1.5707963, 0.85);
}
float frownMouth(vec2 p, float w) {
    return sdArc(p, vec2(0.0, 0.78), w, TH, -1.5707963, 0.70);
}
float flatMouth(vec2 p) {
    return sdBox(p, vec2(0.02, 0.36), vec2(0.055, 0.02), 0.02, 0.0);
}

// ---- 5x5 疑似 ASCII フォント（bit index = row*5 + col, row 0 が上段）--------
int glyphBits(int i) {
    if (i == 1) return 4194304;   // .
    if (i == 2) return 131200;    // :
    if (i == 3) return 14336;     // -
    if (i == 4) return 145536;    // +
    if (i == 5) return 459200;    // =
    if (i == 6) return 342336;    // *
    if (i == 7) return 27070835;  // %
    if (i == 8) return 11512810;  // #
    if (i == 9) return 33084991;  // @
    return 0;
}
float glyphPixel(int bits, vec2 cellUV) {
    vec2 q = floor(cellUV * 5.0);
    if (q.x < 0.0 || q.x > 4.0 || q.y < 0.0 || q.y > 4.0) return 0.0;
    // TOPDOWN_Y=1: cellUV は fragCoord 由来で q.y=0 が画面の上段 → row 0 にそのまま対応。
    // TOPDOWN_Y=0（標準規約）: q.y=4 が画面の上段 → 反転して row 0 に対応させる。
    int row = TOPDOWN_Y > 0.5 ? int(q.y) : int(4.0 - q.y);
    int idx = row * 5 + int(q.x);
    return float((bits >> idx) & 1);
}

// ---- Claude Code 状態別の表情 ------------------------------------------
// idle/think/work/done の具体的な表情は後述のバリアントテーブル（*EyesVar /
// *MouthVar）が持つ。ここに残っているのは err（バリアント要件の対象外で単一
// 表情）と、done のキラキラが使うタイムライン定数のみ。
// 2026-07-14: 旧単一表情（丸目 idle / 上目遣い think / スリット work /
// 周期ウィンク done）は「既存パターンの焼き増しはやめて」との指摘があり、
// バリアント刷新時にプールから削除した。SMILE（打鍵反応）・まばたきの閉じ目・
// err は対象外で存続。
//
// DONE_*: 元は done のウィンクのタイムラインだったが、ウィンク廃止後も
// キラキラ（doneDecoLum）の「溜め → バースト → 消灯」のリズムとして存続。
// 値を変えるときは doneDecoLum の t1/t2 の組み立てを参照。
const float DONE_PERIOD   = 3.2;  // 1周期の長さ
const float DONE_CLOSE_AT = 0.35; // バースト前の溜め（旧: 閉じ始め）
const float DONE_CLOSE    = 0.14; // 溜めの長さ（旧: 閉じ時間）
const float DONE_HOLD     = 0.55; // バースト持続（旧: 閉じ保持）
const float DONE_OPEN     = 0.55; // 旧: 開き時間（現在はタイムライン互換のため残置）
float errEyes(vec2 p, vec2 g) {
    return min(slitEye(p, -1.0, g, -0.38), slitEye(p, 1.0, g, -0.38));
}
float errMouth(vec2 p) {
    return frownMouth(p, 0.26);
}

// ---- フェーズ内表情バリアント -----------------------------------------------
// 2026-07-14: 各フェーズ（idle/think/work/done）に 3 表情を持たせ、VAR_PERIOD
// ごとに hash で次の表情を選ぶ。完全ランダムで、連続して同じ表情が選ばれるのも
// 許容（ユーザー要件）。err は 1 表情のまま（要件外）。
// - 選択は iTime 基準: since 基準だと打鍵のたびに表情が切り替わってしまう
//   （デコレーション同様、打鍵に左右されない iTime 純関数のループにする）。
// - 区間先頭 VAR_MORPH の間、前区間の表情から SDF morph する（表情遷移 =
//   距離場の線形補間、という既存の流儀のまま。spec.md §7.1 の中間形の溶けは
//   同一フェーズ内の近い形状同士なので許容範囲）。
//
// パターン一覧と意図（2026-07-14 全面新規デザイン。当初は「従来表情 + 新規2種」
// で構成したが「既存パターンの焼き増しはやめて」との指摘を受け、3 種すべてを
// 新規に差し替え。従来の単一表情はプールから引退）:
//   idle（待機）    v0 半目+ぽかんと開いた小さな口 … まったり脱力
//                   v1 縦長楕円のよそ見目+口笛の「o」口 … 手持ち無沙汰に口笛
//                   v2 ∪∪目+「〜」の波線口   … 和んでとろける
//   think（思案）   v0 伏し目(浅い∪弧)+「へ」の口 … 視線を落として考え込む
//                   v1 同方向に傾いた細目+すぼめ口 … 「本当か?」と訝る
//                   v2 ○輪郭の見開き目+「お」のリング口 … ひらめき寸前に息を呑む
//   work（奮闘）    v0 片目つぶり+○スコープ目+横に引き結ぶ口 … 照準を合わせる職人
//                   v1 ＞＜目+厚く結んだ口   … 全力で食いしばる
//                   v2 縦バー目+小さな口     … ロボット的に無心で凝視
//   done（得意）    v0 ✦の星目+ω口          … 完了のきらめきを目に宿すしたり顔
//                   v1 太い∩∩の笑い目+開けた「▽」口 … 声を上げて大笑い
//                   v2 傾いた半目+片側スマーク口 … 「当然ですけど?」の得意顔
// 設計の共通ルール:
//   - 各フェーズの雰囲気（idle=穏やか/think=思案/work=奮闘/done=得意）から
//     外れない範囲で振れ幅を作る。フェーズ判別が表情バリアントで曖昧に
//     ならないよう、色とデコレーション（?/汗/キラキラ）は全バリアント共通。
//   - SMILE（打鍵直後の顔）はバリアント対象外: 入力への即時反応は毎回同じ
//     顔で返すほうが「反応した」ことが伝わる。
const float VAR_PERIOD = 7.0;   // 1 表情の保持時間（秒）
const float VAR_MORPH  = 0.09;  // 区間頭の morph 割合（≈0.63s）

float pickVar(float i, float seed) { return floor(hash(vec2(i, seed)) * 3.0); }

// -- バリアント用の新パーツ --
float sdRing(vec2 p, vec2 c, float r, float th) { return abs(length(p - c) - r) - th; }

// 4 方向スパーク（✦）。細長いボックス 2 本の直交クロス。done の星目と
// デコレーション（sparkLum）で共用するため、デコ節ではなくここに置く。
float sdSparkle(vec2 p, vec2 c, float s, float rot) {
    vec2 d = p - c;
    float sn = sin(rot), cs = cos(rot);
    d = vec2(d.x * cs - d.y * sn, d.x * sn + d.y * cs);
    float arm = s * 0.20;
    return min(sdBox(d, vec2(0.0), vec2(s, arm), arm, 0.0),
               sdBox(d, vec2(0.0), vec2(arm, s), arm, 0.0));
}

float cupEye(vec2 p, float sx, vec2 g) {  // ∪（和み目）。arcEye(∩) の上下反転版
    // 開口 1.45(>arcEye の 1.15): ∪ は底が水平に量子化されて「閉じ目」に見えやすい。
    // 端の跳ね上がりを 1 セル分以上確保して ∪ と読めるようにする（2026-07-14 プレビュー確認）
    return sdArc(p, vec2(sx * EX + g.x, EY - 0.04 + g.y), 0.155, TH, 1.5707963, 1.45);
}
float halfLidEye(vec2 p, float sx, vec2 g, float r, float tilt) {  // 半目（上まぶたで水平カット）
    vec2 q = p - vec2(sx * EX + g.x, EY + 0.02 + g.y);
    float s = sin(tilt * sx), co = cos(tilt * sx);  // sx を掛けて左右対称の傾きにする
    q = vec2(q.x * co - q.y * s, q.x * s + q.y * co);
    float d = sdBox(q, vec2(0.0), vec2(r, r), r * 0.8, 0.0);
    return max(d, -0.012 - q.y);  // q.y > -0.012（下半分）だけ残す = SDF の交差
}
float ovalEye(vec2 p, float sx, vec2 g) {  // 縦長の楕円目
    return sdBox(p, vec2(sx * EX + g.x, EY + g.y), vec2(0.072, 0.118), 0.065, 0.0);
}
float downcastEye(vec2 p, float sx, vec2 g) {  // 伏し目（浅い∪弧。視線を落とす）
    // cupEye（深い∪=和み）と区別するため、半径を大きく開口を狭くして平たい弧にする
    return sdArc(p, vec2(sx * EX + g.x, EY - 0.20 + g.y), 0.22, TH * 0.9, 1.5707963, 0.62);
}
float ringEye(vec2 p, float sx, vec2 g, float r) {  // ○の輪郭目（見開き / スコープ）
    return sdRing(p, vec2(sx * EX + g.x, EY + g.y), r, 0.038);
}
float dotMouth(vec2 p) {  // ぽかんと小さく開いた口
    return sdCircle(p, vec2(0.0, 0.385), 0.05);
}
float waveMouth(vec2 p) {  // 「〜」（左が山∩・右が谷∪の連続弧。脱力）
    float a = sdArc(p, vec2(-0.085, 0.455), 0.095, TH * 0.85, -1.5707963, 1.1);
    float b = sdArc(p, vec2( 0.085, 0.305), 0.095, TH * 0.85,  1.5707963, 1.1);
    return min(a, b);
}
float chevMouth(vec2 p) {  // 「へ」（口を結んで考え込む）
    float a = sdBox(p, vec2(-0.075, 0.39), vec2(0.08, 0.02), 0.02,  0.30);
    float b = sdBox(p, vec2( 0.075, 0.39), vec2(0.08, 0.02), 0.02, -0.30);
    return min(a, b);
}
float omegaMouth(vec2 p) {  // ω（したり顔の猫口。∪弧を2つ並べる）
    float a = sdArc(p, vec2(-0.10, 0.32), 0.10, TH * 0.9, 1.5707963, 1.2);
    float b = sdArc(p, vec2( 0.10, 0.32), 0.10, TH * 0.9, 1.5707963, 1.2);
    return min(a, b);
}
float tiltEye(vec2 p, float sx, vec2 g, float rot) {  // 左右とも同方向へ傾く（訝しげ）。
    // slitEye は sx*rot でミラーするのに対し、こちらは同符号で「片眉を上げた」非対称感を出す
    return sdBox(p, vec2(sx * EX + g.x, EY + 0.03 + g.y), vec2(0.16, 0.032), 0.03, rot);
}
float sqzEye(vec2 p, float sx, vec2 g) {  // ＞＜（ぎゅっと閉じた目）
    vec2 q = p - vec2(sx * EX + g.x, EY + g.y);
    q.x *= sx;  // 頂点が鼻側を向くよう左右をミラー
    // 上下バーの間隔 0.07 / 傾き 0.62: これより詰める・寝かせると ASCII 格子上で
    // 2 本が繋がり団子に見える（2026-07-14 プレビュー確認）
    float a = sdBox(q, vec2(0.0, -0.07), vec2(0.10, 0.024), 0.024, 0.62);
    float b = sdBox(q, vec2(0.0,  0.07), vec2(0.10, 0.024), 0.024, -0.62);
    return min(a, b);
}
float barEye(vec2 p, float sx, vec2 g) {  // 縦バー（ロボット的な凝視）
    return sdBox(p, vec2(sx * EX + g.x, EY + g.y), vec2(0.038, 0.125), 0.035, 0.0);
}
float laughMouth(vec2 p) {  // 下半円の塗り潰し ▽（口を開けた笑い）
    float d = sdCircle(p, vec2(0.0, 0.26), 0.21);
    return max(d, 0.26 - p.y);  // 円の上半分をカット（max = SDF の交差）
}

// -- 各フェーズの表情テーブル（2026-07-14 全 12 表情を新規デザイン）--
float idleEyesVar(vec2 p, vec2 g, float v) {
    if (v < 0.5) return min(halfLidEye(p, -1.0, g, 0.12, 0.0), halfLidEye(p, 1.0, g, 0.12, 0.0));
    if (v < 1.5) {  // よそ見: 視線が斜め上へ逸れる
        vec2 gw = g + vec2(-0.06, -0.05);
        return min(ovalEye(p, -1.0, gw), ovalEye(p, 1.0, gw));
    }
    return min(cupEye(p, -1.0, g), cupEye(p, 1.0, g));  // ∪∪ 和み
}
float idleMouthVar(vec2 p, float v) {
    if (v < 0.5) return dotMouth(p);
    // リング径は「穴」が最低 1〜2 セル残るサイズにする。小さいと塗り潰れて
    // ただの点になり「o」と読めない（2026-07-14 プレビュー確認）
    if (v < 1.5) return sdRing(p, vec2(0.06, 0.37), 0.095, 0.040);  // 口笛の「o」
    return waveMouth(p);
}
float thinkEyesVar(vec2 p, vec2 g, float v) {
    if (v < 0.5) return min(downcastEye(p, -1.0, g), downcastEye(p, 1.0, g));     // 伏し目
    if (v < 1.5) return min(tiltEye(p, -1.0, g, 0.22), tiltEye(p, 1.0, g, 0.22)); // 訝しげ
    return min(ringEye(p, -1.0, g, 0.115), ringEye(p, 1.0, g, 0.115));            // ○見開き
}
float thinkMouthVar(vec2 p, float v) {
    if (v < 0.5) return chevMouth(p);
    if (v < 1.5) return sdBox(p, vec2(-0.10, 0.42), vec2(0.06, 0.02), 0.02, 0.18);  // 口をすぼめて横へ
    return sdRing(p, vec2(0.0, 0.40), 0.080, 0.038);  // 「お」と息を呑む（穴を残す径。上と同根拠）
}
float workEyesVar(vec2 p, vec2 g, float v) {
    if (v < 0.5) {  // 照準: 片目を閉じ、開いた方は○スコープで狙う
        float l = sdBox(p, vec2(-EX + g.x, EY + 0.02 + g.y), vec2(0.145, 0.022), 0.022, 0.10);
        return min(l, ringEye(p, 1.0, g, 0.115));
    }
    if (v < 1.5) return min(sqzEye(p, -1.0, g), sqzEye(p, 1.0, g));  // ＞＜ 食いしばり
    return min(barEye(p, -1.0, g), barEye(p, 1.0, g));               // 縦バー凝視
}
float workMouthVar(vec2 p, float v) {
    if (v < 0.5) return sdBox(p, vec2(0.10, 0.40), vec2(0.06, 0.022), 0.022, 0.12); // 横へ引き結ぶ
    if (v < 1.5) return sdBox(p, vec2(0.0, 0.40), vec2(0.13, 0.048), 0.035, 0.0);   // 厚く結ぶ
    return sdBox(p, vec2(0.0, 0.38), vec2(0.055, 0.016), 0.016, 0.0);               // 小さく結ぶ
}
float doneEyesVar(vec2 p, vec2 g, float t, float v) {
    if (v < 0.5) {  // 星目: きらめきの傾きがゆっくり揺れる
        float r1 = sin(t * 2.1) * 0.25, r2 = sin(t * 2.1 + 1.1) * 0.25;
        return min(sdSparkle(p, vec2(-EX + g.x, EY + g.y), 0.15, r1),
                   sdSparkle(p, vec2( EX + g.x, EY + g.y), 0.15, r2));
    }
    if (v < 1.5) {  // 大笑い: arcEye より太く大きい∩∩（ぎゅっと閉じた笑い目）
        return min(sdArc(p, vec2(-EX + g.x, EY + 0.10 + g.y), 0.175, 0.066, -1.5707963, 1.3),
                   sdArc(p, vec2( EX + g.x, EY + 0.10 + g.y), 0.175, 0.066, -1.5707963, 1.3));
    }
    return min(halfLidEye(p, -1.0, g, 0.115, 0.18), halfLidEye(p, 1.0, g, 0.115, 0.18)); // ドヤ半目
}
float doneMouthVar(vec2 p, float v) {
    if (v < 0.5) return omegaMouth(p);
    if (v < 1.5) return laughMouth(p);
    return sdArc(p, vec2(0.10, 0.06), 0.34, TH, 1.75, 0.55);  // 片側の上がったスマーク
}

// ---- 状態デコレーション（頭上の「?」/ 飛び散る汗 / 完了のキラキラ）----------
// 顔本体と違い「出現・消滅」を伴うため、faceField() の SDF 重み付き合成には
// 混ぜない。距離の重み付き平均は重みが小さいときに形が溶けて残留する
// （spec.md §7.1 と同根の問題）ので、各デコレーションは自前で輝度
// （fieldLum）まで計算し、mainImage 側で状態重みを掛けて輝度に加算する。
// ステートレス制約のため、アニメーションはすべて iTime の純関数
// （fract/mod ベースのループ）で表現する。

// 「?」グリフ。単位空間（フック円の中心が原点、y 下向き正、全高 ≈ 1.2）。
// フック弧は 左(-π) → 上 → 右 → 下(π/2) を覆い、左下 1/4 が開く。
float sdQuestion(vec2 p) {
    // ストロークを細く(0.085)保ってフック内側の「穴」を残す。太いと ASCII
    // 解像度で塗り潰れて「?」に読めなくなる（2026-07-14 プレビューで確認）。
    float d = sdArc(p, vec2(0.0), 0.30, 0.085, -0.7854, 2.3562);
    d = min(d, sdBox(p, vec2(0.0, 0.42), vec2(0.065, 0.075), 0.055, 0.0)); // 縦棒
    d = min(d, sdCircle(p, vec2(0.0, 0.68), 0.095));                       // 点
    return d;
}

// thinking: 頭上に「?」を浮かべ、一定周期で左右にスライドさせる。
// 各周期の前半 35% で反対側へ移動し、残りは静止して上下に揺れる。
const float QM_PERIOD = 2.8;   // 左右スライドの周期（秒）
const float QM_MOVE   = 0.35;  // 周期のうち移動に使う割合
// 静止位置の振幅（顔空間）。backInOut の沈み込み/行き過ぎ（移動量の約10%）込みで
// 最大到達 ≈ ±0.27 となり、目(±0.46)のブルームと重ならない従来の検証済み範囲に収まる。
const float QM_SWING  = 0.225;

// 「?」の中心位置。t の純関数として切り出し、傾き計算（有限差分）から再利用する。
// x: backInOut で「一瞬逆へ沈む（アンティシペーション）→ 滑り出す → 行き過ぎて
//    戻る（オーバーシュート）」。等速+対称イージングだと質量を感じない
//    （2026-07-14 アニメーション磨き込み）。
// y: 移動中に sin の弧で浮き上がる（直線移動はアークの原則に反する）。上方向
//    なので目との干渉リスクはない。静止中は小さな上下の漂い（bob）のみ。
vec2 qmarkPos(float t) {
    float side = mod(floor(t / QM_PERIOD), 2.0);
    float m    = clamp(fract(t / QM_PERIOD) / QM_MOVE, 0.0, 1.0);
    float pos  = mix(side, 1.0 - side, backInOut(m, 1.70158));
    float x    = mix(-QM_SWING, QM_SWING, pos);
    // y=-0.64: 点の下端が目の上端(-0.455)に食い込まない高さ。これ以上下げると
    // 静止位置で目とブルームが繋がって見える（2026-07-14 プレビューで確認）。
    float y    = -0.64 + sin(t * 2.3) * 0.015 - sin(3.14159265 * m) * 0.045;
    return vec2(x, y);
}

float thinkDecoLum(vec2 p, float t) {
    const float SCALE = 0.28; // 「?」の大きさ（単位空間 → 顔空間）
    vec2  c = qmarkPos(t);
    // 傾きは位置ではなく速度に比例させる（drag: 頭が動きに遅れてついてくる）。
    // 旧実装の位置比例は「静止中に最大傾斜・最速時に直立」という逆の見え方
    // だった（2026-07-14 修正）。有限差分 0.06s は移動時間(≈1s)より十分短い。
    float lean = clamp((c.x - qmarkPos(t - 0.06).x) * 4.5, -0.30, 0.30);
    vec2  q    = p - c;
    float s = sin(lean), co = cos(lean);
    q = vec2(q.x * co - q.y * s, q.x * s + q.y * co);
    return fieldLum(sdQuestion(q / SCALE) * SCALE);
}

// working: こめかみ付近から汗の粒が斜め上へ飛び散る（アニメ的な「ガンバり」記号）。
// 各粒のライフサイクルは fract(t/周期 + 位相) の 0→1。左右交互に 4 粒、
// 位相をずらして常にどれかが飛んでいる状態にする。
float workDecoLum(vec2 p, float t) {
    float lum = 0.0;
    for (int i = 0; i < 4; i++) {
        float fi   = float(i);
        float side = mod(fi, 2.0) < 0.5 ? -1.0 : 1.0;
        // 周期は粒ごとに変える: 全粒が同一周期(旧 0.95s)だと全体が 0.95s ごとに
        // 完全に同じパターンを繰り返し、機械的に見える（2026-07-14）。
        float period = 0.82 + fi * 0.11;
        float life = fract(t / period + fi * 0.37);
        vec2  from = vec2(side * 0.55, -0.42 + fi * 0.04);
        // dir.y は全粒とも上向き(-0.34 以上)にする: 水平に近いと目の高さを飛び、
        // 細目スリットの延長に見えてしまう（2026-07-14 プレビューで確認）。
        vec2  dir  = normalize(vec2(side, -0.70 + fi * 0.12));
        // 射出は減速カーブ（ease-out）: 初速最大で失速しつつ重力で垂れる。
        // 旧実装の等速直線だと粒が「置かれていく」ように見えた（2026-07-14）。
        float flight = 1.0 - (1.0 - life) * (1.0 - life);
        vec2  c    = from + dir * (0.06 + flight * 0.44);
        c.y += life * life * 0.14;
        // 速度ベクトル（上の軌道の life 微分）。尾は進行方向の真後ろに置き、
        // 長さも速度に比例させる（速いほど伸び、失速すると縮む = 疑似ストレッチ）。
        vec2  vel  = dir * (0.88 * (1.0 - life)) + vec2(0.0, 0.28 * life);
        float speed = length(vel);
        vec2  vhat = vel / speed;  // dir.x≠0 と重力項により vel は常に非ゼロ
        // 出現時はスケール 0 から瞬時に膨らませる（フェードのみより「弾け出た」感が出る）
        float r = 0.052 * (1.0 - life * 0.4) * smoothstep(0.0, 0.06, life);
        float d = min(sdCircle(p, c, r),
                      sdCircle(p, c - vhat * (0.03 + speed * 0.09), r * 0.5));
        float a = smoothstep(0.0, 0.08, life) * (1.0 - smoothstep(0.55, 0.9, life));
        lum += fieldLum(d) * a;
    }
    return lum;
}

// 1 粒のキラキラ（sdSparkle はバリアント節で定義 — done の星目と共用）。
// k = DONE_PERIOD 周期内の位相（mod(t, DONE_PERIOD)）。
// popAt でスケール 0 → backOut（約 10% 行き過ぎて戻る）で弾け出て、
// fadeAt から 0.25s かけて消える。ポップをアルファでなくスケールで行うのは、
// フェードだけだと「その場に滲み出る」ように見えて弾ける感じが出ないため
// （2026-07-14 アニメーション磨き込み）。
float sparkLum(vec2 p, vec2 c, float s, float ph, float t, float k, float popAt, float fadeAt) {
    float a = smoothstep(popAt, popAt + 0.08, k) * (1.0 - smoothstep(fadeAt, fadeAt + 0.25, k));
    if (a < 0.004) return 0.0;
    float pop = backOut(clamp((k - popAt) / 0.20, 0.0, 1.0), 1.70158);
    float tw  = 0.7 + 0.3 * sin(t * 7.0 + ph);  // またたき
    float rot = sin(t * 2.4 + ph) * 0.35;       // ゆらゆら傾く
    return fieldLum(sdSparkle(p, c, s * pop * (0.85 + 0.15 * tw), rot)) * a * tw;
}

// done: DONE_* タイムライン（旧ウィンクのリズム）に乗せて、右目の外側に
// キラキラを散らす。溜めのあと 0.13s 間隔で 1 → 2 → 3 個目がポップし、
// バースト終了で逆順（後から出たものが先）に消える。
// 旧実装はウィンク値の閾値で出現させていたが、周期位相ベースの時間差に変更
// （2026-07-14）。同日ウィンク表情自体は引退したが、このリズムは維持。
float doneDecoLum(vec2 p, float t) {
    float k  = mod(t, DONE_PERIOD);
    float t1 = DONE_CLOSE_AT + DONE_CLOSE; // 溜め明け = キラキラ開始
    float t2 = t1 + DONE_HOLD;             // バースト終了 = フェード開始
    if (k < t1 || k > t2 + 0.30 + 0.25) return 0.0;
    float lum = 0.0;
    // x は 0.85 以内に収める: 正方形に近いペインでも画面端で切れないように
    //（顔空間の横半幅は 0.5*aspect/0.62 で、正方形時 ≈ 0.81）。
    lum += sparkLum(p, vec2(0.76, -0.55), 0.100, 0.0, t, k, t1,        t2 + 0.30);
    lum += sparkLum(p, vec2(0.85, -0.20), 0.075, 2.1, t, k, t1 + 0.13, t2 + 0.15);
    lum += sparkLum(p, vec2(0.60, -0.73), 0.060, 4.2, t, k, t1 + 0.26, t2);
    return lum;
}

// ---- face ------------------------------------------------------------------
// wIdleS/wThinkS/wWorkS/wDoneS/wErrS はカーソル色から距離ベースで求めた
// lifecycle 状態の重み（合計 1）。idle バケットの中身だけは、従来通り
// 「打鍵からの経過秒」で smile/idle/sleep をさらにサブブレンドする。
float faceField(vec2 p, vec2 g, float since, float t,
                 float wIdleS, float wThinkS, float wWorkS, float wDoneS, float wErrS) {
    // バリアント選択のタイムラインは全フェーズ共通。可視なのは常にほぼ1フェーズ
    // なので、区間境界が揃っていても見た目には現れない。
    float vi = floor(t / VAR_PERIOD);
    float vf = smoothstep(0.0, VAR_MORPH, fract(t / VAR_PERIOD));

    // 重みがほぼ 0 のフェーズは SDF 評価ごと省く（mainImage のデコレーションと
    // 同じ流儀）。バリアント化で評価数が最大2倍（morph 中は前後2表情）に増えた
    // ためコスト面でも意味を持つ。除外による重み合計の欠損は最大 0.004×4 で、
    // 距離の加重平均への影響は不可視。
    float de = 0.0, dm = 0.0;

    if (wIdleS > 0.004) {
        float wSmile = 1.0 - smoothstep(IDLE_AT - 1.0, IDLE_AT + 1.0, since);
        // 2026-07-12: SLEEP を一旦無効化（要望により）。元に戻す場合は下の行を
        // `float wSleep = smoothstep(SLEEP_AT - 2.0, SLEEP_AT + 2.0, since);` に戻す。
        float wSleep = 0.0;
        float wIdle  = clamp(1.0 - wSmile - wSleep, 0.0, 1.0);

        // バリアントは「無入力の IDLE 表情」にだけ適用する。SMILE は打鍵への
        // 即時反応なので毎回同じ顔で返るほうが「反応した」ことが伝わる。
        float vA = pickVar(vi - 1.0, 21.7), vB = pickVar(vi, 21.7);
        float eIdleV = mix(idleEyesVar(p, g, vA), idleEyesVar(p, g, vB), vf);
        float mIdleV = mix(idleMouthVar(p, vA), idleMouthVar(p, vB), vf);

        float eSmile = min(arcEye(p, -1.0, g), arcEye(p, 1.0, g));
        float eSleep = min(closedEye(p, -1.0, g), closedEye(p, 1.0, g));
        float eG = wSmile * eSmile + wIdle * eIdleV + wSleep * eSleep;
        float mG = wSmile * smileMouth(p, 0.46) + wIdle * mIdleV + wSleep * flatMouth(p);

        // まばたき。idle ブロック内で完結させる（旧実装は全体 de に wIdleS 減衰で
        // 混ぜていたが、他状態へ閉じ目が滲む余地があった。ブロック内適用なら構造的にゼロ）。
        // 2026-07-14: 対称ガウシアン+完全周期 → 非対称エンベロープ+ジッタに変更。
        //  - タイミング: 周期ごとに hash で発生位置を揺らす（spec.md §7.2 対応）。
        //  - 形: 閉じ 0.019(≈0.10s) は速く、開き 0.045(≈0.24s) は遅い非対称。
        //    まぶたの随意収縮（閉じ）は速く弛緩（開き）は遅いため。
        // 2026-07-14: 二連まばたき追加。約1/3の周期で 0.075周期(≈0.4s) 後に2回目。
        // ジッタ上限 0.78 なら2回目の終端(at+0.15)も周期境界 1.0 を超えない。
        float cyc = t * 0.19;  // 1周期 ≈ 5.26s
        float at  = 0.42 + hash(vec2(floor(cyc), 7.31)) * 0.36;
        float k   = fract(cyc) - at;
        float pulse = smoothstep(0.0, 0.019, k) * (1.0 - smoothstep(0.030, 0.075, k));
        if (hash(vec2(floor(cyc), 11.7)) > 0.67) {
            float k2 = k - 0.075;
            pulse = max(pulse, smoothstep(0.0, 0.019, k2) * (1.0 - smoothstep(0.030, 0.075, k2)));
        }
        eG = mix(eG, eSleep, pulse * (1.0 - wSleep));

        de += wIdleS * eG;
        dm += wIdleS * mG;
    }
    if (wThinkS > 0.004) {
        float vA = pickVar(vi - 1.0, 33.1), vB = pickVar(vi, 33.1);
        de += wThinkS * mix(thinkEyesVar(p, g, vA), thinkEyesVar(p, g, vB), vf);
        dm += wThinkS * mix(thinkMouthVar(p, vA), thinkMouthVar(p, vB), vf);
    }
    if (wWorkS > 0.004) {
        float vA = pickVar(vi - 1.0, 47.9), vB = pickVar(vi, 47.9);
        de += wWorkS * mix(workEyesVar(p, g, vA), workEyesVar(p, g, vB), vf);
        dm += wWorkS * mix(workMouthVar(p, vA), workMouthVar(p, vB), vf);
    }
    if (wDoneS > 0.004) {
        float vA = pickVar(vi - 1.0, 59.3), vB = pickVar(vi, 59.3);
        de += wDoneS * mix(doneEyesVar(p, g, t, vA), doneEyesVar(p, g, t, vB), vf);
        dm += wDoneS * mix(doneMouthVar(p, vA), doneMouthVar(p, vB), vf);
    }
    if (wErrS > 0.004) {
        de += wErrS * errEyes(p, g);
        dm += wErrS * errMouth(p);
    }

    return min(de, dm);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec4 term = texture(iChannel0, uv);

    // Ghostty 1.3+: hide the face when the outer terminal surface is unfocused.
    if (iFocus == 0) {
        fragColor = term;
        return;
    }

    vec2 cellId = floor(fragCoord / CELL);
    vec2 cellUV = fract(fragCoord / CELL);
    vec2 smp    = (cellId + 0.5) * CELL;

    // 元の高さ基準サイズと sidebar 中心配置を保つ。drift/decorations を含む
    // 左端だけは viewport の 0.1% より内側へ入らないよう、必要な場合のみ右へ寄せる。
    float faceScale = FACE_SIZE * iResolution.y;
    float sidebarCenterX = SIDEBAR_CELL_WIDTH * SIDEBAR_COLS * 0.5;
    float minCenterX = FACE_LEFT_GAP * iResolution.x + FACE_BOUND_X * faceScale;
    float centerYRatio = TOPDOWN_Y > 0.5 ? FACE_Y_FROM_TOP : 1.0 - FACE_Y_FROM_TOP;
    vec2 faceCenter = vec2(max(sidebarCenterX, minCenterX), centerYRatio * iResolution.y);
    vec2 p = (smp - faceCenter) / faceScale;
    // TOPDOWN_Y=1（Ghostty）: fragCoord.y は既に下向き正なので反転不要。
    // TOPDOWN_Y=0（標準規約）: fragCoord.y は上向き正なので反転して下向き正にする。
    if (TOPDOWN_Y < 0.5) p.y = -p.y;
    // 生体モーション（設計の経緯は vnoise/faceDrift 群のコメント参照）。faceField()
    // より前の p に適用しているため全フェーズ(idle/think/work/done/err)に等しく効く。
    // 減算にして「faceDrift の符号 = 顔の見かけの移動方向」を一致させる
    // （下の傾き計算が有限差分をそのまま画面上の速度として使えるように）。
    p -= faceDrift(iTime);
    // バンク傾き: ドリフト速度（有限差分 0.3s）に比例して進行方向へ傾ける。
    // ドローンが移動方向へ機体を傾けて滑空する見え方。位置比例ではなく速度比例
    // なのは qmarkPos の lean と同じ根拠（静止中に最大傾斜になる逆転を避ける）。
    // 最大 ±0.12rad ≈ ±7°: これ以上傾けると ASCII 格子上で目の高さが左右非対称に
    // 量子化されて崩れて見える。ゲイン 3.0 はノイズドリフトの典型速度で
    // クランプに張り付かない値（sin 版の 4.0 から再調整）。
    float lean = clamp((faceDrift(iTime).x - faceDrift(iTime - 0.3).x) / 0.3 * 3.0, -0.12, 0.12);
    float ls = sin(lean), lc = cos(lean);
    p = vec2(p.x * lc + p.y * ls, -p.x * ls + p.y * lc); // R(-lean): 画面上で lean 方向に傾く
    // 呼吸: 吸気で胸が持ち上がるイメージの縦優位の膨らみ（y±2.5% / x±0.8%）+
    // 全体がわずかに浮き上がる（p.y への加算は画面上では上方向の移動）。
    // 均一スケールだと「風船の空気圧」に、縦優位だと「胸郭」に見える。
    float br = breathPhase(iTime);
    p.y += br * 0.012;
    p /= vec2(1.0 + 0.008 * br, 1.0 + 0.025 * br);

    vec2 cur = iCurrentCursor.xy / iResolution.xy - 0.5;
    cur.y *= CURSOR_Y_FLIP;
    float since = max(iTime - iTimeCursorChange, 0.0);
    vec2 g = clamp(cur, -0.5, 0.5) * vec2(2.0, 1.4) * GAZE;
    // 打鍵が止まって数秒経つと視線が自律的に漂い出す（注意が逸れる）。打鍵で
    // since がリセットされるため、入力再開の瞬間に重みが 0 へ戻り即カーソル
    // 注視になる — ステートレスのままで「気づいてこちらを向く」反応が出る。
    g += gazeWander(iTime) * smoothstep(1.5, 5.0, since);

    float wIdleS = 0.0, wThinkS = 0.0, wWorkS = 0.0, wDoneS = 0.0, wErrS = 0.0;
    if (FORCED_STATE >= 0) {
        // Pi/Herdr integration selects a pre-generated forced-state shader path.
        wIdleS  = FORCED_STATE == 0 ? 1.0 : 0.0;
        wThinkS = FORCED_STATE == 1 ? 1.0 : 0.0;
        wWorkS  = FORCED_STATE == 2 ? 1.0 : 0.0;
        wDoneS  = FORCED_STATE == 3 ? 1.0 : 0.0;
        wErrS   = FORCED_STATE == 4 ? 1.0 : 0.0;
    } else {
        // Legacy source path: decode state from the OSC cursor-color side channel.
        float ease = smoothstep(0.0, ERR_EASE, since);
        vec3  cc   = mix(iPreviousCursorColor.rgb, iCurrentCursorColor.rgb, ease);

        float dIdle  = distSq(cc, FACE_COL);
        float dThink = distSq(cc, THINK_COL);
        float dWork  = distSq(cc, WORK_COL);
        float dDone  = distSq(cc, DONE_COL);
        float dErr   = distSq(cc, ERR_COL);
        float dMin   = min(dIdle, min(dThink, min(dWork, min(dDone, dErr))));

        wIdleS  = exp(-(dIdle  - dMin) / STATE_SOFT);
        wThinkS = exp(-(dThink - dMin) / STATE_SOFT);
        wWorkS  = exp(-(dWork  - dMin) / STATE_SOFT);
        wDoneS  = exp(-(dDone  - dMin) / STATE_SOFT);
        wErrS   = exp(-(dErr   - dMin) / STATE_SOFT);
        float wSum = wIdleS + wThinkS + wWorkS + wDoneS + wErrS;
        wIdleS /= wSum; wThinkS /= wSum; wWorkS /= wSum; wDoneS /= wSum; wErrS /= wSum;

        // Unknown cursor colors smoothly fall back to idle.
        float gate = smoothstep(STATE_GATE_LO, STATE_GATE_HI, dMin);
        wIdleS = mix(wIdleS, 1.0, gate);
        wThinkS *= (1.0 - gate); wWorkS *= (1.0 - gate);
        wDoneS *= (1.0 - gate); wErrS *= (1.0 - gate);
    }

    float d = faceField(p, g, since, iTime, wIdleS, wThinkS, wWorkS, wDoneS, wErrS);

    float v = fieldLum(d);
    // 状態デコレーションを輝度側で加算（faceField に混ぜない理由はデコレーション
    // ブロック冒頭のコメント参照）。重みがほぼ 0 の状態は評価自体を省く。
    if (wThinkS > 0.004) v += wThinkS * thinkDecoLum(p, iTime);
    if (wWorkS  > 0.004) v += wWorkS  * workDecoLum(p, iTime);
    if (wDoneS  > 0.004) v += wDoneS  * doneDecoLum(p, iTime);
    v *= 0.94 + 0.06 * sin(iTime * 8.0 + cellId.y * 0.9);
    v += (hash(cellId + floor(iTime * 12.0)) - 0.5) * NOISE;
    v = clamp(v, 0.0, 1.0);

    int idx = int(clamp(floor(v * 10.0), 0.0, 9.0));
    if (v < 0.07) idx = 0;

    float ink = glyphPixel(glyphBits(idx), cellUV);
    vec3  tint = FACE_COL * wIdleS + THINK_COL * wThinkS + WORK_COL * wWorkS
               + DONE_COL * wDoneS + ERR_COL * wErrS;
    vec3  face = tint * ink * (0.35 + 0.65 * v) * GAIN;

    float behind = clamp(1.0 - luma(term.rgb) * 1.6, 0.0, 1.0);
    vec3  col = term.rgb + face * behind;

    fragColor = vec4(col, max(term.a, luma(face) * behind));
}
