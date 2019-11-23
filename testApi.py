import requests
import json
import random
import time

url = "http://statifier.herokuapp.com/twosamplettest/gender/test_score"

genders = ["male", "female"]
hours_slept_limits = [0, 12]
test_score_limits = [0, 100]

data_dict = [
    {
        "gender": gender, 
        "hours_slept": random.randint(hours_slept_limits[0], hours_slept_limits[1]),
        "test_score": random.randint(test_score_limits[0], test_score_limits[1])
    } 
    for i in range(1000) for gender in genders
]

pre_request = time.time()
response = requests.post(url, data=json.dumps(data_dict))
post_request = time.time()

print(f'Results: {json.dumps(response.json(), indent=4, sort_keys=True)}')
print(f'Response time: {int((post_request - pre_request) * 1000)}ms')