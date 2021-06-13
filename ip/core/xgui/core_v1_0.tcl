# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  set song_data_width [ipgui::add_param $IPINST -name "song_data_width" -widget comboBox]
  set_property tooltip {“Ù∆µŒªøÌ°£} ${song_data_width}

}

proc update_PARAM_VALUE.audio_period { PARAM_VALUE.audio_period } {
	# Procedure called to update audio_period when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.audio_period { PARAM_VALUE.audio_period } {
	# Procedure called to validate audio_period
	return true
}

proc update_PARAM_VALUE.draw_period { PARAM_VALUE.draw_period } {
	# Procedure called to update draw_period when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.draw_period { PARAM_VALUE.draw_period } {
	# Procedure called to validate draw_period
	return true
}

proc update_PARAM_VALUE.pre_data_width { PARAM_VALUE.pre_data_width } {
	# Procedure called to update pre_data_width when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.pre_data_width { PARAM_VALUE.pre_data_width } {
	# Procedure called to validate pre_data_width
	return true
}

proc update_PARAM_VALUE.song_data_width { PARAM_VALUE.song_data_width } {
	# Procedure called to update song_data_width when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.song_data_width { PARAM_VALUE.song_data_width } {
	# Procedure called to validate song_data_width
	return true
}

proc update_PARAM_VALUE.state_width { PARAM_VALUE.state_width } {
	# Procedure called to update state_width when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.state_width { PARAM_VALUE.state_width } {
	# Procedure called to validate state_width
	return true
}

proc update_PARAM_VALUE.system_clock { PARAM_VALUE.system_clock } {
	# Procedure called to update system_clock when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.system_clock { PARAM_VALUE.system_clock } {
	# Procedure called to validate system_clock
	return true
}

proc update_PARAM_VALUE.update_period { PARAM_VALUE.update_period } {
	# Procedure called to update update_period when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.update_period { PARAM_VALUE.update_period } {
	# Procedure called to validate update_period
	return true
}


proc update_MODELPARAM_VALUE.song_data_width { MODELPARAM_VALUE.song_data_width PARAM_VALUE.song_data_width } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.song_data_width}] ${MODELPARAM_VALUE.song_data_width}
}

proc update_MODELPARAM_VALUE.state_width { MODELPARAM_VALUE.state_width PARAM_VALUE.state_width } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.state_width}] ${MODELPARAM_VALUE.state_width}
}

proc update_MODELPARAM_VALUE.pre_data_width { MODELPARAM_VALUE.pre_data_width PARAM_VALUE.pre_data_width } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.pre_data_width}] ${MODELPARAM_VALUE.pre_data_width}
}

proc update_MODELPARAM_VALUE.system_clock { MODELPARAM_VALUE.system_clock PARAM_VALUE.system_clock } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.system_clock}] ${MODELPARAM_VALUE.system_clock}
}

proc update_MODELPARAM_VALUE.update_period { MODELPARAM_VALUE.update_period PARAM_VALUE.update_period } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.update_period}] ${MODELPARAM_VALUE.update_period}
}

proc update_MODELPARAM_VALUE.audio_period { MODELPARAM_VALUE.audio_period PARAM_VALUE.audio_period } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.audio_period}] ${MODELPARAM_VALUE.audio_period}
}

proc update_MODELPARAM_VALUE.draw_period { MODELPARAM_VALUE.draw_period PARAM_VALUE.draw_period } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.draw_period}] ${MODELPARAM_VALUE.draw_period}
}

