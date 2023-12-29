-- Random Vita Game version 1.0 by jimbob4000

-- More information and credits:
-- https://github.com/jimbob4000/Random-Vita-Game-Launcher


-- Check settings launch parameter

	setings_mode = 0;
	args = System.getBootParams()
	if string.match (args, "settings") then
		setings_mode = 1
	end

-- Basic setup 
	local working_dir = "ux0:/app"
	function System.currentDirectory(dir)
	    if dir == nil then
	        return working_dir
	    else
	        working_dir = dir
	    end
	end

	local cur_dir = "ux0:/data/Random Vita Game"

	local gameready = false

-- Debug mode - prints title ID before launching
	debug_mode = false


-- Create directories
	if not System.doesDirExist("ux0:/data/Random Vita Game") then
		System.createDirectory("ux0:/data/Random Vita Game")
	end

-- Create include and exclude files

	-- Titles to exclude by default
	local exclude_list_default =
	{
	["PSPEMUCFW"] = {include = false, title = "Adrenaline"},
	["ADRBUBMAN"] = {include = false, title = "Adrenaline Bubbles Manager"},
	["ADRLANCHR"] = {include = false, title = "Adrenaline Launcher"},
	["HXLC00001"] = {include = false, title = "HexFlow Custom"},
	["HXFL00001"] = {include = false, title = "HEXFlow Launcher"},
	["SMLA00001"] = {include = false, title = "Launcher"},
	["RETROVITA"] = {include = false, title = "RetroArch"},
	["RETROLNCR"] = {include = false, title = "RetroFlow Adrenaline Launcher"},
	["RETROFLOW"] = {include = false, title = "RetroFlow Launcher"},
	["SVEW00001"] = {include = false, title = "SwitchView"},
	}

	-- Create exclusion file
	if not System.doesFileExist(cur_dir .. "/app_list.lua") then
        
        local file_over = System.openFile(cur_dir .. "/app_list.lua", FCREATE)
	    System.closeFile(file_over)

	    file = io.open(cur_dir .. "/app_list.lua", "w")
	    file:write('return {' .. "\n")
	    for k, v in pairs(exclude_list_default) do
	    	file:write('["' .. k .. '"] = {include = ' .. tostring(v.include) .. ', title = "' .. v.title .. '"},' .. "\n")
	    end
	    file:write('}')
	    file:close()
        
    end

-- Init some colors
	local white = Color.new(255, 255, 255)
	local black = Color.new(0, 0, 0)
	local purple = Color.new(60, 12, 112)
	local dark_purple = Color.new(20, 4, 35)
	local white_opaque = Color.new(255, 255, 255, 100)
	themeCol = purple

-- Controls
	local oldpad = SCE_CTRL_CROSS
	local delayButton = 8.0

-- List a directory
    local scripts = System.listDirectory("ux0:/")
    local cur_dir_fm = "ux0:/"

-- Init a index
    local i = 1

-- Menu
	local menuY = 0

-- SFO extraction setup
    local info = System.extractSfo("app0:/sce_sys/param.sfo")
	local app_title = info.short_title
	local app_titleid = info.titleid

-- Load images
	local btnX = Graphics.loadImage("app0:/DATA/x.png")
    local btnO = Graphics.loadImage("app0:/DATA/o.png")

    icon_square = Graphics.loadImage("app0:/DATA/square.png")
	icon_square_check = Graphics.loadImage("app0:/DATA/square-check.png")

-- Menu Layout
    btnMargin = 32
	setting_x = 20
	setting_x_icon = 16
    setting_x_icon_offset = setting_x + 35
    setting_yh = 20
    setting_y0 = setting_yh + 49

