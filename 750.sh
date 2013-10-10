#!/bin/sh
swords_email='you@example.net'
swords_password='secret'
beeminder_username='you'
beeminder_auth_token='abcdefg'
beeminder_goal='750words'
beeminder_value='750' # number to add to the goal if words are completed
swords_date='' # YYYY-MM-DD the day to update. leave blank for today.

if [ -z $swords_date ]; then
  swords_date=$(date +"%Y-%m-%d")
fi

beeminder_url=https://www.beeminder.com/api/v1/users/$beeminder_username
auth_token=$(curl -b cookies.txt -c cookies.txt https://750words.com/auth |\
  grep authenticity | grep -o 'value=\"[^ ]*' | cut -c 8- | tr -d '"')
if [ $auth_token ]; then
  curl -b cookies.txt -c cookies.txt\
    --data-urlencode "authenticity_token=$auth_token"\
    --data-urlencode "person%5Bemail_address%5D=$swords_email"\
    --data-urlencode "person%5Bpassword%5D=$swords_password"\
    --data "commit=Submit"\
    https://750words.com/auth/signin
fi
if curl -b cookies.txt http://750words.com/statistics/$swords_date |\
  grep "You completed your words."
then
  curl\
    --data "timestamp=$(date +%s)"\
    --data "value=$beeminder_value"\
    --data "auth_token=$beeminder_auth_token"\
    $beeminder_url/goals/$beeminder_goal/datapoints.json
else
  echo "Evidence of completed words for $swords_date not found."
fi
