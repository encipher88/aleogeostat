#!/usr/local/bin/bash 
echo -e '\n\e[42mPreparing to install libs\e[0m\n' && sleep 1
sudo apt update && sudo apt upgrade -y >> /dev/null 2>&1
sudo apt install curl tar wget original-awk clang pkg-config libssl-dev libclang-dev dos2unix -y >> /dev/null 2>&1
sudo apt install jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y >> /dev/null 2>&1
sudo apt install -y uidmap dbus-user-session  >> /dev/null 2>&1
sudo apt install python3-numpy python3-matplotlib libgeos-dev python3-geoip2 python3-mpltoolkits.basemap -y >> /dev/null 2>&1
sudo pip install pillow  >> /dev/null 2>&1
echo -e '\n\e[42mSuccessfull install libs\e[0m\n' && sleep 1
cd $HOME

bash_profile=$HOME/.bash_profile
if [ -f "$bash_profile" ]; then
    . $HOME/.bash_profile
fi

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


	if [ ! $TOKEN ]; then
		read -e -p "Enter your TOKEN : " TOKEN
		echo 'export TOKEN='${TOKEN} >> $HOME/.bash_profile
	fi
	echo -e '\n\e[42mYour TOKEN is:' $TOKEN '\e[0m\n'
	echo 'source $HOME/.bashrc' >> $HOME/.bash_profile
	. $HOME/.bash_profile
	sleep 1


DATA="$(date +"^%d-%m-%y^%H:%M^utc")" 
touch $HOME/aleogeostat/iptest${DATA}.json
chmod +x $HOME/aleogeostat/iptest${DATA}.json
IPDATA=$HOME/aleogeostat/iptest${DATA}.json
IPDATA2=$HOME/aleogeostat/iptest2${DATA}.json
STATOUT=$HOME/aleogeostat/OUTPUT${DATA}.txt
if [ -z "$IPDATA" ]; then
  echo "Please configure IP FILE in script"
  exit 1
fi

. $HOME/.bash_profile

curl -sS http://vm.aleo.org/api/testnet3/peers/all  | sed 's/","/\n/g' | sed 's/"]//g'    >> $IPDATA

for line in `cat "$IPDATA"` 
 do
IP1="$( cut -d":" -f1 <<< "$line" )";
echo $IP1 >> "${IPDATA2}"
done
sleep 5

cd $GEO_DATA_DIR
if [ ! -f "GeoLite2-City.mmdb" ]; then
wget "https://github.com/P3TERX/GeoLite.mmdb/raw/download/GeoLite2-City.mmdb"
fi
echo "Drawing MAP in progress..."
echo "Please wait..."
python3 pygeoipmap.py -i "${IPDATA2}"  --service m --db "$HOME/aleogeostat/GeoLite2-City.mmdb"  --output "$HOME/aleogeostat/map${DATA}.png" >> /dev/null 2>&1

echo -e '\n\e[42mSuccessfull draw map: \e[0m\n' $HOME/aleogeostat/map${DATA}.png && sleep 1

tar -zxf files.tar.gz -C $GEO_DATA_DIR



declare -a Countries Cities Organizations;
# shellcheck disable=SC2002

counter=0
for line in `cat "$IPDATA2"` 
#for line in `cat "/root/aleogeostat/111.json"` 

do
counter=$((counter+1))

printf "%s\r" "Collection of statistics in progress...Provers: $counter"

IP="$( cut -d":" -f1 <<< "$line" )";
#echo $IP 
#sleep 10
  if [ ! -f "$GEO_DATA/$IP.json" ]; then
    # shellcheck disable=SC2034
    DATA=$(curl -s "https://ipinfo.io/${IP}?token=${TOKEN}");
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

# shellcheck disable=SC2034
MAP="map.svg";
NEW_MAP="new_map.svg";
FILE=$(cat "$MAP");

for COUNTRY in "${!StatisticCountry[@]}"; do
  # shellcheck disable=SC2004
  PERCENT=$((${StatisticCountry[$COUNTRY]} * 100 / $SUM))
  if [ $PERCENT -lt 5 ]; then
    COLOR="E6E6FA";
  elif [ $PERCENT -lt 10 ]; then
    COLOR="D8BFD8";
  elif [ $PERCENT -lt 20 ]; then
    COLOR="EE82EE";
  elif [ $PERCENT -lt 30 ]; then
    COLOR="FF00FF";
  elif [ $PERCENT -lt 40 ]; then
    COLOR="BA55D3";
  elif [ $PERCENT -lt 50 ]; then
    COLOR="8A2BE2";
  else
    COLOR="4B0082";
  fi
  # shellcheck disable=SC2002
  STRING=$(cat "$MAP" | grep "$COUNTRY" | sed -e 's/^[[:space:]]*//' | awk -F 'transform' '{print $2}');
  if [ "$STRING" ]; then
    NEW_STRING=$(sed -e "s/818181/$COLOR/; s/fill-opacity=\"0\"/fill-opacity=\"1\"/" <<< "$STRING")
    FILE=$(sed -e "s|$STRING|$NEW_STRING|" <<< "$FILE")
  fi
  # shellcheck disable=SC2074
  # shellcheck disable=SC1072
  # shellcheck disable=SC1073
  # shellcheck disable=SC1009
  if [ $PERCENT -gt 0 ]; then
    printf "COUNTRY: %s, Servers: %s, Current Percent: %s\r\n" "$COUNTRY" "${StatisticCountry[$COUNTRY]}" "$PERCENT%" >> $STATOUT
  fi
done
echo "$FILE" >> "$NEW_MAP"

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

echo -e '\n\e[42mYou can find statistic here:' $STATOUT '\e[0m\n'


TOTAL="$(curl -sS http://vm.aleo.org/api/testnet3/peers/count)"
echo -e '\n\e[42mPROVERS TOTAL:' $TOTAL '\e[0m\n'  >> $STATOUT

cat $STATOUT
