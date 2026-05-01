import os
import cv2
import math
import argparse
import sys
import re
from faster_whisper import WhisperModel

def format_text(text):
    if len(text) <= 10:
        return text
    # 句読点で改行を挿入
    formatted = re.sub(r'([。、！？])', r'\1<br>', text)
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
    # infoに言語情報などが入ります
    segments, info = model.transcribe(video_path, beam_size=5)
    all_segments = list(segments)

    # 3. 動画キャプチャの準備
    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        print(f"Error: 動画ファイルを開けませんでした")
        return

    # HTMLの構築
    html_content = f"""
    <html><head><meta charset="utf-8"><style>
        body {{ font-family: 'Helvetica Neue', Arial, sans-serif; background: #f0f2f5; color: #333; padding: 20px; }}
        .container {{ max-width: 800px; margin: auto; }}
        .card {{ background: #fff; border-radius: 12px; margin-bottom: 20px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); overflow: hidden; display: flex; }}
        .img-box {{ width: 300px; min-width: 300px; }}
        img {{ width: 100%; height: 100%; object-fit: cover; }}
        .content {{ padding: 20px; flex-grow: 1; }}
        .timestamp {{ color: #65676b; font-size: 0.85em; margin-bottom: 8px; font-weight: bold; }}
        .text {{ font-size: 1.1rem; line-height: 1.5; color: #050505; }}
        h1 {{ text-align: center; color: #1c1e21; }}
    </style></head><body><div class="container">
    <h1>Video Transcription Log</h1>
    """

    # 4. 発話セグメントごとの処理
    print(f"--- 抽出開始 (全 {len(all_segments)} セグメント) ---")
    
    for i, s in enumerate(all_segments):
        start_t = s.start
        end_t = s.end
        text = s.text.strip()

        # そのセグメントの開始時点のフレームを取得
        cap.set(cv2.CAP_PROP_POS_MSEC, start_t * 1000)
        ret, frame = cap.read()
        
        if ret:
            img_name = f"seg_{i:04d}.jpg"
            img_path = os.path.join(output_folder, img_name)
            cv2.imwrite(img_path, frame)

            formatted_text = format_text(text)
            
            # 時間表示を 00:00 形式に変換
            start_m = int(start_t // 60)
            start_s = int(start_t % 60)
            end_m = int(end_t // 60)
            end_s = int(end_t % 60)

            html_content += f"""
            <div class="card">
                <div class="img-box"><img src="{img_name}"></div>
                <div class="content">
                    <div class="timestamp">⏱ {start_m:02d}:{start_s:02d} - {end_m:02d}:{end_s:02d}</div>
                    <div class="text">{formatted_text}</div>
                </div>
            </div>
            """
        
        if i % 10 == 0:
            print(f"処理済み: {i}/{len(all_segments)}...")

    cap.release()
    html_content += "</div></body></html>"

    with open(os.path.join(output_folder, "index.html"), "w", encoding="utf-8") as f:
        f.write(html_content)

    print(f"\n[+] 完了しました！")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--src', type=str, required=True)
    parser.add_argument('--out', type=str, required=True)
    args = parser.parse_args()
    generate_storyboard(args.src, args.out)

if __name__ == "__main__":
    main()