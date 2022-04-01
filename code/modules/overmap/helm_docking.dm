/obj/machinery/computer/helm
	var/mob/camera/aiEye/remote/shuttle_docker/eyeobj
	var/mob/living/current_user = null
	var/list/actions = list()

	var/datum/action/innate/camera_off/off_action = new
	var/datum/action/innate/shuttledocker_rotate/rotate_action = new
	var/datum/action/innate/shuttledocker_place/place_action = new

	var/obj/docking_port/stationary/my_port //the custom docking port placed by this console

	var/view_range = 20
	var/static/list/whitelist_turfs = list(/turf/open/space, /turf/open/floor/plating, /turf/open/lava, /turf/closed/mineral)
	var/designate_time = 5 SECONDS
	var/turf/designating_target_loc

/obj/machinery/computer/helm/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	whitelist_turfs = typecacheof(whitelist_turfs)

/obj/machinery/computer/helm/proc/GrantActions(mob/living/user)
	if(off_action)
		off_action.target = user
		off_action.Grant(user)
		actions += off_action

	if(rotate_action)
		rotate_action.target = user
		rotate_action.Grant(user)
		actions += rotate_action

	if(place_action)
		place_action.target = user
		place_action.Grant(user)
		actions += place_action

/obj/machinery/computer/helm/proc/give_eye_control(mob/user, turf/target)
	if(!isliving(user))
		return
	if(!eyeobj)
		CreateEye()
	GrantActions(user)
	current_user = user
	eyeobj.eye_user = user
	eyeobj.name = "Camera Eye ([user.name])"
	user.remote_control = eyeobj
	user.reset_perspective(eyeobj)
	eyeobj.setLoc(target, TRUE)
	if(!QDELETED(user) && user.client)
		var/list/to_add = list()
		to_add += eyeobj.placement_images
		to_add += eyeobj.placed_images

		user.client.images += to_add
		user.client.view_size.setTo(view_range)

/obj/machinery/computer/helm/remove_eye_control(mob/user)
	if(!user)
		return
	for(var/V in actions)
		var/datum/action/A = V
		A.Remove(user)
	actions.Cut()
	for(var/datum/camerachunk/C as anything in eyeobj.visibleCameraChunks)
		C.remove(eyeobj)
	if(user.client)
		user.reset_perspective(null)
		if(eyeobj.visible_icon && user.client)
			user.client.images -= eyeobj.user_image

	eyeobj.eye_user = null
	user.remote_control = null

	current_user = null
	user.unset_machine()

	playsound(src, 'sound/machines/terminal_off.ogg', 25, FALSE)

	if(!QDELETED(user) && user.client)
		var/list/to_remove = list()
		to_remove += eyeobj.placement_images
		to_remove += eyeobj.placed_images

		user.client.images -= to_remove
		user.client.view_size.resetToDefault()

/obj/machinery/computer/helm/proc/CreateEye()
	if(QDELETED(current_ship))
		return

	eyeobj = new(null, src)
	eyeobj.setDir(current_ship.shuttle_port.dir)
	var/turf/origin = locate(current_ship.shuttle_port.x, current_ship.shuttle_port.y, current_ship.shuttle_port.z)
	for(var/area/A as anything in current_ship.shuttle_port.shuttle_areas)
		for(var/turf/T in A)
			if(T.virtual_z != origin.virtual_z)
				continue
			var/image/I = image('icons/effects/alphacolors.dmi', origin, "red")
			var/x_off = T.x - origin.x
			var/y_off = T.y - origin.y
			I.loc = locate(origin.x + x_off, origin.y + y_off, origin.z) //we have to set this after creating the image because it might be null, and images created in nullspace are immutable.
			I.layer = ABOVE_NORMAL_TURF_LAYER
			I.plane = 0
			I.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
			eyeobj.placement_images[I] = list(x_off, y_off)

/obj/machinery/computer/helm/proc/placeLandingSpot()
	if(designating_target_loc || !current_user)
		return

	if(current_ship.docked_to)
		to_chat(usr, "<span class='warning'>Shuttle has already docked.</span>")
		return

	var/landing_clear = checkLandingSpot()
	if(designate_time && landing_clear)
		to_chat(current_user, "<span class='warning'>Targeting transit location, please wait [DisplayTimeText(designate_time)]...</span>")
		designating_target_loc = eyeobj.loc
		var/wait_completed = do_after(current_user, designate_time, FALSE, designating_target_loc, TRUE, CALLBACK(src, .proc/canDesignateTarget))
		designating_target_loc = null
		if(!current_user)
			return
		if(!wait_completed)
			to_chat(current_user, "<span class='warning'>Operation aborted.</span>")
			return
		landing_clear = checkLandingSpot()

	if(!landing_clear)
		to_chat(current_user, "<span class='warning'>Invalid transit location.</span>")
		return

	///Make one use port that deleted after fly off, to don't lose info that need on to properly fly off.
	if(my_port)
		my_port.delete_after = TRUE
		my_port.name = "Old [my_port.name]"
		my_port = null

	if(!my_port)
		my_port = new(locate(eyeobj.x, eyeobj.y, eyeobj.z))
		my_port.height = current_ship.shuttle_port.height
		my_port.width = current_ship.shuttle_port.width
		my_port.dheight = current_ship.shuttle_port.dheight
		my_port.dwidth = current_ship.shuttle_port.dwidth

	my_port.setDir(eyeobj.dir)

	if(current_user.client)
		current_user.client.images -= eyeobj.placed_images

	QDEL_LIST(eyeobj.placed_images)

	for(var/image/I as anything in eyeobj.placement_images)
		var/image/newI = image('icons/effects/alphacolors.dmi', eyeobj.loc, "blue")
		newI.loc = I.loc //It is highly unlikely that any landing spot including a null tile will get this far, but better safe than sorry.
		newI.layer = ABOVE_OPEN_TURF_LAYER
		newI.plane = 0
		newI.mouse_opacity = 0
		eyeobj.placed_images += newI

	remove_eye_control(usr)

	current_ship.shuttle_port.initiate_docking(my_port)
	return TRUE

