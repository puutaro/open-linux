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
    
    base_name = os.path.basename(video_path)
    display_title = base_name[:50]

    img_folder = os.path.join(output_folder, "img")
    if not os.path.exists(output_folder):
        os.makedirs(output_folder, exist_ok=True)
    if not os.path.exists(img_folder):
        os.makedirs(img_folder, exist_ok=True)

    print("--- AIモデルをロード中 ---")
    model = WhisperModel("base", device="cpu", compute_type="int8")

    print(f"--- 音声解析中: {base_name} ---")
    segments, _ = model.transcribe(video_path, beam_size=5)
    all_segments = list(segments)

    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        print(f"Error: 動画ファイルを開けませんでした")
        return

    # HTML構築
    html_content = f"""
    <!DOCTYPE html>
    <html lang="ja"><head><meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{display_title}</title>
    <style>
        body {{ 
            font-family: 'Helvetica Neue', Arial, 'Hiragino Kaku Gothic ProN', sans-serif; 
            background: #f0f2f5; color: #1c1e21; margin: 0; padding-top: 90px; 
        }}
        
        /* スマートヘッダー (下で表示、上で隠れる) */
        #main-header {{ 
            position: fixed; top: 0; left: 0; width: 100%; height: 70px;
            background: rgba(255, 255, 255, 0.98); 
            display: flex; align-items: center; justify-content: center;
            border-bottom: 1px solid #ddd;
            font-size: 1.5rem; font-weight: bold; color: #333;
            transition: transform 0.3s ease-in-out;
            z-index: 500; 
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            padding: 0 20px; box-sizing: border-box;
            white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
        }}
        
        /* 非表示状態 */
        .header-hide {{ transform: translateY(-100%); }}

        .container {{ max-width: 1100px; margin: auto; padding: 0 15px; }}
        
        .card {{ 
            background: #fff; border: 1px solid #ddd; margin-bottom: 25px; 
            display: flex; flex-direction: row; border-radius: 15px; overflow: hidden;
            box-shadow: 0 4px 15px rgba(0,0,0,0.08);
        }}
        
        .img-box {{ 
            width: {thumb_width}px; min-width: {thumb_width}px; 
            cursor: zoom-in; background: #000; display: flex; align-items: center;
        }}
        img.thumb {{ width: 100%; height: auto; display: block; }}
        
        .content {{ padding: 30px; flex: 1; }}
        .timestamp {{ 
            color: #0084ff; font-size: 1.3rem; margin-bottom: 15px; 
            font-weight: bold; font-family: monospace;
        }}
        .text {{ font-size: 1.85rem; line-height: 1.6; color: #050505; word-break: break-all; }}

        #overlay {{
            position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0,0,0,0.95); display: none; align-items: center; justify-content: center;
            z-index: 9999; cursor: zoom-out;
        }}
        #overlay img {{ max-width: 100%; max-height: 100%; object-fit: contain; }}

        @media (max-width: 768px) {{
            body {{ padding-top: 70px; }}
            #main-header {{ height: 60px; font-size: 1.1rem; }}
            .card {{ flex-direction: column; }}
            .img-box {{ width: 100%; min-width: 100%; }}
            .text {{ font-size: 1.5rem; }}
        }}
    </style>
    <script>
        let lastScrollY = window.scrollY;

        window.addEventListener('scroll', () => {{
            const header = document.getElementById('main-header');
            const currentScrollY = window.scrollY;

            // 要求: 下スクロールで見える、上スクロールで隠れる
            if (currentScrollY > lastScrollY) {{
                // 下に動いている時は表示
                header.classList.remove('header-hide');
            }} else if (currentScrollY < lastScrollY && currentScrollY > 50) {{
                // 上に動いている時は隠す（最上部付近は除く）
                header.classList.add('header-hide');
            }}
            
            // 最上部に近いときは必ず表示
            if (currentScrollY <= 50) {{
                header.classList.remove('header-hide');
            }}

            lastScrollY = currentScrollY;
        }});

        function openFull(src) {{
            const div = document.getElementById('overlay');
            const img = document.getElementById('fullImg');
            img.src = src;
            div.style.display = 'flex';
            document.body.style.overflow = 'hidden'; 
        }}
        function closeFull() {{
            document.getElementById('overlay').style.display = 'none';
            document.body.style.overflow = 'auto';
        }}
    </script>
    </head><body>
    <div id="overlay" onclick="closeFull()"><img id="fullImg" src=""></div>
    
    <header id="main-header">{display_title}</header>

    <div class="container">
    """

    print(f"--- 抽出開始 ---")
    
    for i, s in enumerate(all_segments):
        start_t, text = s.start, s.text.strip()
        cap.set(cv2.CAP_PROP_POS_MSEC, start_t * 1000)
        ret, frame = cap.read()
        
        if ret:
            full_fn = f"full_{i:04d}.jpg"
            cv2.imwrite(os.path.join(img_folder, full_fn), frame, [int(cv2.IMWRITE_JPEG_QUALITY), 80])

            h, w = frame.shape[:2]
            target_h = int(h * (thumb_width / w))
            thumb_f = cv2.resize(frame, (thumb_width, target_h), interpolation=cv2.INTER_AREA)
            thumb_fn = f"thumb_{i:04d}.jpg"
            cv2.imwrite(os.path.join(img_folder, thumb_fn), thumb_f, [int(cv2.IMWRITE_JPEG_QUALITY), 85])

            fmt_text = format_text(text)
            sm, ss = divmod(int(start_t), 60)
            em, es = divmod(int(s.end), 60)

            html_content += f"""
            <div class="card">
                <div class="img-box" onclick="openFull('img/{full_fn}')">
                    <img src="img/{thumb_fn}" class="thumb">
                </div>
                <div class="content">
                    <div class="timestamp">{sm:02d}:{ss:02d} - {em:02d}:{es:02d}</div>
                    <div class="text">{fmt_text}</div>
                </div>
            </div>
            """
        
        if (i + 1) % 20 == 0:
            print(f"進捗: {i + 1} / {len(all_segments)} 件完了")

    cap.release()
    html_content += "</div></body></html>"

    with open(os.path.join(output_folder, "index.html"), "w", encoding="utf-8") as f:
        f.write(html_content)

    print(f"\n[+] 完了！")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--src', type=str, required=True)
    parser.add_argument('--out', type=str, required=True)
    parser.add_argument('--width', type=int, default=200)
    args = parser.parse_args()
    generate_storyboard(args.src, args.out, args.width)

if __name__ == "__main__":
    main()