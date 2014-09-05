#!/bin/sh

pDownDir="/media/WII/Descargas/wget"

authDownload(){
	if [ "$4" = "" ]; then
		screen wget -P $pDownDir --http-user=$2 --http-password=$3 --no-check-certificate $1
	else 
		screen wget -P $pDownDir --http-user=$2 --http-password=$3 -O "$pDownDir/$4" --no-check-certificate "$1"
	fi
}


directDownload(){
	if [ "$2" = "" ]; then
		screen wget -P $pDownDir --no-check-certificate $1
	else
		screen wget -P $pDownDir -O "$pDownDir/$2" --no-check-certificate "$1"
	fi
}	

a=0

while [ $a -eq 0 ]
do
	echo "Especifica la url: "
	read pUrl
	
	echo "Especifica el nombre del fichero (Vacío si no desea cambiarlo): "
	read pFilename

	echo "1. Descarga directa"
	echo "2. Descarga con autenticacion"
	read dType

	if [ $dType -eq "1" ]; then
		directDownload $pUrl $pFilename
	else
		echo "Especifica un usuario: "
		read pUser
		echo "Especifica un password: "
		read pPass 
		authDownload $pUrl $pUser $pPass $pFilename
	fi
	echo "¿Deseas descargar algo más? [S/N]"
	read pContinue
	if [ "$pContinue" = "S" ] || [ "$pContinue" = "s" ]; then
		a=0
	else
		a=1
	fi
	
	
done





