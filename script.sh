#!/bin/bash

# Check if a directory is passed as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <directory> [--repaired]"
  exit 1
fi

if [ "$2" == "--repaired" ]; then
  REPAIRED=true
else
  REPAIRED=false
fi

IMAGE_DIR="$1"

OUTPUT_DIR="./processed"
mkdir -p "$OUTPUT_DIR"

# dimensions for padding
TARGET_WIDTH=3035
TARGET_HEIGHT=2396

# process each image in the directory
for IMAGE in "$IMAGE_DIR"/*.{jpg,jpeg,png,tif}; do

  # extract the filename without the path
  FILENAME=$(basename "$IMAGE")
  BASENAME="${FILENAME%.*}"
  TEMP_FILE="$OUTPUT_DIR/temp_$FILENAME"

  if [ $REPAIRED = true ]; then 

    # # If in portrait, rotate counter clockwise 90 degrees
    mogrify -rotate "-90<" $IMAGE

    magick "$IMAGE" -resize 3035x2396 -density 240 -units PixelsPerInch -strip -quality 90 -profile "/Library/Application Support/Adobe/Color/Profiles/Recommended/sRGB Color Space Profile.icm" "$OUTPUT_DIR/$BASENAME.jpg" 2>/dev/null

    magick "$IMAGE" -background black -gravity center -extent ${TARGET_WIDTH}x${TARGET_HEIGHT} "$OUTPUT_DIR/$FILENAME"

    IMAGE_SIZE=$(identify -format "%wx%h\n" "$OUTPUT_DIR/$FILENAME")
    
  else
    # invert, increase contrast, greyscale, clip white and black points, flip horizontally
    magick "$IMAGE" -brightness-contrast 0x15 -negate -set colorspace Gray -black-threshold 10% -white-threshold 90% -flop "$TEMP_FILE"
    
    magick mogrify -resize 3035x2396 $TEMP_FILE

    magick "$IMAGE" -background black -gravity center -extent ${TARGET_WIDTH}x${TARGET_HEIGHT} "$OUTPUT_DIR/$FILENAME"
    
    rm "$TEMP_FILE"
    
    IMAGE_SIZE=$(identify -format "%wx%h\n" "$IMAGE")
  fi
    
  echo "Processed $IMAGE. Size: $IMAGE_SIZE"
done

echo "Processing complete. Processed images are in $OUTPUT_DIR"
