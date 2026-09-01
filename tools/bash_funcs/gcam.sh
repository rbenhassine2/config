gcam(){
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        echo "Usage: gcam <message>"
        echo
        echo "Stage all changes and commit with the given message."
        echo "Runs 'git add .', then 'git commit -am \"<message>\"'."
        return 0
    fi

    if [ $# -eq 0 ]; then
        echo "Error: Function requires a commit message"
        return 1
    fi

    git add .

    if [[ $? -eq 0 ]]; then
        git commit -am "$1"
    fi     
}