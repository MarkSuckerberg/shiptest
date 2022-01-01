/datum/ship_bounty/docking
	name = "Exploration Bounty"
	description = "Land your ship on X planets."
	var/planet_type
	var/amount
	var/count = 0

/datum/ship_bounty/docking/New()
	..()
	if(planet_type)
		name = "Exploration Bounty: [planet_type]"
	if(!amount)
		amount = rand(2, 5)
		description = "Land your ship on [amount] planets."

/datum/ship_bounty/docking/claim(obj/structure/overmap/ship/simulated/claimant)
	. = ..()
	RegisterSignal(claimant, COMSIG_OVERMAP_DOCK_LOCATION, .proc/handle_docking)

/datum/ship_bounty/docking/proc/handle_docking(obj/structure/overmap/dynamic/docked)
	SIGNAL_HANDLER

	if(!istype(docked) || (planet_type && docked.planet != planet_type)) // checks to see if it's actually a dynamic overmap planetoid, and that it matches the desired type
		return

	count++

	if(count >= amount)
		complete()
