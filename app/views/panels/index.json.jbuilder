json.array!(@panels) do |panel|
  json.extract! panel, :id, :wire_length, :init_fault, :runs, :voltage, :c_value
  json.url panel_url(panel, format: :json)
end
