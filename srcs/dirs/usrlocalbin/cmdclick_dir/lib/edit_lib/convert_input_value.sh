#!/bin/bash

convert_input_value(){
  LANG=C
  #入力値を取得
  # echo "convert_input_value1: ${ini_value}"
  local ini_value=$(echo "${1}" | sed 's/^"-"$//' | sed 's/^"-"/-/' | sed 's/\\"\\\-\\"/-/' | sed -r 's/^"(.*)( .)(.*)"$/\1\2\3/' | sed  -re "s/(.*)( .)(.*)/\"\1\2\3\"/")
  # echo "${ini_contents}"
  local set_key_value=$(paste -d '=' <(echo "${all_key_con}") <(echo "${ini_value}" | sed -r 's/([^a-zA-Z0-9_])/\\\1/g'))
  local sed_set_key_value_con=$(echo "${set_key_value}" | sed -r "s/(^[a-zA-Z0-9_-]{1,100})\=(.*)/| sed \"s\/^\1\=.*\/\1=\2\/\"/")
  local sed_set_key_value_con=$(echo ${sed_set_key_value_con} | tr -d '\n')
  # echo ---
  # echo "sed_set_key_value_con: ${sed_set_key_value_con}"
  ini_contents=$(eval "echo \"\${ini_contents}\" ${sed_set_key_value_con}" | sed -r "s/(^[a-zA-Z0-9_-]{1,100}=)-$/\1/")
  # echo "ini_contents: ${ini_contents}"
}