/obj/machinery/computer/helm/proc/canDesignateTarget()
	if(!designating_target_loc || !current_user || (eyeobj.loc != designating_target_loc) || (machine_stat & (NOPOWER|BROKEN)) )
		return FALSE
	return TRUE

/obj/machinery/computer/helm/proc/rotateLandingSpot()
	var/list/image_cache = eyeobj.placement_images
	eyeobj.setDir(turn(eyeobj.dir, -90))
	for(var/image/pic as anything in image_cache)
		var/list/coords = image_cache[pic]
		var/Tmp = coords[1]
		coords[1] = coords[2]
		coords[2] = -Tmp
		pic.loc = locate(eyeobj.x + coords[1], eyeobj.y + coords[2], eyeobj.z)
	checkLandingSpot()

/obj/machinery/computer/helm/proc/checkLandingSpot()
	var/turf/eyeturf = get_turf(eyeobj)
	if(!eyeturf)
		return FALSE
	if(!eyeturf.z)
		return FALSE

	var/list/bounds = current_ship.shuttle_port.return_coords(eyeobj.x, eyeobj.y, eyeobj.dir)
	var/list/overlappers = SSshuttle.get_dock_overlap(bounds[1], bounds[2], bounds[3], bounds[4], eyeobj.z)
	var/list/image_cache = eyeobj.placement_images
	for(var/image/I as anything in image_cache)
		var/list/coords = image_cache[I]
		var/turf/T = locate(eyeturf.x + coords[1], eyeturf.y + coords[2], eyeturf.z)
		I.loc = T
		if(checkLandingTurf(T, overlappers))
			I.icon_state = "green"
			return TRUE
		else
			I.icon_state = "red"
			return FALSE

/obj/machinery/computer/helm/proc/checkLandingTurf(turf/T, list/overlappers)
	// If it's one of our shuttle areas assume it's ok to be there
	if(current_ship.shuttle_port.shuttle_areas[T.loc])
		return TRUE
	if(length(whitelist_turfs))
		if(!is_type_in_typecache(T.type, whitelist_turfs))
			return FALSE

	// Checking for overlapping dock boundaries
	for(var/obj/docking_port/port as anything in overlappers)
		if(port == current_ship.shuttle_port || port == my_port)
			continue
		var/list/overlap = overlappers[port]
		var/list/xs = overlap[1]
		var/list/ys = overlap[2]
		if(xs["[T.x]"] && ys["[T.y]"])
			return FALSE

/mob/camera/aiEye/remote/shuttle_docker
	visible_icon = FALSE
	use_static = USE_STATIC_NONE
	var/list/placement_images = list()
	var/list/placed_images = list()

/mob/camera/aiEye/remote/shuttle_docker/Initialize(mapload, obj/machinery/computer/camera_advanced/origin)
	src.origin = origin
	return ..()

/mob/camera/aiEye/remote/shuttle_docker/setLoc(T)
	..()
	var/obj/machinery/computer/helm/console = origin
	console.checkLandingSpot()

/mob/camera/aiEye/remote/shuttle_docker/update_remote_sight(mob/living/user)
	user.sight = BLIND|SEE_TURFS
	user.lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
	user.sync_lighting_plane_alpha()
	return TRUE

/datum/action/innate/shuttledocker_rotate
	name = "Rotate"
	icon_icon = 'icons/mob/actions/actions_mecha.dmi'
	button_icon_state = "mech_cycle_equip_off"

/datum/action/innate/shuttledocker_rotate/Activate()
	if(QDELETED(target) || !isliving(target))
		return
	var/mob/living/C = target
	var/mob/camera/aiEye/remote/remote_eye = C.remote_control
	var/obj/machinery/computer/helm/origin = remote_eye.origin
	origin.rotateLandingSpot()

/datum/action/innate/shuttledocker_place
	name = "Place"
	icon_icon = 'icons/mob/actions/actions_mecha.dmi'
	button_icon_state = "mech_zoom_off"

/datum/action/innate/shuttledocker_place/Activate()
	if(QDELETED(target) || !isliving(target))
		return
	var/mob/living/C = target
	var/mob/camera/aiEye/remote/remote_eye = C.remote_control
	var/obj/machinery/computer/helm/origin = remote_eye.origin
	origin.placeLandingSpot(target)
