#!/usr/bin/env bash
# Exit on error
set -e

echo "=== [1/5] Upgrading pip and installing Python dependencies ==="
python -m pip install --upgrade pip
python -m pip install -r src/requirements.txt
python -m pip install GitPython

echo "=== [2/5] Setting up directories ==="
mkdir -p bin
mkdir -p data
mkdir -p src/static

echo "=== [3/5] Generating version info ==="
if [ ! -f "version.txt" ]; then
    python src/version.py 2>/dev/null || echo "1.0.0" > version.txt
fi
cp version.txt src/version.txt 2>/dev/null || true

echo "=== [4/5] Downloading static FFmpeg and Deno ==="
# Download static FFmpeg for Linux x64
if [ ! -f "bin/ffmpeg" ]; then
    echo "Downloading FFmpeg static binary..."
    curl -L https://github.com/eugeneware/ffmpeg-static/releases/latest/download/linux-x64 -o bin/ffmpeg
    chmod +x bin/ffmpeg
fi

# Download static Deno for Linux x64 (JS runtime for yt-dlp)
if [ ! -f "bin/deno" ]; then
    echo "Downloading Deno..."
    curl -fsSL https://deno.land/install.sh | DENO_INSTALL=./deno_tmp sh || true
    if [ -f "./deno_tmp/bin/deno" ]; then
        mv ./deno_tmp/bin/deno bin/deno
        chmod +x bin/deno
        rm -rf deno_tmp
    fi
fi

# Copy binaries into src/ so external.py directly detects them
cp bin/ffmpeg src/ffmpeg 2>/dev/null || true
cp bin/deno src/deno 2>/dev/null || true

# Copy extension.js to static if present
if [ -f "extension/extension.js" ]; then
    cp extension/extension.js src/static/extension.js 2>/dev/null || true
fi

echo "=== [5/5] Build Complete! Ready for Render ==="
