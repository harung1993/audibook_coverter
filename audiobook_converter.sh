#!/bin/bash

# Check if a file or folder path was provided
if [[ -n "$1" ]]; then
    if [[ -f "$1" ]]; then
        audiobook_name="${1%.*}"
        existing_file="$1"
    elif [[ -d "$1" ]]; then
        cd "$1" || { echo "Error: Folder not found!"; exit 1; }
    else
        echo "Error: Invalid file or folder provided!"
        exit 1
    fi
fi

# Determine audiobook name based on folder if executing inside a folder
if [[ -z "$audiobook_name" || "$audiobook_name" == "" ]]; then
    audiobook_name=$(basename "$PWD")
fi

# Count the number of MP3 and M4B files in the folder
mp3_count=$(ls -1 *.mp3 2>/dev/null | wc -l)
m4b_count=$(ls -1 *.m4b 2>/dev/null | wc -l)

# Check if a cover image exists
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

# Function to fetch metadata from Google Books API
fetch_metadata() {
    local query=$(echo "$audiobook_name" | sed 's/ /%20/g')
    metadata=$(curl -s "https://www.googleapis.com/books/v1/volumes?q=intitle:$query")
    
    title=$(echo "$metadata" | jq -r '.items[0].volumeInfo.title' 2>/dev/null)
    artist=$(echo "$metadata" | jq -r '.items[0].volumeInfo.authors[0]' 2>/dev/null)
    album="$audiobook_name"
    cover_url=$(echo "$metadata" | jq -r '.items[0].volumeInfo.imageLinks.thumbnail' 2>/dev/null)
    
    [[ -z "$title" || "$title" == "null" ]] && title="$audiobook_name"
    [[ -z "$artist" || "$artist" == "null" ]] && artist="Unknown Author"
    
    if [[ -n "$cover_url" && "$cover_url" != "null" ]]; then
        curl -s "$cover_url" -o "cover.jpg"
        cover_image="cover.jpg"
    fi
}

# If a single M4B exists, update metadata
if [[ "$m4b_count" -eq 1 ]]; then
    existing_m4b=$(ls -1 *.m4b)
    echo "🔄 Updating metadata and embedding cover for existing M4B file: $existing_m4b"
    fetch_metadata
    AtomicParsley "$existing_m4b" --title "$title" --artist "$artist" --album "$album" \
        ${cover_image:+--artwork "$cover_image"} --overWrite
    echo "✅ Metadata update complete for: $existing_m4b"
    exit 0
fi

# If a single MP3 exists, convert and update metadata
if [[ "$mp3_count" -eq 1 ]]; then
    single_mp3=$(ls -1 *.mp3)
    echo "🎧 Converting single MP3 file: $single_mp3"
    fetch_metadata
    ffmpeg -i "$single_mp3" -c:a aac -b:a 128k -vn -f mp4 "${audiobook_name}.m4b"
    AtomicParsley "${audiobook_name}.m4b" --title "$title" --artist "$artist" --album "$album" \
        ${cover_image:+--artwork "$cover_image"} --overWrite
    echo "✅ Conversion complete! Your audiobook is ready as: ${audiobook_name}.m4b"
    exit 0
fi

# If multiple M4B files exist, merge them and update metadata
if [[ "$m4b_count" -gt 1 ]]; then
    echo "📚 Merging multiple M4B files into a single audiobook..."
    ls -1 *.m4b | sed "s/^/file '/;s/$/'/" > filelist.txt
    ffmpeg -f concat -safe 0 -i filelist.txt -c copy "${audiobook_name}_merged.m4b"
    fetch_metadata
    AtomicParsley "${audiobook_name}_merged.m4b" --title "$title" --artist "$artist" --album "$album" \
        ${cover_image:+--artwork "$cover_image"} --overWrite
    rm filelist.txt
    echo "✅ Merging and metadata update complete! Your audiobook is ready as: ${audiobook_name}_merged.m4b"
    exit 0
fi

# If multiple MP3 files exist, merge, convert, and update metadata
if [[ "$mp3_count" -gt 1 ]]; then
    echo "📚 Merging multiple MP3 files before conversion..."
    ls -1 *.mp3 | sed "s/^/file '/;s/$/'/" > filelist.txt
    ffmpeg -f concat -safe 0 -i filelist.txt -c:a aac -b:a 128k -vn "${audiobook_name}.m4b"
    fetch_metadata
    AtomicParsley "${audiobook_name}.m4b" --title "$title" --artist "$artist" --album "$album" \
        ${cover_image:+--artwork "$cover_image"} --overWrite
    rm filelist.txt
    echo "✅ Merging, conversion, and metadata update complete! Your audiobook is ready as: ${audiobook_name}.m4b"
    exit 0
fi
