 #!/bin/bash

read -p "Enter Full path of domains list: " domlist
[ -z $domlist ] || [ ! -f $domlist ] && { echo "***File Not Found, enter a valid path***"; exit 1; }
c=$( cat $domlist |  wc -l )
printf "There are %d domains present in %s \n" $c $domlist

read -p "Enter number of crons to be run per minute: " n
[ -z $n ] && { echo "***Number not supplied, try again***"; exit 1; }

echo "----------------------------"
printf "1. Run all the crons Every Hours\n"
printf "2. Run all the crons for evry two Hours\n"
read -p "Enter your selection: " s
[ -z $s ] && { echo "***Number not selected, try again***"; exit 1; }

tmpfile=/tmp/cronjobs.txt
rm -f  $tmpfile
m=0
j=0
even=0,2,4,6,8,10,12,14,16,18,20,22
odd=1,3,5,7,9,11,13,15,17,19,21,23

cron()
{
        printf   "%02d $hour * * * /usr/bin/wget -q -O - http://$i/wp-cron.php?doing_wp_cron > /dev/null 2>&1\n"  $m  >> $tmpfile
        j=$(( j+1 ))

        if [ $j -eq $n ]
        then
        j=0
        m=$(( m+1 ))
        fi
}


case $s in
        1)
for i  in  `cat $domlist`;
do
        hour=*
        cron
        if [ $m -gt 59 ]
        then
        m=0
        fi
done
        ;;

        2) hour=$even
for i  in  `cat $domlist`;
do
        cron
        if [ $m -gt 59 ]
        then
        m=0
        unset hour
        hour=$odd
        fi
done
        ;;

        *) echo "Invalid selection, please try again" ; exit 1;
esac


echo "***************************************************************"
echo "Cron Generation completed! Please find the output in $tmpfile"
echo "***************************************************************"

exit 0
