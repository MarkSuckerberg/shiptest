#define BROADCAST_TYPE_GENERIC 0
#define BROADCAST_TYPE_EMERGENCY 1

GLOBAL_LIST_EMPTY(broadcast_list)

/obj/machinery/computer/communications_ship
	name = "shipboard communications console"
	desc = "A console used for high-priority announcements and emergencies."
	icon_screen = "comm"
	icon_keyboard = "tech_key"
	circuit = /obj/item/circuitboard/computer/communications
	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/communications_ship/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("sendBroadcast")
			var/content = params["content"]
			var/broadcast_type = params["type"]
			var/datum/ship_message/message = new(src, broadcast_type, content)

/datum/ship_message
	var/obj/structure/overmap/sender
	var/location
	var/type
	var/content
	var/timestamp

/datum/ship_message/New(obj/structure/overmap/sender, type, content)
	src.sender = sender
	src.type = type
	src.content = content
	timestamp = time_stamp()
