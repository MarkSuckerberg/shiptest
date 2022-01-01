/datum/ship_bounty
	var/name
	var/description
	var/reward
	var/obj/structure/overmap/ship/simulated/claimer

/datum/ship_bounty/proc/claim(obj/structure/overmap/ship/simulated/claimant)
	SHOULD_CALL_PARENT(TRUE)
	claimer = claimant

/datum/ship_bounty/proc/complete(obj/structure/overmap/ship/simulated/fulfiller)
	if(isnum(reward))
		fulfiller.ship_account.adjust_money(reward)
	if(isatom(reward))
		new reward(get_turf(fulfiller.shuttle))
