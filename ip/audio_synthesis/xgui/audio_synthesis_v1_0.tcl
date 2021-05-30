# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  set resolution_input [ipgui::add_param $IPINST -name "resolution_input" -widget comboBox]
  set_property tooltip {输入音频的分辨率。} ${resolution_input}
  set resolution_output [ipgui::add_param $IPINST -name "resolution_output" -widget comboBox]
  set_property tooltip {输出音频的分辨率。不应小于输入音频的。} ${resolution_output}

}

proc update_PARAM_VALUE.resolution_input { PARAM_VALUE.resolution_input } {
	# Procedure called to update resolution_input when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.resolution_input { PARAM_VALUE.resolution_input } {
	# Procedure called to validate resolution_input
	return true
}

proc update_PARAM_VALUE.resolution_output { PARAM_VALUE.resolution_output } {
	# Procedure called to update resolution_output when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.resolution_output { PARAM_VALUE.resolution_output } {
	# Procedure called to validate resolution_output
	return true
}


proc update_MODELPARAM_VALUE.resolution_input { MODELPARAM_VALUE.resolution_input PARAM_VALUE.resolution_input } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.resolution_input}] ${MODELPARAM_VALUE.resolution_input}
}

proc update_MODELPARAM_VALUE.resolution_output { MODELPARAM_VALUE.resolution_output PARAM_VALUE.resolution_output } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.resolution_output}] ${MODELPARAM_VALUE.resolution_output}
}

