# 🔄 Git Profile Switcher

A simple Bash CLI for quickly switching between **personal** and **work** GitHub profiles — including Git username, email, and SSH key configuration.  
Perfect for developers who use **multiple GitHub accounts** on the same machine.

---

## 📌 Features

- Store and reuse **work** and **personal** Git configuration.
- Automatically **generate SSH keys** for each profile.
- Update your SSH config so GitHub uses the correct key.
- Display your current Git username and email.
- Simple profile switching with one command.

---

## ⚙️ Installation

1. **Clone this repository**

   ```bash
   git clone https://github.com/<yourusername>/git-profile-switcher.git
   cd git-profile-switcher
   ```

2. **Make the script executable**

   ```bash
   chmod +x git-switcher.sh
   ```

3. **(Optional) Move it to a folder in your PATH**

   ```bash
   sudo mv git-switcher.sh /usr/local/bin/git-switcher
   ```
