#####################################################
import requests
import json

output = {}
metadata_url = 'http://169.254.169.254/latest/meta-data/'
print(metadata_url)
r = requests.get(metadata_url)
text = r.text

unicode_to_list = str(text)
get_list = unicode_to_list.split()

#iterate the list to get the values
for item in get_list:
    r1 = requests.get( metadata_url + item )
    text1 = r1.text
    output[item] = text1
    metadata_json = json.dumps(output, indent=4, sort_keys=True)
print(metadata_json)

#get The Particular value 
d = json.loads(metadata_json)
print(d.get('ami-id'))
