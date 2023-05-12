basedir=$(pwd)/

echo "" > build.log
for dir in $basedir/*/  # list subdirectories
do
    echo -e "\e[101m\e[01;97m- $dir -\e[0m"
    echo -e "\n\n\e[101m\e[01;97m-------------- $dir ----------------\e[0m" >> build.log
    echo -e "\nBuilding... See build.log for results\e[0m"

    # fix pnpm lock file
    cd $dir
    pnpm i &>> build.log

    img_test_name="get.stopphish.ru:5000/stopphish/${PWD##*/}"
    echo $img_test_name

    # go back and build
    cd $basedir
    #docker build $dir
    docker build -t $img_test_name $dir &>> build.log
done


