class Panel < ActiveRecord::Base
	after_save do |panel|
		panel.f_value = (1.73 * panel.wire_length * panel.init_fault)/
	    (panel.runs * panel.c_value * panel.voltage)
	    panel.m_value = 1/(1+panel.f_value)
	    panel.final_value = panel.init_fault * panel.m_value
	end
		after_update do |panel|
		panel.f_value = (1.73 * panel.wire_length * panel.init_fault)/
	    (panel.runs * panel.c_value * panel.voltage)
	    panel.m_value = 1/(1+panel.f_value)
	    panel.final_value = panel.init_fault * panel.m_value
	end
end
