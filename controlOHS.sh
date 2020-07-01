#!/bin/bash

OHS_HOME=/proxy/owt/proxy/12.2.1.4/lab/lab_01


comps=`ls "${OHS_HOME}"/config/fmwconfig/components/OHS/instances/`
nmAddr=`grep 'ListenAddress' "${OHS_HOME}"/nodemanager/nodemanager.properties | cut -d '=' -f2`
nmPort=`grep 'ListenPort' "${OHS_HOME}"/nodemanager/nodemanager.properties | cut -d '=' -f2`

startNM () {

	"$OHS_HOME"/bin/startNodeManager.sh > /dev/null 2>&1 &
	echo "== Starting NodeManager =="

}
	
testport () {
	
	RETVAL=1
	cat 1>&- 2>&- < /dev/null > /dev/tcp/$1/$2
	TESTVAL=$?
	if [ $TESTVAL -eq 0 ]; then
		RETVAL=2;
	fi

	echo "Testing Port code: " $RETVAL 
	
}

startAllComp () {

	testport $nmAddr $nmPort

	while [ $RETVAL -eq 1 ]; do
		startNM
		sleep 3
		testport $nmAddr $nmPort
		if [ $RETVAL -eq 2 ]; then
			break
		fi
	done

	for comp in $comps; do
		"${OHS_HOME}"/bin/startComponent.sh $comp > /dev/null 2>&1 &
		echo "Starting Component: " $comp
	done
}

stopAllComp () {

	for comp in $comps; do
		"${OHS_HOME}"/bin/stopComponent.sh $comp > /dev/null 2>&1 &
		echo "Stopping Component: " $comp
	done
}

restartAllComp () {

	stopAllComp
	startAllComp
}

startComp () {

	testport $nmAddr $nmPort

	while [ $RETVAL -eq 1 ]; do
		startNM
		sleep 3
		testport $nmAddr $nmPort
		if [ $RETVAL -eq 2 ]; then
			break
		fi
	done

	startCustom=`echo $1 | sed 's/,/ /'`
	for i in $startCustom; do
		"${OHS_HOME}"/bin/startComponent.sh $i > /dev/null 2>&1 &
		echo "Starting Component: " $i
	done

}

stopComp () {

        stopCustom=`echo $1 | sed 's/,/ /'`
        for j in $stopCustom; do  
                "${OHS_HOME}"/bin/stopComponent.sh $j > /dev/null 2>&1 &
		echo "Stopping Component: " $j
        done

}

restartComp () {

	stopComp
	startComp
}
 

case "$1" in 
	start-all)
	startAllComp
	;;

	stop-all)
	stopAllComp
	;;

	restart-all)
	restartAllComp
	;;

	start-component)
	startComp $2
	;;

	stop-component)
	stopComp $2
	;;

	restart-component)
	restartComp
	;;
*)

echo $"Common usage		: start|stop|restart-all  "
echo $"If using custom instance: start|stop|restart-component component_name_1,component_name_2"
exit 1
esac
