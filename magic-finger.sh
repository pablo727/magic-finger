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
output_json=false
minimal_mode=false

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --markdown) show_markdown=true ;;
        --copy) copy_to_clipboard=true ;;
        --all) all_users=true ;;
        --json) output_json=true ;;
        --minimal) minimal_mode=true ;;
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

    if $output_json; then
        jq -n \
            --arg username "$username" \
            --arg realname "$realname" \
            --arg homedir "$homedir" \
            --arg shell "$shell" \
            --arg last_login "$last_login" \
            --arg logged_in "$([ "$logged_in" -gt 0 ] && echo "Yes" || echo "No")" \
            --arg uptime "$uptime_info" \
            --arg file_count "$file_count" \
            '{
                username: $username,
                realname: $realname,
                homedir: $homedir,
                shell: $shell,
                last_login: $last_login,
                logged_in: $logged_in,
                system_uptime: $uptime,
                home_file_count: ($file_count | tonumber)
            }'
        return
    fi

    # ── Output formatting ────────────────────────────────
    if $minimal_mode; then
        output=$(cat <<EOF
Username       : $username
Real Name      : $realname
Home Directory : $homedir
Shell          : $shell
Last Login     : $last_login
Logged In      : $( [ "$logged_in" -gt 0 ] && echo "Yes" || echo "No" )
System Uptime  : $uptime_info
Files in Home  : $file_count
EOF
)
    else
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
    fi

    echo -e "$output"

    # ── Markdown Export ───────────────────────────
    if $show_markdown && ! $minimal_mode && ! $output_json; then
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
    if $copy_to_clipboard && ! $output_json; then
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
            $output_json || $minimal_mode || echo -e "\n${cyan}===== $u =====${reset}"
            print_user_info "$u"
        fi
    done
else
    print_user_info "$user"
fi
