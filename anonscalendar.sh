#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
BLUE='\033[0;34m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# ── System Date Detection ──────────────────────────────────
CURRENT_DAY=$(date +%-d)
CURRENT_MONTH=$(date +%-m)
CURRENT_YEAR=$(date +%Y)
CURRENT_DOW=$(date +%A)
CURRENT_DATE_FULL=$(date +"%A, %B %d, %Y")
CURRENT_TIME=$(date +"%I:%M:%S %p")

VIEWED_MONTH=$CURRENT_MONTH
VIEWED_YEAR=$CURRENT_YEAR

show_banner() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "  ╔══════════════════════════════════════════════════════════════════════════╗"
    echo "  ║                                                                          ║"
    echo "  ║   █████╗ ███╗   ██╗ ██████╗ ███╗   ██╗███████╗                         ║"
    echo "  ║  ██╔══██╗████╗  ██║██╔═══██╗████╗  ██║██╔════╝                         ║"
    echo "  ║  ███████║██╔██╗ ██║██║   ██║██╔██╗ ██║███████╗                         ║"
    echo "  ║  ██╔══██║██║╚██╗██║██║   ██║██║╚██╗██║╚════██║                         ║"
    echo "  ║  ██║  ██║██║ ╚████║╚██████╔╝██║ ╚████║███████║                         ║"
    echo "  ║  ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝                         ║"
    echo "  ║                                                                          ║"
    echo "  ║  ██╗   ██╗███████╗ █████╗ ██████╗ ██╗  ██╗   ██╗                       ║"
    echo "  ║  ╚██╗ ██╔╝██╔════╝██╔══██╗██╔══██╗██║  ╚██╗ ██╔╝                       ║"
    echo "  ║   ╚████╔╝ █████╗  ███████║██████╔╝██║   ╚████╔╝                        ║"
    echo "  ║    ╚██╔╝  ██╔══╝  ██╔══██║██╔══██╗██║    ╚██╔╝                         ║"
    echo "  ║     ██║   ███████╗██║  ██║██║  ██║███████╗██║                           ║"
    echo "  ║     ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝                          ║"
    echo "  ║                                                                          ║"
    echo "  ║   ██████╗ █████╗ ██╗     ███████╗███╗   ██╗██████╗  █████╗ ██████╗     ║"
    echo "  ║  ██╔════╝██╔══██╗██║     ██╔════╝████╗  ██║██╔══██╗██╔══██╗██╔══██╗    ║"
    echo "  ║  ██║     ███████║██║     █████╗  ██╔██╗ ██║██║  ██║███████║██████╔╝    ║"
    echo "  ║  ██║     ██╔══██║██║     ██╔══╝  ██║╚██╗██║██║  ██║██╔══██║██╔══██╗    ║"
    echo "  ║  ╚██████╗██║  ██║███████╗███████╗██║ ╚████║██████╔╝██║  ██║██║  ██║    ║"
    echo "  ║   ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝   ║"
    echo "  ║                                                                          ║"
    echo "  ╠══════════════════════════════════════════════════════════════════════════╣"
    echo -e "  ║${MAGENTA}                    c0d3d By @non G00nz                                  ${CYAN}║"
    echo "  ╚══════════════════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
}

# ── Helpers ────────────────────────────────────────────────
is_leap_year() {
    local y=$1
    if (( y % 400 == 0 )) || (( y % 4 == 0 && y % 100 != 0 )); then
        echo 1
    else
        echo 0
    fi
}

days_in_month() {
    local m=$1 y=$2
    local days=(0 31 28 31 30 31 30 31 31 30 31 30 31)
    if [[ $m -eq 2 ]] && [[ $(is_leap_year $y) -eq 1 ]]; then
        echo 29
    else
        echo "${days[$m]}"
    fi
}

month_name() {
    local names=("" "January" "February" "March" "April" "May" "June"
                 "July" "August" "September" "October" "November" "December")
    echo "${names[$1]}"
}

