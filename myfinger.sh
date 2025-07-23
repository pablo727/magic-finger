#!/bin/bash

# ── Colors ───────────────────────────────────────────────
bold="\033[1m"
reset="\033[0m"
blue="\033[34m"
green="\033[32m"
cyan="\033[36m"
red="\033[31m"

# ── Default Target User ──────────────────────────────────
user="${USER}"

# ── Parse Flags ──────────────────────────────────────────
show_markdown=false
copy_to_clipboard=false
all_users=false

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --markdown) show_markdown=true ;;
        --copy) copy_to_clipboard=true ;;
        --all) all_users=true ;;
        *) echo -e "${red}Unknown option: $1${reset}" && exit 1 ;;
    esac
    shift
done

# ── Function: Get and Print Info ─────────────────────────
print_user_info() {
    local user="$1"
    IFS=":" read -r username _ uid gid realname homedir shell <<< "$(getent passwd "$user")"
    last_login=$(lastlog -u "$user" | awk 'NR==2 {print $4, $5, $6, $7}')
    logged_in=$(who | rg "^$user" | wc -l)
    uptime_info=$(uptime -p)
    file_count=$(find "$homedir" -type f 2>/dev/null | wc -l)

    output=$(cat <<EOF
${bold}${blue}👤 Username    ${reset}: $username
${bold}${blue}📛 Real Name   ${reset}: $realname
${bold}${blue}🏠 Home Dir    ${reset}: $homedir
${bold}${blue}🖥️  Shell       ${reset}: $shell
${bold}${blue}🕘 Last Login  ${reset}: $last_login
${bold}${blue}✅ Logged In   ${reset}: $( [ "$logged_in" -gt 0 ] && echo "${green}Yes${reset}" || echo "${red}No${reset}" )
${bold}${blue}📈 System Uptime${reset}: $uptime_info
${bold}${blue}📄 Files in Home${reset}: $file_count
EOF
)

    echo -e "$output"

    # ── Markdown Export ───────────────────────────
    if $show_markdown; then
        output_md="/tmp/user_${username}.md"
        cat << MD > "$output_md"
# 👤 User Info: \`$username\`

- **Real Name**: $realname
- **Home Dir**: $homedir
- **Shell**: \`$shell\`
- **Last Login**: $last_login
- **Logged In**: $( [ "$logged_in" -gt 0 ] && echo "✅ Yes" || echo "❌ No" )
- **System Uptime**: $uptime_info
- **Files in Home**: $file_count

MD
        glow "$output_md"
    fi

    # ── Copy to Clipboard ─────────────────────────
    if $copy_to_clipboard; then
        if command -v xclip &>/dev/null; then
            echo -e "$output" | xclip -selection clipboard
            echo -e "${green}📋 Copied to clipboard (xclip)!${reset}"
        elif command -v pbcopy &>/dev/null; then
            echo -e "$output" | pbcopy
            echo -e "${green}📋 Copied to clipboard (pbcopy)!${reset}"
        else
            echo -e "${red}Clipboard tool not found (xclip or pbcopy)${reset}"
        fi
    fi
}

# ── Main Execution ──────────────────────────────────────
if $all_users; then
    for u in $(cut -d: -f1 /etc/passwd); do
        if id "$u" &>/dev/null; then
            echo -e "\n${cyan}===== $u =====${reset}"
            print_user_info "$u"
        fi
    done
else
    print_user_info "$user"
fi
