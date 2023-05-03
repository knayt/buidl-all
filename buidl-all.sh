basedir=$(pwd)/

echo "" > build.log
for dir in $basedir/*/  # list subdirectories
do
    echo -e "\e[101m\e[01;97m- $dir -\e[0m"
    echo -e "\n\n\e[101m\e[01;97m-------------- $dir ----------------\e[0m" >> build.log
    #docker build $dir &>> build.log
    docker build $dir
done


