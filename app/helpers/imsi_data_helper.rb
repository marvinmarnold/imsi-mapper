module ImsiDataHelper
	def human_threat_level(lvl_i)
		{
			"-1" => "Unknown",
			"0" => "Idle",
			"5" => "Normal",
			"10" => "Medium",
			"15" => "Alarm"
		}[lvl_i.to_s]
	end
end
