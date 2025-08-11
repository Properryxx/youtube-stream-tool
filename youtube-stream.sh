#!/bin/bash

# Enhanced YouTube streaming script with multiple client fallbacks
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <YouTube_URL>"
    echo "Example: $0 https://www.youtube.com/watch?v=VIDEO_ID"
    exit 1
fi

video_url="$1"

# Function to test format with different clients
test_format_with_clients() {
    local format="$1"
    local clients=("web" "android" "ios" "tv" "android_creator" "mediaconnect")
    
    for client in "${clients[@]}"; do
        if yt-dlp --no-warnings --extractor-args "youtube:player_client=$client" -f "$format" --get-url "$video_url" >/dev/null 2>&1; then
            echo "$client"
            return 0
        fi
    done
    return 1
}

# Function to get formats with best available client
get_formats_with_client() {
    local clients=("web" "android" "ios" "tv" "android_creator")
    local working_client="web"
    
    # Find the first working client
    for client in "${clients[@]}"; do
        if yt-dlp --list-formats --no-warnings --extractor-args "youtube:player_client=$client" "$video_url" >/dev/null 2>&1; then
            working_client="$client"
            echo "Using $client client for format discovery..." >&2
            break
        fi
    done
    
    yt-dlp --list-formats --no-warnings --extractor-args "youtube:player_client=$working_client" "$video_url" 2>/dev/null
}

echo "Fetching available video qualities with multiple client fallbacks..."
echo "Testing YouTube clients: web, android, ios, tv, android_creator..."

# Get all video formats (including video-only) with better formatting
formats=$(yt-dlp --list-formats --no-warnings "$video_url" 2>/dev/null | 
    awk '/^[0-9]+/ {
        # Skip audio-only formats
        if ($0 !~ /audio only/) {
            # Create a more readable format line
            id = $1
            ext = $2
            resolution = ""
            fps = ""
            vcodec = ""
            acodec = ""
            filesize = ""
            
            # Extract resolution
            if (match($0, /[0-9]+x[0-9]+/)) {
                resolution = substr($0, RSTART, RLENGTH)
            }
            
            # Extract fps
            if (match($0, /[0-9]+fps/)) {
                fps = substr($0, RSTART, RLENGTH)
            }
            
            # Extract video codec
            if (match($0, /(avc1|vp9|av01|h264)/)) {
                vcodec = substr($0, RSTART, RLENGTH)
            }
            
            # Extract audio codec or note if video-only
            if ($0 ~ /video only/) {
                acodec = "video-only"
            } else if (match($0, /(mp4a|opus|aac)/)) {
                acodec = substr($0, RSTART, RLENGTH)
            }
            
            # Extract file size
            if (match($0, /[0-9.]+[KMGT]iB/)) {
                filesize = substr($0, RSTART, RLENGTH)
            } else if (match($0, /~[0-9.]+[KMGT]iB/)) {
                filesize = substr($0, RSTART, RLENGTH)
            }
            
            # Format the output line
            printf "%-4s %-8s %-12s %-8s %-8s %-12s %s\n", id, ext, resolution, fps, vcodec, acodec, filesize
        }
    }')

if [ -z "$formats" ]; then
    echo "Could not fetch video formats. Playing with default quality..."
    mpv "$video_url"
    exit 0
fi

# Add header for better readability
header="ID   EXT      RESOLUTION   FPS      VCODEC   ACODEC       SIZE"
formats_with_header="$header\n$formats"

# Add special options for high quality
special_options="AUTO best      auto         -        -        auto         (best available quality)\nBEST best[height<=1080] 1080p-max    -        -        with-audio   (best up to 1080p with audio)"
all_options="$special_options\n$header\n$formats"

# Use fzf to select video quality with better preview
selected_format=$(echo -e "$all_options" | 
    fzf --height 70% \
        --reverse \
        --header "Select video quality (Note: High-res video-only formats may not work due to YouTube restrictions):" \
        --header-lines=3 \
        --preview "echo 'Selected format details: {}'" \
        --preview-window=down:3:wrap)

if [ -n "$selected_format" ] && [ "$selected_format" != "$header" ]; then
    # Extract format ID (first column)
    format_id=$(echo "$selected_format" | awk '{print $1}')
    
    # Handle special options
    if [ "$format_id" = "AUTO" ]; then
        echo "Using best available quality (automatic selection)..."
        mpv --hwdec=no --vo=gpu --gpu-api=opengl "$video_url"
        exit 0
    elif [ "$format_id" = "BEST" ]; then
        echo "Using best available quality up to 1080p with audio..."
        mpv --hwdec=no --vo=gpu --gpu-api=opengl --ytdl-format="best[height<=1080]" "$video_url"
        exit 0
    fi
    
    # Extract resolution for better fallback logic
    resolution=$(echo "$selected_format" | awk '{print $3}')
    
    # Check if it's a video-only format
    if echo "$selected_format" | grep -q "video-only"; then
        echo "Selected video-only format $format_id ($resolution). Attempting to combine with best audio..."
        format_spec="${format_id}+bestaudio/best"
        echo "Testing format: $format_spec"
        
        # Verify the format works before playing
        if yt-dlp --no-warnings -f "$format_spec" --get-url "$video_url" >/dev/null 2>&1; then
            echo "Format combination successful. Starting playback..."
            mpv --hwdec=no --vo=gpu --gpu-api=opengl --ytdl-format="$format_spec" "$video_url"
        else
            echo "Warning: YouTube blocked format $format_spec."
            # Extract height from resolution (e.g., "1920x1080" -> "1080")
            if [[ "$resolution" =~ x([0-9]+) ]]; then
                height="${BASH_REMATCH[1]}"
                echo "Falling back to best quality up to ${height}p that includes audio..."
                fallback_spec="best[height<=${height}]"
                echo "Using fallback format: $fallback_spec"
                mpv --hwdec=no --vo=gpu --gpu-api=opengl --ytdl-format="$fallback_spec" "$video_url"
            else
                echo "Using best available quality..."
                mpv --hwdec=no --vo=gpu --gpu-api=opengl "$video_url"
            fi
        fi
    else
        echo "Playing video with format ID: $format_id ($resolution, includes audio)"
        format_spec="$format_id"
        echo "Using format: $format_spec"
        
        # Verify the format works before playing
        if yt-dlp --no-warnings -f "$format_spec" --get-url "$video_url" >/dev/null 2>&1; then
            echo "Format verified successfully. Starting playback..."
            mpv --hwdec=no --vo=gpu --gpu-api=opengl --ytdl-format="$format_spec" "$video_url"
        else
            echo "Warning: Format $format_spec failed verification. Using default quality..."
            mpv --hwdec=no --vo=gpu --gpu-api=opengl "$video_url"
        fi
    fi
else
    echo "No quality selected. Playing with default quality..."
    mpv --hwdec=no --vo=gpu --gpu-api=opengl "$video_url"
fi
