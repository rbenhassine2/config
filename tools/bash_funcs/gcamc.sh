gcamc(){
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        echo "Usage: gcamc"
        echo
        echo "Stage all changes and commit with an ISO timestamp message."
        echo "Runs 'git add .', then 'git commit -am \"checkpoint <timestamp>\"'."
        return 0
    fi

    git add .

    if [[ $? -eq 0 ]]; then
        git commit -am "checkpoint `date -Im -u`"
    fi     
}