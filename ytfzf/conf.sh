external_menu() {
    sxmo_dmenu.sh 
}

video_player() {
    mpv --ytdl-format='[height<420]' "$@" 
}
