#!/bin/bash

# Ensure the script is run with root privileges
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root (use sudo)"
  exit 1
fi

# 1. Install the Google Authenticator module if not present
if ! dpkg -l | grep -q libpam-google-authenticator; then
    echo "Installing libpam-google-authenticator..."
    apt update && apt install -y libpam-google-authenticator
fi

# 2. Identify the target user
TARGET_USER="ubuntu"

# Verify user exists
if ! id "$TARGET_USER" &>/dev/null; then
    echo "Error: User '$TARGET_USER' does not exist."
    exit 1
fi

PAM_FILE="/etc/pam.d/common-auth"

# 3. Create a backup of the PAM file
cp "$PAM_FILE" "${PAM_FILE}.bak"
echo "Backup created at ${PAM_FILE}.bak"

# 4. Inject the logic
# We place this at the top of the auth section to ensure it triggers before standard password auth
# The logic: If user is NOT the target, skip the next line (the 2FA requirement).
sed -i "1i auth [success=done default=ignore] pam_succeed_if.so user != $TARGET_USER" "$PAM_FILE"
sed -i "2i auth required pam_google_authenticator.so" "$PAM_FILE"

echo "--------------------------------------------------------"
echo "Success! 2FA is now enforced ONLY for: $TARGET_USER"
echo "IMPORTANT: The user must now run 'google-authenticator' in their"
echo "terminal to generate their secret key and QR code, or they"
echo "will be unable to log in."
echo "--------------------------------------------------------"