month_short() {
    local names=("" "Jan" "Feb" "Mar" "Apr" "May" "Jun"
                 "Jul" "Aug" "Sep" "Oct" "Nov" "Dec")
    echo "${names[$1]}"
}

# Returns 0=Sun 1=Mon ... 6=Sat for the 1st of given month/year
first_dow() {
    local m=$1 y=$2
    date -d "$y-$(printf '%02d' $m)-01" +%w 2>/dev/null \
        || python3 -c "import datetime; print(datetime.date($y,$m,1).weekday())" 2>/dev/null \
        || python -c "import datetime; print datetime.date($y,$m,1).weekday()" 2>/dev/null
}

# ── Single Month Calendar Renderer ────────────────────────
draw_month() {
    local m=$1 y=$2 highlight_today=$3
    local dim=$(days_in_month $m $y)
    local fdow=$(first_dow $m $y)
    # Convert Monday-based (python) to Sunday-based if needed
    # date +%w gives 0=Sun..6=Sat, so we keep that
    local mname=$(month_name $m)
    local header=$(printf "%s %d" "$mname" "$y")
    local hlen=${#header}
    local pad=$(( (20 - hlen) / 2 ))

    echo -e "${YELLOW}${BOLD}$(printf '%*s' $pad '')$header${RESET}"
    echo -e "${CYAN} Su Mo Tu We Th Fr Sa${RESET}"

    local col=$fdow
    local line=""
    # Leading spaces
    for (( i=0; i<col; i++ )); do
        line+="   "
    done

    for (( d=1; d<=dim; d++ )); do
        if [[ $highlight_today -eq 1 ]] && \
           [[ $d -eq $CURRENT_DAY ]] && \
           [[ $m -eq $CURRENT_MONTH ]] && \
           [[ $y -eq $CURRENT_YEAR ]]; then
            line+="${RED}${BOLD}$(printf '%2d' $d)${RESET} "
        else
            # Weekend coloring
            if [[ $col -eq 0 ]] || [[ $col -eq 6 ]]; then
                line+="${MAGENTA}$(printf '%2d' $d)${RESET} "
            else
                line+="${WHITE}$(printf '%2d' $d)${RESET} "
            fi
        fi
        col=$(( (col + 1) % 7 ))
        if [[ $col -eq 0 ]]; then
            echo -e " $line"
            line=""
        fi
    done
    if [[ -n "$line" ]]; then
        echo -e " $line"
    fi
}

# ── Today Panel ────────────────────────────────────────────
show_today_panel() {
    echo -e "${CYAN}  ╔══════════════════════════════════════════════╗"
    echo -e "  ║${YELLOW}${BOLD}                  TODAY'S DATE                ${CYAN}║"
    echo -e "  ╠══════════════════════════════════════════════╣"
    printf "  ${CYAN}║${WHITE}  %-44s${CYAN}║\n" "Date : $CURRENT_DATE_FULL"
    printf "  ${CYAN}║${WHITE}  %-44s${CYAN}║\n" "Time : $CURRENT_TIME"
    printf "  ${CYAN}║${WHITE}  %-44s${CYAN}║\n" "Day  : $CURRENT_DOW"
    printf "  ${CYAN}║${WHITE}  %-44s${CYAN}║\n" "Year : $CURRENT_YEAR"
    echo -e "  ╚══════════════════════════════════════════════╝${RESET}"
    echo ""
}

# ── Single Month View ──────────────────────────────────────
show_single_month() {
    show_banner
    show_today_panel
    local m=$VIEWED_MONTH
    local y=$VIEWED_YEAR
    local mname=$(month_name $m)

    echo -e "${BLUE}  ╔══════════════════════════╗"
    echo -e "  ║${YELLOW}${BOLD}   $mname $y$(printf '%*s' $((15 - ${#mname} - ${#y})) '')${BLUE}     ║"
    echo -e "  ╚══════════════════════════╝${RESET}"
    echo ""
    draw_month $m $y 1
    echo ""
}

# ── Full Year View (3-column grid) ────────────────────────
show_full_year() {
    show_banner
    show_today_panel

    echo -e "${YELLOW}${BOLD}  ══════════════════════════════════════════════════════════════${RESET}"
    echo -e "${CYAN}${BOLD}$(printf '%*s' 28 '')FULL YEAR $VIEWED_YEAR${RESET}"
    echo -e "${YELLOW}${BOLD}  ══════════════════════════════════════════════════════════════${RESET}"
    echo ""

    for row in 0 1 2 3; do
        local months_in_row=()
        for col in 1 2 3; do
            months_in_row+=( $(( row * 3 + col )) )
        done

        # Capture each month as array of lines
        declare -a m1_lines m2_lines m3_lines
        while IFS= read -r line; do m1_lines+=("$line"); done < <(draw_month ${months_in_row[0]} $VIEWED_YEAR 1)
        while IFS= read -r line; do m2_lines+=("$line"); done < <(draw_month ${months_in_row[1]} $VIEWED_YEAR 1)
        while IFS= read -r line; do m3_lines+=("$line"); done < <(draw_month ${months_in_row[2]} $VIEWED_YEAR 1)

        local max=0
        [[ ${#m1_lines[@]} -gt $max ]] && max=${#m1_lines[@]}
        [[ ${#m2_lines[@]} -gt $max ]] && max=${#m2_lines[@]}
        [[ ${#m3_lines[@]} -gt $max ]] && max=${#m3_lines[@]}

        for (( i=0; i<max; i++ )); do
            local l1="${m1_lines[$i]:-}"
            local l2="${m2_lines[$i]:-}"
            local l3="${m3_lines[$i]:-}"
            # Strip ANSI for length calculation
            local plain1=$(echo -e "$l1" | sed 's/\x1b\[[0-9;]*m//g')
            local plain2=$(echo -e "$l2" | sed 's/\x1b\[[0-9;]*m//g')
            local pad1=$(( 22 - ${#plain1} ))
            local pad2=$(( 22 - ${#plain2} ))
            printf "    %b%*s    %b%*s    %b\n" \
                "$l1" $pad1 "" \
                "$l2" $pad2 "" \
                "$l3"
        done
        echo ""
        unset m1_lines m2_lines m3_lines
    done
}

# ── Year Overview Strip ────────────────────────────────────
show_year_strip() {
    show_banner
    show_today_panel
    echo -e "${YELLOW}${BOLD}  Year Overview: $VIEWED_YEAR${RESET}"
    echo -e "${CYAN}  ─────────────────────────────────────────────────────────────${RESET}"
    echo ""
    for m in {1..12}; do
        local mname=$(month_name $m)
        local dim=$(days_in_month $m $VIEWED_YEAR)
        local tag=""
        if [[ $m -eq $CURRENT_MONTH ]] && [[ $VIEWED_YEAR -eq $CURRENT_YEAR ]]; then
            tag="${RED}${BOLD} << CURRENT MONTH${RESET}"
        fi
        printf "  ${CYAN}%-12s${WHITE} %2d days   ${YELLOW}%d${tag}\n" \
            "$mname" "$dim" "$VIEWED_YEAR"
        echo -e "${RESET}"
    done
}

# ── Navigation Menu ────────────────────────────────────────
show_nav_menu() {
    local mname=$(month_name $VIEWED_MONTH)
    echo -e "${BLUE}  ╔════════════════════════════════════════╗"
    echo -e "  ║${WHITE}  Viewing : ${YELLOW}$mname $VIEWED_YEAR$(printf '%*s' $((20 - ${#mname} - ${#VIEWED_YEAR})) '')${BLUE}     ║"
    echo -e "  ╠════════════════════════════════════════╣"
    echo -e "  ║  ${GREEN}[1]${WHITE} View This Month                  ${BLUE}║"
    echo -e "  ║  ${GREEN}[2]${WHITE} View Full Year Grid              ${BLUE}║"
    echo -e "  ║  ${GREEN}[3]${WHITE} View Year Strip Overview         ${BLUE}║"
    echo -e "  ║  ${GREEN}[4]${WHITE} Next Month  >>>                  ${BLUE}║"
    echo -e "  ║  ${GREEN}[5]${WHITE} Prev Month  <<<                  ${BLUE}║"
    echo -e "  ║  ${GREEN}[6]${WHITE} Next Year   >>>                  ${BLUE}║"
    echo -e "  ║  ${GREEN}[7]${WHITE} Prev Year   <<<                  ${BLUE}║"
    echo -e "  ║  ${GREEN}[8]${WHITE} Jump to Specific Month/Year      ${BLUE}║"
    echo -e "  ║  ${GREEN}[9]${WHITE} Return to Today                  ${BLUE}║"
    echo -e "  ║  ${RED}[0]${WHITE} Exit                             ${BLUE}║"
    echo -e "  ╚════════════════════════════════════════╝${RESET}"
    echo -ne "${YELLOW}  Choose [0-9]: ${WHITE}"
}

# ── Jump to Month ──────────────────────────────────────────
jump_to_date() {
    echo -ne "${YELLOW}  Enter month (1-12): ${WHITE}"
    read jm
    echo -ne "${YELLOW}  Enter year (e.g. 2025): ${WHITE}"
    read jy
    if [[ "$jm" =~ ^[0-9]+$ ]] && [[ "$jy" =~ ^[0-9]+$ ]] && \
       [[ $jm -ge 1 ]] && [[ $jm -le 12 ]]; then
        VIEWED_MONTH=$((10#$jm))
        VIEWED_YEAR=$((10#$jy))
        echo -e "${GREEN}  Jumped to $(month_name $VIEWED_MONTH) $VIEWED_YEAR${RESET}"
    else
        echo -e "${RED}  [!] Invalid input.${RESET}"
    fi
    sleep 1
}

# ── Main Loop ──────────────────────────────────────────────
show_banner
show_today_panel
echo -e "${CYAN}  Loading Anon's Yearly Calendar...${RESET}"
sleep 1

while true; do
    show_single_month
    show_nav_menu
    read choice
    case "$choice" in
        1)
            show_single_month
            echo -ne "${CYAN}  Press [ENTER] to continue...${RESET}"
            read
            ;;
        2)
            show_full_year
            echo -ne "${CYAN}  Press [ENTER] to continue...${RESET}"
            read
            ;;
        3)
            show_year_strip
            echo -ne "${CYAN}  Press [ENTER] to continue...${RESET}"
            read
            ;;
        4)
            VIEWED_MONTH=$(( VIEWED_MONTH + 1 ))
            if [[ $VIEWED_MONTH -gt 12 ]]; then
                VIEWED_MONTH=1
                VIEWED_YEAR=$(( VIEWED_YEAR + 1 ))
            fi
            ;;
        5)
            VIEWED_MONTH=$(( VIEWED_MONTH - 1 ))
            if [[ $VIEWED_MONTH -lt 1 ]]; then
                VIEWED_MONTH=12
                VIEWED_YEAR=$(( VIEWED_YEAR - 1 ))
            fi
            ;;
        6)
            VIEWED_YEAR=$(( VIEWED_YEAR + 1 ))
            ;;
        7)
            VIEWED_YEAR=$(( VIEWED_YEAR - 1 ))
            ;;
        8)
            jump_to_date
            ;;
        9)
            VIEWED_MONTH=$CURRENT_MONTH
            VIEWED_YEAR=$CURRENT_YEAR
            CURRENT_TIME=$(date +"%I:%M:%S %p")
            echo -e "${GREEN}  Returned to today: $CURRENT_DATE_FULL${RESET}"
            sleep 1
            ;;
        0)
            clear
            echo -e "${MAGENTA}${BOLD}"
            echo "  ╔══════════════════════════════════════════════╗"
            echo -e "  ║     Anon's Yearly Calendar - Session End     ║"
            echo -e "  ║          c0d3d By @non G00nz                 ║"
            echo "  ╚══════════════════════════════════════════════╝"
            echo -e "${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}  [!] Invalid option. Choose between 0 and 9.${RESET}"
            sleep 1
            ;;
    esac
done

