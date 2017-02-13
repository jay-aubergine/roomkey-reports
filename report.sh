RRBIN="${GOPATH}/src/rentroll/tmp/rentroll"

if [ ! -d ${RRBIN} ]; then
    echo "Rentroll has not been setup"
    exit 1
fi

ROOMKEYLOAD="${RRBIN}/importers/roomkey/roomkeyload"
CSVLOAD="${RRBIN}/rrloadcsv"
BUD=RKEY

# create new database, drop it if already exists
${RRBIN}/rrnewdb

# load business information first
${CSVLOAD} -b ./business.csv >./business.txt 2>&1

# dirs for different reports
OCCUPANCY_DIR="occupancy"
OCCUPANCY_GUEST_DIR="occupancy_guest"

# generate reports for each dir which has no `report.txt` file
for dir in $(find . -maxdepth 1 -type d -name "[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]"); do

    OCCUPANCY_DIR_PATH="${dir}/${OCCUPANCY_DIR}/"
    OCCUPANCY_GUEST_DIR_PATH="${dir}/${OCCUPANCY_GUEST_DIR}/"

    ROOMKEY_CSV="${dir}/roomkey.csv"
    GUEST_CSV="${dir}/guest.csv"

    # first do for occupancy report only without guest info
    REPORT_PATH="${OCCUPANCY_DIR_PATH}report.txt"
    if [ ! -f ${REPORT_PATH} ]; then
        LOGFILE="${OCCUPANCY_DIR_PATH}log"
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
        echo "\nGenerating roomkey report for ${ROOMKEY_CSV} and ${GUEST_CSV}..." | tee -a ${LOGFILE}
        ${ROOMKEYLOAD} -csv ${ROOMKEY_CSV} -guestinfo ${GUEST_CSV} -bud ${BUD} >${REPORT_PATH} 2>&1
        echo "Report has been generated for ${ROOMKEY_CSV} with guest csv ${GUEST_CSV} at path ${REPORT_PATH}" | tee -a ${LOGFILE}
    fi
done

