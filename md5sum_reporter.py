import requests, time

hashes_file = {}

with open("test.txt", "r") as f:
    hashes_list = f.read().split("\n")

vtkeys = ["570480f666a9b4a23afd05f42f4bf9878b90d10ef2427f5b2e885c4f4a3fe19b"]
vt_key_counter = 0

for hashes in hashes_list:
    hash = hashes.split("  ")[0]
    file_location = hashes.split("  ")[-1]
    params = {'apikey': vtkeys[vt_key_counter], 'resource': hash}
    headers = {"User-Agent" : "User-Agent': 'Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.14 (KHTML, like Gecko) Chrome/24.0.1292.0 Safari/537.14"}
    r = requests.get('https://www.virustotal.com/vtapi/v2/file/report',params=params, headers=headers)
    data = r.json()
    vt_key_counter += 1
    vt_key_counter = vt_key_counter % len(vtkeys)
    if data['response_code'] == 1:
        positives = data['positives']
        total = data['total']
        print ("Detection Ratio: {}/{} for {}".format(positives,total, file_location))
    else:
        print ("No records on VirusTotal for {}".format(file_location))
    time.sleep(16//len(vtkeys))
