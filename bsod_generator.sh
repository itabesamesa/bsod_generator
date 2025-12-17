#!/bin/bash

displays=
emoticon=":("
message="Your PC ran into a problem and needs to restart. We\'re just collecting some error info, and then we\'ll restart for you."
percentage="20% Complete"
qrcode="https://www.windows93.net/"
stop_code="CRITICAL PROCESS DIED"
url="https://www.windows.com/stopcode"
err="For more information about this issue and possible fixes, visit __url__\n\n\nIf you call a support person, give them this info:\n\nStop code: __stp__"
font="Noto-Sans-Regular"
font_size_emoticon=200
font_size_message=36
font_size_err=22
offset=200
color='#0078d7'
out_dir=~/Pictures/bsod/
message_to_qrcode=0
message_generator=

while [[ $# -gt 0 ]]; do
  case $1 in
  -e | --emoticon)
    emoticon=$2
    shift
    ;;
  -m | --message)
    message=$2
    shift
    ;;
  -mg | --message-generator)
    message_generator=$2
    shift
    ;;
  -p | --percentage)
    percentage="${2}% Complete"
    shift
    ;;
  -rp | --random-percent)
    percentage="$(shuf -i 0-100 -n 1)% Complete"
    ;;
  -q | --qrcode)
    qrcode=$2
    shift
    ;;
  -mtq | --message-to-qrcode)
    message_to_qrcode=1
    ;;
  -s | --stop-code)
    stop_code=$2
    shift
    ;;
  -u | --url)
    url=$2
    shift
    ;;
  -err | --error)
    err=$2
    shift
    ;;
  -f | --font)
    font=$2
    shift
    ;;
  -fse | --font-size-emoticon)
    font_size_emoticon=$2
    shift
    ;;
  -fsm | --font-size-message)
    font_size_message=$2
    shift
    ;;
  -fserr | --font-size-error)
    font_size_err=$2
    shift
    ;;
  -off | --offset)
    offset=$2
    shift
    ;;
  -c | --color | --colour)
    color=$2
    shift
    ;;
  -o)
    out_dir=$2
    shift
    ;;
  -d | --displays)
    displays=($2)
    shift
    ;;
  -h | --help)
    echo "Help menu"
    echo "  -e,     --emoticon            Emoticon to display. Defualt is: \"${emoticon}\""
    echo "  -m,     --message             Message to display. Defualt is: \"${message}\""
    echo "  -mg,    --message-generator   Use for different messages per display. E.g.: fortune"
    echo "  -p,     --percentage          Creates string: NUM% Complete. Defualt is: \"${percentage}\""
    echo "  -rp,    --random-percent      Generates random number from 0-100 for use for above option"
    echo "  -q,     --qrcode              String to send to qrencode. Defualt is \"${qrcode}\""
    echo "  -mtq,   --message-to-qrcode   When specified, the message will be used to generate the qrcode"
    echo "  -s,     --stop-code           Stop code to display as part of the error message next to the qrcode. Defualt is ${stop_code}"
    echo "  -u,     --url                 Url to display as part of the error message next to the qrcode. Defualt is ${url}"
    echo "  -err,   --error               Error message next to the qrcode. Defualt is: \"${err}\". Use \"__url__\" and \"__stp__\" to replce with the url and stopcode respectively"
    echo "  -f,     --font                Font to use. Defualt is ${font}. If you want accurace you should use the Segoe UI font"
    echo "  -fse,   --font-size-emoticon  Font size of the emoticon. Defualt is: ${font_size_emoticon}"
    echo "  -fsm,   --font-size-message   Font size of the message. Defualt is: ${font_size_message}"
    echo "  -fserr, --font-size-error     Font size of the error message. Defualt is: ${font_size_err}"
    echo "  -off,   --offset              Offset from the top left of the entire message. Defualt is: ${offset}"
    echo "  -c,     --color, --colour     Colour of the background. Must work with imageMagick. Defualt is: ${color}"
    echo "  -o                            Output directory. If argument is \"-\", then output will be sent to STDOUT. \"-\" doesn't seem to work with multiple displays"
    echo "  -d,     --displays            String of \"name0 width0 height0 name1 width1 height1\" etc."
    echo "  -h,     --help                Show this message"
    echo "Piping"
    echo "  If you pipe something into the script, it will be the message"
    echo "  e.g.:"
    echo "    fortune | ${0}"
    echo "Example commands"
    echo "  ${0} -mtq -e ':3' -rp -d \"eDP-2 2560 1600\""
    echo "  fortune | ${0} -mtq -e ':3' -rp -o - | cat"
    echo "  ${0} -mtq -e ':3' -rp -mg fortune"
    echo "  ${0} -err \"url: __url__ stopcode: __stp__\""
    exit
    ;;
  *)
    echo "Option ${1} not recognized"
    exit
    ;;
  esac
  shift
done

if [ "$displays" == "" ]; then
  displays=($(swaymsg -t get_outputs -r | jq -r '.[] | "\(.name) \(.current_mode.width) \(.current_mode.height)"'))
fi

if [ ${out_dir:((${#out_dir} - 1))} != '/' ]; then
  out_dir=$out_dir'/'
fi

if test ! -t 0; then
  message=$(</dev/stdin)
fi

if [ $message_to_qrcode ]; then
  qrcode=$message
fi

err=${err/"__url__"/$url}
err=${err/"__stp__"/$stop_code}

while [[ ${#displays[@]} -gt 0 ]]; do
  out=
  if [ "$out_dir" == "-/" ]; then
    out='png:-'
  else
    out=$out_dir${displays[0]}.png
  fi
  if [ "$message_generator" != "" ]; then
    message=$(exec $message_generator)
  fi
  width=${displays[1]}
  height=${displays[2]}
  res="${width}x${height}"
  max_width=$((width - offset - offset))
  err_width=$((max_width - 200)) #guessing the size of the qrcode
  displays=("${displays[@]:3}")
  qrencode "${qrcode}" -o - |
    magick \
      \( - +level-colors $color,white -background none -resize 200x200% -extent 120% \
      -fill white -pointsize $font_size_err \
      -font $font -size ${err_width}x caption:"${err}" \
      +append \) -extent x200%+0-50 png:- |
    magick \
      -fill white -background none -pointsize $font_size_emoticon \
      -font $font -size ${max_width}x caption:"${emoticon}" \
      -fill white -background none -pointsize $font_size_message \
      -font $font -size ${max_width}x caption:"${message}" -extent x120% \
      -fill white -background none -pointsize $font_size_message \
      -font $font -size ${max_width}x caption:"${percentage}" \
      - \
      -append png:- |
    magick -size $res canvas:$color \
      \( - -background none -extent $res-$offset-$offset \) \
      -layers merge $out
done
