TODAY_DATE := $(shell date +%Y-%m-%d)

OCCUPANCY_DIR = occupancy
OCCUPANCY_GUEST_DIR = occupancy_guest

report:
	./report.sh

setreportdir:
	@mkdir ${TODAY_DATE}
	@mkdir ${TODAY_DATE}/${OCCUPANCY_DIR}
	@mkdir ${TODAY_DATE}/${OCCUPANCY_GUEST_DIR}

clean:
	rm -f roomkey.log business.txt
