import os, shutil
from random import choice

damaged = []
for file in os.listdir("testing"):
    damaged.append(file)

# remove photos for testing
for i in range(27):
    later = choice(damaged)
    shutil.move(f"training/{later}", f"testing/{later}")
    damaged.remove(later)
print(len(damaged))

for file in os.listdir("repaired-processed"):
    name = file.split("-")
    for item in damaged:
        if name[0] in item:
            shutil.copyfile(f"repaired-processed/{file}", f"testing/{file}")
