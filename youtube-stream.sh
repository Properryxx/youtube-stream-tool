#!/bin/bash

# Enhanced YouTube streaming script with cookie support and homepage functionality
# Usage: $0 [YouTube_URL]
# If no URL provided, will use YouTube homepage from cookies

# Configuration
COOKIE_FILE="$HOME/.config/youtube-cookies.txt"
DEFAULT_HOMEPAGE="https://www.youtube.com"

# YouTube 403 error mitigation settings
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
REFERER="https://www.youtube.com/"

# Function to get enhanced yt-dlp arguments for 403 mitigation
get_enhanced_ytdlp_args() {
    local cookie_args=""
    if [ -f "$COOKIE_FILE" ]; then
        cookie_args="--cookies $COOKIE_FILE"
    fi
    
    echo "$cookie_args --user-agent '$USER_AGENT' --add-header 'Referer:$REFERER' --sleep-requests 1 --sleep-subtitles 1"
}

# Function to try multiple extraction methods for 403 errors
try_multiple_extraction_methods() {
    local video_url="$1"
    local format="$2"
    local enhanced_args=$(get_enhanced_ytdlp_args)
    
    echo "Trying multiple extraction methods to bypass 403 errors..."
    
    # Method 1: Enhanced headers with different clients
    local clients=("web" "android" "ios" "tv")
    for client in "${clients[@]}"; do
        echo "Trying $client client with enhanced headers..."
        if yt-dlp --no-warnings $enhanced_args --extractor-args "youtube:player_client=$client" -f "$format" --get-url "$video_url" >/dev/null 2>&1; then
            echo "Success with $client client!"
            return 0
        fi
        sleep 2  # Rate limiting
    done
    
    # Method 2: Try with different format selection
    echo "Trying alternative format selection..."
    if yt-dlp --no-warnings $enhanced_args -f "worst+bestaudio/worst" --get-url "$video_url" >/dev/null 2>&1; then
        echo "Success with alternative format!"
        return 0
    fi
    
    # Method 3: Try basic extraction without format specification
    echo "Trying basic extraction..."
    if yt-dlp --no-warnings $enhanced_args --get-url "$video_url" >/dev/null 2>&1; then
        echo "Success with basic extraction!"
        return 0
    fi
    
    return 1
}

# Function to check if cookies exist and are valid
check_cookies() {
    if [ -f "$COOKIE_FILE" ]; then
        echo "Found cookie file: $COOKIE_FILE"
        return 0
    else
        echo "Warning: Cookie file not found at $COOKIE_FILE"
        echo "To use cookies, export them from your browser to: $COOKIE_FILE"
        return 1
    fi
}

# Function to get YouTube homepage/recommendations
get_homepage_videos() {
    echo "Fetching YouTube homepage/recommendations..."
    
    local cookie_args=""
    if [ -f "$COOKIE_FILE" ]; then
        cookie_args="--cookies $COOKIE_FILE"
    fi
    
    # Get homepage videos using yt-dlp
    local videos=$(yt-dlp $cookie_args --flat-playlist --print "%(title)s|%(id)s|%(uploader)s" "$DEFAULT_HOMEPAGE" 2>/dev/null | head -20)
    
    if [ -z "$videos" ]; then
        echo "Could not fetch homepage videos. Using fallback..."
        # Fallback to trending videos
        videos=$(yt-dlp --flat-playlist --print "%(title)s|%(id)s|%(uploader)s" "https://www.youtube.com/feed/trending" 2>/dev/null | head -10)
    fi
    
    if [ -z "$videos" ]; then
        echo "Error: Could not fetch any videos from YouTube."
        exit 1
    fi
    
    echo "$videos"
}

