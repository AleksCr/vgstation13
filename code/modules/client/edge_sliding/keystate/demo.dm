world
	version = 2
	maxx = 13; maxy = 13; maxz = 1
	New()	//create the spring and ball then the line of ground turfs
		new /obj/spring (locate(4,1,1))
		new /obj/ball (locate(4,2,1))
		for(var/index = 1 to world.maxx)
			new /turf/floor (locate(index,3,1))

client
	Move()
		//If this gets called, the focus must be off, so refocus it.
		KeyFocus()
	var
		//these are for the walking and jumping
		left = 0
		right = 0
		up = 0
	New()
		//setting up...
		. = ..()
		var/mob/M = .
		M.loc = locate(5,4,1)
		M.dir = EAST
		spawn() M.stop()
		InfoSetup()  //grabs the client's info (resolution, system_type, etc.)
		spawn(4)
			KeySetup()	//focus it after they enter
			if(!resolution)	//if resolution is false, InfoSetup failed to get the data
				world.log << "Failed to detect [key]'s system information."
				return .
			var
				//calculate a view size based on resolution
				x = copytext(resolution, 1, findtext(resolution, ","))
				y = copytext(resolution, findtext(resolution, ",")+1, 0)
			x = round(text2num(x) / 50)
			y = round(text2num(y) / 50)
			view = "[x]x[y]"
			src << "Your resolution is [resolution]: setting view to [x]x[y]."
			src << "However, only [avail_resolution] is available."
			src << "Your color quality is at [color_quality]bit."
			src << "Your operating system is [system_type]."
			src << {"
Hold space bar to pull back the plunger, then let go to release.
Use the arrow keys to move and jump.
Hold Ctrl while pressing Q to exit."}

	KeyDown(KeyCode, shift)	//On to the interesting stuff! This gets triggered whenever a key is pressed
		//The stuff in here that all begins with KS_ are constants used in place of numbers\
			and they tell it what keys you want. Look into 1constants.dm or the bottom of the documentation file
		//If the player pressed ctrl+Q, logout
		if(KeyCode == KS_Q && shift&KS_SHIFT_CTRL) mob.Logout()
		else if(KeyCode == KS_SPACE)
			var/obj/spring/O = locate()
			O.tension()
		else switch(KeyCode)
			//Check to see if they pushed one of these directions, and if so move
			if(KS_UP)
				up = 1
				spawn() mob.go(1)
			if(KS_RIGHT)
				if(left) return
				right = 1
				spawn() mob.go(2)
			if(KS_LEFT)
				if(right) return
				left = 1
				spawn() mob.go(3)
	KeyUp(KeyCode)	//This is triggered whenever a key is released after having been pressed
		//Release the spring if it's the space bar.
		if(KeyCode == KS_SPACE)
			var/obj/spring/O = locate()
			O.pulling = 0
		//Stalk walking or jumping if it's a direction.\
			Then, if they are already holding the opposite direction, start up going that way.
		else switch(KeyCode)
			if(KS_LEFT)
				left = 0
				if(keystate.key[KS_RIGHT])
					right = 1
					spawn() mob.go(2)
			if(KS_RIGHT)
				right = 0
				if(keystate.key[KS_LEFT])
					left = 1
					spawn() mob.go(3)
			if(KS_UP)
				up = 0

//Everything beyond this does not deal directly with the library.

atom/icon = 'icon.dmi'

turf/floor
	icon_state = "turf"

mob
	icon_state = "mob"
	animate_movement = 0
	var
		horizontal_velocity = 0
		vertical_velocity = 0
		jumping = 0
		running = 0
	proc
		go(Dir)
			//I decided to put it all into this one function. Probably a bad idea,\
				but it's not the main concern of the library.
			switch(Dir)
				if(1)
					if(jumping || vertical_velocity)return
					jump()
				if(2)
					if(!running)
						spawn() move()
					while(client.right)
						if(horizontal_velocity < 8)
							horizontal_velocity += 1
						if(jumping) sleep(2)
						else sleep(1)
				if(3)
					if(!running)
						spawn() move()
					while(client.left)
						if(horizontal_velocity > -8)
							horizontal_velocity -= 1
						if(jumping) sleep(2)
						else sleep(1)
		stop()	//stops horizontal acceleration acceleration
			while(1)
				if(!client.left && !client.right)
					if(horizontal_velocity > 0)
						horizontal_velocity -= 1
					if(horizontal_velocity < 0)
						horizontal_velocity +=1
				sleep(1)
		move()
			//takes care of actual acceleration and direction
			/*Objects in this face the direction they are moving in.
				You probably could change that easily, such as not changing direction while jumping.*/
			running = 1
			var/turf/T
			while(running || horizontal_velocity)
				if(horizontal_velocity > 0)
					dir = EAST	//such as here, if you're moving east then turn to face east
				else if(horizontal_velocity < 0)
					dir = WEST
				pixel_x += horizontal_velocity
				if(pixel_x >= 16)
					T = get_step(src, EAST)
					if(T)
						pixel_x -= 32
						loc = T
					else pixel_x -= horizontal_velocity
				if(pixel_x <= -16)
					T = get_step(src, WEST)
					if(T)
						pixel_x += 32
						loc = T
					else pixel_x -= horizontal_velocity
				sleep(1)
			running = 0
		jump()
			//Start rising.
			jumping = 1
			vertical_velocity = 16
			while(vertical_velocity > 0)
				sleep(1)
				pixel_y += vertical_velocity
				if(pixel_y >= 32)
					pixel_y -= 32
					loc = get_step(src, NORTH)
				vertical_velocity -= 1
				//If the client has stopped holding jump and has\
					jumped the minimum distance, don't go much higher.
				if(!client.up && vertical_velocity > 5)
					vertical_velocity = 5
			while(y > 4)
				sleep(1)
				pixel_y += vertical_velocity
				if(pixel_y <= -32)
					pixel_y += 32
					loc = get_step(src, SOUTH)
				vertical_velocity -=1
			pixel_y = 0
			vertical_velocity = 0
			jumping = 0

obj/ball
	icon_state = "ball"
	animate_movement = 0
	var/bouncing = 0
	proc/bounce(tension)
		if(bouncing) return
		bouncing = 1
		//rise loop
		for(var/index = tension to 1 step -1)
			sleep(1)
			pixel_y += index
			if(pixel_y >= 32)
				pixel_y -= 32
				loc = get_step(src, NORTH)
		sleep(1)
		//fall loop
		for(var/index = 1 to tension)
			pixel_y -= index
			if(pixel_y <= -32)
				pixel_y += 32
				loc = get_step(src, SOUTH)
			sleep(1)
		bouncing=0

obj/spring
	icon_state = "16"
	var
		tension = 0  //how far down it is pulled
		pulling = 0  //if space bar is down
	proc
		tension()
			//spring is being pulled back
			if(pulling || tension) return
			pulling = 1
			while(pulling)
				sleep(1)
				if(tension < 16)
					tension += 1
					icon_state = num2text(17 - tension)
			//if loop breaks and gets here, spring was let go, so call spring
			spring(tension)
		spring(N)
			var/obj/ball/O = locate()
			spawn() O.bounce(N)
			tension = 0
			icon_state = "16"