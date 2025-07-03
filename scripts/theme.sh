#!/usr/bin/env sh

# Dependency matugen(https://github.com/InioX/matugen) and swww

# Set variables
wal_dir="/home/stoney/Pictures/walls/"
mode="dark"
default_scheme="scheme-content"

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS] [WALLPAPER_PATH]"
    echo ""
    echo "Options:"
    echo "  -s, --scheme TYPE     Set scheme type (content|monochrome|random)"
    echo "  -m, --mode MODE       Set color mode (dark|light)"
    echo "  -r, --random-scheme   Use random scheme type"
    echo "  -h, --help           Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                           # Random wallpaper with default scheme"
    echo "  $0 -s content               # Random wallpaper with content scheme"
    echo "  $0 -s monochrome            # Random wallpaper with monochrome scheme"
    echo "  $0 -r                       # Random wallpaper with random scheme"
    echo "  $0 /path/to/wallpaper.jpg   # Specific wallpaper with default scheme"
    echo "  $0 -s content /path/to/wallpaper.jpg  # Specific wallpaper with content scheme"
}

# All available scheme types
schemes=("scheme-content" "scheme-monochrome")

# Function to get random scheme
get_random_scheme() {
    echo "${schemes[$((RANDOM % ${#schemes[@]}))]}"
}

# Initialize variables
scheme_type="$default_scheme"
use_random_scheme=false
wall=""

# Parse command line arguments
while [ $# -gt 0 ]; do
    case $1 in
        -s|--scheme)
            if [ -n "$2" ]; then
                case $2 in
                    content|scheme-content)
                        scheme_type="scheme-content"
                        ;;
                    monochrome|scheme-monochrome)
                        scheme_type="scheme-monochrome"
                        ;;
                    random)
                        use_random_scheme=true
                        ;;
                    *)
                        echo "Error: Invalid scheme type '$2'." >&2
                        echo "Valid options: content, monochrome, random" >&2
                        exit 1
                        ;;
                esac
                shift 2
            else
                echo "Error: --scheme requires an argument" >&2
                exit 1
            fi
            ;;
        -m|--mode)
            if [ -n "$2" ]; then
                case $2 in
                    dark|light)
                        mode="$2"
                        ;;
                    *)
                        echo "Error: Invalid mode '$2'. Use 'dark' or 'light'." >&2
                        exit 1
                        ;;
                esac
                shift 2
            else
                echo "Error: --mode requires an argument" >&2
                exit 1
            fi
            ;;
        -r|--random-scheme)
            use_random_scheme=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        -*)
            echo "Error: Unknown option '$1'" >&2
            show_usage
            exit 1
            ;;
        *)
            # This should be the wallpaper path
            if [ -z "$wall" ]; then
                wall="$1"
            else
                echo "Error: Multiple wallpaper paths specified" >&2
                exit 1
            fi
            shift
            ;;
    esac
done

# Determine scheme type
if [ "$use_random_scheme" = true ]; then
    scheme_type=$(get_random_scheme)
    echo "Using random scheme: $scheme_type"
fi

# Select wallpaper if not provided
if [ -z "$wall" ]; then
    if [ ! -d "$wal_dir" ]; then
        echo "Error: Wallpaper directory '$wal_dir' does not exist" >&2
        exit 1
    fi
    
    wall="$(fd . "$wal_dir" -e jpg -e jpeg -e png -e gif --type f | shuf -n 1)"
    
    if [ -z "$wall" ]; then
        echo "Error: No wallpapers found in '$wal_dir'" >&2
        exit 1
    fi
    
    echo "Selected random wallpaper: $(basename "$wall")"
else
    # Validate provided wallpaper path
    if [ ! -f "$wall" ]; then
        echo "Error: Wallpaper file '$wall' does not exist" >&2
        exit 1
    fi
    echo "Using wallpaper: $(basename "$wall")"
fi

# Display configuration
echo "Configuration:"
echo "  Mode: $mode"
echo "  Scheme: $scheme_type"
echo "  Wallpaper: $wall"

# Generate theme with matugen
echo "Generating theme..."
if matugen -t "$scheme_type" -m "$mode" image "$wall"; then
    echo "Theme generated successfully!"
else
    echo "Error: Failed to generate theme" >&2
    exit 1
fi
