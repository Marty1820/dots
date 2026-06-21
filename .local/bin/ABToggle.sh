#!/usr/bin/env sh
set -u

SERVICE="AB.service"
NOTIFY_APP='bk-lit'
LOG_TAG='brightness-toggle'

# Ensure you're in a graphical session
if [ -z "${DISPLAY:-}" ] && [ -z "${WAYLAND_DISPLAY:-}" ]; then
  echo "[${LOG_TAG}] Error: No graphical session detected" >&2
  exit 1
fi

notify() {
  # Silent notification if D-Bus unavailable
  notify-send -t 1000 -a "$NOTIFY_APP" "$1" >/dev/null 2>&1 || true
}

notify_critical() {
  # Critical notification for failures
  notify-send -u critical -t 5000 -a "$NOTIFY_APP" "$1" >/dev/null 2>&1 || true
}

# Toggle logic with proper error capture
if systemctl --user is-active --quiet "$SERVICE" 2>/dev/null; then
  # Service is currently running — stop it
  if systemctl --user stop "$SERVICE"; then
    notify "Adaptive Brightness off"
    exit 0
  else
    msg="Failed to stop ${SERVICE}"
    echo "[${LOG_TAG}] $msg" >&2
    notify_critical "$msg"
    journalctl --user -xe -n 10 2>/dev/null | tail -n 5 >&2
    exit 3
  fi
else
  # Service is stopped/inactive — start it
  if systemctl --user start "$SERVICE"; then
    # Give it a moment to become active
    sleep 0.5
    if systemctl --user is-active --quiet "$SERVICE"; then
      notify "Adaptive Brightness on"
      exit 0
    else
      msg="${SERVICE} failed to activate after start"
      echo "[${LOG_TAG}] $msg" >&2
      notify_critical "$msg"
      exit 4
    fi
  else
    msg="Failed to start ${SERVICE}"
    echo "[${LOG_TAG}] $msg" >&2
    notify_critical "$msg"
    journalctl --user -xe -n 5 2>/dev/null | tail -n 3 >&2
    exit 5
  fi
fi
