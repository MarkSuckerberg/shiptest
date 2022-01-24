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
	var/static/list/broadcast_list = list()

/obj/machinery/computer/communications_ship/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ShipCommunicationsConsole", name)
		ui.open()

/obj/machinery/computer/communications_ship/ui_static_data(mob/user)
	. = list()
	.["messages"] = list()
	for(var/datum/ship_message/message in broadcast_list)
		.["messages"] += list(
			"content" = message.content,
			"type" = message.message_type,
			"time" = message.timestamp,
			"sender" = message.sender.name,
			"location" = message.location
		)


/obj/machinery/computer/communications_ship/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("sendBroadcast")
			var/content = params["content"]
			var/broadcast_type = params["type"]
			var/datum/ship_message/message = new(src, broadcast_type, content)
			broadcast_list += message

/datum/ship_message
	var/obj/structure/overmap/sender
	var/location
	var/message_type
	var/content
	var/timestamp

/datum/ship_message/New(obj/structure/overmap/sender, message_type, content)
	src.sender = sender
	src.message_type = message_type
	src.content = content
	timestamp = time_stamp()
