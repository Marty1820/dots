#!/bin/zsh
ex() {
  local archive="$1"
  [[ -f "$archive" ]] || { echo "ex: '$archive' not found"; return 1; }

  # Determine the base name
  local base_name="${archive}"
  local -a extensions=(tar.bz2 tar.gz tar.xz tar.zst .tar .tgz .tbz2 .txz .bz2 .gz .xz .zip .rar .7z .epub .cbt .cbr .cbz .cb7 .cab .iso .dmg .deb .cpio .ace .exe)
  for ext in "${extensions[@]}"; do
    if [[ "$base_name" == *."$ext" ]]; then
      base_name="${base_name%.$ext}"
      break
    fi
  done
  base_name="${base_name##*/}" # Remove path
  [[ -z "$base_name" ]] && base_name="extracted"

  # Define extraction commands as an associative array
  local -A extractors=(
    [*.tar.bz2]='tar -xjf'
    [*.tbz2]='tar -xjf'
    [*.cbt]='tar -xjf'
    [*.tar.gz]='tar -xzf'
    [*.tgz]='tar -xzf'
    [*.tar.xz]='tar -xJf'
    [*.txz]='tar -xJf'
    [*.tar.zst]='unzstd -c "$archive" | tar xf -'
    [*.tar]='tar -xf'
    [*.zip]='unzip -q'
    [*.cbz]='unzip -q'
    [*.epub]='unzip -q'
    [*.rar]='unrar x -ad'
    [*.cbr]='unrar x -ad'
    [*.7z]='7z x'
    [*.arj]='7z x'
    [*.cab]='7z x'
    [*.cb7]='7z x'
    [*.chm]='7z x'
    [*.iso]='7z x'
    [*.lzh]='7z x'
    [*.msi]='7z x'
    [*.pkg]='7z x'
    [*.rpm]='7z x'
    [*.udf]='7z x'
    [*.wim]='7z x'
    [*.xar]='7z x'
    [*.deb]='dpkg-deb -x'
    [*.cpio]='cpio -id'
    [*.ace]='unace x'
  )

  case "$archive" in
    *.tar*|*.zip|*.rar|*.7z|*.epub|*.cb[rtb7]|*.cab|*.iso|*.dmg|*.deb|*.cpio|*.ace|*.exe)
      _extract_to_tmp "$archive" "$base_name" "${extractors[$archive]}" || return 1
      ;;
    *.gz|*.bz2|*.xz)
      _extract_simple "$archive"
      ;;
    *)
      echo "ex:unsupported format '$archive'"
      return 1
      ;;
  esac
}

_extract_to_tmp() {
  local archive=$1 base_name=$2 cmd=$3
  local target_dir="$(pwd)/${base_name}_tmp"
  mkdir -p "$target_dir" || return 1

  case "$archive" in
    *.tar.bz2|*.tbz2|*.cbt) tar -xjf "$archive" -C "$target_dir" ;;
    *.tar.gz|*.tgz) tar -xzf "$archive" -C "$target_dir" ;;
    *.tar.xz|*.txz) tar -xJf "$archive" -C "$target_dir" ;;
    *.tar.zst) unzstd -c "$archive" | tar xf - -C "$target_dir" ;;
    *.tar) tar -xf "$archive" -C "$target_dir" ;;
    *.zip|*.cbz|*.epub) unzip -q "$archive" -d "$target_dir" ;;
    *.deb) dpkg-deb -x "$archive" "$target_dir" ;;
    *.cpio) cpio -id < "$archive" -D "$target_dir" ;;
    *.rar|*.cbr) unrar x -ad "$archive" "$target_dir/" ;;
    *.ace) unace x "$archive" "$target_dir/" ;;
    *.exe) cabextract "$archive" -d "$target_dir" >/dev/null 2>&1 ;;
    *) 7z x "$archive" -o"$target_dir" >/dev/null 2>&1 ;;
  esac || { rm -rf "$target_dir"; return 1; }

  _handle_extracted "$target_dir" "$base_name"
}

_extract_simple() {
  local archive=$1 out_name
  case "$archive" in
    *.gz) gunzip -c "$archive" > "${archive%.gz}" 2>/dev/null || gunzip -f "$archive" ;;
    *.bz2) bzip2 -dc "$archive" > "${archive%.bz2}" ;;
    *.xz) xz -dc "$archive" > "${archive%.xz}" ;;
  esac
}

_handle_extracted() {
  local target_dir=$1 base_name=$2
  local contents=( "$target_dir"/*(-N) )
  local count=${#contents[@]}

  if (( count == 0 )); then
    echo "ex: archive appears empty"
    rmdir "$target_dir"
    return 1
  elif (( count == 1 )) && [[ -d "${contents[1]}" ]]; then
    # Single folder: rename it to base_name and move to current dir
    local dir_name=$(basename "${contents[1]}")
    local final_dir="${base_name}"
    while [[ -e "$final_dir" ]]; do
      final_dir="${base_name}_$(date +%s)"
    done
    mv "${contents[1]}" "./$final_dir"
    rmdir "$target_dir"
    echo "Extracted to: $final_dir/"
  elif (( count == 1 )) && [[ -f "${contents[1]}" ]]; then
    # Single file: move it to current directory
    mv "${contents[1]}" .
    rmdir "$target_dir"
  else
    # Multiple items: rename temp folder to base_name
    local final_dir="${base_name}"
    while [[ -e "$final_dir" ]]; do
      final_dir="${base_name}_$(date +%s)"
    done
    mv "$target_dir" "./$final_dir"
    echo "Extracted to: $final_dir/"
  fi
}
