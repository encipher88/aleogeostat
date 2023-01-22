#!/usr/local/bin/bash 
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget awk clang pkg-config libssl-dev libclang-dev -y
sudo apt install jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
sudo apt install -y uidmap dbus-user-session
sudo apt install python3-numpy python3-matplotlib libgeos-dev python3-geoip2 python3-mpltoolkits.basemap -y





GEO_DATA_DIR="$HOME/aleogeostat"
if [ ! -d "$GEO_DATA_DIR" ]; then
  mkdir "$GEO_DATA_DIR";
fi

GEO_DATA="$GEO_DATA_DIR/data"
if [ ! -d "$GEO_DATA" ]; then
  mkdir "$GEO_DATA";
fi

if [ -f "$bash_profile" ]; then
    . $HOME/.bash_profile
fi


DATA="$(date +"utc^%d-%m-%y^%H:%M")" 
touch $HOME/aleogeostat/iptest${DATA}.json
chmod +x $HOME/aleogeostat/iptest${DATA}.json
IPDATA=$HOME/aleogeostat/iptest${DATA}.json
STATOUT=$HOME/aleogeostat/OUTPUT${DATA}.txt
if [ -z "$IPDATA" ]; then
  echo "Please configure IP FILE in script"
  exit 1
fi

curl -sS http://vm.aleo.org/api/testnet3/peers/all  | sed 's/","/\n/g' | sed 's/"]//g'    >> $IPDATA

for line in `cat "$IPDATA"` 
 do
IP1="$( cut -d":" -f1 <<< "$line" )";
done

python3 pygeoipmap.py -i $IPDATA  --service m --db "$HOME/aleogeostat/GeoLite2-City.mmdb"  --output "$HOME/aleogeostat/output/map.png"

cd $GEO_DATA_DIR
tar -zxf files.tar.gz -C $GEO_DATA_DIR



declare -a Countries Cities Organizations;
# shellcheck disable=SC2002

for line in `cat "$IPDATA"` 
do
IP="$( cut -d":" -f1 <<< "$line" )";
echo $IP 
#sleep 10
  if [ ! -f "$GEO_DATA/$IP.json" ]; then
    # shellcheck disable=SC2034
    DATA=$(curl -s "https://ipinfo.io/$IP");
    # shellcheck disable=SC2034
    # shellcheck disable=SC2036
    # shellcheck disable=SC2030
    IP=$(echo "$DATA" | jq '.ip' | sed 's/\"//g');
    # shellcheck disable=SC2034
    COUNTRY=$(echo "$DATA" | jq '.country' | sed 's/\"//g');
    # shellcheck disable=SC2034
    # shellcheck disable=SC2030
    CITY=$(echo "$DATA" | jq '.city' | sed 's/\"//g');
    # shellcheck disable=SC2034
    # shellcheck disable=SC2030
    ORG=$(echo "$DATA" | jq '.org' | sed 's/\"//g');
    # shellcheck disable=SC2034
    # shellcheck disable=SC2157
    JSON_STRING=$( jq -n \
                      --arg ip "$IP"  \
                      --arg country "$COUNTRY" \
                      --arg city "$CITY" \
                      --arg org "$ORG" \
                      '{ip: $ip, country: $country, city: $city, org: $org}' )
    echo "$JSON_STRING" >> "$GEO_DATA/$IP.json";
  fi
  
  
  if [ -f "$GEO_DATA/$IP.json" ]; then
    COUNTRY=$(cat "$GEO_DATA/$IP.json" | jq '.country')
    CITY=$(cat "$GEO_DATA/$IP.json" | jq '.city')
    ORG=$(cat "$GEO_DATA/$IP.json" | jq '.org')
    # shellcheck disable=SC2206
    Countries+=($COUNTRY);
    # shellcheck disable=SC2030
    # shellcheck disable=SC2001
    # shellcheck disable=SC2179
    Cities+=($(echo "$CITY" | sed s/' '/_/g));
    # shellcheck disable=SC2030
    # shellcheck disable=SC2001
    # shellcheck disable=SC2179
    Organizations+=($(echo "$ORG" | sed s/' '/_/g));
  fi
  done

# shellcheck disable=SC2034
SUM="${#Countries[@]}";
# shellcheck disable=SC2068
# shellcheck disable=SC2207
# shellcheck disable=SC2006
UniqCountries=( `for i in ${Countries[@]}; do echo "$i"; done | sort -u` )
# shellcheck disable=SC2068
# shellcheck disable=SC2207
# shellcheck disable=SC2068
# shellcheck disable=SC2006
# shellcheck disable=SC2034
UniqCities=( `for i in ${Cities[@]}; do echo "$i"; done | sort -u` )
# shellcheck disable=SC2034
# shellcheck disable=SC2068
# shellcheck disable=SC2207
# shellcheck disable=SC2207
# shellcheck disable=SC2207
# shellcheck disable=SC2068
# shellcheck disable=SC2006
UniqOrganizations=( `for i in ${Organizations[@]}; do echo "$i"; done | sort -u` )

##COUNTRIES
# shellcheck disable=SC2028
echo "Statistic Countries"
declare -A StatisticCountry
for COUNTRY in ${UniqCountries[*]}; do
  # shellcheck disable=SC2031
  COUNT=$(grep -o "$COUNTRY" <<< "${Countries[*]}" | wc -l)
  StatisticCountry["$COUNTRY"]=$COUNT;
done


for COUNTRY in "${!StatisticCountry[@]}"; do
  PERCENT=$((${StatisticCountry[$COUNTRY]} * 100 / $SUM))
  if [ $PERCENT -gt 0 ]; then
    printf "COUNTRY: %s, Servers: %s, Current Percent: %s\r\n" "$COUNTRY" "${StatisticCountry[$COUNTRY]}" "$PERCENT%" >> $STATOUT
  fi
done




##CITIES
# shellcheck disable=SC2028
echo "Statistic Cities"
declare -A StatisticCity
for CITY in ${UniqCities[*]}; do
  # shellcheck disable=SC2031
  COUNT=$(grep -o "$CITY" <<< "${Cities[*]}" | wc -l)
  StatisticCity["$CITY"]=$COUNT;
done

for CITY in "${!StatisticCity[@]}"; do
  # shellcheck disable=SC2004
  # shellcheck disable=SC2074
  PERCENT=$((${StatisticCity[$CITY]} * 100 / $SUM))
  if [ $PERCENT -gt 0 ]; then
    printf "CITY: %s, Servers: %s, Current Percent: %s\r\n" "$CITY" "${StatisticCity[$CITY]}" "$PERCENT%" >> $STATOUT
  fi
done

##ORGANIZATIONS
# shellcheck disable=SC2028
echo "Statistic Organizations"
declare -A StatisticOrg
for ORG in ${UniqOrganizations[*]}; do
  # shellcheck disable=SC2031
  COUNT=$(grep -o "$ORG" <<< "${Organizations[*]}" | wc -l)
  # shellcheck disable=SC2034
  StatisticOrg["$ORG"]=$COUNT;
done

for ORG in "${!StatisticOrg[@]}"; do
  # shellcheck disable=SC2004
  # shellcheck disable=SC1072
  # shellcheck disable=SC1073
  # shellcheck disable=SC1009
  PERCENT=$((${StatisticOrg[$ORG]} * 100 / $SUM))
  if [ $PERCENT -gt 0 ]; then
    printf "ORGANIZATION: %s, Servers: %s, Current Percent: %s\r\n" "$ORG" "${StatisticOrg[$ORG]}" "$PERCENT%" >> $STATOUT
  fi
done


echo "You can find statisti here: $STATOUT"
cat $STATOUT