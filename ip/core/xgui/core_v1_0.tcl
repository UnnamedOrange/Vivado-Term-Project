# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  set song_data_width [ipgui::add_param $IPINST -name "song_data_width" -widget comboBox]
  set_property tooltip {“Ù∆µŒªøÌ°£} ${song_data_width}

}

proc update_PARAM_VALUE.song_data_width { PARAM_VALUE.song_data_width } {
	# Procedure called to update song_data_width when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.song_data_width { PARAM_VALUE.song_data_width } {
	# Procedure called to validate song_data_width
	return true
}


proc update_MODELPARAM_VALUE.song_data_width { MODELPARAM_VALUE.song_data_width PARAM_VALUE.song_data_width } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.song_data_width}] ${MODELPARAM_VALUE.song_data_width}
}