-- Functions

	if setings_mode == 1 then

		-- Load fonts
		    fontname = "font-SawarabiGothic-Regular.woff"
			fnt20 = Font.load("app0:/DATA/" .. fontname)
			fnt22 = Font.load("app0:/DATA/" .. fontname)

			Font.setPixelSizes(fnt20, 20)
			Font.setPixelSizes(fnt22, 22)

		-- Get app list game
		function listDirectory(dir)
		    dir = System.listDirectory(dir)
		    app_table = {}
		    files_table = {}
			
			-- Get games to exclude
			app_list_imported = {}
		    if System.doesFileExist(cur_dir .. "/app_list.lua") then
		        app_list_imported = dofile(cur_dir .. "/app_list.lua")
		    end

		    for i, file in pairs(dir) do

		    	-- Only use folders with 9 characters and not this app
		        if file.directory and string.len(file.name) == 9 and not string.match(file.name, "RANDOMPSV") then

		        	-- Vita titles
		        	if string.match(file.name, "PCS") and not string.match(file.name, "PCSI") then
			        	include_flag = true
			        else
			        	include_flag = false
			        end

			        -- Get overrides
			        if app_list_imported[file.name] ~= nil then
			        	include_flag = app_list_imported[file.name].include
			        	app_title = app_list_imported[file.name].title:gsub("\n","")
			        else
			        	-- get app name to match with custom cover file name
			            if System.doesFileExist(working_dir .. "/" .. file.name .. "/sce_sys/param.sfo") then
			                info = System.extractSfo(working_dir .. "/" .. file.name .. "/sce_sys/param.sfo")
			                app_title = info.title:gsub("\n","")
			            end
			        end

		            file.name = file.name
		            file.apptitle = app_title

		            if include_flag == true then
		            	file.include = true
		                table.insert(app_table, file)
			        else
		            	file.include = false
			    		table.insert(app_table, file)
		            end

				    -- Sort by App name
			        table.sort(app_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)

		        end
		    end
		end

		files_table = listDirectory(System.currentDirectory())


	else

		-- Get random game
		function listDirectory(dir)
		    dir = System.listDirectory(dir)
		    games_table = {}
		    files_table = {}
			
		    -- Get games to exclude
			app_list_imported = {}
		    if System.doesFileExist(cur_dir .. "/app_list.lua") then
		        app_list_imported = dofile(cur_dir .. "/app_list.lua")
		    end


		    for i, file in pairs(dir) do

		    	-- Only use folders with 9 characters and not this app
		        if file.directory and string.len(file.name) == 9 and not string.match(file.name, "RANDOMPSV") then

		        	-- Vita titles
		        	if string.match(file.name, "PCS") and not string.match(file.name, "PCSI") then
			        	include_flag = true
			        else
			        	include_flag = false
			        end

			        -- Get overrides
			        if app_list_imported[file.name] ~= nil then
			        	include_flag = app_list_imported[file.name].include
			        end

		        	-- Include Vita titles if not in exclusion list
		            if include_flag == true then
						file.include = true
		                table.insert(games_table, file)
		            else
				    end

		        end
		    end
		end

		files_table = listDirectory(System.currentDirectory())

	    function Shuffle(games_table)
		    math.randomseed( os.time() )
		    games_shuffled = {}
		    for i = 1, #games_table do games_shuffled[i] = games_table[i] end
		    for i = #games_table, 2, -1 do
		        local j = math.random(i)
		        games_shuffled[i], games_shuffled[j] = games_shuffled[j], games_shuffled[i]
		    end
		    return games_shuffled
		end

		Shuffle(games_table)
		random_game = games_shuffled[1].name
		gameready = true
	end

	
