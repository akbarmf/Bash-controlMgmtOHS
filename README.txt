

1. Change variable value "OHS_HOME" to your OHS instance absolute path in
every scripts.

2. Parameter for "controlOHS.sh" :
	start-all	: start all components OHS
	stop-all	: stop all components OHS
	restart-all	: restart all components OHS
	
3. If you want to start|stop|restart for certain component :
	start-component component_name1,component_name2
	stop-component component_name1,component_name2
	restart-component component_name1,component_name2

4. example:
	./controlOHS.sh start-all
	./controlOHS.sh stop-component ohs_01,ohs_02

5. "monitor.sh" is for check instance OHS state

