import os
import cv2
import argparse
import sys
import re
import math
from faster_whisper import WhisperModel

def format_text(text):
    if len(text) <= 10: return text
    return re.sub(r'([。、！？])', r'\1<br>', text)

def save_html_page(page_idx, total_pages, segments_chunk, output_folder, display_title, thumb_width):
    html_folder = os.path.join(output_folder, "html")
    
    if page_idx == 1:
        file_path = os.path.join(output_folder, "index.html")
        img_rel_path = "img/"
        link_prefix = "html/"
        to_index_link = "index.html"
    else:
        file_path = os.path.join(html_folder, f"index_{page_idx}.html")
        img_rel_path = "../img/"
        link_prefix = ""
        to_index_link = "../index.html"

    nav_html = '<div class="pagination">'
    range_size = 5
    start_p = max(1, page_idx - range_size)
    end_p = min(total_pages, page_idx + range_size)
    
    if start_p > 1:
        nav_html += f'<a href="{to_index_link}" class="page-link">1</a><span class="dots">..</span>'

    for i in range(start_p, end_p + 1):
        active = 'active' if i == page_idx else ''
        if i == 1: target = to_index_link
        else: target = f"{link_prefix}index_{i}.html"
        nav_html += f'<a href="{target}" class="page-link {active}">{i}</a>'
    
    if end_p < total_pages:
        nav_html += f'<span class="dots">..</span><a href="{link_prefix}index_{total_pages}.html" class="page-link">{total_pages}</a>'
    nav_html += '</div>'

    html_content = f"""
    <!DOCTYPE html>
    <html lang="ja"><head><meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{display_title} - P.{page_idx}</title>
    <style>
        body {{ 
            font-family: 'Helvetica Neue', Arial, sans-serif; 
            background: #f0f2f5; color: #1c1e21; margin: 0; padding-top: 100px; padding-bottom: 120px;
        }}
        #main-header, #main-footer {{ 
            position: fixed; left: 0; width: 100%; background: rgba(255, 255, 255, 0.98); 
            border-style: solid; border-color: #ddd; transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1); z-index: 1000; 
            display: flex; align-items: center; justify-content: center; box-shadow: 0 2px 10px rgba(0,0,0,0.08);
        }}
        
        #main-header {{ 
            top: 0; height: 90px; border-width: 0 0 1px 0; 
            font-size: 2.6rem; /* 2倍サイズに変更 */
            font-weight: bold; padding: 0 10px; 
            box-sizing: border-box; display: flex; justify-content: center;
        }}
        .header-title {{ white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 100%; text-align: left; }}
        
        #main-footer {{ bottom: 0; min-height: 85px; border-width: 1px 0 0 0; padding: 10px 0; }}
        .header-hidden {{ transform: translateY(-100%); }}
        .footer-hidden {{ transform: translateY(100%); }}
        .container {{ max-width: 1000px; margin: auto; padding: 0 15px; }}
        .card {{ background: #fff; border: 1px solid #ddd; margin-bottom: 25px; display: flex; flex-direction: row; border-radius: 15px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }}
        .img-box {{ width: {thumb_width}px; min-width: {thumb_width}px; cursor: zoom-in; background: #000; display: flex; align-items: center; }}
        img.thumb {{ width: 100%; height: auto; display: block; }}
        .content {{ padding: 30px; flex: 1; }}
        .timestamp {{ color: #0084ff; font-size: 1.2rem; margin-bottom: 10px; font-weight: bold; font-family: monospace; }}
        .text {{ font-size: 1.85rem; line-height: 1.6; color: #050505; word-break: break-all; }}
        .pagination {{ display: flex; gap: 8px; flex-wrap: wrap; justify-content: center; max-width: 95%; margin: 0 auto; }}
        .page-link {{ text-decoration: none; color: #333; padding: 12px 18px; border-radius: 10px; background: #fff; border: 1px solid #ccc; font-weight: bold; font-size: 1.1rem; }}
        .page-link.active {{ background: #0084ff; color: #fff; border-color: #0084ff; }}
        #overlay {{ position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.95); display: none; align-items: center; justify-content: center; z-index: 9999; cursor: zoom-out; }}
        #overlay img {{ max-width: 100%; max-height: 100%; object-fit: contain; }}
        
        @media (max-width: 768px) {{
            #main-header {{ height: 75px; font-size: 1.8rem; }} /* スマホでは巨大すぎないよう調整 */
            body {{ padding-top: 85px; }}
            .card {{ flex-direction: column; }}
            .img-box {{ width: 100%; min-width: 100%; }}
            .text {{ font-size: 1.5rem; }}
        }}
    </style>
    <script>
        let lastScrollY = window.scrollY;
        window.addEventListener('scroll', () => {{
            const header = document.getElementById('main-header');
            const footer = document.getElementById('main-footer');
            const currentScrollY = window.scrollY;
            const windowHeight = window.innerHeight;
            const documentHeight = document.documentElement.scrollHeight;
            const isBottom = (windowHeight + currentScrollY) >= (documentHeight - 10);
            if (isBottom) {{
                footer.classList.remove('footer-hidden');
                if (currentScrollY > lastScrollY) header.classList.remove('header-hidden');
                else header.classList.add('header-hidden');
            }} else if (currentScrollY > lastScrollY) {{
                header.classList.remove('header-hidden'); 
                footer.classList.add('footer-hidden');    
            }} else {{
                header.classList.add('header-hidden');    
                footer.classList.remove('footer-hidden'); 
            }}
            if (currentScrollY <= 50) {{
                header.classList.remove('header-hidden');
                footer.classList.remove('footer-hidden');
            }}
            lastScrollY = currentScrollY;
        }});
        function openFull(src) {{
            const div = document.getElementById('overlay');
            document.getElementById('fullImg').src = src;
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
    <header id="main-header"><div class="header-title">{display_title}</div></header>
    <div class="container">
    """

    for i, s, full_fn, thumb_fn in segments_chunk:
        fmt_text = format_text(s.text.strip())
        sm, ss = divmod(int(s.start), 60)
        em, es = divmod(int(s.end), 60)
        html_content += f"""
        <div class="card">
            <div class="img-box" onclick="openFull('{img_rel_path}{full_fn}')">
                <img src="{img_rel_path}{thumb_fn}" class="thumb">
            </div>
            <div class="content">
                <div class="timestamp">{sm:02d}:{ss:02d} - {em:02d}:{es:02d}</div>
                <div class="text">{fmt_text}</div>
            </div>
        </div>
        """

    html_content += f"</div><footer id='main-footer'>{nav_html}</footer></body></html>"
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(html_content)

