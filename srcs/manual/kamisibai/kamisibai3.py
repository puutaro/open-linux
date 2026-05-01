import os
import cv2
import argparse
import sys
import re
from faster_whisper import WhisperModel

def format_text(text):
    if len(text) <= 10:
        return text
    formatted = re.sub(r'([。、！？])', r'\1<br>', text)
    return formatted

def generate_storyboard(video_path, output_folder, thumb_width):
    video_path = os.path.abspath(video_path)
    output_folder = os.path.abspath(output_folder)
    
    # フォルダ構成: 
    # output/index.html
    # output/img/thumb_... (表示用)
    # output/img/full_...  (拡大用)
    img_folder = os.path.join(output_folder, "img")

    if not os.path.exists(output_folder):
        os.makedirs(output_folder, exist_ok=True)
    if not os.path.exists(img_folder):
        os.makedirs(img_folder, exist_ok=True)

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

    # HTMLの構築
    html_content = f"""
    <html><head><meta charset="utf-8">
    <style>
        body {{ font-family: sans-serif; background: #fafafa; color: #333; padding: 20px; }}
        .container {{ max-width: 1000px; margin: auto; }}
        .card {{ 
            background: #fff; border: 1px solid #ddd; margin-bottom: 12px; 
            display: flex; align-items: flex-start; border-radius: 8px; overflow: hidden;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }}
        /* クリックしてない時はこのサイズ */
        .img-box {{ 
            width: 200px; min-width: 100px; 
            cursor: zoom-in; background: #000;
        }}
        img.thumb {{ width: 100%; height: auto; display: block; transition: 0.2s; }}
        img.thumb:hover {{ opacity: 0.8; }}
        
        .content {{ padding: 15px; flex: 1; }}
        .timestamp {{ color: #00a884; font-size: 0.85em; margin-bottom: 8px; font-weight: bold; font-family: monospace; }}
        .text {{ font-size: 1.05rem; line-height: 1.5; color: #111; }}
        h1 {{ font-size: 1.6rem; text-align: center; color: #444; }}

        /* 拡大表示用オーバーレイ */
        #overlay {{
            position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0,0,0,0.9); display: none; align-items: center; justify-content: center;
            z-index: 1000; cursor: zoom-out;
        }}
        #overlay img {{ max-width: 98%; max-height: 98%; object-fit: contain; }}
    </style>
    <script>
        function openFull(src) {{
            const div = document.getElementById('overlay');
            const img = document.getElementById('fullImg');
            img.src = src;
            div.style.display = 'flex';
        }}
        function closeFull() {{
            document.getElementById('overlay').style.display = 'none';
        }}
    </script>
    </head><body>
    <div id="overlay" onclick="closeFull()"><img id="fullImg" src=""></div>
    <div class="container">
    <h1>Video Transcription Log</h1>
    """

    # 4. 発話セグメントごとの処理
    print(f"--- 抽出開始 (全 {len(all_segments)} 件) ---")
    
    for i, s in enumerate(all_segments):
        start_t, end_t, text = s.start, s.end, s.text.strip()
        cap.set(cv2.CAP_PROP_POS_MSEC, start_t * 1000)
        ret, frame = cap.read()
        
        if ret:
            # 1. 拡大用画像（オリジナルサイズ）の保存
            full_filename = f"full_{i:04d}.jpg"
            full_save_path = os.path.join(img_folder, full_filename)
            cv2.imwrite(full_save_path, frame, [int(cv2.IMWRITE_JPEG_QUALITY), 80])

            # 2. サムネイル用画像（指定pxに縮小）の保存
            h, w = frame.shape[:2]
            target_height = int(h * (thumb_width / w))
            thumb_frame = cv2.resize(frame, (thumb_width, target_height), interpolation=cv2.INTER_AREA)
            
            thumb_filename = f"thumb_{i:04d}.jpg"
            thumb_save_path = os.path.join(img_folder, thumb_filename)
            cv2.imwrite(thumb_save_path, thumb_frame, [int(cv2.IMWRITE_JPEG_QUALITY), 85])

            formatted_text = format_text(text)
            start_m, start_s = divmod(int(start_t), 60)
            end_m, end_s = divmod(int(end_t), 60)

            # HTML内では thumb/img を表示し、クリックで full/img を開く
            html_content += f"""
            <div class="card">
                <div class="img-box" onclick="openFull('img/{full_filename}')">
                    <img src="img/{thumb_filename}" class="thumb" title="クリックで原寸表示">
                </div>
                <div class="content">
                    <div class="timestamp">[{start_m:02d}:{start_s:02d} - {end_m:02d}:{end_s:02d}]</div>
                    <div class="text">{formatted_text}</div>
                </div>
            </div>
            """
        
        if (i + 1) % 20 == 0:
            print(f"進捗: {i + 1} / {len(all_segments)} 件...")

    cap.release()
    html_content += "</div></body></html>"

    with open(os.path.join(output_folder, "index.html"), "w", encoding="utf-8") as f:
        f.write(html_content)

    print(f"\n[+] 完了！")
    print(f"表示サイズ: {thumb_width}px / クリックで原寸表示可能")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--src', type=str, required=True)
    parser.add_argument('--out', type=str, required=True)
    parser.add_argument('--width', type=int, default=200, help='通常時の横幅px (デフォルト: 200)')

    args = parser.parse_args()
    generate_storyboard(args.src, args.out, args.width)

if __name__ == "__main__":
    main()