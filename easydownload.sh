#!/bin/bash

pDownDir="/media/WII/Descargas/wget"
pLogFile="easydownloader.dat"
fileDescargar=""

resumirConsolas(){
	clear
	texto="$1"
	b=".pts-"
	numSesiones=0
	
	pos=`expr index "$texto" $b`
	while [ $pos -gt 0 ]
	do	
		texto=${texto%$b*}
		len=`expr ${#first} - 4`
		echo ${texto:len:4}
		pos=`expr index "$texto" $b`
		numSesiones=`expr $numSesiones + 1`
	done

	if [ $numSesiones -gt 1 ]; then
		echo "Introduce el numero de consola de screen que deseas recuperar"
		read consoleNum
		sudo screen -r $consoleNum
	else 
		echo "No hay descargas en segundo plano"
		read consoleNum
	fi

}


buscarEnString(){
	fileDescargar=""
	url=$1
	fileDescargar="${url##*/}"
	indexParms=`expr index "$fileDescargar" \?`
	if [ $indexParms -gt 0 ]; then
		indexParms=`expr $indexParms - 1`
		fileDescargar=`expr substr $fileDescargar 1 $indexParms`
	fi
}

# Funcion para arrancar o parar xbmc
xbmcUtils(){
	clear
	echo "1. Stop XBMC"
	echo "2. Start XBMC"
	read pXbox
	
	if [ $pXbox -eq "1" ]; then
		sudo initctl stop xbmc
	elif [ $pXbox -eq "2" ]; then
		sudo initctl start xbmc
	fi
}

# Funcion para realizar un test de velocidad de descarga
netTest(){
	rm -fR Firefox*
	wget --no-check-certificate https://ftp.mozilla.org/pub/mozilla.org/firefox/releases/22.0/win32/en-US/Firefox%20Setup%2022.0.exe
}

# Funcion para reiniciar el pc
restartPC(){
	clear
	echo "¿Confirmas que deseas reiniciar? [S/N]"
	read pContinue
	if [ "$pContinue" = "S" ] || [ "$pContinue" = "s" ]; then
		sudo shutdown -r now
	fi
}

# Funcion para guardar un log con los ficheros descargados.
# Tambien se guarda información de contrasenya y usuario
# Parametros:
#	$1 - url a descargar
#	$2 - usuario http para realizar la autenticacion basica
#	$3 - password http para realizar la autenticacion basica
#	$4 - nombre del fichero que se guardara en el disco (opcional)
logDownload(){
	clear
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
		sudo screen wget -c -P $pDownDir --http-user=$2 --http-password=$3 --no-check-certificate "$1"
	else 
		sudo screen wget -c -P $pDownDir --http-user=$2 --http-password=$3 -O "$pDownDir/$4" --no-check-certificate "$1"
	fi
}
# Funcion para poder descargar un fichero securizado con autenticacion basica
# Parametros:
#	$1 - url a descargar
#	$2 - nombre del fichero que se guardara en el disco (opcional)
directDownload(){
	logDownload $1 "" "" $2
	if [ "$2" = "" ]; then
		sudo screen wget -c -P $pDownDir --no-check-certificate "$1"
	else
		sudo screen wget -c -P $pDownDir -O "$pDownDir/$2" --no-check-certificate "$1"
	fi
}	

# Funcion que muestra por pantalla el uso de screen
screenHelp(){
	clear
	echo "Una vez que empieza la descarga, se inicia screen y lanza wget para"
	echo "empezar la descarga del fichero. En ese momento se puede dejar la"
	echo "descarga en segundo plano pulsando 'CTRL + a' y a continuación pulsar 'd': "
	echo " * SCREEN DETACH: CTRL + a, d"
}

# Muestra el historial de descargas
historyDownload(){
	filename="$pDownDir/$pLogFile"
	# Especificamos el separador de parametros dentro de cada linea
	export IFS=";"
	
	i=1
	while read -r line
	do
		countword=0
		#Leemos la linea del fichero y la almacenamos en lineRead
		lineRead=$line
		
		#Reseteamos las variables
		url=""
		user=""
		password=""
		downFileName=""
			
		# Recorremos la linea para obtener todos los parametros segun el string
		# especificado en la variable IFS
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
		
		# Si el parametro coincide con la linea "i" que estamos leyendo y si es mayor que 0
		# procedemos a realizar la descarga. 
		if [ $1 > 0 ] && [ $1 -eq $i ]; then
			if [ "$password" != "" ] && [ "$user" != "" ]; then
				echo "Descargando por autenticacion"
				authDownload $url $user $password $downFileName
			else
				echo "Descargando directamente"
				directDownload $url $downFileName
			fi
		elif [ "$1" = "" ]; then
			# Si no se ha pasado ningun parametro, sacamos por pantalla la url que se descargo
			# anteriormente, para que el usuario pueda seleccionarla al salir del bucle
			echo "*****************************************"
			echo "$i: $url"
		fi
		
		# Aumentamos el contador de las lineas
		i=`expr $i + 1`
	done < "$filename"
	
	# Despues de pintar todas las urls, damos al usuario la opcion de descargarlas nuevamente
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
	clear
	echo "" > $pDownDir/$pLogFile
}


# flag para controlar la salida de la ejecucion del script
a=0

while [ $a -eq 0 ]
do
	clear
	echo "1. Descarga directa"
	echo "2. Descarga con autenticacion"
	echo "3. Descargas en curso"
	echo "4. Historial de descargas"
	echo "5. Limpiar Historial"
	echo "6. Uso de screen"
	echo "7. XBMC"
	echo "8. Test de velocidad de red"
	echo "9. Reiniciar"
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
		#Buscamos el nombre del fichero en la url y lo almacenamos en la variable 
		#global fileDescargar
		buscarEnString $pUrl
		echo "Especifica el nombre del fichero ($fileDescargar): "
		read pFilename
		if [ "$pFilename" = "" ]; then
			pFilename="$fileDescargar"
		fi
		echo "Especifica un usuario: "
		read pUser
		echo "Especifica un password: "
		read pPass 
		authDownload $pUrl $pUser $pPass $pFilename
	elif [ $dType -eq "3" ]; then
		pConsoles=`sudo screen -r | grep .pts`
		resumirConsolas "$pConsoles"
		
	elif [ $dType -eq "4" ]; then
		historyDownload
	elif [ $dType -eq "5" ]; then
		historyClean
	elif [ $dType -eq "6" ]; then
		screenHelp
	elif [ $dType -eq "7" ]; then
		xbmcUtils
	elif [ $dType -eq "8" ]; then
		netTest
	elif [ $dType -eq "9" ]; then
		restartPC
	fi
	clear
	echo "¿Deseas descargar algo más? [S/N]"
	read pContinue
	if [ "$pContinue" = "S" ] || [ "$pContinue" = "s" ]; then
		a=0
	else
		a=1
	fi
done





