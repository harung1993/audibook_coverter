#!/bin/bash

# Check if a folder path was provided, otherwise use the current directory
if [[ -n "$1" ]]; then
    cd "$1" || { echo "Error: Folder not found!"; exit 1; }
fi

# Get audiobook name from folder name
audiobook_name=$(basename "$PWD")

# Count the number of MP3 files in the folder
mp3_count=$(ls -1 *.mp3 2>/dev/null | wc -l)

# Check if a cover image exists (cover.jpg, folder.jpg, or first found image)
cover_image=""
if [[ -f "cover.jpg" ]]; then
    cover_image="cover.jpg"
elif [[ -f "folder.jpg" ]]; then
    cover_image="folder.jpg"
else
    first_image=$(ls -1 *.jpg *.png 2>/dev/null | head -n 1)
    if [[ -n "$first_image" ]]; then
        cover_image="$first_image"
    fi
fi

# Function to extract metadata
extract_metadata() {
    local file="$1"
    title=$(ffprobe -v error -show_entries format_tags=title -of default=noprint_wrappers=1:nokey=1 "$file")
    artist=$(ffprobe -v error -show_entries format_tags=artist -of default=noprint_wrappers=1:nokey=1 "$file")
    album=$(ffprobe -v error -show_entries format_tags=album -of default=noprint_wrappers=1:nokey=1 "$file")

    # Use defaults if metadata is missing
    [[ -z "$title" ]] && title="$audiobook_name"
    [[ -z "$artist" ]] && artist="Unknown Author"
    [[ -z "$album" ]] && album="$audiobook_name"
}

# Checks the folder, if only one mp3 it just converts it to m4b else it combines them
if [[ "$mp3_count" -eq 1 ]]; then
    single_file=$(ls -1 *.mp3)
    audiobook_name="${single_file%.mp3}"  # Removing .mp3 extension for naming

    echo "🎧 Detected a single MP3 file: $single_file"
    echo "Extracting metadata..."
    
    extract_metadata "$single_file"

    echo "Converting to M4B with metadata..."
    
    ffmpeg -i "$single_file" \
        -metadata title="$title" \
        -metadata artist="$artist" \
        -metadata album="$album" \
        ${cover_image:+-i "$cover_image" -map 1:0 -metadata:s:v title="Cover" -metadata:s:v comment="Cover (Front)"} \
        -c:a aac -b:a 128k -vn -f mp4 "${audiobook_name}.m4b"

    echo "✅ Conversion complete! Your audiobook is ready as: ${audiobook_name}.m4b"

else
    echo "📚 Detected multiple MP3 files. Merging before conversion..."

    #creating the file list ffmpeg will use
    ls -1 *.mp3 | sed "s/^/file '/;s/$/'/" > filelist.txt

    # Merging mp3s into a single file
    ffmpeg -f concat -safe 0 -i filelist.txt -c copy "${audiobook_name}.mp3"

    echo "Extracting metadata from first MP3 file..."
    first_file=$(ls -1 *.mp3 | head -n 1)
    extract_metadata "$first_file"

    echo "Converting to M4B with metadata..."
    
    ffmpeg -i "${audiobook_name}.mp3" \
        -metadata title="$title" \
        -metadata artist="$artist" \
        -metadata album="$album" \
        ${cover_image:+-i "$cover_image" -map 1:0 -metadata:s:v title="Cover" -metadata:s:v comment="Cover (Front)"} \
        -c:a aac -b:a 128k -vn -f mp4 "${audiobook_name}.m4b"

    # Cleaning up
    rm filelist.txt "${audiobook_name}.mp3"

    echo "✅ Conversion complete! Your audiobook is ready as: ${audiobook_name}.m4b"
fi
