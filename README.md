# bsod_generator
generate windows bsods to use as your lockscreen on sway

## Commandline arguments
<pre>
Help menu
  -e,     --emoticon            Emoticon to display. Defualt is: ":("
  -m,     --message             Message to display. Defualt is: "Your PC ran into a problem and needs to restart. We\'re just collecting some error info, and then we\'ll restart for you."
  -mg,    --message-generator   Use for different messages per display. E.g.: fortune
  -p,     --percentage          Creates string: NUM% Complete. Defualt is: "20% Complete"
  -rp,    --random-percent      Generates random number from 0-100 for use for above option
  -q,     --qrcode              String to send to qrencode. Defualt is "https://www.windows93.net/"
  -mtq,   --message-to-qrcode   When specified, the message will be used to generate the qrcode
  -s,     --stop-code           Stop code to display as part of the error message next to the qrcode. Defualt is CRITICAL PROCESS DIED
  -u,     --url                 Url to display as part of the error message next to the qrcode. Defualt is https://www.windows.com/stopcode
  -err,   --error               Error message next to the qrcode. Defualt is: "For more information about this issue and possible fixes, visit __url__\n\n\nIf you call a support person, give them this info:\n\nStop code: __stp__". Use "__url__" and "__stp__" to replce with the url and stopcode respectively
  -f,     --font                Font to use. Defualt is Noto-Sans-Regular. If you want accurace you should use the Segoe UI font
  -fse,   --font-size-emoticon  Font size of the emoticon. Defualt is: 200
  -fsm,   --font-size-message   Font size of the message. Defualt is: 36
  -fserr, --font-size-error     Font size of the error message. Defualt is: 22
  -off,   --offset              Offset from the top left of the entire message. Defualt is: 200
  -c,     --color, --colour     Colour of the background. Must work with imageMagick. Defualt is: #0078d7
  -o                            Output directory. If argument is "-", then output will be sent to STDOUT. "-" doesn't seem to work with multiple displays
  -d,     --displays            String of "name0 width0 height0 name1 width1 height1" etc.
  -h,     --help                Show this message
Piping
  If you pipe something into the script, it will be the message
  e.g.:
    fortune | ./bsod_generator.sh
Example commands
  ./bsod_generator.sh -mtq -e ':3' -rp -d "eDP-2 2560 1600"
  fortune | ./bsod_generator.sh -mtq -e ':3' -rp -o - | cat
  ./bsod_generator.sh -mtq -e ':3' -rp -mg fortune
  ./bsod_generator.sh -err "url: __url__ stopcode: __stp__"
</pre>

## Example outputs
<img width="2560" height="1600" alt="eDP-2" src="https://github.com/user-attachments/assets/059dde08-d1af-4e70-a5b7-87e37a5572dc" />
<img width="1280" height="788" alt="2025-12-17-17:57:22-screenshot" src="https://github.com/user-attachments/assets/e478da62-432f-4b12-b28e-068c909c643d" />
<img width="2560" height="1600" alt="funny" src="https://github.com/user-attachments/assets/b6f291cd-7f5b-40ab-8bf6-b58438449ab3" />
<img width="2560" height="1600" alt="eDP-2" src="https://github.com/user-attachments/assets/f5cbbffe-f39d-4113-b2f0-e1a255a90307" />

## Usage for lockscreen
If you are using sway, you can use something similiar to this script to create a bsod for each display:
<pre>
#!/bin/bash

./bsod_generator.sh -mtq -e ':3' -rp -mg fortune

args=
dir=~/Pictures/bsod/

for output in $(swaymsg -t get_outputs | jq -r '.[].name'); do
  args="${args} --image ${output}:${dir}${output}.png"
done

swaylock -Fe $args
</pre>

## Extra stuff
`fortune`: [https://wiki.archlinux.org/title/Fortune](url)

`cat` used in the examples is an alias for `mcat`: [https://crates.io/crates/mcat](url)