def generate_storyboard(video_path, output_folder, thumb_width):
    img_folder = os.path.join(output_folder, "img")
    html_folder = os.path.join(output_folder, "html")
    os.makedirs(img_folder, exist_ok=True)
    os.makedirs(html_folder, exist_ok=True)
    
    print("\n[1/3] 音声解析中 (Whisper AI)...")
    model = WhisperModel("base", device="cpu", compute_type="int8")
    segments, _ = model.transcribe(video_path, beam_size=5)
    all_segments = list(segments)
    total_segments = len(all_segments)

    cap = cv2.VideoCapture(video_path)
    processed_data = []
    
    print(f"\n[2/3] 画像生成中 (全 {total_segments} セグメント)...")
    for i, s in enumerate(all_segments):
        cap.set(cv2.CAP_PROP_POS_MSEC, s.start * 1000)
        ret, frame = cap.read()
        if ret:
            full_fn, thumb_fn = f"full_{i:04d}.jpg", f"thumb_{i:04d}.jpg"
            cv2.imwrite(os.path.join(img_folder, full_fn), frame, [int(cv2.IMWRITE_JPEG_QUALITY), 80])
            h, w = frame.shape[:2]
            thumb_f = cv2.resize(frame, (thumb_width, int(h*(thumb_width/w))), interpolation=cv2.INTER_AREA)
            cv2.imwrite(os.path.join(img_folder, thumb_fn), thumb_f, [int(cv2.IMWRITE_JPEG_QUALITY), 85])
            processed_data.append((i, s, full_fn, thumb_fn))
        
        if (i + 1) % 5 == 0 or (i + 1) == total_segments:
            percent = (i + 1) / total_segments * 100
            sys.stdout.write(f"\r      進捗: [{i+1}/{total_segments}] {percent:4.1f}% 処理中...")
            sys.stdout.flush()
    cap.release()

    print("\n\n[3/3] HTMLページ分割出力中...")
    pages_data = []
    if processed_data:
        max_time = processed_data[-1][1].start
        total_p = math.ceil(max_time / 300) if max_time > 0 else 1
        for p in range(1, total_p + 1):
            chunk = [d for d in processed_data if (p-1)*300 <= d[1].start < p*300]
            if chunk: pages_data.append(chunk)

    title = os.path.basename(video_path)
    for idx, chunk in enumerate(pages_data):
        save_html_page(idx + 1, len(pages_data), chunk, output_folder, title, thumb_width)
        print(f"      ページ {idx+1} 生成完了...")

    print(f"\n[+] 全工程完了！ メイン: {os.path.join(output_folder, 'index.html')}")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--src', type=str, required=True)
    parser.add_argument('--out', type=str, required=True)
    parser.add_argument('--width', type=int, default=200)
    args = parser.parse_args()
    generate_storyboard(args.src, args.out, args.width)

if __name__ == "__main__":
    main()