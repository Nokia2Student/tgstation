
#define CARP_ORGAN_COLOR "#4caee7"
#define CARP_SCLERA_COLOR "#ffffff"
#define CARP_PUPIL_COLOR "#00b1b1"

#define CARP_COLORS CARP_ORGAN_COLOR + CARP_SCLERA_COLOR + CARP_PUPIL_COLOR

///bonus of the carp: you can swim through space!
/datum/status_effect/organ_set_bonus/carp
	organs_needed = 4
	bonus_activate_text = span_notice("Carp DNA is deeply infused with you! You've learned how to propel yourself through space!")
	bonus_deactivate_text = span_notice("Your DNA is once again mostly yours, and so fades your ability to space-swim...")

/datum/status_effect/organ_set_bonus/carp/enable_bonus()
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, REF(src))

/datum/status_effect/organ_set_bonus/carp/disable_bonus()
	. = ..()
	REMOVE_TRAIT(src, TRAIT_SPACEWALK, REF(src))

///Carp lungs! You can breathe in space! Oh... you can't breathe on the station, you need low oxygen environments.
/obj/item/organ/internal/lungs/carp
	name = "mutated carp-lungs"
	desc = "Carp DNA infused into what was once some normal lungs."
	safe_oxygen_min = 0 //we don't breathe this!

	icon = 'icons/obj/medical/organs/infuser_organs.dmi'
	icon_state = "lungs"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = CARP_COLORS

/obj/item/organ/internal/lungs/carp/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noticable_organ, "has odd neck gills.", BODY_ZONE_HEAD)
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/carp)

///occasionally sheds carp teeth, stronger melee (bite) attacks, but you can't cover your mouth anymore.
/obj/item/organ/internal/tongue/carp
	name = "mutated carp-jaws"
	desc = "Carp DNA infused into what was once some normal teeth."

	say_mod = "gnashes"

	icon = 'icons/obj/medical/organs/infuser_organs.dmi'
	icon_state = "tongue"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = CARP_COLORS

/obj/item/organ/internal/tongue/carp/Insert(mob/living/carbon/tongue_owner, special, drop_if_replaced)
	. = ..()
	if(!ishuman(tongue_owner))
		return
	var/mob/living/carbon/human/human_receiver = tongue_owner
	var/datum/species/rec_species = human_receiver.dna.species
	rec_species.update_no_equip_flags(tongue_owner, rec_species.no_equip_flags | ITEM_SLOT_MASK)
	var/obj/item/bodypart/head/head = human_receiver.get_bodypart(BODY_ZONE_HEAD)
	head.unarmed_damage_low = 10
	head.unarmed_damage_high = 15
	head.unarmed_stun_threshold = 15

/obj/item/organ/internal/tongue/carp/Remove(mob/living/carbon/tongue_owner, special)
	. = ..()
	if(!ishuman(tongue_owner))
		return
	var/mob/living/carbon/human/human_receiver = tongue_owner
	var/datum/species/rec_species = human_receiver.dna.species
	rec_species.update_no_equip_flags(tongue_owner, initial(rec_species.no_equip_flags))
	var/obj/item/bodypart/head/head = human_receiver.get_bodypart(BODY_ZONE_HEAD)
	head.unarmed_damage_low = initial(head.unarmed_damage_low)
	head.unarmed_damage_high = initial(head.unarmed_damage_high)
	head.unarmed_stun_threshold = initial(head.unarmed_stun_threshold)

/obj/item/organ/internal/tongue/carp/on_life(delta_time, times_fired)
	. = ..()
	if(owner.stat != CONSCIOUS || !prob(0.1))
		return
	owner.emote("cough")
	var/turf/tooth_fairy = get_turf(owner)
	if(tooth_fairy)
		new /obj/item/knife/carp(tooth_fairy)

/obj/item/knife/carp
	name = "carp tooth"
	desc = "Looks sharp. Sharp enough to poke someone's eye out. Holy fuck it's big."
	icon_state = "carptooth"

///carp brain. you need to occasionally go to a new zlevel. think of it as... walking your dog!
/obj/item/organ/internal/brain/carp
	name = "mutated carp-brain"
	desc = "Carp DNA infused into what was once a normal brain."

	icon = 'icons/obj/medical/organs/infuser_organs.dmi'
	icon_state = "brain"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = CARP_COLORS

	///Timer counting down. When finished, the owner gets a bad moodlet.
	var/cooldown_timer
	///how much time the timer is given
	var/cooldown_time = 10 MINUTES

/obj/item/organ/internal/brain/carp/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noticable_organ, "seems unable to stay still.")
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/carp)

/obj/item/organ/internal/brain/carp/Insert(mob/living/carbon/brain_owner, special, drop_if_replaced, no_id_transfer)
	. = ..()
	cooldown_timer = addtimer(CALLBACK(src, PROC_REF(unsatisfied_nomad)), cooldown_time, TIMER_STOPPABLE|TIMER_OVERRIDE|TIMER_UNIQUE)
	RegisterSignal(brain_owner, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(satisfied_nomad))

//technically you could get around the mood issue by extracting and reimplanting the brain but it will be far easier to just go one z there and back
/obj/item/organ/internal/brain/carp/Remove(mob/living/carbon/brain_owner, special, no_id_transfer)
	. = ..()
	UnregisterSignal(brain_owner)
	deltimer(cooldown_timer)

/obj/item/organ/internal/brain/carp/get_attacking_limb(mob/living/carbon/human/target)
	return owner.get_bodypart(BODY_ZONE_HEAD)

/obj/item/organ/internal/brain/carp/proc/unsatisfied_nomad()
	owner.add_mood_event("nomad", /datum/mood_event/unsatisfied_nomad)

/obj/item/organ/internal/brain/carp/proc/satisfied_nomad()
	SIGNAL_HANDLER
	owner.clear_mood_event("nomad")
	cooldown_timer = addtimer(CALLBACK(src, PROC_REF(unsatisfied_nomad)), cooldown_time, TIMER_STOPPABLE|TIMER_OVERRIDE|TIMER_UNIQUE)

/// makes you cold resistant, but heat-weak.
/obj/item/organ/internal/heart/carp
	name = "mutated carp-heart"
	desc = "Carp DNA infused into what was once a normal heart."

	icon = 'icons/obj/medical/organs/infuser_organs.dmi'
	icon_state = "heart"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = CARP_COLORS

	organ_traits = list(TRAIT_RESISTCOLD, TRAIT_RESISTLOWPRESSURE)

/obj/item/organ/internal/heart/carp/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noticable_organ, "skin has small patches of scales growing...")
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/carp)

#undef CARP_ORGAN_COLOR
#undef CARP_SCLERA_COLOR
#undef CARP_PUPIL_COLOR

#undef CARP_COLORS
