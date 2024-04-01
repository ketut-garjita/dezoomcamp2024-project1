import os
import json

# Define the content of the kaggle.json file
data = {
    "username": "<kaggle_username>",
    "key": "<kaggle ke>y"
}

# Convert the data to a JSON string
json_string = json.dumps(data)

# Put the JSON string into the /home/src
file1 = open('/home/<some_folder>/code/kaggle.json', 'w')
file1.write(json_string)
file1.close()
