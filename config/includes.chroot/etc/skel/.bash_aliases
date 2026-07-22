##aliases, debian, machiner
#------------------------------------------////
# System:
#------------------------------------------////
alias rslv='sudo nano /etc/resolv.conf'
#alias ports='sudo nmap -F 192.168.1.0/24'
alias ports='netstat -tulanp'
alias ping='ping -c 4'
alias router='x-www-browser https://192.168.1.1 &'
alias myip='lynx -dump -hiddenlinks=ignore -nolist http://checkip.dyndns.org:8245/ | sed "/^$/d; s/^[ ]*//g; s/[ ]*$//g"'
alias code='~/.local/share/opencode/bin/rg'
alias listening='netstat -alnp --protocol=inet | grep -v CLOSE_WAIT | cut -c-6,21-94 | tail +2'
alias iotop='sudo iotop -o -a'
alias fstab='sudo cp /etc/fstab /etc/fstab.backup; sudo nano /etc/fstab'
alias mounted='df -hT'
alias batt='upower -i $(upower -e | grep BAT) | grep --color=never -E "state|to\ full|to\ empty|percentage"'
#alias find='fdfind'
alias hwmon-id='for i in /sys/class/hwmon/hwmon*/temp*_input; do echo "$(<$(dirname $i)/name): $(cat ${i%_*}_label 2>/dev/null || echo $(basename ${i%_*})) $(readlink -f $i)"; done'
alias guts='sudo inxi -Fx -c24'
alias dim='xrandr --output HDMI-2 --brightness 0.6'
alias bright='xrandr --output HDMI-2 --brightness 1.0'
alias cleancache='sudo /sbin/sysctl vm.drop_caches=3'
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'
alias mount='mount |column -t'
alias rm='rm -I --preserve-root'
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'
alias less='less -r'
alias bd='cd "$OLDPWD"'
alias rmd='/bin/rm  --recursive --force --verbose '
alias checkcommand="type -t"
alias del='mv --force -t ~/.local/share/Trash/files'
alias edit='nano --smarthome --multibuffer --const --autoindent'
alias nano='nano --smarthome --multibuffer --const --autoindent'
alias cat='batcat'
alias killx='killall -15 xscreensaver'
alias su='sudo -i'
alias src='source ~/.bashrc'
alias path='echo -e ${PATH//:/\\n}'
alias services='systemctl list-units --type=service --state=running,failed'
alias servicesall='systemctl list-units --type=service'
alias {failed,servicefailed}='systemctl --failed'
alias servicestatus='sudo systemctl status'
alias serviceenable='sudo systemctl enable --now'
alias servicedisable='sudo systemctl disable'
alias servicestart='sudo systemctl start'
alias servicestop='sudo systemctl stop'
alias servicekill='sudo systemctl kill'
alias servicerestart='sudo systemctl restart'
alias servicereload='sudo systemctl reload'
#------------------------------------------////
# Package Management:
#------------------------------------------////
alias sources='sudo x-text-editor /etc/apt/sources.list'
alias deb='sudo dpkg -i'
alias show='aptitude show'
alias list='dpkg -L'
alias cpf='sudo aptitude clean && sudo aptitude purge ~c && sudo aptitude -f install'
alias remove='sudo aptitude purge'
alias install='sudo aptitude -y install'
alias apps='sudo synaptic'
alias search='aptitude search'
alias update='sudo aptitude update'
alias upgrade='sudo aptitude full-upgrade'
alias updoogie='runwithfeedback upgrading upgrade'
alias devs="aptitude -F '%p' search '~i -dev$'"
alias devsizes="aptitude -F '%I %p' search '~i -dev$'"
alias otto='sudo apt autoremove'
#------------------------------------------////
# Desktop:
#------------------------------------------////