# Handle arguments
if [ "$#" -eq 0 ]; then
    echo "No URL provided. Fetching YouTube homepage..."
    check_cookies
    
    # Get homepage videos and let user select
    videos=$(get_homepage_videos)
    
    if [ -z "$videos" ]; then
        echo "Failed to fetch homepage videos."
        exit 1
    fi
    
    # Format videos for selection
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
                formatted_videos="$formatted_videos\n$title | $uploader | https://youtu.be/$video_id"
            fi
        fi
    done <<< "$videos"
    
    # Use fzf to select video
    if [ -t 0 ] && [ -t 1 ]; then
        # Interactive mode - use fzf
        selected_video=$(echo -e "$formatted_videos" | 
            fzf --height 70% \
                --reverse \
                --header "Select a video from YouTube homepage:" \
                --preview "echo 'Video: {1}\nUploader: {2}\nURL: {3}'" \
                --preview-window=down:3:wrap \
                --delimiter=" | ")
    else
        # Non-interactive mode - select first video
        echo "Non-interactive mode detected. Selecting first video..."
        selected_video=$(echo -e "$formatted_videos" | head -2 | tail -1)
    fi
    
    if [ -z "$selected_video" ]; then
        echo "No video selected. Exiting."
        exit 0
    fi
    
    # Extract URL from selection (last field after the last | separator)
    video_url=$(echo "$selected_video" | rev | cut -d'|' -f1 | rev | sed 's/^ *//')
    echo "Selected: $video_url"
elif [ "$#" -eq 1 ]; then
    video_url="$1"
else
    echo "Usage: $0 [YouTube_URL]"
    echo "Examples:"
    echo "  $0                                          # Browse YouTube homepage"
    echo "  $0 https://www.youtube.com/watch?v=VIDEO_ID  # Play specific video"
    exit 1
fi

# Function to test format with different clients
test_format_with_clients() {
    local format="$1"
    local clients=("web" "android" "ios" "tv" "android_creator" "mediaconnect")
    
    local cookie_args=""
    if [ -f "$COOKIE_FILE" ]; then
        cookie_args="--cookies $COOKIE_FILE"
    fi
    
    for client in "${clients[@]}"; do
        if yt-dlp --no-warnings $cookie_args --extractor-args "youtube:player_client=$client" -f "$format" --get-url "$video_url" >/dev/null 2>&1; then
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
    
    local cookie_args=""
    if [ -f "$COOKIE_FILE" ]; then
        cookie_args="--cookies $COOKIE_FILE"
    fi
    
    # Find the first working client
    for client in "${clients[@]}"; do
        if yt-dlp --list-formats --no-warnings $cookie_args --extractor-args "youtube:player_client=$client" "$video_url" >/dev/null 2>&1; then
            working_client="$client"
            echo "Using $client client for format discovery..." >&2
            break
        fi
    done
    
    yt-dlp --list-formats --no-warnings $cookie_args --extractor-args "youtube:player_client=$working_client" "$video_url" 2>/dev/null
}

# Check if AUTO mode is requested via stdin
if read -t 0.1 auto_selection && [ "$auto_selection" = "AUTO" ]; then
    echo "AUTO mode detected. Using best available quality with 403 mitigation..."
    enhanced_args=$(get_enhanced_ytdlp_args)
    
    # Try enhanced extraction first
    if try_multiple_extraction_methods "$video_url" "bestvideo+bestaudio/best"; then
        echo "Extraction successful! Starting playback..."
        mpv --hwdec=no --vo=gpu --gpu-api=opengl --ao=pipewire --volume=80 --ytdl-format="bestvideo+bestaudio/best" --ytdl-raw-options=cookies="$COOKIE_FILE",user-agent="$USER_AGENT",add-header="Referer:$REFERER" "$video_url"
    else
        echo "Enhanced extraction failed. Trying basic playback..."
        mpv --hwdec=no --vo=gpu --gpu-api=opengl --ao=pipewire --volume=80 "$video_url"
    fi
    exit 0
fi

echo "Fetching available video qualities with multiple client fallbacks..."
echo "Testing YouTube clients: web, android, ios, tv, android_creator..."

# Prepare cookie arguments
cookie_args=""
if [ -f "$COOKIE_FILE" ]; then
    cookie_args="--cookies $COOKIE_FILE"
fi

