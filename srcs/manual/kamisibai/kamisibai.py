import os
import cv2
import math
import argparse
import sys
import re
from faster_whisper import WhisperModel

def format_text(text):
    """
    10文字以上続く場合、句読点（。、！？）で改行を挿入する
    """
    if len(text) <= 10:
        return text
    
    # 句読点の後ろに改行を挿入（。、！？に対応）
    # 読点（、）でも改行することで、紙芝居風のセリフ回しを再現します
    formatted = re.sub(r'([。、！？ 　])', r'\1<br>', text)
    return formatted

def generate_storyboard(video_path, output_folder):
    video_path = os.path.abspath(video_path)
    output_folder = os.path.abspath(output_folder)

    if not os.path.exists(output_folder):
        os.makedirs(output_folder, exist_ok=True)

    # 1. Faster-Whisperのロード
    print("--- AIモデルをロード中 ---")
    model = WhisperModel("base", device="cpu", compute_type="int8")

    # 2. 文字起こしの実行
    print(f"--- 音声解析中: {os.path.basename(video_path)} ---")
    segments, _ = model.transcribe(video_path, beam_size=5)
    all_segments = list(segments)

    # 3. 動画キャプチャの準備
    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        print(f"Error: 動画ファイルを開けませんでした")
        return

    fps = cap.get(cv2.CAP_PROP_FPS)
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    duration_sec = total_frames / fps

    # HTMLの構築
    html_content = f"""
    <html><head><meta charset="utf-8"><style>
        body {{ font-family: 'Inter', sans-serif; background: #111; color: #eee; padding: 40px; line-height: 1.8; }}
        .container {{ max-width: 900px; margin: auto; }}
        .card {{ background: #222; border-radius: 15px; margin-bottom: 40px; border: 1px solid #444; overflow: hidden; }}
        img {{ width: 100%; height: auto; display: block; }}
        .content {{ padding: 25px; }}
        .timestamp {{ color: #00ffcc; font-family: monospace; margin-bottom: 15px; font-size: 0.9em; }}
        .text {{ font-size: 1.2rem; font-weight: 500; letter-spacing: 0.05em; }}
        h1 {{ text-align: center; color: #fff; }}
    </style></head><body><div class="container">
    <h1>Video Storyboard</h1>
    """

    # 4. 1分間隔の処理
    print("--- 画像抽出とテキスト整形中 ---")
    for minute in range(math.ceil(duration_sec / 60)):
        start_time = minute * 60
        end_time = start_time + 60
        
        cap.set(cv2.CAP_PROP_POS_MSEC, start_time * 1000)
        ret, frame = cap.read()
        
        if ret:
            img_name = f"slide_{minute:03d}.jpg"
            img_path = os.path.join(output_folder, img_name)
            cv2.imwrite(img_path, frame)

            # セリフを抽出し、10文字以上なら改行処理を適用
            raw_text = "".join([s.text for s in all_segments if start_time <= s.start < end_time]).strip()
            formatted_text = format_text(raw_text)

            html_content += f"""
            <div class="card">
                <img src="{img_name}">
                <div class="content">
                    <div class="timestamp">TIME: {minute:02d}:00 - {min(minute+1, int(duration_sec/60)+1):02d}:00</div>
                    <div class="text">{formatted_text if formatted_text else "（静寂）"}</div>
                </div>
            </div>
            """
        print(f"進捗: {minute + 1} 分目処理中...", end="\r")

    cap.release()
    html_content += "</div></body></html>"

    with open(os.path.join(output_folder, "index.html"), "w", encoding="utf-8") as f:
        f.write(html_content)

    print(f"\n[+] 完了しました！")
    print(f"ファイルパス: {os.path.join(output_folder, 'index.html')}")

def main():
    parser = argparse.ArgumentParser(description="動画を1分毎の画像と改行済みテキストに変換します")
    parser.add_argument('--src', type=str, required=True, help='入力動画のフルパス')
    parser.add_argument('--out', type=str, required=True, help='出力フォルダのフルパス')

    args = parser.parse_args()

    if not os.path.isfile(args.src):
        print(f"Error: 入力ファイルが見つかりません: {args.src}")
        sys.exit(1)

    generate_storyboard(args.src, args.out)

if __name__ == "__main__":
    main()