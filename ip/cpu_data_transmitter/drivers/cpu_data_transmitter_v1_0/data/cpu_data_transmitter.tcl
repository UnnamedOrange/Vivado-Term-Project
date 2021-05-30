

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "cpu_data_transmitter" "NUM_INSTANCES" "DEVICE_ID"  "C_S00_AXI_BASEADDR" "C_S00_AXI_HIGHADDR"
}
