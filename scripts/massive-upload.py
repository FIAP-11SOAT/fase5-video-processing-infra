import requests
import os
import time
import argparse
import sys

# ─────────────────────────────────────────────
# Configuration
# ─────────────────────────────────────────────
API_URL = "https://gtw.frameify.dev/videos"

DEFAULT_TOKEN = (
    "eyJraWQiOiI5VnRWNFwveno2KzhLVjFyKzhxcmY2MXFZQzdrQms2WlJOM1c2YkVScVdkND0iLCJhbGciOiJSUzI1NiJ9"
    ".eyJzdWIiOiI0NGM4OTRlOC03MGIxLTcwYzYtMWY5ZC0wNjkwOWM2NzQyOTYiLCJpc3MiOiJodHRwczpcL1wvY29nbml0"
    "by1pZHAudXMtZWFzdC0xLmFtYXpvbmF3cy5jb21cL3VzLWVhc3QtMV9WNUlxV2FRTFYiLCJjbGllbnRfaWQiOiIzMmxk"
    "djRjc3BvcjQxMHExaWVodjYxOWNtYSIsIm9yaWdpbl9qdGkiOiJlNjRmMWM4Ny02MjExLTQzZGEtOGM5ZS0zYzJlZmIz"
    "ZGUwZmQiLCJldmVudF9pZCI6IjQ5ZmJmYWI0LWU0MzMtNDRjYy05ZDk0LWI3MmY5MDVlYjEwYiIsInRva2VuX3VzZSI6"
    "ImFjY2VzcyIsInNjb3BlIjoiYXdzLmNvZ25pdG8uc2lnbmluLnVzZXIuYWRtaW4iLCJhdXRoX3RpbWUiOjE3NzI0MTUy"
    "NzYsImV4cCI6MTc3MjQxODg3NiwiaWF0IjoxNzcyNDE1Mjc2LCJqdGkiOiI5Mzg5ZmNkMS1lZWUwLTQwYWMtODI3ZC0y"
    "NzcyMjM0NmE2ODkiLCJ1c2VybmFtZSI6ImFkbWluIn0.I7qot12fDfbFpFgw3P347aC3R4PrDN6YlcGrQ20q2eUDxjUf"
    "bx4V59TK39D7wkYlESTRD4pgjVzAsJebH3XI4W6ofwFFlUkvhwPykyMwUt5gvN9-uws53kcZ7gSc5vfOcm2V4DXHrM1c4"
    "hZJ6IBNhSA6K59XTu8Ei_MREiJ8S36-GrAqcWMo6-o8glBOZT7bPcnfa2cKMZMHG4nX2Fvnflb86QKrAmF5ANEMRv1YV"
    "fn6kuPrazoDg4W3MqidUmigTDquncAz6RNBvEQaU3wOQ7g_9svnbuQ0y-LSohTkK2yQzzFddoaPos-usjVvA0WzRKqpLL"
    "5DwGQsy4raB422yQ"
)

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
DEFAULT_VIDEO = os.path.join(SCRIPT_DIR, "video_contangem_teste.mp4")

HEADERS = {
    "accept": "*/*",
    "accept-language": "pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7",
    "cache-control": "no-cache",
    "origin": "https://frameify.dev",
    "pragma": "no-cache",
    "priority": "u=1, i",
    "referer": "https://frameify.dev/",
    "sec-ch-ua": '"Not:A-Brand";v="99", "Google Chrome";v="145", "Chromium";v="145"',
    "sec-ch-ua-mobile": "?0",
    "sec-ch-ua-platform": '"Linux"',
    "sec-fetch-dest": "empty",
    "sec-fetch-mode": "cors",
    "sec-fetch-site": "same-site",
    "user-agent": (
        "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
        "(KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36"
    ),
}


def upload_video(video_path: str, token: str, index: int) -> bool:
    """Upload a single video and return True on success."""
    headers = {**HEADERS, "authorization": f"Bearer {token}"}

    with open(video_path, "rb") as f:
        files = {"file": (os.path.basename(video_path), f, "video/mp4")}
        try:
            response = requests.post(API_URL, headers=headers, files=files, timeout=60)
            status = response.status_code
            ok = status in (200, 201, 202)
            symbol = "✅" if ok else "❌"
            print(f"  [{index:>3}] {symbol}  HTTP {status}  —  {response.text[:120]}")
            return ok
        except requests.exceptions.RequestException as exc:
            print(f"  [{index:>3}] 💥  Request error: {exc}")
            return False


def main():
    parser = argparse.ArgumentParser(
        description="Massive video uploader — stress-test for KEDA autoscaling"
    )
    parser.add_argument(
        "-n", "--count",
        type=int,
        default=20,
        help="Number of uploads to perform (default: 20)",
    )
    parser.add_argument(
        "-d", "--delay",
        type=float,
        default=0.5,
        help="Seconds to wait between uploads (default: 0.5)",
    )
    parser.add_argument(
        "-t", "--token",
        type=str,
        default=DEFAULT_TOKEN,
        help="Bearer token for authorization (default: token baked into the script)",
    )
    parser.add_argument(
        "-f", "--file",
        type=str,
        default=DEFAULT_VIDEO,
        help=f"Path to the video file (default: {DEFAULT_VIDEO})",
    )
    args = parser.parse_args()

    if not os.path.isfile(args.file):
        print(f"❌  Video file not found: {args.file}")
        sys.exit(1)

    file_size_mb = os.path.getsize(args.file) / (1024 * 1024)
    print("=" * 60)
    print("  🚀  Massive Upload — KEDA stress test")
    print("=" * 60)
    print(f"  File   : {args.file}  ({file_size_mb:.2f} MB)")
    print(f"  Target : {API_URL}")
    print(f"  Uploads: {args.count}")
    print(f"  Delay  : {args.delay}s between requests")
    print("=" * 60)

    successes = 0
    failures = 0
    start = time.time()

    for i in range(1, args.count + 1):
        if upload_video(args.file, args.token, i):
            successes += 1
        else:
            failures += 1

        if i < args.count and args.delay > 0:
            time.sleep(args.delay)

    elapsed = time.time() - start
    print("=" * 60)
    print(f"  ✅  Successes : {successes}")
    print(f"  ❌  Failures  : {failures}")
    print(f"  ⏱️  Elapsed   : {elapsed:.1f}s")
    print("=" * 60)


if __name__ == "__main__":
    main()