alias tasks='task next'
alias sizes='duc ui .'
alias taska='task add'
alias nuke='/bin/rm  --recursive --force --verbose'
alias cpuwatch="watch -d -n 1 'ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head'"
alias max='echo "performance" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor'
alias checkmax='sudo cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor'
alias b='buku --suggest'
alias stopwatch='date && echo "Press CTRL+D to stop" && time read'
alias again='systemctl reboot'
alias off='systemctl poweroff'
alias nap='systemctl suspend'
alias h='history'
alias auto='x-text-editor ~/.config/openbox/autostart &'
alias menu='x-text-editor ~/.config/openbox/menu.xml &'
alias rc='x-text-editor ~/.config/openbox/rc.xml &'
alias aliases='x-text-editor ~/.bash_aliases'
alias recdesk='ffmpeg -video_size 1920x1080 -framerate 25 -f x11grab -i :0.0 -f alsa -ac 2 -i hw:0 output.mkv'
alias pick='shuf -n 1 films.txt'
alias whoami='espeak -v mb-en1 "Bitch, I am Dracula"'
alias say='espeak -v mb-en1 -s170'
alias saygreet='echo "$(HOUR=$(date +%H); echo "$( [ "$HOUR" -lt 12 ] && echo "Good morning" || { [ "$HOUR" -lt 17 ] && echo "Good afternoon" || { [ "$HOUR" -lt 21 ] && echo "Good evening" || echo "Good night"; }; }) $(getent passwd "${USER}" | cut -d ":" -f 5 | cut -d "," -f 1 || echo "${USER}")! It is $(date +"%-I. %M. %p" | sed "s/AM/A. M./; s/PM/P. M./"). $(grep -q "^To " /var/mail/${USER} 2>/dev/null && echo "You have new messages." || echo "")")" | espeak -v mb-en1 -s170'
alias home='cl ~'
alias fetcher='fastfetch'
alias excuses='echo `telnet bofh.jeffballard.us 666 2>/dev/null` |grep --color -o "Your excuse is:.*$"'
alias funfacts='wget http://www.randomfunfacts.com -O - 2>/dev/null | grep \<strong\> | sed "s;^.*<i>\(.*\)</i>.*$;\1;";'
alias insults='wget http://www.randominsults.net -O - 2>/dev/null | grep \<strong\> | sed "s;^.*<i>\(.*\)</i>.*$;\1;";'
alias lotto='shuf -i 1-49 -n 6 | sort -n | xargs'
alias matrix='echo -e "\e[32m"; while :; do for i in {1..16}; do r="$(($RANDOM % 2))"; if [[ $(($RANDOM % 5)) == 1 ]]; then if [[ $(($RANDOM % 4)) == 1 ]]; then v+="\e[1m $r   "; else v+="\e[2m $r   "; fi; else v+="     "; fi; done; echo -e "$v"; v=""; done'
alias matrix2='echo -ne "\e[32m" ; while true ; do echo -ne "\e[$(($RANDOM % 2 + 1))m" ; tr -c "[:print:]" " " < /dev/urandom | dd count=1 bs=50 2> /dev/null ; done'
alias matrix3='tr -c "[:digit:]" " " < /dev/urandom | dd cbs=$COLUMNS conv=lcase,unblock | GREP_COLOR="1;32" grep --color "[^ ]"'
alias busy='my_file=$(find /usr/include -type f | sort -R | head -n 1); my_len=$(wc -l $my_file | awk "{print $1}"); let "r = $RANDOM % $my_len" 2>/dev/null; nano +$r $my_file'
alias sing='x="bottles of beer";y="on the wall";for b in {99..1};do echo "$b $x $y, $b $x. Take one down pass it around, $(($b-1)) $x $y"; sleep 8;done'
alias weather='~/bin/weather.sh && ~/bin/forecast.sh'
alias burn='sudo mintstick -m iso'
alias map='telnet mapscii.me'
alias wicn='mpg123 https://wicn-ice.streamguys1.com/live-mp3'
alias obr='openbox --reconfigure && openbox --restart'
alias color='sh ~/bin/color.sh'
alias ssr='simplescreenrecorder --start-recording'
alias clf='curl "https://www.commandlinefu.com/commands/browse/sort-by-votes/plaintext"'
alias rec='sox -t alsa default "$(date +"%Y-%m-%d-%I-%M-%S")-output.flac"'
alias word='/usr/bin/lowriter &'
alias tunes='mpv --shuffle --playlist=tunage20jan25.m3u &'
alias killtunes='killall -9 mpv'
alias clients='sudo nmap -sn 192.168.1.0/24'
alias timer='~/bin/timer1.sh'
alias bp="sudo chattr +i ${HOME}/.bashrc"
alias bup="sudo chattr -i ${HOME}/.bashrc"
alias bcp='if [[ $(lsattr -R -l ~/.bashrc | grep " Immutable") ]]; then echo "Protected"; else echo "Not Protected"; fi;'
alias jan='cal -m 01'
alias feb='cal -m 02'
alias mar='cal -m 03'
alias apr='cal -m 04'
alias may='cal -m 05'
alias jun='cal -m 06'
alias jul='cal -m 07'
alias aug='cal -m 08'
alias sep='cal -m 09'
alias oct='cal -m 10'
alias nov='cal -m 11'
alias dec='cal -m 12'
alias icat='~/Downloads/kitty-0.45.0-x86_64/bin/kitten icat'
alias nbp='~/bin/mkpwd.sh 32 1 >> new-bigass-passwords.txt && cat new-bigass-passwords.txt'
#------------------------------------------////
# Lookin' at Stuff:
#-------------------------------
alias dir='dir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias parts='sudo gparted'
#alias du='du -kh'
alias df='df --human-readable --print-type --exclude-type=squashfs --exclude-type=tmpfs --exclude-type=devtmpfs --exclude-type=efivarfs'
alias new='lsd -lAtr --almost-all --color=always| tail -10 | tac'
alias tree='tree -CAhF --dirsfirst'
alias ltree='command lsd --almost-all --blocks permission,user,size,date,name --group-dirs first --header --long --tree'
alias la='ls -Alh' # show hidden files
alias ls='ls -aFh --color=always' # add colors and file type extensions
alias lx='ls -lXBh' # sort by extension
alias lf="lsd -Alh --color=always | awk '{k=0;for(i=0;i<=8;i++)k+=((substr(\$1,i+2,1)~/[rwx]/)*2^(8-i));if(k)printf(\" %0o \",k);print}'"
alias lm='lsd -l --color=always | less -R'
alias lk='ls -lSrh' # sort by size
alias lc='ls -lcrh' # sort by change time
alias lu='ls -lurh' # sort by access time
alias lr='ls -lRh' # recursive ls
alias lt='ls -ltrh' # sort by date
alias lm='ls -alh |more' # pipe through 'more'
alias lw='ls -xAh' # wide listing format
alias ll='ls -Fls' # long listing format
alias labc='ls -lap' #alphabetical sort
alias lf="ls -l | egrep -v '^d'"
alias ldir="ls -l | egrep '^d'"
alias grep='grep --color=auto'
alias dmesg='dmesg --color'
alias du='du -h --max-depth=1 . | sort -h'
alias cards='lspci -k | grep -A 2 -E "(VGA|3D)"'
