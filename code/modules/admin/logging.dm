var/list/mob_logging_datums = list()
var/list/active_player_logging_datums = list()
var/list/inactive_player_logging_datums = list()
var/mobcount = 1

/datum/logging
	var/combined_logs
	var/mobid
	var/currentckey
	var/virus_logs
	var/attack_logs
	var/login_logs
	var/charactername

/mob/New()
	. = ..()
	tag = "mob[++mobcount]"
	mob_logging_datums[tag] = new /datum/logging(src)

/datum/logging/New(mob/M)
	charactername = M.real_name
	mobid = M.tag

/datum/disease2/disease/proc/add_virus_log(var/text)
	var/datum/logging/logs = mob_logging_datums[mob_tag]
	logs.virus_logs += "[text]<br>"
	logs.combined_logs += "<div class='viruslog'>[text]</div><br>"

/mob/proc/add_attack_log(var/text)
	var/datum/logging/logs = mob_logging_datums[tag]
	logs.virus_logs += "[text]<br>"
	logs.combined_logs += "<div class='attacklog'>[text]</div><br>"

/mob/proc/log_login()
	active_player_logging_datums |= tag
	inactive_player_logging_datums -= tag

	var/datum/logging/logs = mob_logging_datums[tag]
	logs.currentckey = ckey
	var/text = "\[[time_stamp()]\] Player login. Ckey: <b>[ckey]</b>"
	logs.login_logs += "[text]<br>"
	logs.combined_logs += "<div class='loginlog'>[text]</div><br>"

/mob/proc/log_logout()
	active_player_logging_datums -= tag
	inactive_player_logging_datums |= tag

	var/datum/logging/logs = mob_logging_datums[tag]
	var/text = "\[[time_stamp()]\] Player logout. Ckey: <b>[ckey]</b>"
	logs.login_logs += "[text]<br>"
	logs.combined_logs += "<div class='loginlog'>[text]</div><br>"
	logs.currentckey = null

/mob/fully_replace_character_name(oldname, newname)
	if(newname)
		var/datum/logging/logs = mob_logging_datums[tag]
		logs.charactername = newname
	return ..()

/proc/transfer_logging_persistance(mob/oldmob, mob/newmob)
	//First we get the log that will tie them to each other
	var/datum/logging/logs = mob_logging_datums[oldmob.tag]

	//If the old mob had someone inside, log their logout of the mob
	if(oldmob.ckey)
		oldmob.log_logout()
	//Log the transfer
	logs.combined_logs += "<div class='newmob'>\[[time_stamp()]\] Mob logging datum transferred to new mob</div><br>"

	//Remove the old log from respective lists it might be in still
	mob_logging_datums -= oldmob.tag
	if(inactive_player_logging_datums.Remove(oldmob.tag) && newmob.ckey)
		inactive_player_logging_datums |= newmob.tag

	//Set the logging datum to this new log
	mob_logging_datums[newmob.tag] = logs
	//Repeat new()
	logs.charactername = newmob.real_name
	logs.mobid = newmob.tag
	//Let the new mob log in
	if(newmob.ckey)
		newmob.log_login()

/*
/datum/admins/proc/view_mob_attack_log(var/mob/M as mob)
	set category	= "Admin"
	set name		= "Show mob's attack logs"
	set desc			= "Shows the (formatted) attack log of a mob in a HTML window."

	if(!istype(M))
		to_chat(usr, "That's not a valid mob!")
		return

	var/datum/browser/clean/popup = new (usr, "\ref[M]_admin_log_viewer", "Attack logs of [M]", 300, 300)
	popup.set_content(jointext(M.attack_log, "<br/>"))
	popup.open()

	feedback_add_details("admin_verb","VMAL")


/client/proc/cmd_admin_attack_log(mob/M as mob in mob_list)
	set category = "Special Verbs"
	set name = "Attack Log"

	to_chat(usr, text("<span class='danger'>Attack Log for []</span>", mob))
	for(var/t in M.attack_log)
		to_chat(usr, t)
	feedback_add_details("admin_verb","ATTL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

*/






















