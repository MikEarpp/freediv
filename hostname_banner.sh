#!/bin/bash

declare -A colors; E=$'\e'
colors=(["sage"]="135;151;122" ["purple"]="189;147;249"    ["cyan"]="139;233;253"  ["deep-blue"]="52;59;88"
        ["mint"]="95;175;135"  ["forest"]="34;139;34"      ["coral"]="255;184;108" ["black"]="0;0;0"
        ["gray"]="68;71;90"    ["off-white"]="248;248;242" ["teal"]="0;128;128"    ["brick"]="227;95;95"
        ["emerald"]="26;94;99" ["oracle-red"]="199;70;52"  ["reset"]="${E}[0m")

#----------------------------------------------------------------------------------------------------------------
color_keys=("${!colors[@]}")
get_rand() { echo "${color_keys[$RANDOM % ${#color_keys[@]}]}"; }
is_valid() { [[ -n "$1" && -n "${colors[$1]}" ]]; }
show_help() {
    local c_title="${E}[1;38;2;${colors["cyan"]}m"
    local c_opt="${E}[38;2;${colors["coral"]}m"
    local c_param="${E}[38;2;${colors["sage"]}m"
    local c_reset="${colors["reset"]}"
    cat << EOF

${c_title}COCO.SH - Affichage Système Colorisé${c_reset}

${c_title}USAGE:${c_reset}
    ./coco.sh [OPTIONS]

${c_title}OPTIONS:${c_reset}
    ${c_opt}-b   ${c_param}[couleur]${c_reset}  Couleur de fond principale (ligne OS)
    ${c_opt}-b4  ${c_param}[couleur]${c_reset}  Couleur de fond secondaire (lignes Logo)
    ${c_opt}-c   ${c_param}[couleur]${c_reset}  Couleur du texte principal
    ${c_opt}-c4  ${c_param}[couleur]${c_reset}  Couleur du texte secondaire
    ${c_opt}-bl  ${c_param}[couleur]${c_reset}  Couleur de fond du bloc logo
    ${c_opt}-fl  ${c_param}[couleur]${c_reset}  Couleur des caractères du logo
    ${c_opt}-m   ${c_param}[suffixe]${c_reset}  Modifie le mot de recherche et limite la hauteur
    ${c_opt}-wl${c_reset}            Désactive le logo
    ${c_opt}-x${c_reset}             Désactive le remplissage d'espaces (full_space=0)
    ${c_opt}-h${c_reset}             Affiche cette aide

${c_title}COULEURS DISPONIBLES:${c_reset}
    $(echo "${!colors[@]}" | fmt -w 60 | sed 's/^/    /')

${c_title}EXEMPLE:${c_reset}
    ./coco.sh -b deep-blue -c cyan -fl oracle-red

EOF
}

get_hostname() {
    local hn=$(hostname --short)
    grep -Fx "$hn" "$0" > /dev/null 2>&1 && echo "$hn" || echo "null"
}
#----------------------------------------------------------------------------------------------------------------
b_color="deep-blue"; b4_color="$b_color"
f_color="cyan";      f4_color="coral"
bl_color="$b_color"; fl_color="oracle-red"
hostn_max=5
full_space=1; with_logo=1
word=$(get_hostname)

