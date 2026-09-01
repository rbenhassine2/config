mp3chsplt() {
    local use_dir_name=false
    local dir_name
    local mp3_files
    local file_num=1
    local bitrate="46k"

    # Parse flags
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                echo "Usage: mp3chsplt [--dir-name true|false] [--bitrate <bitrate>]"
                echo
                echo "Convert every .mp3 file in the current directory to Opus"
                echo "(libopus), split into 5-minute segments named"
                echo "<prefix>-001.opus, ... (a single segment drops the -001)."
                echo "Original .mp3 files are removed on success."
                echo
                echo "Options:"
                echo "  --dir-name true|false   Prefix outputs with the current"
                echo "                          directory name (default: false)."
                echo "  --bitrate <bitrate>     Opus bitrate, e.g. 46k, 64k, 128k"
                echo "                          (default: 46k)."
                echo
                echo "Requires: ffmpeg."
                return 0
                ;;
            --dir-name)
                shift
                if [[ "$1" == "true" || "$1" == "false" ]]; then
                    use_dir_name="$1"
                    shift
                else
                    echo "Error: --dir-name requires a boolean value (true or false)"
                    echo "Usage: mp3splt [--dir-name true|false] [--bitrate <bitrate>]"
                    return 1
                fi
                ;;
            --bitrate)
                shift
                if [[ -n "$1" ]]; then
                    bitrate="$1"
                    shift
                else
                    echo "Error: --bitrate requires a value (e.g., 46k, 64k, 128k)"
                    echo "Usage: mp3splt [--dir-name true|false] [--bitrate <bitrate>]"
                    return 1
                fi
                ;;
            *)
                echo "Unknown option: $1"
                echo "Usage: mp3splt [--dir-name true|false] [--bitrate <bitrate>]"
                return 1
                ;;
        esac
    done

    # Find all MP3 files in current directory, sorted by name
    mapfile -t mp3_files < <(find . -maxdepth 1 -name "*.mp3" -type f | sort -V)

    if [[ ${#mp3_files[@]} -eq 0 ]]; then
        echo "Error: No MP3 files found in current directory"
        return 1
    fi

    echo "Found ${#mp3_files[@]} MP3 file(s)"

    # Get current directory name for output prefix
    dir_name=$(basename "$(pwd)")

    # Determine zero-padding for file numbers
    local file_num_format
    if [[ ${#mp3_files[@]} -lt 100 ]]; then
        file_num_format="%02d"
    else
        file_num_format="%03d"
    fi

    # Check if ffmpeg is available
    if ! command -v ffmpeg &> /dev/null; then
        echo "Error: ffmpeg is not installed or not in PATH"
        return 1
    fi

    # Process each MP3 file
    for input_file in "${mp3_files[@]}"; do
        echo "Converting $input_file to Opus (file $file_num)..."

        # Format file number with appropriate zero-padding
        local formatted_file_num
        printf -v formatted_file_num "$file_num_format" "$file_num"

        # Build output filename based on flag
        local output_prefix
        if [[ "$use_dir_name" == true ]]; then
            output_prefix="${dir_name}-${formatted_file_num}"
        else
            output_prefix="${formatted_file_num}"
        fi

        # Split and convert to Opus
        ffmpeg -i "$input_file" -f segment -segment_time 300 -reset_timestamps 1 -threads 1 -map_metadata -1 -map_chapters -1 -map 0:a -c:a libopus -b:a "$bitrate" "${output_prefix}-%03d.opus" -y

        if [[ $? -ne 0 ]]; then
            echo "Error: Failed to process $input_file"
            return 1
        fi

        # Count resulting files
        local file_count
        file_count=$(find . -maxdepth 1 -name "${output_prefix}-*.opus" -type f | wc -l)

        if [[ $file_count -eq 1 ]]; then
            # Only one segment, remove the suffix
            local segment_file
            segment_file=$(find . -maxdepth 1 -name "${output_prefix}-*.opus" -type f -print -quit)
            mv "$segment_file" "${output_prefix}.opus"
        fi

        rm "$input_file"
        echo "Successfully processed $input_file"

        ((file_num++))
    done

    # Clean up any non-Opus files
    find . -maxdepth 1 -type f ! -name "*.opus" -delete
    echo "All conversions completed successfully!"
}
