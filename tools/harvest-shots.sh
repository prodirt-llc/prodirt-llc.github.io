#!/usr/bin/env bash
# harvest-shots.sh — pull an app's Play Store screenshots into <appdir>/shots/.
#
# Play serves listing screenshots from play-lh.googleusercontent.com at a
# resizable URL. We pull "=w540" — web-weight (~800KB vs ~2-3MB for the
# original) and still crisp at the gallery's display size. Bump WEBSIZE below
# if you ever want larger. These are your own assets. Run this AFTER refreshing
# the Play listing so it grabs the new screenshots, not the ones you replaced.
#
# Usage:
#   ./tools/harvest-shots.sh                 # harvest every published app below
#   ./tools/harvest-shots.sh colorseeker     # just one (by site folder name)
#
# Trailer Boss is in testing (no public listing) — supply its shots by hand.

set -euo pipefail
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WEBSIZE="w540"   # play-lh resize suffix used for the downloaded images
FMT="rj"         # force JPEG (much smaller than PNG for screenshots)
EXT="jpg"

# site-folder <TAB> package-id
APPS='
bloodhound	bloodhound.com.bloodhound
fieldquote	com.prodirt.fieldquote
trailmapper	com.prodirt.trailmapper
bandpass	com.bandpass
colorseeker	com.colorseeker
kiteforcepro	com.kiteforcepro
evenspacing	even.spacingcalculator
FractionPro	com.prodirt.fractionpro
StrikeAnalyzer	com.prodirt.strikeanalyzer
'

harvest() {
  local dir="$1" pkg="$2"
  local out="$ROOT/$dir/shots"
  echo "== $dir ($pkg)"
  local html
  html="$(curl -sL -A "$UA" "https://play.google.com/store/apps/details?id=$pkg&hl=en&gl=US")" || {
    echo "   ! fetch failed"; return; }

  # Screenshot images render in the grid at the =w526-h296 thumb size.
  # The icon (=w240-h240) and feature graphic (…-pc…-pd) use other suffixes,
  # so this pattern isolates screenshots. Preserve document order, dedupe.
  local urls
  urls="$(printf '%s' "$html" \
    | grep -oE 'https://play-lh\.googleusercontent\.com/[A-Za-z0-9_-]+=w526-h296' \
    | sed 's/=w526-h296$//' \
    | awk '!seen[$0]++')" || true

  if [ -z "$urls" ]; then echo "   ! no screenshots found (listing public?)"; return; fi

  mkdir -p "$out"
  rm -f "$out"/*.png "$out"/*.jpg "$out"/*.webp 2>/dev/null || true
  local i=1
  while IFS= read -r u; do
    [ -z "$u" ] && continue
    curl -sL "${u}=${WEBSIZE}-${FMT}" -o "$out/$i.$EXT" && echo "   -> shots/$i.$EXT" || echo "   ! $i failed"
    i=$((i+1))
  done <<< "$urls"
  echo "   done: $((i-1)) screenshot(s)"
}

only="${1:-}"
printf '%s\n' "$APPS" | while IFS=$'\t' read -r dir pkg; do
  [ -z "${dir:-}" ] && continue
  if [ -n "$only" ] && [ "$only" != "$dir" ]; then continue; fi
  harvest "$dir" "$pkg"
done
echo "All done."
