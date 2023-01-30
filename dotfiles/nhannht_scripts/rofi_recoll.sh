#!/usr/bin/env bash
proxy_addr="http://localhost:8000"
query_endpoint="/query"
arg=$1

function send_query_to_recoll_proxy() {
  local query=$1
  local json_object=$(jq -n \
    --arg query "$1" \
    '{"query": $query}')
  curl -s -H "Content-Type: application/json" -X GET -d "$json_object" "$proxy_addr$query_endpoint"
}

case $arg in
-h | --help)
script_name=$(basename "$0")
  echo "Usage: run ./$script_name alone to popup a rofi window to input query
  run ./$script_name --query <query> to query recoll directly"
  ;;
--query | -q)
  shift
  query=$@
  options=()
  response=$(send_query_to_recoll_proxy "$query")
  length=$(echo "$response" | jq 'length' )
  for count in $(seq 0 "$length"); do
    url=$(echo "$response" | jq ".[$count].url")
    #    if url = numm break
    if [ "$url" = "null" ]; then
      break
    fi
    title=$(echo "$response" | jq ".[$count].title")
    snippet=$(echo "$response" | jq ".[$count].snippet_abstract")
    # Define the long string
    wrap_length=60
    long_string=$snippet

    # Define the desired length of each substring

    # Split the long string into substrings
    for i in $(seq 0 $((${#long_string} / wrap_length))); do
      # shellcheck disable=SC2116
      substrings[$i]=$(echo "${long_string:$((i * wrap_length)):$wrap_length}")
    done
    # slice first 5 lines
    substrings=("${substrings[@]:0:5}")
    # Print the substrings

    snippet=$(printf "%s\n" "${substrings[@]}")
    options+=("URL:<u>$url</u>\nTitle:<b>$title</b>\nSnippet:$snippet\x0f")
  done
  #  execute command after select
  # shellcheck disable=SC2006
  seleted=$(echo -ne "${options[@]}" | rofi -dmenu -sep "\x0f" -config "/usr/share/rofi/themes/sidebar.rasi" \
    -eh 7 -markup-rows -p "Recoll")
  if [ -n "$seleted" ]; then
    selected_url=$(echo "$seleted" | head -n 1 | sed 's/<[^>]*>//g' | sed 's/URL://g')
    notify-send "Opening $selected_url"
    echo "$selected_url" | xargs -I {} xdg-open {}
  fi

  ;;

*)
  init_query=$(rofi -dmenu )
  if [ -n "$init_query" ]; then
    "$0" --query "$init_query"
  fi
  ;;
esac
