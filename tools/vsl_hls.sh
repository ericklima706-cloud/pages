#!/usr/bin/env bash
# Converte a VSL em HLS com 2 qualidades (baixa primeiro, para começar rápido) + poster.
# Uso: vsl_hls.sh <video de entrada> <pasta de saída>
set -euo pipefail
IN="$1"; OUT="$2"
rm -rf "$OUT"; mkdir -p "$OUT"
IFS=x read W H < <(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0:s=x "$IN")
if [ "$H" -ge "$W" ]; then  # vertical: fixa a largura
  S1="scale=360:-2"; S2="scale=720:-2"
else                         # horizontal: fixa a altura
  S1="scale=-2:360"; S2="scale=-2:720"
fi
HASA=$(ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 "$IN" | head -1)
AMAP=(); VSM="v:0 v:1"
if [ -n "$HASA" ]; then AMAP=(-map 0:a:0 -map 0:a:0); VSM="v:0,a:0 v:1,a:1"; fi
ffmpeg -hide_banner -loglevel error -y -i "$IN" \
  -filter_complex "[0:v]split=2[a][b];[a]${S1}[lo];[b]${S2}[hi]" \
  -map "[lo]" -map "[hi]" "${AMAP[@]}" \
  -c:v libx264 -preset veryfast -profile:v main -pix_fmt yuv420p \
  -b:v:0 450k -maxrate:v:0 550k -bufsize:v:0 900k \
  -b:v:1 1400k -maxrate:v:1 1700k -bufsize:v:1 2800k \
  -force_key_frames "expr:gte(t,n_forced*2)" -sc_threshold 0 \
  -c:a aac -ac 2 -b:a 96k \
  -f hls -hls_time 4 -hls_playlist_type vod -hls_flags independent_segments \
  -hls_segment_filename "$OUT/v%v/seg_%04d.ts" -master_pl_name master.m3u8 \
  -var_stream_map "$VSM" "$OUT/v%v/index.m3u8"
ffmpeg -hide_banner -loglevel error -y -ss 0.5 -i "$IN" -frames:v 1 -vf "${S2}" -q:v 6 "$OUT/poster.jpg"
echo "W=$W H=$H"; cat "$OUT/master.m3u8"; du -sh "$OUT"; find "$OUT" -type f | wc -l
