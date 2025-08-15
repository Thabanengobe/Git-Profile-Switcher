#!/bin/bash

CONFIG_FILE="$HOME/.gitsetup.conf"
SSH_KEY_PERSONAL="$HOME/.ssh/id_personal"
SSH_KEY_WORK="$HOME/.ssh/id_work"
SSH_CONFIG="$HOME/.ssh/config"

# ======================= Utility Functions =======================

save_config() {
  cat >"$CONFIG_FILE" <<EOF
USERNAME_WORK="$USERNAME_WORK"
EMAIL_WORK="$EMAIL_WORK"
SSH_KEY_WORK="$SSH_KEY_WORK"

USERNAME_PERSONAL="$USERNAME_PERSONAL"
EMAIL_PERSONAL="$EMAIL_PERSONAL"
SSH_KEY_PERSONAL="$SSH_KEY_PERSONAL"
EOF
}

generate_ssh_key() {
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"

  if [ "$1" = "work" ]; then
    ssh-keygen -t rsa -f "$SSH_KEY_WORK" -N "$2"
  else
    ssh-keygen -t rsa -f "$SSH_KEY_PERSONAL" -N "$2"
  fi
}

update_ssh_config() {

  if [ -f "$SSH_CONFIG" ]; then
    rm "$SSH_CONFIG"
  fi

  cat >>"$SSH_CONFIG" <<EOF
# GIT PROFILE SWITCHER
Host github.com
  HostName github.com
  User git
  IdentityFile $1
EOF

  chmod 600 "$SSH_CONFIG"
}

show_git_config() {
  local profile="$1"
  local username="$2"
  local email="$3"
  local ssh_key="$4"

  echo -e "\n\033[1;34m==================== GIT PROFILE SWITCHED ====================\033[0m"
  printf " Profile:      \033[1;33m%s\033[0m\n" "$profile"
  printf " Username:     %s\n" "$username"
  printf " Email:        %s\n" "$email"
  printf " SSH Key:      %s\n" "$ssh_key"
  echo -e "\n\033[1;32mPublic SSH Key:\033[0m"
  cat "${ssh_key}.pub" 2>/dev/null || echo "No public key found."
  echo -e "\033[1;34m===============================================================\033[0m\n"
}

setup_git_user_details() {
  git config --global user.name "$2"
  git config --global user.email "$3"

  if [ "$1" = "work" ]; then
    show_git_config "Work" "$2" "$3" "$SSH_KEY_WORK"
  else
    show_git_config "Personal" "$2" "$3" "$SSH_KEY_PERSONAL"
  fi
}

get_git_user_details() {
  echo -e "\nEnter your $1 credentials\n"

  read -rp "Enter Git username: " username
  read -rp "Enter Git email: " email
  read -sp "Enter password for your ssh key: " ssh_key_pass
  echo

  if [[ -n "$username" && -n "$email" ]]; then
    if [[ "$1" == "work" ]]; then
      USERNAME_WORK="$username"
      EMAIL_WORK="$email"
      update_ssh_config "$SSH_KEY_WORK"
    else
      USERNAME_PERSONAL="$username"
      EMAIL_PERSONAL="$email"
      update_ssh_config "$SSH_KEY_PERSONAL"
    fi

    generate_ssh_key "$1" "$ssh_key_pass"
    setup_git_user_details "$1" "$username" "$email"
    save_config
  else
    echo -e "\033[1;31mError: Username and email cannot be empty.\033[0m"
    exit 1
  fi
}

load_user_config_details() {
  [[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE" || save_config

  if [[ "$1" == "work" && -n "$USERNAME_WORK" && -n "$EMAIL_WORK" ]]; then
    setup_git_user_details "work" "$USERNAME_WORK" "$EMAIL_WORK"
  elif [[ "$1" == "personal" && -n "$USERNAME_PERSONAL" && -n "$EMAIL_PERSONAL" ]]; then
    setup_git_user_details "personal" "$USERNAME_PERSONAL" "$EMAIL_PERSONAL"
  else
    get_git_user_details "$1"
  fi
}

# ======================= CLI Argument Handling =======================

case "$1" in
"--work" | "-w")
  load_user_config_details "work"
  ;;
"--personal" | "-p")
  load_user_config_details "personal"
  ;;
"--help" | "-h")
  echo -e "
Git Profile Switcher

Usage:
  $0 [option]

Options:
  -w, --work         Switch to Work Git profile (username, email, SSH key)
  -p, --personal     Switch to Personal Git profile
  -h, --help         Show this help message

Description:
  Quickly switch between GitHub profiles (Work & Personal).
  Updates:
    • Git username and email
    • SSH key configuration for GitHub
    • Saves details for reuse

Examples:
  $0 -w         # Switch to Work profile
  $0 -p         # Switch to Personal profile

SSH Keys:
  Stored in:
    Work:      ~/.ssh/id_work
    Personal:  ~/.ssh/id_personal
"
  ;;
*)
  echo -e "\033[1;31mUnknown option: $1\033[0m"
  echo "Use: $0 --help for usage information."
  exit 1
  ;;
esac
