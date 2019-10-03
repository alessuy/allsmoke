#! /bin/sh

echo "Content-type: text/html;charset=ISO-8859"
echo ""

#smoke_bb="/var/smoke-bb-lib"  
smoke_dcl="/var/smoke-dcl-lib"
smoke_dcp="/var/lib/smokeping"
image_dir="/var/www/all_smoke/img"
web_image_dir="all_smoke/img"
H="40"
W="510"
ARROW_COL="0000FF"
BACK_COL="E6EDF3"
CANVAS_COL="E6EDF3" #"1C2833"
FONT_COL="000000"
BB_COL="AAB7B8"
DCL_COL="000011"
DCP_COL="0000FF" #"213C54"

grafica_rtt(){
# 1 nombre, 2 tiempo , 3 base,
rrdtool graph  $image_dir/$1.png  \
        --imgformat PNG \
        --start now-$2  \
        --end now \
        --title "Latencia $1"  \
        --vertical-label "Segundos" \
        -l 0 \
        --height $H \
        --width $W \
        --color ARROW#$ARROW_COL \
	--color BACK#$BACK_COL \
	--color CANVAS#$CANVAS_COL \
        --color FONT#$FONT_COL \
        -W "www.bse.com.uy" \
	DEF:rtt_dcl=$smoke_dcl/$3:median:AVERAGE \
        LINE2:rtt_dcl#$DCL_COL:"RTT desde-DCL" \
	DEF:rtt_dcp=$smoke_dcp/$3:median:AVERAGE \
        LINE2:rtt_dcp#$DCP_COL:"RTT desde-DCP"  > /dev/null
}


grafica_loss(){
rrdtool graph  $image_dir/$1-loss.png  \
        --imgformat PNG \
        --start now-$2  \
        --end now \
        --title "Perdida de paquetes $1"  \
        --vertical-label "pl %" \
        -l 0 \
        --height $H \
        --width $W \
        --color ARROW#$ARROW_COL \
        --color BACK#$BACK_COL \
        --color CANVAS#$CANVAS_COL \
        --color FONT#$FONT_COL \
        -W "www.bse.com.uy" \
        DEF:pl_dcl=$smoke_dcl/$3:loss:AVERAGE \
 	CDEF:pl_dcl_p100=pl_dcl,5,* \
        LINE2:pl_dcl_p100#$DCL_COL:"Perdidas desde-DCL" \
        DEF:pl_dcp=$smoke_dcp/$3:loss:AVERAGE \
	CDEF:pl_dcp_p100=pl_dcp,5,* \
        LINE2:pl_dcp_p100#$DCP_COL:"Perdidas desde-DCP" > /dev/null
}


for i in  "Edificios" "Sucursales"
	do
	for j in $(ls $smoke_dcp/$i)
	do
		nombre=$(echo $j |  awk -F "." '{print $1}')
		grafica_rtt $nombre $1 $i/$j 
		grafica_loss $nombre $1 $i/$j 

	done

done

echo "<html></body>"
for i in  $(ls $image_dir) 
do

echo "<img src=/$web_image_dir/$i>"

done

echo "</body></html>"
