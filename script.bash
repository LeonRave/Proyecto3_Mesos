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

