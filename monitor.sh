#!/bin/bash

# INSERT ABSOLUTE PATH OF OHS INSTANCE LOCATION
OHS_DIR=/proxy/owt/proxy/12.2.1.4/lab/lab_01

# CONCAT PATH TO CONFIG FILE
INS_DIR="${OHS_DIR}"/config/fmwconfig/components/OHS/instances/

# LIST ALL COMPONENTS
comps=`ls "${INS_DIR}"`

# LOOPING IN EVERY COMPONENT
for comp in $comps
do

    ip_ohs=`grep -i 'Listen' "${OHS_DIR}"/config/fmwconfig/components/OHS/"${comp}"/httpd.conf | \
            grep -v '#' | \
            awk '{print $2}'`

    ip_ssl=`grep -i 'Listen' "${OHS_DIR}"/config/fmwconfig/components/OHS/"${comp}"/ssl.conf | \
            grep -v '#' | \
            awk '{print $2}'`

    target=`grep -i 'WebLogicCluster' "${OHS_DIR}"/config/fmwconfig/components/OHS/"${comp}"/mod_wl_
ohs.conf | \
            grep -v '#' | \
            awk '{print $2}' | \
            sed "s/,/ /g"`

    curl -q http://$ip_ohs &> /dev/null

    retVal=$?
    if  [ $retVal -eq 0 ]
        then state=`echo RUNNING`
    else
        state=`echo FAILED`
    fi

    echo "Instance : " $comp
    echo "State    : " $state
    echo "  - Proxy Host    : " $ip_ohs
    echo "  - Proxy SSL     : " $ip_ssl
    echo "  - Target List   :"

    for tar in $target
    do
        curl -q http://$tar &> /dev/null
        retVal=$?

            if  [ $retVal -eq 0 ]
                then stat=`echo OK`
            else
                stat=`echo FAILED`
            fi

        echo "      - " $tar  $stat
    done

    echo

done


