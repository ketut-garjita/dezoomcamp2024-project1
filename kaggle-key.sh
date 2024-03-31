import os
import json

# Define the content of the kaggle.json file
data = {
    "username": "ketutgarjita",
    "key": "105b7cfe0e35251e4f61267478ae09f3"
}

# Convert the data to a JSON string
json_string = json.dumps(data)

# Put the JSON string into the /home/src
file1 = open('/home/smrhitam/code/kaggle.json', 'w')
file1.write(json_string)
file1.close()
