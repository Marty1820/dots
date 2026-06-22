#!/bin/zsh
ex() {
  local archive="$1"
  local base_name tmp_dir target_dir exit_code=0
  [[ -f "$archive" ]] || { echo "ex: '$archive' not found"; return 1; }
  # Determine the base name
  base_name="${archive%.tar}"
  base_name="${base_name%.tgz}"
  base_name="${base_name%.tbz2}"
  base_name="${base_name%.txz}"
  base_name="${base_name%.tar.xz}"
  base_name="${base_name%.tar.bz2}"
  base_name="${base_name%.tar.gz}"
  base_name="${base_name%.*}" # Strip last remaining dot-extension (e.g. .zip, .rar)
  # Fallback if stripping removed everything (rare edge case)
  [[ -z "$base_name" ]] && base_name="extracted"
  # For complex archives (tar/7z/etc), we might need a specific folder.
  case "$archive" in
    *.tar*|*.zip|*.rar|*.7z|*.epub|*.cb[rtb7]|*.cab|*.iso|*.dmg|*.deb|*.cpio|*.ace)
      target_dir="$(pwd)/${base_name}_tmp"
      mkdir -p "$target_dir" || return 1

      case "$archive" in
        *.tar.bz2|*.tbz2|*.cbt) tar xvjf "$archive" -C "$target_dir" ;;
        *.tar.gz|*.tgz)         tar xvzf "$archive" -C "$target_dir" ;;
        *.tar.xz|*.txz)         tar xvJf "$archive" -C "$target_dir" ;;
        *.tar.zst)              unzstd -c "$archive" | tar xvf - -C "$target_dir" ;;
        *.tar)                  tar xvf "$archive" -C "$target_dir" ;;
        *.zip|*.cbz|*.epub)     unzip -q "$archive" -d "$target_dir" ;;
        *.rar|*.cbr)            unrar x -ad "$archive" "$target_dir/" ;;
        *.7z|*.arj|*.cab|*.cb7|*.chm|*.iso|*.lzh|*.msi|*.pkg|*.rpm|*.udf|*.wim|*.xar)
                                7z x "$archive" -o"$target_dir" >/dev/null 2>&1 ;;
        *.deb)                  dpkg-deb -x "$archive" "$target_dir" ;;
        *.cpio)                 cpio -id < "$archive" -D "$target_dir" ;;
        *.ace)                  unace x "$archive" "$target_dir/" ;;
        *.exe)                  cabextract "$archive" -d "$target_dir" >/dev/null 2>&1 ;;
        *)                      echo "ex: unknown format '$archive'"; rm -rf "$target_dir"; return 1 ;;
      esac
      exit_code=$?
      if (( exit_code == 0 )); then
        local contents=( "$target_dir"/*(-N) )
        local count=${#contents[@]}
        if (( count == 0 )); then
          echo "ex: archive appears empty"
          rmdir "$target_dir"
          return 1
        elif (( count == 1 )) && [[ -d "${contents[1]}" ]]; then
          # Single folder: Move contents to current dir
          mv -n "${contents[1]}"/* ./ 2>/dev/null || true
          rmdir "${contents[1]}"
          rmdir "$target_dir"
        elif (( count == 1 )) && [[ -f "${contents[1]}" ]]; then
          # Single file: Move file to current dir
          mv "${contents[1]}" .
          rmdir "$target_dir"
        else
          # Multiple items: Rename tmp to base_name
          local final_dir="${base_name}"
          while [[ -e "$final_dir" ]]; do
            final_dir="${final_dir}_$(date +%s)"
          done
          mv "$target_dir" "./$final_dir"
          echo "Extracted to : $final_dir/"
        fi
      fi
      ;;
    # Handle simple compressors
    *.gz)
      local out_name="${archive%.gz}"
      gunzip -c "$archive" > "$out_name" 2>/dev/null || {
        gunzip -f "$archive"
        out_name=$(basename "$archive" .gz)
      }
      ;;
    *.bz2)
      bzip2 -dc "$archive" > "${archive%.bz2}"
      ;;
    *.xz)
      xz -dc "$archive" > "${archive%.xz}"
      ;;
    *)
      echo "ex: unsupported simple compression '$archive'"
      return 1
      ;;
  esac
  return $exit_code
}
