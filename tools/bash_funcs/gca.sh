gca(){
    git add .

    if [[ $? -eq 0 ]]; then
        git commit -a
    fi     
}