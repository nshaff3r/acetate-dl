#!/bin/bash

OUTPUT_DIR="../expanded-training"
mkdir -p "$OUTPUT_DIR"

# dimensions for padding
TARGET_WIDTH=3035
TARGET_HEIGHT=2396
COLOR_PROFILE="/Library/Application Support/Adobe/Color/Profiles/Recommended/sRGB Color Space Profile.icm"

IMAGE="$1"
TASK="$2"
echo "$TASK"

# extract the filename without the path
FILENAME=$(basename "$IMAGE")
BASENAME="${FILENAME%.*}"

# Loop through each character in the TASK string
for digit in $(echo "$TASK" | fold -w1); do
    case $digit in
        1)
            magick "$IMAGE" -crop 1518x1518+0+0 -resize 256x256 -strip -profile "$COLOR_PROFILE" "$OUTPUT_DIR/${BASENAME}_1.jpg"
            ;;
        2)
            magick "$IMAGE" -crop 1518x1518+1517+0 -resize 256x256 -strip -profile "$COLOR_PROFILE" "$OUTPUT_DIR/${BASENAME}_2.jpg"
            ;;
        3)
            magick "$IMAGE" -crop 1518x1518+0+878 -resize 256x256 -strip -profile "$COLOR_PROFILE" "$OUTPUT_DIR/${BASENAME}_3.jpg"
            ;;
        4)
            magick "$IMAGE" -crop 1518x1518+1517+878 -resize 256x256 -strip -profile "$COLOR_PROFILE" "$OUTPUT_DIR/${BASENAME}_4.jpg"
            ;;
        *)
            echo "Invalid task digit: $digit"
            ;;
    esac
done

echo "Processed $IMAGE."
