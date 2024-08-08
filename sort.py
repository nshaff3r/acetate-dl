import os, shutil
from random import choice

"""
Script for organizing files
"""

images = []
for file in os.listdir("all-processed"):
    name = file.split(".")[0]
    if len(name) > 1:
      images.append(name)  
    

for file in os.listdir("not-to-use"):
    if file.split(".")[0] in images:
        images.remove(file.split(".")[0])
        images.remove(file.split(".")[0] + "-repaired")

with open("aa.txt", "r") as file:
    for line in file.readlines():
        name = line.rstrip().split("/")[-1].split(".")[0]
        if name in images:
            images.remove(name)
            images.remove(name + "-repaired")
damaged = []
for image in images:
    if "repaired" not in image:
        damaged.append(image)
print(len(damaged))

# remove photos for testing
for i in range(5):
    random_sel = choice(damaged)
    later_pair = random_sel + "-repaired.jpg"
    later = random_sel + ".jpg"
    shutil.copyfile(f"all-processed/{later}", f"verification/{later}")
    shutil.copyfile(f"all-processed/{later_pair}", f"verification/{later_pair}")
    images.remove(random_sel)
    images.remove(random_sel + "-repaired")

for image in images:
    shutil.copyfile(f"all-processed/{image}.jpg", f"training-final/{image}.jpg")
