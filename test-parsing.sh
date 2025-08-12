#!/bin/bash

# Test the parsing logic
videos='Rutherford And Chase Masterclass! | Highlights | West Indies v Pakistan | 2nd ODI|O2AIWbZNab0|NA
A Tactical Wonderland! || Nihal Sarin vs Arjun Erigaisi || Chennai Grand Masters 2025|0OTttpQVxMg|NA
The TRUTH Behind Popularity of Action Films | War 2 | Superman | F4 | Dhruv Rathee|veiAkFHyJ5c|NA'

echo "Raw videos:"
echo "$videos"
echo
echo "Formatted videos:"

formatted_videos=""
while IFS= read -r line; do
    if [ -n "$line" ]; then
        # Split only on the last two | characters to handle titles with pipes
        # Extract video_id (second to last field)
        video_id=$(echo "$line" | rev | cut -d'|' -f2 | rev)
        # Extract uploader (last field)
        uploader=$(echo "$line" | rev | cut -d'|' -f1 | rev)
        # Extract title (everything except the last two fields)
        title=$(echo "$line" | rev | cut -d'|' -f3- | rev)
        
        if [ -n "$title" ] && [ -n "$video_id" ]; then
            formatted_line="$title | $uploader | https://youtu.be/$video_id"
            formatted_videos="$formatted_videos\n$formatted_line"
            echo "$formatted_line"
        fi
    fi
done <<< "$videos"

echo
echo "Testing fzf output (selecting first item):"
# Simulate selecting the first video
selected_video=$(echo -e "$formatted_videos" | head -2 | tail -1)
echo "Selected: $selected_video"

# Extract URL from selection
video_url=$(echo "$selected_video" | awk -F' | ' '{print $3}')
echo "URL: $video_url"
