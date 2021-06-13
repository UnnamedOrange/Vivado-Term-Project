# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  set key_0 [ipgui::add_param $IPINST -name "key_0"]
  set_property tooltip {从左到右第一个键。} ${key_0}
  set key_1 [ipgui::add_param $IPINST -name "key_1"]
  set_property tooltip {从左到右第二个键。} ${key_1}
  set key_2 [ipgui::add_param $IPINST -name "key_2"]
  set_property tooltip {从左到右第三个键。} ${key_2}
  set key_3 [ipgui::add_param $IPINST -name "key_3"]
  set_property tooltip {从左到右第四个键。} ${key_3}

}

proc update_PARAM_VALUE.key_0 { PARAM_VALUE.key_0 } {
	# Procedure called to update key_0 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.key_0 { PARAM_VALUE.key_0 } {
	# Procedure called to validate key_0
	return true
}

proc update_PARAM_VALUE.key_1 { PARAM_VALUE.key_1 } {
	# Procedure called to update key_1 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.key_1 { PARAM_VALUE.key_1 } {
	# Procedure called to validate key_1
	return true
}

proc update_PARAM_VALUE.key_2 { PARAM_VALUE.key_2 } {
	# Procedure called to update key_2 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.key_2 { PARAM_VALUE.key_2 } {
	# Procedure called to validate key_2
	return true
}

proc update_PARAM_VALUE.key_3 { PARAM_VALUE.key_3 } {
	# Procedure called to update key_3 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.key_3 { PARAM_VALUE.key_3 } {
	# Procedure called to validate key_3
	return true
}


proc update_MODELPARAM_VALUE.key_0 { MODELPARAM_VALUE.key_0 PARAM_VALUE.key_0 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.key_0}] ${MODELPARAM_VALUE.key_0}
}

proc update_MODELPARAM_VALUE.key_1 { MODELPARAM_VALUE.key_1 PARAM_VALUE.key_1 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.key_1}] ${MODELPARAM_VALUE.key_1}
}

proc update_MODELPARAM_VALUE.key_2 { MODELPARAM_VALUE.key_2 PARAM_VALUE.key_2 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.key_2}] ${MODELPARAM_VALUE.key_2}
}

proc update_MODELPARAM_VALUE.key_3 { MODELPARAM_VALUE.key_3 PARAM_VALUE.key_3 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.key_3}] ${MODELPARAM_VALUE.key_3}
}

