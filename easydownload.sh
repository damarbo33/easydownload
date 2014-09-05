#!/bin/sh

pDownDir="/media/WII/Descargas/wget"
pLogFile="easydownloader.dat"

logDownload(){
	echo "$1;$2;$3;$4" >> $pDownDir/$pLogFile
}

# Funcion para poder descargar un fichero directamente
# Parametros:
#	$1 - url a descargar
#	$2 - usuario http para realizar la autenticacion basica
#	$3 - password http para realizar la autenticacion basica
#	$4 - nombre del fichero que se guardara en el disco (opcional)
authDownload(){
	logDownload $1 $2 $3 $4
	if [ "$4" = "" ]; then
		screen wget -c -P $pDownDir --http-user=$2 --http-password=$3 --no-check-certificate $1
	else 
		screen wget -c -P $pDownDir --http-user=$2 --http-password=$3 -O "$pDownDir/$4" --no-check-certificate "$1"
	fi
}
# Funcion para poder descargar un fichero securizado con autenticacion basica
# Parametros:
#	$1 - url a descargar
#	$2 - nombre del fichero que se guardara en el disco (opcional)
directDownload(){
	logDownload $1 "" "" $2
	if [ "$2" = "" ]; then
		screen wget -c -P $pDownDir --no-check-certificate $1
	else
		screen wget -c -P $pDownDir -O "$pDownDir/$2" --no-check-certificate "$1"
	fi
}	

# Funcion que muestra por pantalla el uso de screen
screenHelp(){
	echo "Una vez que empieza la descarga, se inicia screen y lanza wget para"
	echo "empezar la descarga del fichero. En ese momento se puede dejar la"
	echo "descarga en segundo plano pulsando 'CTRL + a' y a continuación pulsar 'd': "
	echo " * SCREEN DETACH: CTRL + a, d"
}

# Muestra el historial de descargas
historyDownload(){
	filename="$pDownDir/$pLogFile"
	
	i=1
	while read -r line
	do
		countword=0
		lineRead=$line
		#echo "fila $i: $lineRead"
		
		url=""
		user=""
		password=""
		downFileName=""
		
		export IFS=";"
		for word in $lineRead; do
		  if [ $countword -eq 0 ]; then
			url=$word
		  elif [ $countword -eq 1 ]; then
			user=$word
		  elif [ $countword -eq 2 ]; then
			password=$word
		  elif [ $countword -eq 3 ]; then
			downFileName=$word
		  fi
		  countword=`expr $countword + 1`
		done
		
		if [ $1 > 0 ] && [ $1 -eq $i ]; then
			if [ "$password" = "" ] && [ "$user" = "" ]; then
				echo "Descargando directamente"
				directDownload $url $downFileName
			else
				echo "Descargando por autenticacion"
				authDownload $url $user $password $downFileName
			fi
		elif [ "$1" = "" ]; then
			echo "*****************************************"
			echo "$i: $url"
		fi
		
		i=`expr $i + 1`
	done < "$filename"

	if [ "$1" = "" ]; then
		echo "*****************************************"
		echo "¿Deseas descargar alguna url? [S/N]"
		read pContinue
		if [ "$pContinue" = "S" ] || [ "$pContinue" = "s" ]; then
			echo "Introduce el numero a descargar. (Para no descargar nada introducir 0)"
			read pContinue
			if [ $pContinue > 0 ]; then
				historyDownload $pContinue
			fi
		fi
	fi
}

# Limpia el historial de descargas
historyClean(){
	echo "" > $pDownDir/$pLogFile
}


# flag para controlar la salida de la ejecucion del script
a=0

while [ $a -eq 0 ]
do
	echo "1. Descarga directa"
	echo "2. Descarga con autenticacion"
	echo "3. Descargas en curso"
	echo "4. Historial de descargas"
	echo "5. Limpiar Historial"
	echo "6. Uso de screen"
	read dType

	if [ $dType -eq "1" ]; then
		echo "Especifica la url: "
		read pUrl
		echo "Especifica el nombre del fichero (Vacío si no desea cambiarlo): "
		read pFilename
		directDownload $pUrl $pFilename
	elif [ $dType -eq "2" ]; then
		echo "Especifica la url: "
		read pUrl
		echo "Especifica el nombre del fichero (Vacío si no desea cambiarlo): "
		read pFilename
		echo "Especifica un usuario: "
		read pUser
		echo "Especifica un password: "
		read pPass 
		authDownload $pUrl $pUser $pPass $pFilename
	elif [ $dType -eq "3" ]; then
		screen -r
	elif [ $dType -eq "4" ]; then
		historyDownload
	elif [ $dType -eq "5" ]; then
		historyClean
	elif [ $dType -eq "6" ]; then
		screenHelp
	fi
	echo "¿Deseas descargar algo más? [S/N]"
	read pContinue
	if [ "$pContinue" = "S" ] || [ "$pContinue" = "s" ]; then
		a=0
	else
		a=1
	fi
done