# Get all video formats (including video-only) with better formatting
formats=$(yt-dlp --list-formats --no-warnings $cookie_args "$video_url" 2>/dev/null |
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
    mpv --ao=pipewire --volume=80 "$video_url"
    exit 0
fi

# Add header for better readability
header="ID   EXT      RESOLUTION   FPS      VCODEC   ACODEC       SIZE"
formats_with_header="$header\n$formats"

# Add special options for high quality
special_options="AUTO best      auto         -        -        auto         (best available quality)\nBEST best[height<=1080] 1080p-max    -        -        with-audio   (best up to 1080p with audio)"
all_options="$special_options\n$header\n$formats"

# Use fzf to select video quality with better preview
if [ -t 0 ] && [ -t 1 ]; then
    # Interactive mode - use fzf
    selected_format=$(echo -e "$all_options" | 
        fzf --height 70% \
            --reverse \
            --header "Select video quality (Note: High-res video-only formats may not work due to YouTube restrictions):" \
            --header-lines=3 \
            --preview "echo 'Selected format details: {}'" \
            --preview-window=down:3:wrap)
else
    # Non-interactive mode - select AUTO (best quality)
    echo "Non-interactive mode detected. Selecting AUTO (best quality)..."
    selected_format="AUTO best      auto         -        -        auto         (best available quality)"
fi

if [ -n "$selected_format" ] && [ "$selected_format" != "$header" ]; then
    # Extract format ID (first column)
    format_id=$(echo "$selected_format" | awk '{print $1}')
    
# Handle special options
    if [ "$format_id" = "AUTO" ]; then
        echo "Using best available quality (automatic selection)..."
        # Try bestaudio+bestvideo combination first, then fallback
        if mpv --hwdec=no --vo=gpu --gpu-api=opengl --ao=pipewire --volume=80 --ytdl-format="bestvideo+bestaudio/best" "$video_url" 2>/dev/null; then
            exit 0
        else
            echo "Fallback: Trying basic format..."
            mpv --hwdec=no --vo=gpu --gpu-api=opengl --ao=pipewire --volume=80 "$video_url"
        fi
        exit 0
    elif [ "$format_id" = "BEST" ]; then
        echo "Using best available quality up to 1080p with audio..."
        # Try with explicit audio combination
        if mpv --hwdec=no --vo=gpu --gpu-api=opengl --ao=pipewire --volume=80 --ytdl-format="bestvideo[height<=1080]+bestaudio/best[height<=1080]" "$video_url" 2>/dev/null; then
            exit 0
        else
            echo "Fallback: Trying simpler format..."
            mpv --hwdec=no --vo=gpu --gpu-api=opengl --ao=pipewire --volume=80 --ytdl-format="best[height<=1080]" "$video_url"
        fi
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
        if yt-dlp --no-warnings $cookie_args -f "$format_spec" --get-url "$video_url" >/dev/null 2>&1; then
            echo "Format combination successful. Starting playback..."
            mpv --hwdec=no --vo=gpu --gpu-api=opengl --ao=pipewire --volume=80 --ytdl-format="$format_spec" "$video_url"
        else
            echo "Warning: YouTube blocked format $format_spec."
            # Extract height from resolution (e.g., "1920x1080" -> "1080")
            if [[ "$resolution" =~ x([0-9]+) ]]; then
                height="${BASH_REMATCH[1]}"
                echo "Falling back to best quality up to ${height}p that includes audio..."
                fallback_spec="best[height<=${height}]"
                echo "Using fallback format: $fallback_spec"
                mpv --hwdec=no --vo=gpu --gpu-api=opengl --ao=pipewire --volume=80 --ytdl-format="$fallback_spec" "$video_url"
            else
                echo "Using best available quality..."
                mpv --hwdec=no --vo=gpu --gpu-api=opengl --ao=pipewire --volume=80 "$video_url"
            fi
        fi
    else
        echo "Playing video with format ID: $format_id ($resolution, includes audio)"
        format_spec="$format_id"
        echo "Using format: $format_spec"
        
        # Verify the format works before playing
        if yt-dlp --no-warnings $cookie_args -f "$format_spec" --get-url "$video_url" >/dev/null 2>&1; then
            echo "Format verified successfully. Starting playback..."
            mpv --hwdec=no --vo=gpu --gpu-api=opengl --ao=pipewire --volume=80 --ytdl-format="$format_spec" "$video_url"
        else
            echo "Warning: Format $format_spec failed verification. Using default quality..."
            mpv --hwdec=no --vo=gpu --gpu-api=opengl --ao=pipewire --volume=80 "$video_url"
        fi
    fi
else
    echo "No quality selected. Playing with default quality..."
    mpv --hwdec=no --vo=gpu --gpu-api=opengl --ao=pipewire --volume=80 "$video_url"
fi