-- Main loop
while true do
	
	if setings_mode == 1 then

		-- Game List Browser

			Graphics.initBlend()
			Screen.clear()

			if delayButton > 0 then
		        delayButton = delayButton - 0.1
		    else
		        delayButton = 0
		    end
			
			label1 = Font.getTextWidth(fnt20, "Save and close")
	        label2 = Font.getTextWidth(fnt20, "Select")

	        Graphics.fillRect(0, 960, 0, 496, dark_purple)--dark background

	        Font.print(fnt22, setting_x, setting_yh, "Select which games to include:", white)
	        Graphics.fillRect(0, 960, setting_yh + 36, setting_yh + 40, white)

	        Graphics.fillRect(0, 960, 82 - 21 + (menuY * 47), 129 - 21 + (menuY * 47), themeCol)-- selection

			-- Reset y axis for menu blending
			local y = setting_y0

			-- Write visible menu entries
			for j, file in pairs(app_table) do
				exclude_match = app_list_imported[file.name]
				x = 20
				if j >= i and y < 450 then

					if file.include == true then
						color = white
						Font.print(fnt22, setting_x_icon_offset, y, file.apptitle, color)
                        Graphics.drawImage(setting_x_icon, y, icon_square_check, color)
					else
						color = white_opaque
						Font.print(fnt22, setting_x_icon_offset, y, file.apptitle, color)
                        Graphics.drawImage(setting_x_icon, y, icon_square, color)
					end

					y = y + 47
				end
			end

			-- Draw footer ontop of dynamic list
	        Graphics.fillRect(0, 960, 496, 544, themeCol)-- footer bottom

	        Graphics.drawImage(900-label1, 510, btnO)
	        Font.print(fnt20, 900+28-label1, 508, "Save and close", white)

	        Graphics.drawImage(900-(btnMargin * 2)-label1-label2, 510, btnX)
	        Font.print(fnt20, 900+28-(btnMargin * 2)-label1-label2, 508, "Select", white)--Select

	        menuItems = 0

			Graphics.termBlend()
			
			-- Check for input
			pad = Controls.read()
			mx, my = Controls.readLeftAnalog()

			if Controls.check(pad, SCE_CTRL_CROSS) and not Controls.check(oldpad, SCE_CTRL_CROSS) then

				if app_table[i].include == true then
					app_table[i].include = false
				else
					app_table[i].include = true
				end

			elseif Controls.check(pad, SCE_CTRL_CIRCLE) and not Controls.check(oldpad, SCE_CTRL_CIRCLE) then
				
				-- Print exclusion list
					local file_over = System.openFile(cur_dir .. "/app_list.lua", FCREATE)
				    System.closeFile(file_over)

				    file = io.open(cur_dir .. "/app_list.lua", "w")
				    file:write('return {' .. "\n")
				    for k, v in pairs(app_table) do

				    	if v.include == true then
				    		file:write('["' .. v.name .. '"] = {include = ' .. tostring(v.include) .. ' , title = "' .. v.apptitle .. '"},' .. "\n")
				    	else	
					    	file:write('["' .. v.name .. '"] = {include = ' .. tostring(v.include) .. ', title = "' .. v.apptitle .. '"},' .. "\n")
					    end
				    end
				    file:write('}')
				    file:close()

			    System.exit()


			elseif Controls.check(pad, SCE_CTRL_UP) and not Controls.check(oldpad, SCE_CTRL_UP) then
				i = i - 1
			elseif Controls.check(pad, SCE_CTRL_DOWN) and not Controls.check(oldpad, SCE_CTRL_DOWN) then
				i = i + 1
			else
			end
			
			-- Controls for left stick
			if my < 64 then
	            if delayButton < 0.5 then
	                delayButton = 1
	                i = i - 1
	            end
	        elseif my > 180 then
	            if delayButton < 0.5 then
	                delayButton = 1
	                i = i + 1
	            end
	        end

			-- Check for out of bounds in menu
			if i > #app_table then
				i = 1
			elseif i < 1 then
				i = #app_table
			end
			
			-- Update oldpad and flip screen
			oldpad = pad
			Screen.flip()

	else
		-- Launch random game
		if gameready == true then

			Graphics.initBlend()
			Screen.clear()

			if debug_mode == true then
				Graphics.debugPrint(5, 5, games_shuffled[1].name, white)
			else
				Graphics.debugPrint(5, 5, games_shuffled[1].name, black)
			end
			Graphics.termBlend()
			
			-- Update screen (For double buffering)
			Screen.flip()

			-- Wait and launch (waiting seems more reliable)
			System.wait(50000)
			System.launchApp(tostring(games_shuffled[1].name))
			System.exit()

			-- -- Refreshing screen
		    -- Screen.waitVblankStart()
		    -- Screen.flip()
		end
	end

end