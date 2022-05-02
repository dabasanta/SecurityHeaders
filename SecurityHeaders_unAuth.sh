#!/usr/bin/env bash
#
# Script to check for misssing security http headers in non-authenticated webapps. Can pass an URL or file as argmument. If the argmument is a file, make sure the file is ASCII/text.
# You can pass a complete URI resource "http(s)://www.website.com/resource/id/here" or only hostname/DNS name, as appropriate.
#
# Note: if you're using a filename containing URLs to test, please don't let blank lines, this may affect script performance and make it too slow.
#
# @author: Danilo Basanta
# @author-linkedin: https://www.linkedin.com/in/danilobasanta/
# @author-github: https://github.com/dabasanta


# Changing between bash colors in outputs
end="\e[0m"
output="\e[1m\e[36m[+]"
error="\e[1m\e[91m[!]"
question="\e[1m\e[93m[?]"
green="\e[1m\e[92m"

tput civis  # Making beep off

clean(){  # Cleaning the system after execution
    echo -e "\n\n"
    rm -rf /tmp/curl.output
    echo -e "$output Happy hunting.$end"
    tput cnorm
    exit 0
}

function scape() {  # Catch the ctrl_c INT key
  echo -e "$output Exiting ... $end"
  clean
}
trap scape INT

help(){

  columns=$(stty -a | head -1 | cut -d ';' -f 3 | grep -Eo '[0-9]+')
  if [ $columns -ge 164 ] ; then
    echo -e "\e[1m\e[91m


                                                                                           ....
                                                                                    .&%%%%%%%%%. .
                                                                                 . %%%(((((((((#%% ....
                                                                                  #%%(((((((((((#%%(.&&&%&..
                                                                             .   .*%%((((#%%%%%%%%%%#((((%% ...
                                                                                 . /%%%%%%%%%%%%%%#(((((#%%&&&&(,  .
                                                                               . .(&%%%%%%%%%%%#((((((%%%,*,****#&%&,..
                                                                                &%((((((((((((((((#%%&***,,,,**,*,*,&%,
                                                                               ..&%%##(###%&&%%%&%/,********,***,****,&% ..
                                                                                 .  ....&&/,*********************,#&&&&&%&#
                                                                              .  ......&%***********************&&.....@%%%%% .  .
                                                                                  ....@&#******,*&&&&&&%******/&#....&%&%%%&&%.
                                                                              ......@&&&(*****%&........ %&***&& ...&&&&%%%&&&........   .......
                                                                           .  ...*&&&&&&%****&/..@&&&&&&/..&(*&&...,&&&&&%%&&&........,&@&&&&&&&&% .   .
                                                                             ..(&&&&&&&&&***(&..@&&&&&&&&(.%&**&%...&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& .
                                                                        .  ..*&&&&&&&&&&&/**%%.(&&&&&&&&&%.%&***#&( .,&&&%/,******&&&&&&&&&&&&&&&&&&*.
                                                                      .. ...@&&&&&&&&&&&&%***&.,@&&&&&&&&..@(******&&(************&&&&&&&&&&&&&&&&&&...
                                                                     .....(&&&&&&&&&&&&&&&***%&..(@&&&&..,@/*****%*****************%&&&&&&&&&&&&&&*..
                                                           . ..   .......%@&&&&&&&&&&&&&&%****/@#.....,&@/*****************************#%&&%(**,&%.. . ,
                                                         .. ............,@@&&&&&&&&&&&&&@*********/((*****************&&**********************&&*.   .
                                                          .....#/.......&@&&&&&&&&&&&&&@**************************@@%*/&&&@%*************(@&@# .....
                                                          .....,###....,@@&&&&&&&&&&&@&*********************************/@. ,(&@&@&@@@&%, ..... ..
                                                           .....(###@@&(#@@&&&&&&&&&@/**********************************%@.....................
                                                           .....,%#%@%((((#&@&&&@@@*************************************#@(..................
                                                           ......%#@@#(((#(#@%%%%@@**********&&&*************************@@....................
                                                           ......%#@@((((#(#@%%%%@@******&***@#**************************#@@..............(...
                                                           ......%%@@#(#(#(%@%%%%@@*****/@/**@%***************************@@/.........../#*....
                                                          ......#%%@@#((#(#%@&%%%@@*****/@#**&@/**************************(@@ .........###*...
                                                         ......#%%%@@%#####%@&%%%&@#*****(@/**@@*/************************/@@.........#####.....
                                                ..............%%%%%%@&######@@%%%%@@/*****(@(**@@/************************(@@......../####%,... .
                                              ..............(%%%%%%%@@######@@%%%%%@@*******@@**#@@(*/*******************/@@&........#######/..........
                                             .....,%*.....,%%%%%%%(/%@&#####%@%%%%%&@@/******/@@(*/&@@@(****************%@@@@&&@@....%%%((####*.........  .
                                           ......(%%,....*%%%%%%(////@@######%@&%&@@@@@@///***//(@@@%#&@@@@@@@@@@@@@&#@@@@@@//*/%@,..(##(//######....##... .
                                           .....#%%%(...,%%%%#///////#@@&#(((##@@&#####%@@@&(/****%@#/////*///////**@@%****/@#***@@,*&@@@&////#%%%/../%#/. ...
                                          ...../%%%%%(..%%%#///////////%%%**/&@@%###########&@@@@@@@@@@@@@@@&@@%*/**#@#****/@@***#&/****/#@(/////#%%.%####... .
                                         ......%%%%%%%%(%%//////**////(%%%..%%@@###############################@%***#@%(@@@@@@***********@@//***///(%%/(%%/..
                                         .....*%%%%(/%%%%//////***////#%%(.#%%@@@%%%##########################(&@*//*%&/*/*@@@%(////(%@@@%%///*,,*/*##///%%.....
                                         .....*%%%(///%%%////***,*////(%%(,%%/(%&&&&&@@@@@@@@@@@@@@@@@@@@@@@@@@@@**/*////*%@@@@@@,%(///#(#%/**/,,,*///*//#%.....
                                         .....*%%%/////(%(//**,***/**//%%%/%%/*/////(&@####@&./@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%///**#%#%//,*,,,,****//(%.....
                                          .....%%%////*/////**,,,*/**//(%%(%%/***/**/#@%###@&..%@@@@@@@@@@@@@@@@%%%%@@@@@@@@@@@@@%/****/%%(//,,,,,,,,,*/*#/.....
                                          .....(%%////**///*****,****///(%%%%/*******%@%###@&...........%@@@@@@@%%%%@@....@@@%%%@%/*,,**////*,,,,,,,,,//#(.......
                                           .....%%(////*,*****,*,*****////%%#/****,**&@%###@(...........#@@@@@@@%%%%@@....@@@%%%@#**,,,,,//*,,,,,,,*,*/%..*%.....
                                           ......%%(///****************//////********&@%###@#....((*....(@@@@@@@%%%%@@....@@@&%%@#,,,,,,,,,*,,,,,,,*/#%%%##......
                                            ......(%#///****************/////********%@&###@@#*(###,..../@@@@@@@%%%%@@....@@@&##@@*,,,,,,,,,,,,*,*//////(.......
                                           .........%%(///****************//*********#@&###@&(((##(.....*@@@@@@@%%%%@@....@@@(/(&@...,******,,,*,***,.........
                                           .....#,...,(%(//**************************(@&###@##(#####,...*@@@@@@@&%%%@@....@@@(((%@..........................
                                           ....../%%%%(*,(%(/*************************@@#########((##(..,@@@@@@@@%%%@@....&@@&##%@#,..................,.
                                             ......*&%(#%%%%%%#/**********************@@######(///#####/,@@@@@#@@%%%@@....*@@@%%%@((,.....*
                                               ......,(&(///////////*************,....#@&####(//**/(###,...,...(@&%%@@.....*@@@@@@&#.....
                                                 ,.........,*/*************,,..........*&&%#(/*,,,*/(#..........@@@@(.....................
                                                    ........................................./*,,,,/.....................................................
                                                  ....................................................................................*....................
                                                ............,*(,.,*(*,*/&&/(%@@,....@@@@@#......@@@@...,@@@@@@%.....%@@@@@@@@,@@@@,@@@@%.%@@@/@@@@@@@@&.....
                                                .....@@@@@@@@@@@@@@@*,@@@@*@@@@.,(@@@@@@@&,.....@@@@./@@@%,%#*.,....(@@@#,,.,,@@@&*@@@@@(%@@@/&@@@(,..,.....
                                                .....,.,&@@@,,,,@@@@*,@@@@*@@@@,@@@@%#&@@@*,....@@@&*@@@@@@@@@@%..../@@@@@@@@.@@@%*@@@@@@@@@@/%@@@@@@@,....
                                                 ,.....,%@@@/,,,&@@@@@@@@@*@@@@,*@@&#/*&@@@.....@@@@.....,,/@@@%,...*@@@%.....@@@&*@@@@%@@@@@/#@@@&&@@@.....
                                                   .....(@@@&.,,&@@@/,@@@@*@@@@,.,&@@@@@@/,....,&@@@..,@@@@@@,,.....,@@@@.....@@@@.@@@@..&@@%*(@@@@@@@@/....
                                                   ....,/@@@@..,%@@(,,@&/.,,,.....,,,,......................................................................
                                                    ......,................................/*.................,/.,.......................................
                                                     ,.......,,..,,,,.,*****.  .*/****,
\e[1m\e[36m
                                              v: 0.1 - Danilo Basanta                          Report errors in: https://github.com/dabasanta/SecurityHeaders/issues
\e[1m\e[93m
    Usage: $0 <URL>
    Usage: $0 <URLfile>

              <URL>     ~   https://example.com/complete/uri/if/neccesary

              <URLfile> ~   ../path/of/file.txt   |   #Must be ASCII unformated text with a URL by line

   $end"
 else
   echo -e "\e[1m\e[36mv: 0.1 - Danilo Basanta\nReport errors in: https://github.com/dabasanta/SecurityHeaders/issues
   \e[1m\e[93m
       Usage: $0 <URL>
       Usage: $0 <URLfile>

       <URL>     ~   https://example.com/complete/uri/if/neccesary

      <URLfile> ~   ../path/of/file.txt   |   #Must be ASCII unformated text with a URL by line$end"
 fi
tput cnorm
}

banner(){
  echo -e "

            ███████╗███████╗ ██████╗██╗   ██╗██████╗ ██╗████████╗██╗   ██╗
            ██╔════╝██╔════╝██╔════╝██║   ██║██╔══██╗██║╚══██╔══╝╚██╗ ██╔╝
            ███████╗█████╗  ██║     ██║   ██║██████╔╝██║   ██║    ╚████╔╝
            ╚════██║██╔══╝  ██║     ██║   ██║██╔══██╗██║   ██║     ╚██╔╝
            ███████║███████╗╚██████╗╚██████╔╝██║  ██║██║   ██║      ██║
            ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝   ╚═╝      ╚═╝
            ██╗  ██╗███████╗ █████╗ ██████╗ ███████╗██████╗ ███████╗
            ██║  ██║██╔════╝██╔══██╗██╔══██╗██╔════╝██╔══██╗██╔════╝
            ███████║█████╗  ███████║██║  ██║█████╗  ██████╔╝███████╗
            ██╔══██║██╔══╝  ██╔══██║██║  ██║██╔══╝  ██╔══██╗╚════██║
            ██║  ██║███████╗██║  ██║██████╔╝███████╗██║  ██║███████║
            ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝

            For: Testing security headers missing on un-authenticated responses
"
}

checkDependencies(){
  echo -e "\n"
  if which curl > /dev/null 2>&1 ; then
    cURLversion=$(curl -V | head -1 | awk '{print $1,$2}')
    echo -e "$output $cURLversion. Installed.$end"
  else
    echo -e "$error Error: cURL couldn't found.$end"
    exit 1
  fi
  echo -e "\n"
}

securityHeaders(){
  host="$1"
  curl -LIs --max-redirs 5 -X GET "$host" -o /tmp/curl.output 2>/dev/null
  echo -e "\n\e[1m\e[93m [*] Results for $host$end\n"
  cat /tmp/curl.output | cut -d : -f 1 | grep -Eiw 'Content-Security-Policy|X-Content-Type-Options|X-Frame-Options|X-XSS-Protection' | uniq
}

checkConn(){
  filename=$1
  long=$(wc -l $filename)
  ok=0

  for url in $(cat $filename) ; do
    if curl --output /dev/null --silent --head --fail "$url" ; then
      ok=$(($ok+1))
      securityHeaders "$url"
    fi
  done

  echo -e "\n\n$info Done! $ok URL tested.$end\n\n"
}

checkArg(){
  if file $1 | grep -Eo "ASCII text" > /dev/null 2>&1 ; then
    checkConn $1
  else
    if curl --output /dev/null --silent --head --fail $1 ; then
      echo ""
    else
      echo -e "$error Error while check URL, connection fail.$end"
    fi
  fi
}

if echo $@ | grep -E "help|--help|-h|--h" > /dev/null 2>&1 ; then
  help
else
  banner
  checkDependencies
  checkArg $1
fi
