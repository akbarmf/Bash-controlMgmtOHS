#!/bin/bash

# INSERT ABSOLUTE PATH OF OHS INSTANCE LOCATION
OHS_DIR=/oracle/owt/proxy/12.2.1.4/lab/lab_01
#OHS_DIR=/oracle/wls/domains/12.2.1/ohs_osb_dev

# CONCAT PATH TO CONFIG FILE
INS_DIR="${OHS_DIR}"/config/fmwconfig/components/OHS/instances/

# LIST ALL COMPONENTS
comps=`ls "${INS_DIR}"`

# FUNCTION GET HTTP RESPONSE CODE
getRes () {
    response=`curl --write-out '%{http_code}' -sL --output /dev/null http://$1`

    if  [ $response -eq 200 ]; then
        state=`echo RUNNING`
    elif [ $response -eq 000 ]; then
        state=`echo FAILED`
    else
        state=`echo "Unidentified HTTP Response: " $response`
    fi

}

# LOOPING IN EVERY COMPONENT
for comp in $comps
do

    ip_ohs=`grep -i 'Listen' "${OHS_DIR}"/config/fmwconfig/components/OHS/"${comp}"/httpd.conf | \
            grep -v '#' | \
            awk '{print $2}'`

    ip_ssl=`grep -i 'Listen' "${OHS_DIR}"/config/fmwconfig/components/OHS/"${comp}"/ssl.conf | \
            grep -v '#' | \
            awk '{print $2}'`

    target=`grep -i 'WebLogicCluster' "${OHS_DIR}"/config/fmwconfig/components/OHS/"${comp}"/mod_wl_ohs.c
onf | \
            grep -v '#' | \
            awk '{print $2}' | \
            sed "s/,/ /g"`

    getRes $ip_ohs

    echo "Instance : " $comp
    echo "State    : " $state
    echo "  - Proxy Host    : " $ip_ohs
    echo "  - Proxy SSL     : " $ip_ssl
    echo "  - Target List   :"

    for tar in $target
    do
        getRes $tar
        echo "      - " $tar  $state
    done

    echo

done