while [[ $# -gt 0 ]]; do
    offset=2
    case "$1" in
        -b)  if is_valid "$2"; then b_color="$2";  else b_color=$(get_rand); fi ;;
        -b4) if is_valid "$2"; then b4_color="$2"; else b4_color=$(get_rand); fi ;;
        -c)  if is_valid "$2"; then f_color="$2";  else f_color=$(get_rand); fi ;;
        -c4) if is_valid "$2"; then f4_color="$2"; else f4_color=$(get_rand); fi ;;
        -bl) if is_valid "$2"; then bl_color="$2"; else bl_color=$(get_rand); fi ;;
        -fl) if is_valid "$2"; then fl_color="$2"; else fl_color=$(get_rand); fi ;;
        -wl) with_logo=0; offset=1 ;;
        -m)  if [ " $2 " != *" 2 "* ]; then word="$word$2"; hostn_max=4; fi ;;
        -x)  full_space=0; offset=1 ;;
        -h)  show_help; exit 0 ;;
        *)   echo "Option invalide: $1" >&2; "$0" -h; exit 1 ;;
    esac
    (( $# < offset )) && { "$0" -h; exit 1; }
    shift $offset
done

for _ in {1..10}; do [[ "$b_color" != "$f_color" ]] && break; f_color=$(get_rand); done
for _ in {1..10}; do [[ "$b4_color" != "$f4_color" ]] && break; f4_color=$(get_rand); done
for _ in {1..10}; do [[ "$bl_color" != "$fl_color" ]] && break; fl_color=$(get_rand); done
bl_val="${colors[$bl_color]}";  fl_val="${colors[$fl_color]}"
bg_val="${colors[$b_color]}";   fg_val="${colors[$f_color]}"
bg4_val="${colors[$b4_color]}"; fg4_val="${colors[$f4_color]}"

mapfile -t hostn < <(grep -m 1 -B $hostn_max -F "$word" "$0" | head -n $hostn_max)
[ "$with_logo" == "1" ] && { mapfile -t logo < <(grep -B 3 -E "^oracle *" "$0" | head -n 3); }
nb_char="${#logo[0]}"
: "${nb_char:=0}"
max=${#hostn[0]}

# ajout de lOS
width=${#hostn[0]}; str="???"
(( width == 0 )) && width=33 
if [ -f /etc/alpine-release ]; then
    str="Alpine v$(cat /etc/alpine-release)"
elif [ -f /etc/os-release ]; then
    source /etc/os-release
    [[ -z "$ID" || -z "$VERSION" ]] && str="$PRETTY_NAME" || str="${ID^} $VERSION"
fi
hostn+=( "$(printf "%-${width}.${width}s" "$str")" )

# ajout du logo
for i in "${!logo[@]}"; do hostn[hostn_max-${#logo[@]}+i+1]+="${E}[48;2;${bl_val}m${E}[38;2;${fl_val}m${logo[i]}${colors["reset"]}"; done
# tableau colorisé final
lignes_sans_logo=$(( ${#hostn[@]} - ${#logo[@]} ))
for i in "${!hostn[@]}"; do
    # remplissage au dessus du logo si besoin
    [ "$full_space" == "1" ] && (( i < lignes_sans_logo )) && hostn[i]+="$(printf "%${nb_char}s" "")"
    (( i == ${#hostn[@]} - 1 )) && printf "${E}[48;2;%sm${E}[38;2;%sm%s${colors["reset"]}\n" "${bg_val}" "${fg_val}" "${hostn[$i]}" || \
        printf "${E}[48;2;%sm${E}[38;2;%sm%s${colors["reset"]}\n" "${bg4_val}" "${fg4_val}" "${hostn[$i]}"
done
exit 0
#----------------------------------------------------------------------------------------------------------------
⣠⡶⠶⠶⢦⡀⢰⡶⠶⢶⡀⠀⣠⣶⡄⠀⣠⠶⠶⠶⠂⢰⡆⠀⠀⢠⠶⠶⠶⠂
⢿⣄⣀⣀⣼⠇⢸⡗⢶⣞⠀⣰⠏⠬⢿⡄⢿⣄⣀⣀⠀⢸⣇⣀⡀⢻⣏⣉⣉⡉
⠀⠈⠉⠉⠀⠀⠈⠁⠀⠉⠀⠉⠀⠀⠀⠉⠀⠈⠉⠁⠀⠈⠉⠉⠀⠀⠈⠉⠉⠀
oracle   
https://patorjk.com/software/taag/ (standard - Small Block)

slant              _                     __              __                                           
  _______  _______(_)__                 / /_  ___  _____/ /_____               ____ __________ ___  __ 
 / ___/ / / / ___/ / _ \               / __ \/ _ \/ ___/ __/_  /              / __ `/ ___/ __ `/ / / / 
/ /__/ /_/ / /  / /  __/              / / / /  __/ /  / /_  / /_             / /_/ / /  / /_/ / /_/ /  
\___/\__,_/_/  /_/\___/              /_/ /_/\___/_/   \__/ /___/             \__, /_/   \__,_/\__, /   
                                                                            /____/           /____/    
small slant    _             __           __                               
 ______ ______(_)__         / /  ___ ____/ /____        ___ ________ ___ __
/ __/ // / __/ / -_)       / _ \/ -_) __/ __/_ /       / _ `/ __/ _ `/ // /
\__/\_,_/_/ /_/\__/       /_//_/\__/_/  \__//__/       \_, /_/  \_,_/\_, / 
                                                      /___/         /___/  
      ▜▜ 
▛▀▖▌ ▌▐▐ 
▌ ▌▌ ▌▐▐ 
▘ ▘▝▀▘ ▘▘
null
             _ _ 
 _ __  _   _| | |
| '_ \| | | | | |
| | | | |_| | | |
|_| |_|\__,_|_|_|
null2
            _ _   
__   _____ | | |_ 
\ \ / / _ \| | __|
 \ V / (_) | | |_ 
  \_/ \___/|_|\__|
volt
      ▜▐  
▌ ▌▞▀▖▐▜▀ 
▐▐ ▌ ▌▐▐ ▖
 ▘ ▝▀  ▘▀ 
volt2
  __                     _ 
 / _| __ _ _ __ __ _  __| |
| |_ / _` | '__/ _` |/ _` |
|  _| (_| | | | (_| | (_| |
|_|  \__,_|_|  \__,_|\__,_|
farad
▗▀▖           ▌
▐  ▝▀▖▙▀▖▝▀▖▞▀▌
▜▀ ▞▀▌▌  ▞▀▌▌ ▌
▐  ▝▀▘▘  ▝▀▘▝▀▘
farad2
 _                            
| |_   _ _ __ ___   ___ _ __  
| | | | | '_ ` _ \ / _ \ '_ \ 
| | |_| | | | | | |  __/ | | |
|_|\__,_|_| |_| |_|\___|_| |_|
lumen
▜              
▐ ▌ ▌▛▚▀▖▞▀▖▛▀▖
▐ ▌ ▌▌▐ ▌▛▀ ▌ ▌
 ▘▝▀▘▘▝ ▘▝▀▘▘ ▘
lumen2
 _
| |_   ___  __
| | | | \ \/ /
| | |_| |>  < 
|_|\__,_/_/\_\
lux
▜       
▐ ▌ ▌▚▗▘
▐ ▌ ▌▗▚ 
 ▘▝▀▘▘ ▘
 lux2
  __ _ _ __ __ _ _   _ 
 / _` | '__/ _` | | | |
| (_| | | | (_| | |_| |
 \__, |_|  \__,_|\__, |
 |___/           |___/ 
gray

▞▀▌▙▀▖▝▀▖▌ ▌
▚▄▌▌  ▞▀▌▚▄▌
▗▄▘▘  ▝▀▘▗▄▘
gray2
                 _      
 _ __ ___   ___ | | ___ 
| '_ ` _ \ / _ \| |/ _ \
| | | | | | (_) | |  __/
|_| |_| |_|\___/|_|\___|
mole
       ▜    
▛▚▀▖▞▀▖▐ ▞▀▖
▌▐ ▌▌ ▌▐ ▛▀ 
▘▝ ▘▝▀  ▘▝▀▘
mole2
 _         _        _ 
| | ____ _| |_ __ _| |
| |/ / _` | __/ _` | |
|   < (_| | || (_| | |
|_|\_\__,_|\__\__,_|_|
katal
▌     ▐     ▜ 
▌▗▘▝▀▖▜▀ ▝▀▖▐ 
▛▚ ▞▀▌▐ ▖▞▀▌▐ 
▘ ▘▝▀▘ ▀ ▝▀▘ ▘
katal2
              _               
__      _____| |__   ___ _ __ 
\ \ /\ / / _ \ '_ \ / _ \ '__|
 \ V  V /  __/ |_) |  __/ |   
  \_/\_/ \___|_.__/ \___|_|   
weber
       ▌        
▌  ▌▞▀▖▛▀▖▞▀▖▙▀▖
▐▐▐ ▛▀ ▌ ▌▛▀ ▌  
 ▘▘ ▝▀▘▀▀ ▝▀▘▘  
 weber2
       _               
  ___ | |__  _ __ ___  
 / _ \| '_ \| '_ ` _ \ 
| (_) | | | | | | | | |
 \___/|_| |_|_| |_| |_|
ohm
   ▌      
▞▀▖▛▀▖▛▚▀▖
▌ ▌▌ ▌▌▐ ▌
▝▀ ▘ ▘▘▝ ▘
ohm2
               _   _   
__      ____ _| |_| |_ 
\ \ /\ / / _` | __| __|
 \ V  V / (_| | |_| |_ 
  \_/\_/ \__,_|\__|\__|
watt
       ▐  ▐  
▌  ▌▝▀▖▜▀ ▜▀ 
▐▐▐ ▞▀▌▐ ▖▐ ▖
 ▘▘ ▝▀▘ ▀  ▀ 
 watt2
 _               _       
| |__   ___ _ __| |_ ____
| '_ \ / _ \ '__| __|_  /
| | | |  __/ |  | |_ / / 
|_| |_|\___|_|   \__/___|
hertz
▌        ▐     
▛▀▖▞▀▖▙▀▖▜▀ ▀▜▘
▌ ▌▛▀ ▌  ▐ ▖▗▘ 
▘ ▘▝▀▘▘   ▀ ▀▀▘
hertz2
               _ 
 _ __ __ _  __| |
| '__/ _` |/ _` |
| | | (_| | (_| |
|_|  \__,_|\__,_|
rad
        ▌
▙▀▖▝▀▖▞▀▌
▌  ▞▀▌▌ ▌
▘  ▝▀▘▝▀▘
rad2
                 _      
  ___ _   _ _ __(_) ___ 
 / __| | | | '__| |/ _ \
| (__| |_| | |  | |  __/
 \___|\__,_|_|  |_|\___|
curie
         ▗    
▞▀▖▌ ▌▙▀▖▄ ▞▀▖
▌ ▖▌ ▌▌  ▐ ▛▀ 
▝▀ ▝▀▘▘  ▀▘▝▀▘
curie2
 _
| |__   __ _ _ __ 
| '_ \ / _` | '__|
| |_) | (_| | |   
|_.__/ \__,_|_|   
bar
▌        
▛▀▖▝▀▖▙▀▖
▌ ▌▞▀▌▌  
▀▀ ▝▀▘▘  
bar2
#----------------------------------------------------------------------------------------------------------------
