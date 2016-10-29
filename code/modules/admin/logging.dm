var/global/mob_logging_datums = list()
var/global/active_player_logging_datums = list()

var/mobcount = 1
/datum/logging
	var/mobid
	var/currentckey
	var/virus_logs
	var/attack_logs
	var/login_logs

/mob/New()
	. = ..()
	tag = "mob[++mobcount]"

/datum/disease2/disease/proc/add_virus_log(var/text)


/mob/proc/add_attack_log(var/text)


/mob/proc/log_login()


/mob/proc/log_logout()




























