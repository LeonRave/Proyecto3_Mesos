## Synopsis

En este archivo se detalla la instalacion de mesos, los errores comunes al usar mesos y las pruebas hechas en el cluster de mesos

## Instalacion
	
    # Repositorio 
    sudo rpm -Uvh http://repos.mesosphere.io/el/7/noarch/RPMS/mesosphere-el-repo-7-1.noarch.rpm
    # Instalacion de mesos 
    sudo yum -y install mesos 
    # Instalacion de marathon
    sudo yum -y install marathon
    # Instalacion de zookeeper
    sudo yum -y install mesosphere-zookeeper


## Confieguracion

    # En cada master
    sudo vim /etc/mesos/zk
	zk://ipmaster1:2181,ipmaster2:2181/mesos
    sudo vim /etc/zookeeper/conf/myid
	1   --en servidor1
	2   --en servidor2
    sudo vim /etc/zookeeper/conf/zoo.cfg
	server.1=ipmaster1:2888:3888
	server.2=ipmaster2:2888:3888
    sudo vim /etc/mesos-master/quorum
	1   --la mitad de la cantidad de los servidores
    sudo vim /etc/mesos-master/ip
	ipmaster1 --en servidor1
	ipmaster2 --en servidor2
    sudo vim /etc/mesos-master/hostname
	ipmaster1 --en servidor1
	ipmaster2 --en servidor2

    sudo mkdir -p /etc/marathon/conf
    sudo vim /etc/marathon/conf/master
	ipmaster1 --en servidor1
	ipmaster2 --en servidor2
    sudo vim /etc/marathon/conf/zk
	zk://ipmaster1:2181,ipmaster2:2181/marathon

    # otros
    sudo service mesos-slave stop
    echo manual | sudo tee /etc/init.d/mesos-slave.override

    sudo systemctl restart zookeeper
    sudo service mesos-master start
    sudo service marathon start

    
    # En cada slave
    sudo vim /etc/mesos/zk
	zk://ipmaster1:2181,ipmaster2:2181/mesos
    sudo vim /etc/mesos-slave/ip
	ipesclavo
    sudo vim /etc/mesos-slave/hostname 
	ipesclavo

    # otros
    sudo rm -f /var/lib/mesos/meta/slaves/latest
    sudo systemctl stop zookeeper
    echo manual | sudo tee /etc/init.d/zookeeper.override
    sudo service mesos-master stop
    echo manual | sudo tee /etc/init.d/mesos-master.override
    

    sudo service mesos-slave start
    /usr/sbin/mesos-slave --master=zk://ipmaster:2181/mesos --log_dir=/var/log/mesos --hostname=ipslave --ip=ipslave --work _dir=/var/lib/mesos 


## Errores comunes

    - Cada nodo debe ser configurado como esclavo o master si no se van a usar ambos roles.
    - Si un esclavo inicia marathon tira el marathon del maestro.
    - Si se cae el maestro y no inicia, reinicia zookeeper.

## Pruebas

    Para probar el cluster de marathon se realizaron 1000000 de escrituras en bash, bajo diferentes recursos del cluster y se conto el tiempo de ejecucion.

    Para esto se tiene el siguiente script llamado... script.bash:

        a=1

	inicio=`date +%s`

	while [ $a -le 1000000 ]
	do
		echo $a
		echo "Escribiendo... $a">>archivo.txt
		(( a++ ))

	done

	fin=`date +%s`
	let total=$fin-$inicio

	echo "ha tardado: $total segundos"

    Para ejecutar en mesos se tiene el JSON con diferentes configuraciones:
	app1.json
        app2.json
        app3.json

    Para ejecutar hacer la peticion con el JSOn se uso el comando:

	curl -X POST http://10.110.70.45:8080/v2/apps -d @app1.json -H "Content-type: application/json"
	curl -X POST http://10.110.70.45:8080/v2/apps -d @app2.json -H "Content-type: application/json"
	curl -X POST http://10.110.70.45:8080/v2/apps -d @app3.json -H "Content-type: application/json"

## Resultados

	Test            CPU            Memory            instances            time        

        app1             2               100                 1

        app2             1                50                 1

        app3             1                50                 2

	local            -                 -                 -                 38 s


