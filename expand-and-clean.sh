#!/bin/bash

# Check if a directory is passed as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <directory> [--task]"
  exit 1
fi

IMAGE_DIR="$1"
TASK="$2"

OUTPUT_DIR="./training-final-expanded"
mkdir -p "$OUTPUT_DIR"

# dimensions for padding
TARGET_WIDTH=3035
TARGET_HEIGHT=2396
COLOR_PROFILE="/Library/Application Support/Adobe/Color/Profiles/Recommended/sRGB Color Space Profile.icm"

# process each image in the directory
for IMAGE in "$IMAGE_DIR"/*.{jpg,jpeg,png,tif}; do

  # Skip if there are no matching files
  [ -e "$IMAGE" ] || continue


  # extract the filename without the path
  FILENAME=$(basename "$IMAGE")
  BASENAME="${FILENAME%.*}"
  TEMP_FILE="$OUTPUT_DIR/temp_$FILENAME"

  if [ "$TASK" = "--repaired" ]; then 

    # # If in portrait, rotate counter clockwise 90 degrees
    mogrify -rotate "-90<" $IMAGE

    magick "$IMAGE" -resize 3035x2396 -density 240 -units PixelsPerInch -strip -quality 90 -profile "/Library/Application Support/Adobe/Color/Profiles/Recommended/sRGB Color Space Profile.icm" "$OUTPUT_DIR/$BASENAME.jpg" 2>/dev/null

    magick "$IMAGE" -background black -gravity center -extent ${TARGET_WIDTH}x${TARGET_HEIGHT} "$OUTPUT_DIR/$FILENAME"

    IMAGE_SIZE=$(identify -format "%wx%h\n" "$OUTPUT_DIR/$FILENAME")
    
  elif [ "$TASK" = "--resize" ]; then 
    # Crop and resize each quadrant
    magick "$IMAGE" -crop 1518x1518+0+0 -resize 256x256 -strip -profile "$COLOR_PROFILE" "$OUTPUT_DIR/${BASENAME}_1.jpg"
    magick "$IMAGE" -crop 1518x1518+1517+0 -resize 256x256 -strip -profile "$COLOR_PROFILE" "$OUTPUT_DIR/${BASENAME}_2.jpg"
    magick "$IMAGE" -crop 1518x1518+0+878 -resize 256x256 -strip -profile "$COLOR_PROFILE" "$OUTPUT_DIR/${BASENAME}_3.jpg"
    magick "$IMAGE" -crop 1518x1518+1517+878 -resize 256x256 -strip -profile "$COLOR_PROFILE" "$OUTPUT_DIR/${BASENAME}_4.jpg"
    IMAGE_SIZE=$(identify -format "%wx%h\n" "$OUTPUT_DIR/${BASENAME}_4.jpg")
    
  elif [ "$TASK" = "--check" ]; then 
    magick "$IMAGE" -strip -profile "$COLOR_PROFILE" "$OUTPUT_DIR/$BASENAME.jpg" 2>/dev/null

  else
    # invert, increase contrast, greyscale, clip white and black points, flip horizontally
    magick "$IMAGE" -brightness-contrast 0x15 -negate -set colorspace Gray -black-threshold 10% -white-threshold 90% -flop "$TEMP_FILE"
    
    magick mogrify -resize -strip 3035x2396 $TEMP_FILE

    magick "$IMAGE" -background black -gravity center -extent ${TARGET_WIDTH}x${TARGET_HEIGHT} "$OUTPUT_DIR/$FILENAME"
    
    rm "$TEMP_FILE"
    
    IMAGE_SIZE=$(identify -format "%wx%h\n" "$IMAGE")
  fi
    
  echo "Processed $IMAGE. Size: $IMAGE_SIZE"
done

echo "Processing complete. Processed images are in $OUTPUT_DIR"
