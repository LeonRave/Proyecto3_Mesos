#!/bin/sh


inicio=`date +%s`

a=1

while [ $a -le 1000000 ]
do
        echo $a
        echo "Escribiendo... $a">>archivo.txt
        (( a++ ))

done

fin=`date +%s`
let total=$fin-$inicio

echo "ha tardado: $total segundos"
~                                      
