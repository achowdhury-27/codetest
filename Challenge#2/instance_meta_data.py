import requests

meta_keys=requests.get('http://169.254.169.254/latest/meta-data')

meta_keys_list=meta_keys.content.split()


final_json={}
base_url="http://169.254.169.254/latest/meta-data/"
for keys in meta_keys_list:
    url=base_url+keys
    value=requests.get(url)
    final_json[keys]=value.content

print(final_json)
