#!/usr/bin/env bash
# If you created a git submodule or your Laravel web app source folder contains a recently 
# cloned repo, this helper will install dependencies for Laravel packages based on composer.json file.
# This script also will copy .env.example to .env from the Laravel source folder and generate a key app config to the env file.

currentDir=${PWD##*/}
rightWorkingDir=0

if [ "$currentDir" != "scripts" ] && [ -d ".devcontainer" ]; then
    rightWorkingDir=1
fi

if [ $rightWorkingDir -eq 0 ] && [ "$currentDir" == "scripts" ]; then
    echo "Changing working directory..."
    cd ../../
fi

if [ $rightWorkingDir -eq 0 ] && [ "$currentDir" != "scripts" ]; then
    echo "Error, the script will not be executed: You are not in the correct directory to run this script."
    exit
fi

source .devcontainer/.env

FOLDER_NAME=${PROJECT_NAME}_webapp
WEBAPP_PATH=${PWD}/${FOLDER_NAME}

function installDependencies() {
    cp $WEBAPP_PATH/.env.example $WEBAPP_PATH/.env
    docker run --rm -v $WEBAPP_PATH:/app composer /bin/sh -c "composer install  && php artisan key:generate"
    sudo chown -R $USER:$USER $WEBAPP_PATH/vendor
}

if [ -d "$WEBAPP_PATH" ];
then
    installDependencies
else
	echo -e "\n❌ Advertencia: No existe un directorio llamado $FOLDER_NAME.\n No se instalarán las dependencias de Composer.\n"
fi