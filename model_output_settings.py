# `class_data_dir` contains regularization images
import json
import os
import sys

def main():
    folder_name = str(sys.argv[1])
    concepts_list = [
    {
        "instance_prompt":      "photo of " + folder_name + " person",
        "class_prompt":         "photo of a person",
        "instance_data_dir":    "data/"+ folder_name,
        "class_data_dir":       "data/person"
    },
    ]
    for c in concepts_list:
        os.makedirs(c["instance_data_dir"])

    with open("concepts_list.json", "w") as f:
        json.dump(concepts_list, f, indent=4)
    input("ENTER cuando las fotos esten subidas")
    
main()

