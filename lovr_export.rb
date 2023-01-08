require 'sketchup.rb'

module LovrExport

	def self.export_all
		model = Sketchup.active_model
		components = model.entities.grep(Sketchup::ComponentInstance)
		filename_base = UI.savepanel("Save As", "", "export_data")
		model_layers = model.layers
		allow_overwrite = true
		layers = []
		
		# Define the layers (tags) we want to export information from
		model_layers.each do |layer|
			if layer.name == "col" or layer.name == "coins" or layer.name == "gems" or layer.name == "start" or layer.name == "portal" or layer.name == "key"
				layers.append(layer)
			end
		end

		# Check if first file exists
		if File.exist? (filename_base + "_col.txt")
			if UI.messagebox("File(s) exist. Overwrite?", MB_OKCANCEL) == IDCANCEL
				allow_overwrite = false
			end
		end

		if filename_base == nil or not allow_overwrite
			puts "cancelled"
		else
			if allow_overwrite
				layers.each do |layer|
					filename = filename_base + "_" + layer.name + ".txt"
					File.write(filename, "")

					components_in_layer = components.find_all do |comp|
						comp.layer.name == layer.name
					end
					
					components_in_layer.each do |comp|
						if layer.name == "col" # This is a layer that contains box-volumes. If you have other such layers, modify the condition to include those too.
							puts "#{comp.transformation.to_a}"

							# Convert to LOVR coordinate system
							tr = Geom::Transformation.axes(ORIGIN, Geom::Vector3d.new(1,0,0), Geom::Vector3d.new(0,0,-1), Geom::Vector3d.new(0,1,0)) * comp.transformation
							m = tr.to_a
							str = "#{m[0]}" + "," + "#{m[1]}" + "," + "#{m[2]}" + "," + "#{m[3]}" + "," + "#{m[4]}" + "," + "#{m[5]}" + "," + "#{m[6]}" \
								+ "," + "#{m[7]}" + "," + "#{m[8]}" + "," + "#{m[9]}" + "," + "#{m[10]}" + "," + "#{m[11]}" + "," + "#{m[12] / 39.37}" \
								+ "," + "#{m[13] / 39.37}"	+ "," + "#{m[14] / 39.37}" + "," + "#{m[15]}"
							File.write(filename, str, mode: "a")
							File.write(filename, "\n", mode: "a")
						else # And these are layers that contain only positional information
							matrix = comp.transformation.to_a
							File.write(filename, "#{matrix[12] / 39.37}" + "," + "#{matrix[14] / 39.37}" + "," + "#{-matrix[13] / 39.37}", mode: "a") # swap yz
							File.write(filename, "\n", mode: "a")
						end
					end
				end
			end
		end
	end

	unless file_loaded?(__FILE__)
	  menu = UI.menu('Plugins')
	  menu.add_item('LOVR export...') do self.export_all end
	  file_loaded(__FILE__)
	end
end