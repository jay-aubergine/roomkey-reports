
OCCUPANCY_DIR="occupancy"
OCCUPANCY_GUEST_DIR="occupancy_guest"

# continue to rentroll . . .
RRBIN="${GOPATH}/src/rentroll/tmp/rentroll"

if [ ! -d ${RRBIN} ]; then
    echo "Rentroll has not been setup"
    exit 1
fi

ROOMKEYLOAD="${RRBIN}/importers/roomkey/roomkeyload"
CSVLOAD="${RRBIN}/rrloadcsv"
BUD=RKEY

${CSVLOAD} -b ./business.csv >./business.txt 2>&1

for f in */; do

    OCCUPANCY_DIR_PATH="./${f}${OCCUPANCY_DIR}/"
    OCCUPANCY_GUEST_DIR_PATH="./${f}${OCCUPANCY_GUEST_DIR}/"

    ROOMKEY_CSV="./${f}roomkey.csv"
    GUEST_CSV="./${f}guest.csv"

    # first do for occupancy report only without guest info
    REPORT_PATH="./${OCCUPANCY_DIR_PATH}report.txt"
    if [ ! -f ${REPORT_PATH} ]; then
        LOGFILE="./${OCCUPANCY_DIR_PATH}log"
        echo -n "Date/Time:    " >>${LOGFILE}
        date >> ${LOGFILE}
        echo "\nGenerating roomkey report for ${ROOMKEY_CSV} ..." | tee -a ${LOGFILE}
        ${ROOMKEYLOAD} -csv ${ROOMKEY_CSV} -bud ${BUD} >${REPORT_PATH} 2>&1
        echo "Report has been generated for ${ROOMKEY_CSV} at path ${REPORT_PATH}" | tee -a ${LOGFILE}
    fi

    # second do for occupancy report with guest csv
    REPORT_PATH="./${OCCUPANCY_GUEST_DIR_PATH}report.txt"
    if [ ! -f ${REPORT_PATH} ]; then
        LOGFILE="./${OCCUPANCY_GUEST_DIR_PATH}log"
        echo -n "Date/Time:    " >>${LOGFILE}
        date >> ${LOGFILE}
        echo "\nGenerating roomkey report for ${ROOMKEY_CSV} ..." | tee -a ${LOGFILE}
        ${ROOMKEYLOAD} -csv ${ROOMKEY_CSV} -guestinfo ${GUEST_CSV} -bud ${BUD} >${REPORT_PATH} 2>&1
        echo "Report has been generated for ${ROOMKEY_CSV} with guest csv ${GUEST_CSV} at path ${REPORT_PATH}" | tee -a ${LOGFILE}
    fi
done

