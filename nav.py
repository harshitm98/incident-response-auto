import requests
import json

API_key = '570480f666a9b4a23afd05f42f4bf9878b90d10ef2427f5b2e885c4f4a3fe19b'
url = 'https://www.virustotal.com/vtapi/v2/url/report'
urls = ['google.com','gmail.com']
parameters = {}
for i in urls:
    parameters = {'apikey': API_key, 'resource': i}

    response = requests.get(url=url, params=parameters)

    while(response.status_code!=200):
    	sleep(10)
    	response = requests.get(url=url, params=parameters)
    jr=json.loads(response.text)
    if jr['response_code'] == 0:
    	print("No result in Virus Total")
    elif jr['response_code'] >= 1:
    	if jr['positives'] == 0:
    		print(i,"is not malicious")
    	else:
    		print(i,"is malicious. Detected by",str(jr['positives']),"engine.")
	            