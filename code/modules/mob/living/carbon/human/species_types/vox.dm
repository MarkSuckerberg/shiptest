/datum/species/vox
	name = "Vox"
	id = "vox"
	species_traits = list(NO_UNDERWEAR, EYECOLOR)
	limbs_icon = 'icons/mob/vox_parts.dmi'
	species_eye_path = 'icons/mob/vox_parts.dmi'
	species_clothing_path = 'icons/mob/clothing/species/vox.dmi'
	offset_features = list(OFFSET_UNIFORM = list(0,0), OFFSET_ID = list(0,0), OFFSET_GLOVES = list(0,0), OFFSET_GLASSES = list(0,0), OFFSET_EARS = list(0,0), OFFSET_SHOES = list(0,0), OFFSET_S_STORE = list(0,0), OFFSET_FACEMASK = list(10,1), OFFSET_HEAD = list(10,5), OFFSET_FACE = list(0,0), OFFSET_BELT = list(0,0), OFFSET_BACK = list(10,0), OFFSET_SUIT = list(0,0), OFFSET_NECK = list(0,0), OFFSET_ACCESSORY = list(10, 0))

/datum/species/vox/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	C.pixel_x -= 10

/datum/species/vox/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	C.pixel_x += 10
