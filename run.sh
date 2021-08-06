#!/bin/bash

print_usage() {
  cat <<EOF
Usage: $0 [-c twitchChannel1[,twitChannel2]] [-u twitchUser1[,twitchUser2]]]
  [-l lichesAPIToken] [-t twitchOAUTHToken]

Options:
  -c  Twitch channels that the bot will join
  -u  Twitch users that can manage the bot
  -l  Lichess.com API token
  -t  Twitch oauth token

Environment Variables:
  TWITCH_CHANNELS     Twitch channels that the bot will join
  TWITCH_USERS        Twitch users that can manage the bot
  LICHESS_API_TOKEN   Lichess.com API token
  TWITCH_OATUH_TOKEN  Twitch oauth token

Additional Info:
  - Command options take precedence over environment variables
  - To obtain a Twitch Oauth token visit https://twitchapps.com/tmi/
  - To obtain a Liches API Token visit https://lichess.org/account/oauth/token

EOF
}

twitchChannels=${TWITCH_CHANNELS}
twitchUsers=${TWITCH_USERS}
lichessToken=${LICHESS_API_TOKEN}
twitchToken=${TWITCH_OATUH_TOKEN}

scriptdir="$(dirname ${BASH_SOURCE[0]})"
while getopts ":c:u:l:t:h" opt; do
  case ${opt} in
    c )
      twitchChannels=${OPTARG}
      ;;
    u )
      twitchUsers=${OPTARG}
      ;;
    l )
      lichessToken=${OPTARG}
      ;;
    t )
      twitchToken=${OPTARG}
      ;;
    h )
      print_usage
      exit 0
      ;;
    \? )
      echo "Invalid option: $OPTARG" 1>&2
      print_usage 1>&2
      exit 1
      ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      print_usage 1>&2
      exit 1
      ;;
  esac
done

missing=0
if [[ -z "${twitchChannels}" ]]; then
  echo "Need to provide at least 1 twitch channel to join  (-c option or TWITCH_CHANNELS envar)" 1>&2
  missing=$((missing+1))
fi

if [[ -z "${twitchUsers}" ]]; then
  echo "Need to provide at least 1 twitch user that can manager the bot  (-u option or TWITCH_USERS envar)" 1>&2
  missing=$((missing+1))
fi

if [[ -z "${lichessToken}" ]]; then
  echo "Need to provide the Lichess API token (-l option or LICHESS_API_TOKEN envar)" 1>&2
  missing=$((missing+1))
fi

if [[ -z "${twitchToken}" ]]; then
  echo "Need to provide the Twitch OAuth Token (-t option or TWITCH_OAUTH_TOKEN envar)" 1>&2
  missing=$((missing+1))
fi

if [[ $missing -gt 0 ]]; then
  print_usage 1>&2
  exit 1
fi

if ! which npm &>/dev/null; then
  echo "Need to have `npm` installed" 1>&2
  exit 1
fi

if ! which node &>/dev/null; then
  echo "Need to have `node` installed" 1>&2
  exit 1
fi

cd $scriptdir

npm install

node ChatPlaysChess.js $twitchChannels $twitchUsers $lichessToken $twitchToken
