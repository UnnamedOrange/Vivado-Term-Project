
# Loading additional proc with user specified bodies to compute parameter values.
source [file join [file dirname [file dirname [info script]]] gui/PmodAMP3_v1_0.gtcl]

# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  set sample_rate [ipgui::add_param $IPINST -name "sample_rate" -widget comboBox]
  set_property tooltip {采样率，单位为赫兹。} ${sample_rate}
  set resolution [ipgui::add_param $IPINST -name "resolution" -widget comboBox]
  set_property tooltip {采样分辨率，单位为比特。} ${resolution}
  set is_stereo [ipgui::add_param $IPINST -name "is_stereo"]
  set_property tooltip {是否使用双声道，如果使用，输入的采样数据位宽翻倍，高位是右声道。} ${is_stereo}
  set MCLK_ratio [ipgui::add_param $IPINST -name "MCLK_ratio" -widget comboBox]
  set_property tooltip {外部时钟倍率。外部时钟的频率为采样率乘以倍率。} ${MCLK_ratio}
  set MCLK_freq [ipgui::add_param $IPINST -name "MCLK_freq"]
  set_property tooltip {外部时钟频率。} ${MCLK_freq}

}

proc update_PARAM_VALUE.MCLK_freq { PARAM_VALUE.MCLK_freq PARAM_VALUE.sample_rate PARAM_VALUE.MCLK_ratio } {
	# Procedure called to update MCLK_freq when any of the dependent parameters in the arguments change
	
	set MCLK_freq ${PARAM_VALUE.MCLK_freq}
	set sample_rate ${PARAM_VALUE.sample_rate}
	set MCLK_ratio ${PARAM_VALUE.MCLK_ratio}
	set values(sample_rate) [get_property value $sample_rate]
	set values(MCLK_ratio) [get_property value $MCLK_ratio]
	set_property value [gen_USERPARAMETER_MCLK_freq_VALUE $values(sample_rate) $values(MCLK_ratio)] $MCLK_freq
}

proc validate_PARAM_VALUE.MCLK_freq { PARAM_VALUE.MCLK_freq } {
	# Procedure called to validate MCLK_freq
	return true
}

proc update_PARAM_VALUE.MCLK_ratio { PARAM_VALUE.MCLK_ratio } {
	# Procedure called to update MCLK_ratio when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MCLK_ratio { PARAM_VALUE.MCLK_ratio } {
	# Procedure called to validate MCLK_ratio
	return true
}

proc update_PARAM_VALUE.is_stereo { PARAM_VALUE.is_stereo } {
	# Procedure called to update is_stereo when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.is_stereo { PARAM_VALUE.is_stereo } {
	# Procedure called to validate is_stereo
	return true
}

proc update_PARAM_VALUE.resolution { PARAM_VALUE.resolution } {
	# Procedure called to update resolution when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.resolution { PARAM_VALUE.resolution } {
	# Procedure called to validate resolution
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

proc update_MODELPARAM_VALUE.resolution { MODELPARAM_VALUE.resolution PARAM_VALUE.resolution } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.resolution}] ${MODELPARAM_VALUE.resolution}
}

proc update_MODELPARAM_VALUE.is_stereo { MODELPARAM_VALUE.is_stereo PARAM_VALUE.is_stereo } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.is_stereo}] ${MODELPARAM_VALUE.is_stereo}
}

proc update_MODELPARAM_VALUE.MCLK_ratio { MODELPARAM_VALUE.MCLK_ratio PARAM_VALUE.MCLK_ratio } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MCLK_ratio}] ${MODELPARAM_VALUE.MCLK_ratio}
}

proc update_MODELPARAM_VALUE.MCLK_freq { MODELPARAM_VALUE.MCLK_freq PARAM_VALUE.MCLK_freq } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MCLK_freq}] ${MODELPARAM_VALUE.MCLK_freq}
}

