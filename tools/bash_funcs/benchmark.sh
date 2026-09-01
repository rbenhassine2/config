benchmark() {
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        echo "Usage: benchmark <command> [iterations]"
        echo
        echo "Time a shell command over N runs and print per-run timings plus"
        echo "average, min, max and range statistics."
        echo
        echo "Arguments:"
        echo "  command      The shell command to benchmark (quoted if it has spaces)."
        echo "  iterations   Number of runs (default: 10)."
        echo
        echo "Examples:"
        echo "  benchmark 'curl -s http://localhost:8069' 5"
        echo "  benchmark 'python script.py' 20"
        return 0
    fi

    local cmd="$1"
    local iterations="${2:-10}"
    declare -a times
    
    echo "Benchmarking: $cmd"
    echo "Iterations: $iterations"
    echo "------------------------"
    
    for ((i=0; i<$iterations; i++)); do
        start=$(date +%s.%N)
        eval "$cmd" > /dev/null 2>&1
        end=$(date +%s.%N)
        
        runtime=$(echo "$end - $start" | bc)
        times[$i]=$runtime
        printf "Run %2d: %.6f seconds\n" $((i+1)) $runtime
    done
    
    # Calculate statistics
    local sum=0
    local min=${times[0]}
    local max=${times[0]}
    
    for time in "${times[@]}"; do
        sum=$(echo "$sum + $time" | bc)
        min=$(echo "if ($time < $min) $time else $min" | bc)
        max=$(echo "if ($time > $max) $time else $max" | bc)
    done
    
    local average=$(echo "scale=6; $sum / $iterations" | bc)
    
    echo "------------------------"
    printf "Average: %.6f seconds\n" $average
    printf "Min:     %.6f seconds\n" $min
    printf "Max:     %.6f seconds\n" $max
    printf "Range:   %.6f seconds\n" $(echo "$max - $min" | bc)
}