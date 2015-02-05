DTC=/ssdstore/ali/zynq-scratch/linux-xlnx/scripts/dtc/dtc

zynq-zc702.dtb: zynq-zc702.dts pl.dtsi zynq-7000.dtsi
	${DTC} -I dts -O dtb -o zynq-zc702.dtb zynq-zc702.dts
	${DTC} -I dtb -O dts -o gen.dts zynq-zc702.dtb

