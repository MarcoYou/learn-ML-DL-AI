#!/usr/bin/env bash
# 원 저자·공식 호스팅에서 PDF를 받아 books/ 에 저장한다. 이미 있는 파일은 건너뛴다.
set -uo pipefail
cd "$(dirname "$0")/.."
mkdir -p books
fail=0
while IFS=$'\t' read -r name url; do
  [ -z "$name" ] && continue
  if [ -s "books/$name" ]; then echo "skip  $name"; continue; fi
  if curl -fsSL --retry 3 -A "Mozilla/5.0" -o "books/$name.part" "$url" \
     && head -c 4 "books/$name.part" | grep -q '%PDF'; then
    mv "books/$name.part" "books/$name"; echo "ok    $name"
  else
    rm -f "books/$name.part"; echo "FAIL  $name  <- $url"; fail=1
  fi
done < scripts/sources.tsv
exit $fail
