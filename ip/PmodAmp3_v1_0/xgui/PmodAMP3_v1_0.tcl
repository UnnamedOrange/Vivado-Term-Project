# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "sample_rate" -parent ${Page_0}


}

proc update_PARAM_VALUE.MCLK_rate { PARAM_VALUE.MCLK_rate } {
	# Procedure called to update MCLK_rate when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MCLK_rate { PARAM_VALUE.MCLK_rate } {
	# Procedure called to validate MCLK_rate
	return true
}

proc update_PARAM_VALUE.sample_rate { PARAM_VALUE.sample_rate } {
	# Procedure called to update sample_rate when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.sample_rate { PARAM_VALUE.sample_rate } {
	# Procedure called to validate sample_rate
	return true
}


proc update_MODELPARAM_VALUE.sample_rate { MODELPARAM_VALUE.sample_rate PARAM_VALUE.sample_rate } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.sample_rate}] ${MODELPARAM_VALUE.sample_rate}
}

proc update_MODELPARAM_VALUE.MCLK_rate { MODELPARAM_VALUE.MCLK_rate PARAM_VALUE.MCLK_rate } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MCLK_rate}] ${MODELPARAM_VALUE.MCLK_rate}
}

