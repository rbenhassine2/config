gca(){
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        echo "Usage: gca"
        echo
        echo "Stage all changes and commit using the editor."
        echo "Runs 'git add .', then 'git commit -a'."
        return 0
    fi

    git add .

    if [[ $? -eq 0 ]]; then
        git commit -a
    fi     
}