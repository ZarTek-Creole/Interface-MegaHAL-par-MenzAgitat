 ##############################################################################
#
# Interface MegaHAL
# v4.1.0 (02/04/2016)  ©2007-2016 Menz Agitat
# pour MegaHAL v8 (module v3.5) Artixed Edition
#
# IRC: irc.epiknet.org  #boulets / #eggdrop
#
# Mes scripts sont téléchargeables sur http://www.eggdrop.fr
# Retrouvez aussi toute l'actualité de mes releases sur
# http://www.boulets.oqp.me/tcl/scripts/index.html
#
# Remerciements à Artix et à Galdinx pour les coups de main, et à Miocastoor
# pour quelques idées.
#
 ##############################################################################

#
# Description
#
# Interface MegaHAL est une interface pour le module MegaHAL développé par
# Zev ^Baron^ Toledano et modifié par Artix, d'après l'I.A. de Jason Hutchens.
# Ce script ne fonctionnera correctement qu'avec la version 3.5 du module
# MegaHAL modifié par Artix (Artixed Edition); elle est normalement fournie avec
# si vous avez récupéré ce script au bon endroit.
# Remarque : si vous choisissez de ne pas utiliser la version fournie du module
# et que vous avez des problèmes, ne venez pas m'en parler.
#
# Le but de cette interface est d'accroître le contrôle que vous avez sur
# MegaHAL et d'ajouter de nombreuses fonctionnalités et améliorations dont
# vous trouverez une description dans le fichier documentation.txt inclus.
#
 ##############################################################################

#
# Licence
#
#		Cette création est mise à disposition selon le Contrat
#		Attribution-NonCommercial-ShareAlike 3.0 Unported disponible en ligne
#		http://creativecommons.org/licenses/by-nc-sa/3.0/ ou par courrier postal à
#		Creative Commons, 171 Second Street, Suite 300, San Francisco, California
#		94105, USA.
#		Vous pouvez également consulter la version française ici :
#		http://creativecommons.org/licenses/by-nc-sa/3.0/deed.fr
#
 ###############################################################################

if {[::tcl::info::commands ::megahal_interface::uninstall] eq "::megahal_interface::uninstall"} { ::megahal_interface::uninstall }
if { [regsub -all {\.} [lindex $::version 0] ""] < 1620 } { putloglev o * "\00304\[Interface MegaHAL - erreur\]\003 La version de votre Eggdrop est\00304 ${::version}\003; Interface MegaHAL ne fonctionnera correctement que sur les Eggdrops version 1.6.20 ou supérieure." ; return }
if { [::tcl::info::tclversion] < 8.5 } { putloglev o * "\00304\002\[Interface MegaHAL - Erreur\]\002\003 Interface MegaHAL nécessite que Tcl 8.5 (ou plus) soit installé pour fonctionner. Votre version actuelle de Tcl est \00304\002$tcl_version\002\003." ; return }
if { [lsearch -index 0 [modules] "megahal"] == -1 } {
	putloglev o * "\00304\002\[Interface MegaHAL - Erreur\]\002\003 Vous devez charger le module MegaHAL \002avant\002 l'Interface MegaHAL. Tentative de chargement du module..."
	catch { loadmodule megahal }
	if { [lsearch -index 0 [modules] "megahal"] == -1 } { putloglev o * "\00304\002\[Interface MegaHAL - Erreur\]\002\003 Le module MegaHAL n'a pas pu être chargé, abandon du chargement de l'Interface MegaHAL." ; return }
}
if { [::tcl::info::commands *pub:.megaseek] ne "" } {
	putloglev o * "\00304\002\[Interface MegaHAL - Erreur\]\002\003 Vous utilisez une version du module MegaHAL antérieure à la v3.5. Vous devez impérativement utiliser la version fournie avec cette interface pour qu'elle puisse fonctionner." ; return
} elseif { [::tcl::info::commands megahal_searchword] eq "" } {
	putloglev o * "\00304\002\[Interface MegaHAL - Erreur\]\002\003 La version du module MegaHAL que vous utilisez n'est pas une \"Artixed Edition\". Vous devez impérativement utiliser la version fournie avec cette interface pour qu'elle puisse fonctionner." ; return
}
package require Tcl 8.5
namespace eval ::megahal_interface {



 ###############################################################################
### Configuration
 ###############################################################################

	# Chemin et nom du fichier de configuration :
	variable config_file "scripts/megahal_interface/MegaHAL_Interface.cfg"

 ###############################################################################
### Fin de la configuration
 ###############################################################################



	 #############################################################################
	### Initialisation
	 #############################################################################
	package provide MegaHAL_Interface 4.1.0
	variable version "4.1.0.20160402"
	variable scriptname "Interface MegaHAL"
	setudef flag megahal
	setudef flag megahal_learn
	setudef flag megahal_respond
	setudef flag megahal_chatter
	setudef str megahal_brn_birth
	# Chargement de la configuration.
	eval [list source $::megahal_interface::config_file]
	regexp {(.*)\|(.*)} $::megahal_interface::learn_auth {} ::megahal_interface::learn_global_flags ::megahal_interface::learn_local_flags
	regexp {(.*)\|(.*)} $::megahal_interface::reply_auth {} ::megahal_interface::reply_global_flags ::megahal_interface::reply_local_flags
	regexp {(.*)\|(.*)} $::megahal_interface::learn_forbidden_auth {} ::megahal_interface::learn_forbidden_global_flags ::megahal_interface::learn_forbidden_local_flags
	regexp {(.*)\|(.*)} $::megahal_interface::reply_forbidden_auth {} ::megahal_interface::reply_forbidden_global_flags ::megahal_interface::reply_forbidden_local_flags
	regexp {(.*)\|(.*)} $::megahal_interface::shutup_auth {} ::megahal_interface::shutup_global_flags ::megahal_interface::shutup_local_flags
	regexp {(.*)\|(.*)} $::megahal_interface::shutup_forbidden_auth {} ::megahal_interface::shutup_forbidden_global_flags ::megahal_interface::shutup_forbidden_local_flags
	array set ::megahal_interface::instance {}
	array set ::megahal_interface::shutup {}
	array set ::megahal_interface::floodlock_learn {}
	array set ::megahal_interface::floodlock_reply {}
	set ::megahal_interface::backuptime [split $::megahal_interface::backuptime ":"]
	set ::megahal_interface::talk_queue ""
	set ::megahal_interface::delayed_talk_running 0
	set ::megahal_interface::check_responder 0
	set ::megahal_interface::long_message_queue_running 0
	setmegabotnick $::nick
	setmaxcontext $::megahal_interface::maxcontext
	set ::mega_minLearnWords $::megahal_interface::minlearnwords
	set ::mega_verbose 0
	# On désactive l'apprentissage conventionnel du module MegaHAL car l'interface
	# MegaHAL contrôle cet aspect par ses propres moyens.
	learningmode off
	# On enlève les binds que le module MegaHAL a installé afin de pouvoir mettre
	# les nôtres.
	set binds_list [binds]
	if { [lsearch -regexp $binds_list {pubm -(\|-)? \* [0-9]+ \*pubm:mega}] != -1 } {
		unbind pubm -|- * *pubm:mega
	}
	if { [lsearch -regexp $binds_list {ctcp -(\|-)? ACTION [0-9]+ \*ctcp:mega}] != -1 } {
		unbind ctcp -|- ACTION *ctcp:mega
	}
	if { [lsearch -regexp $binds_list {pub -(\|-)? hal: [0-9]+ \*pub:hal:}] != -1 } {
		unbind pub -|- hal: *pub:hal:
	}
	if { [lsearch -regexp $binds_list {dcc -(\|-)? hal [0-9]+ \*dcc:hal}] != -1 } {
		unbind dcc -|- hal *dcc:hal
	}
	if { [lsearch -regexp $binds_list {pub -(\|-)? .megaver [0-9]+ \*pub:.megaver}] != -1 } {
		unbind pub -|- .megaver *pub:.megaver
	}
	if { [lsearch -regexp $binds_list {dcc -(\|-)? megaver [0-9]+ \*dcc:megaver}] != -1 } {
		unbind dcc -|- megaver *dcc:megaver
	}
	if { [lsearch -regexp $binds_list {pub n\|n .forget [0-9]+ \*pub:.forget}] != -1 } {
		unbind pub n|n .forget *pub:.forget
	}
	if { [lsearch -regexp $binds_list {dcc n\|n forget [0-9]+ \*dcc:forget}] != -1 } {
		unbind dcc n|n forget *dcc:forget
	}
	if { [lsearch -regexp $binds_list {pub n\|n .forgetword [0-9]+ \*pub:.forgetword}] != -1 } {
		unbind pub n|n .forgetword *pub:.forgetword
	}
	if { [lsearch -regexp $binds_list {dcc n\|n forgetword [0-9]+ \*dcc:forgetword}] != -1 } {
		unbind dcc n|n forgetword *dcc:forgetword
	}
	# Construction d'une liste qui sera utilisée par le string map du mode
	# "TAGUEULE".
	foreach trigger $::megahal_interface::shutup_triggers {
		lappend ::megahal_interface::shutup_trigger_list [subst $trigger] "!-shutup-!"
	}
	unset ::megahal_interface::shutup_triggers
	set ::megahal_interface::floodlimiter [split $::megahal_interface::floodlimiter ":"]
	# Procédure de désinstallation : le script se désinstalle totalement avant
	# chaque rehash ou à chaque relecture au moyen de la commande "source" ou
	# autre.
	proc uninstall {args} {
		putlog "Désallocation des ressources de l'${::megahal_interface::scriptname}..."
		foreach binding [lsearch -inline -all -regexp [binds *[set ns [::tcl::string::range [namespace current] 2 end]]*] " \{?(::)?$ns"] {
			unbind [lindex $binding 0] [lindex $binding 1] [lindex $binding 2] [lindex $binding 4]
		}
		package forget MegaHAL_Interface
		namespace delete ::megahal_interface
	}
}

 ###############################################################################
### Traitement des données reçues.
 ###############################################################################
proc ::megahal_interface::process_pub_msg {nick host hand chan text} {
	if { ![channel get $chan megahal] } {
		return
	} else {
		if {
			(($::megahal_interface::DEBUGMODE_chan eq "*")
			|| ($chan eq $::megahal_interface::DEBUGMODE_chan))
			&& ([lindex $::megahal_interface::DEBUGMODE 0])
		} then {
			::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00306i!i\003\00313!i!\003\00314 dump \003process_pub_msg\00314 : $nick | $host | $hand | $chan | $text\003"
		}
		::megahal_interface::process $nick $host $hand $chan 0 $text
	}
}
proc ::megahal_interface::process_ctcp_action {nick host hand target ctcp_type text} {
	if {
		([::tcl::string::first "#" $target])
		|| !([channel get $target megahal])
	} then {
		return
	} else {
		if {
			(($::megahal_interface::DEBUGMODE_chan eq "*")
			|| ($target eq $::megahal_interface::DEBUGMODE_chan))
			&& ([lindex $::megahal_interface::DEBUGMODE 0])
		} then {
			::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00306i!i\003\00313!i!\003\00314 dump \003process_ctcp_action\00314 : $nick | $host | $hand | $target | $ctcp_type | $text\003"
		}
		::megahal_interface::process $nick $host $hand $target 1 "$nick $text"
	}
}
proc ::megahal_interface::process {nick host hand chan is_ctcp_action text} {
	if {
		(($::megahal_interface::DEBUGMODE_chan eq "*")
		|| ($chan eq $::megahal_interface::DEBUGMODE_chan))
		&& ([lindex $::megahal_interface::DEBUGMODE 0])
	} then {
		::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00306i!i\003\00313!i!\003\00314 dump \003process\00314 : $nick | $host | $hand | $chan | $text\003"
	}
	set clean_chan [::megahal_interface::neutralize_special_chars $chan]
	set clean_nick [::megahal_interface::neutralize_special_chars $nick]
	# Remarque : l'aller-retour d'encodage permet de contourner un bug d'Eggdrop
	# qui corromp le charset dans certaines conditions lors de l'utilisation de
	# regsub sur une chaîne de caractères.
	set text [encoding convertto utf-8 [encoding convertfrom utf-8 $text]]
	set text [::megahal_interface::tolower [::megahal_interface::strip_codes_trim_spaces [::tcl::string::map {\031 \047} $text]]]
	regexp {(.*) (.*)} [split [chattr $hand $chan] "|"] {} user_global_flags user_local_flags
	if {$hand eq "*"} {
		set user_local_flags "-"
		set user_global_flags "-"
	}
	if {
		(!$is_ctcp_action)
		&& ([::megahal_interface::is_learn_allowed_1st_pass $nick $clean_nick $host $hand $chan $clean_chan $is_ctcp_action $user_global_flags $user_local_flags $text])
	} then {
		regsub "^(\\$::megahal_interface::force_L_R_cmd|\\$::megahal_interface::force_noL_R_cmd|\\$::megahal_interface::force_L_noR_cmd|\\$::megahal_interface::force_noL_noR_cmd)" $text "" unmodified_text_to_learn
		set text_to_learn [::tcl::string::trim [::megahal_interface::moulinex_in "learn" $nick $chan $unmodified_text_to_learn]]
		if { ![::megahal_interface::is_learn_allowed_2nd_pass $nick $host $hand $chan $user_global_flags $user_local_flags $text $text_to_learn] } {
			unset text_to_learn
			unset unmodified_text_to_learn
		}
	}
	# Remarque : on n'apprend pas tout de suite afin de ne pas risquer de
	# retrouver le contenu de la requête dans la réponse.
	if { [::megahal_interface::is_talk_allowed_1st_pass $nick $clean_nick $host $hand $chan $clean_chan $user_global_flags $user_local_flags $text] } {
		if { $::megahal_interface::use_responder } {
			# On définit à 0 la variable de test permettant de savoir si Responder a
			# répondu ou pas.
			variable check_responder 0
			# On appelle Responder pour voir s'il a quelque chose à dire.
			::responder::process $nick $host $hand $chan $text
			# Si Responder a répondu à $nick, on le note pour l'antiflood.
			if { $::megahal_interface::check_responder } {
				::megahal_interface::flood $chan add_instance
				variable floodlock_reply
				set floodlock_reply($clean_chan,$clean_nick) 1
				after [expr {$::megahal_interface::reply_interval * 1000}] [list ::megahal_interface::unfloodlock_reply $clean_chan $clean_nick]
			}
		}
		# On détecte s'il est demandé au bot de se taire.
		if { [::tcl::string::match -nocase "*!-shutup-!*" [::tcl::string::map -nocase $::megahal_interface::shutup_trigger_list $text]] == 1 } {
			# ---------------------------------------------------------------------------
			if {
				(($::megahal_interface::DEBUGMODE_chan eq "*")
				|| ($chan eq $::megahal_interface::DEBUGMODE_chan))
				&& ([lindex $::megahal_interface::DEBUGMODE 2])
			} then {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00306i!i\003\00313!i!i!i!\003\00314 Il a été demandé au bot de se taire."
				if {
					([regexp "\[$::megahal_interface::shutup_global_flags\]" "-$user_global_flags"])
					|| ([regexp "\[$::megahal_interface::shutup_local_flags\]" "-$user_local_flags"])
				} then {
					::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 ${nick}/$hand a les privilèges requis pour demander au bot de se taire (\00307${user_global_flags}|$user_local_flags\00314)\003"
				} else {
					::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 ${nick}/$hand n'a pas les privilèges requis demander au bot de se taire (\00307${user_global_flags}|$user_local_flags\00314)\003"
				}
				if {
					(($::megahal_interface::shutup_forbidden_auth ne "")
					&& ((($::megahal_interface::shutup_forbidden_global_flags ne "")
					&& ([regexp "\[$::megahal_interface::shutup_forbidden_global_flags\]" "-$user_global_flags"]))
					|| (($::megahal_interface::shutup_forbidden_local_flags ne "")
					&& ([regexp "\[$::megahal_interface::shutup_forbidden_local_flags\]" "-$user_local_flags"]))))
				} then {
					::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 ${nick}/$hand a des autorisations rédhibitoires pour pouvoir demander au bot de se taire (\00307${user_global_flags}|$user_local_flags\00314)\003"
				} else {
					::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 ${nick}/$hand n'a pas d'autorisations rédhibitoires pour pouvoir demander au bot de se taire (\00307${user_global_flags}|$user_local_flags\00314)\003"
				}
			}
			# ---------------------------------------------------------------------------
			if {
				(([regexp "\[$::megahal_interface::shutup_global_flags\]" "-$user_global_flags"])
				|| ([regexp "\[$::megahal_interface::shutup_local_flags\]" "-$user_local_flags"]))
				&& !(($::megahal_interface::shutup_forbidden_auth ne "")
				&& ((($::megahal_interface::shutup_forbidden_global_flags ne "")
				&& ([regexp "\[$::megahal_interface::shutup_forbidden_global_flags\]" "-$user_global_flags"]))
				|| (($::megahal_interface::shutup_forbidden_local_flags ne "")
				&& ([regexp "\[$::megahal_interface::shutup_forbidden_local_flags\]" "-$user_local_flags"]))))
			} then {
				set ::megahal_interface::shutup($clean_chan) 1
				after [expr {$::megahal_interface::shutup_time * 60000}] [list ::megahal_interface::unshutup $clean_chan]
				if {
					(($::megahal_interface::DEBUGMODE_chan eq "*")
					|| ($chan eq $::megahal_interface::DEBUGMODE_chan))
					&& ([lindex $::megahal_interface::DEBUGMODE 5])
				} then {
					::megahal_interface::display_output log - - "\00304\[MEGAHAL\] \002Mode TAGUEULE activé pour $::megahal_interface::shutup_time minutes sur $chan\002\003"
				}
			}
		} elseif { [::megahal_interface::is_talk_allowed_2nd_pass $nick $host $hand $chan $user_global_flags $user_local_flags $text] } {
			if { ![::tcl::info::exists text_to_learn] } {
				set submitted_text [::megahal_interface::moulinex_in "submit" $nick $chan [set unmodified_text_to_get_reply_from [regsub "^(\\$::megahal_interface::force_L_R_cmd|\\$::megahal_interface::force_noL_R_cmd|\\$::megahal_interface::force_L_noR_cmd|\\$::megahal_interface::force_noL_noR_cmd)" $text ""]]]
				set is_modified_getreply 1
			} else {
				set submitted_text $text_to_learn
				set is_modified_getreply 0
			}
			# Si un nick est cité et a été substitué dans ce que l'utilisateur a dit,
			# on le note dans $targetnick afin de pouvoir le réutiliser dans la
			# réponse.
			set targetnick "@"
			if { [regexp {oooooousernick([^o]+)oooooo} $submitted_text {} target_hash] } {
				foreach current_nick [chanlist $chan] {
					if { [md5 $current_nick] eq $target_hash } {
						set targetnick $current_nick
					}
				}
			}
			if {
				(($::megahal_interface::DEBUGMODE_chan eq "*")
				|| ($chan eq $::megahal_interface::DEBUGMODE_chan))
				&& ($is_modified_getreply)
				&& ([lindex $::megahal_interface::DEBUGMODE 3])
				&& ([::tcl::string::compare -nocase [::tcl::string::map {"." ""} $submitted_text] [::tcl::string::map {"." ""} $unmodified_text_to_get_reply_from]] != 0)
			} then {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00307\[$chan\]\003 \00314 $unmodified_text_to_get_reply_from\003"
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00312--getreply-->\003\00315 $submitted_text\003"
			}
			set reply [::megahal_interface::moulinex_out $nick $hand $chan $targetnick [::tcl::string::tolower [::megahal_getreply $submitted_text]]]
			if { [::megahal_interface::is_talk_allowed_3rd_pass $nick $host $hand $chan $reply] } {
				::megahal_interface::flood $chan "add_instance"
				::megahal_interface::talk $chan $clean_chan $nick $clean_nick "internal" $reply
			} elseif {
				(($::megahal_interface::DEBUGMODE_chan eq "*")
				|| ($chan eq $::megahal_interface::DEBUGMODE_chan))
				&& ([lindex $::megahal_interface::DEBUGMODE 2])
			} then {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 la réponse contient une commande ne faisant pas partie des commandes autorisées ( \00307[lindex [split $reply] 0]\00314 )\003"
			}				
		}
	}
	if { [::tcl::info::exists text_to_learn] } {
	if {
		(($::megahal_interface::DEBUGMODE_chan eq "*")
		|| ($chan eq $::megahal_interface::DEBUGMODE_chan))
		&& ([lindex $::megahal_interface::DEBUGMODE 3])
		&& ([::tcl::string::compare -nocase [::tcl::string::map {"." ""} $text_to_learn] [::tcl::string::map {"." ""} $unmodified_text_to_learn]] != 0)
	} then {
		::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00307\[$chan\]\003 \00314 $unmodified_text_to_learn\003"
		::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303--learn-->\003\00315 $text_to_learn\003"
	}
		::megahal_interface::learn $nick $clean_nick $chan $clean_chan $text_to_learn
	}
}

 ###############################################################################
### Autorisation d'apprendre ? (1ère passe)
### (retourne 1 pour oui, 0 pour non)
 ###############################################################################
proc ::megahal_interface::is_learn_allowed_1st_pass {nick clean_nick host hand chan clean_chan is_ctcp_action user_global_flags user_local_flags text} {
	if { ![::tcl::info::exists ::megahal_interface::floodlock_learn($clean_chan,$clean_nick)] } { set ::megahal_interface::floodlock_learn($clean_chan,$clean_nick) 0 }
	set coin [rand 101]
	if { $::megahal_interface::learn_exclusion_wordlist ne "" } {
		set forbidden_word ""
		foreach word $::megahal_interface::learn_exclusion_wordlist {
			if { [::tcl::string::match -nocase $word $text] } {
				set forbidden_word $word
			}
		}
	}
	# ---------------------------------------------------------------------------
	if {
		(($::megahal_interface::DEBUGMODE_chan eq "*")
		|| ($chan eq $::megahal_interface::DEBUGMODE_chan))
		&& ($::megahal_interface::DEBUGMODE != 0)
	} then {
		if {
			([lindex $::megahal_interface::DEBUGMODE 0])
			|| ([lindex $::megahal_interface::DEBUGMODE 1])
			|| ([lindex $::megahal_interface::DEBUGMODE 2])
		} then {
			::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00307i!i\003\00308!i!i!i!\003\00314 \002$chan\002 <$nick> $text\003"
		}
		if { [lindex $::megahal_interface::DEBUGMODE 0] } {
			::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00306i!i\003\00313!i!\003\00314 dump \003is_learn_allowed_1st_pass\00314 : $nick | $clean_nick | $host | $hand ([chattr $hand $chan]) | $chan | $clean_chan | $text\003"
		}
		if { [lindex $::megahal_interface::DEBUGMODE 1] } {
			::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00310i!i\003\00311!i!\003\00314 ENUMERATION DES CRITERES D'APPRENTISSAGE (1ERE PASSE)\003"
			if { $is_ctcp_action } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 Il s'agit d'un CTCP ACTION, on ne l'apprend pas.\003"
			} else {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 Il ne s'agit pas d'un CTCP ACTION.\003"
			}
			if { [::tcl::string::match "$::megahal_interface::force_L_R_cmd*" $text] } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 la ligne commence par \"$::megahal_interface::force_L_R_cmd\" : \003\00303\002apprentissage forcé\002\003\00314 + réponse forcée si flags \003\00307$::megahal_interface::force_L_R_auth\003"
			} elseif { [::tcl::string::match "$::megahal_interface::force_L_noR_cmd*" $text] } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 la ligne commence par \"$::megahal_interface::force_L_noR_cmd\" : \003\00303\002apprentissage forcé\002\003\00314 + ne répond pas si flags \003\00307$::megahal_interface::force_L_noR_auth\003"
			}
			if { [channel get $chan megahal_learn] } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 L'apprentissage est actif sur $chan (flag +megahal_learn).\003"
			} else {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 L'apprentissage est inactif sur $chan (flag -megahal_learn).\003"
			}
			if {
				([lsearch -nocase $::megahal_interface::learn_exclusion_list $nick] != -1)
				|| ([lsearch -nocase -exact $::megahal_interface::learn_exclusion_list $hand] != -1)
			} then { 
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 ${nick}/$hand est présent dans la liste \$learn_exclusion_list (\00307$::megahal_interface::learn_exclusion_list\003\00314)\003"
			} else {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 ${nick}/$hand n'est pas présent dans la liste \$learn_exclusion_list\003"
			}
			if {
				(($::megahal_interface::learn_forbidden_auth ne "")
				&& ((($::megahal_interface::learn_forbidden_global_flags ne "")
				&& ([regexp "\[$::megahal_interface::learn_forbidden_global_flags\]" "-$user_global_flags"]))
				|| (($::megahal_interface::learn_forbidden_local_flags ne "")
				&& ([regexp "\[$::megahal_interface::learn_forbidden_local_flags\]" "-$user_local_flags"]))))
			} then {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 ${nick}/$hand a des autorisations rédhibitoires pour pouvoir apprendre à l'I.A. (\00307${user_global_flags}|$user_local_flags\00314)\003"
			} else {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 ${nick}/$hand n'a pas d'autorisations rédhibitoires pour pouvoir apprendre à l'I.A. (\00307${user_global_flags}|$user_local_flags\00314)\003"
			}
			if {
				([regexp "\[$::megahal_interface::learn_global_flags\]" "-$user_global_flags"])
				|| ([regexp "\[$::megahal_interface::learn_local_flags\]" "-$user_local_flags"])
			} then {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 ${nick}/$hand a les privilèges requis pour apprendre à l'I.A. (\00307${user_global_flags}|$user_local_flags\00314)\003"
			} else {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 ${nick}/$hand n'a pas les privilèges requis pour apprendre à l'I.A. (\00307${user_global_flags}|$user_local_flags\00314)\003"
			}
			if { $::megahal_interface::learn_exclusion_wordlist ne "" } {
				if { $forbidden_word ne "" } { 
					::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 au moins un mot figure dans la liste des mots dont l'apprentissage est interdit (\00307$forbidden_word\003\00314)\003"
				} else {
					::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 aucun mot ne figure dans la liste des mots dont l'apprentissage est interdit\003"
				}
			}
			if { !$::megahal_interface::floodlock_learn($clean_chan,$clean_nick) } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 Le mode \"floodlock_learn\" n'est pas actif pour $nick sur $chan\003"
			} else {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 Le mode \"floodlock_learn\" est actif pour $nick sur $chan\003"
			}
			::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00314i!i\003\00315!i!\003\00314 tirage d'un nombre aléatoire entre 1 et 100 afin de déterminer si le bot a le droit d'apprendre : \003\00307$coin\003"

			if { [set num_words [llength [split $text]]] >= $::megahal_interface::minlearnwords } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 La phrase a une longueur supérieure ou égale à \$minlearnwords (\003\00307$num_words \003\00314>=\003\00307 $::megahal_interface::minlearnwords\003\00314)\003"
			} else {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 La phrase a une longueur inférieure à \$minlearnwords (\003\00307$num_words \003\00314<\003\00307 $::megahal_interface::minlearnwords\003\00314)\003"
			}
			if { $::megahal_interface::maxlearnwords } {
				if { $num_words <= $::megahal_interface::maxlearnwords } {
					::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 La phrase a une longueur inférieure ou égale à \$maxlearnwords (\003\00307$num_words \003\00314<=\003\00307 $::megahal_interface::maxlearnwords\003\00314)\003"
				} else {
					::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 La phrase a une longueur supérieure à \$maxlearnwords (\003\00307$num_words \003\00314>\003\00307 $::megahal_interface::maxlearnwords\003\00314)\003"
				}
			}
			if { $coin <= $::megahal_interface::learnrate } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 le bot a \003\00307$::megahal_interface::learnrate%\003\00314 de chances d'apprendre.\003"
			} else {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 le bot a \003\00307$::megahal_interface::learnrate%\003\00314 de chances d'apprendre.\003"
			}
			if { [::tcl::string::match "$::megahal_interface::force_noL_R_cmd*" $text] } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 la ligne commence par \"$::megahal_interface::force_noL_R_cmd\" : n'apprend pas + réponse forcée si flags \003\00307$::megahal_interface::force_noL_R_auth\003"
			} elseif { [::tcl::string::match "$::megahal_interface::force_noL_noR_cmd*" $text] } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 la ligne commence par \"$::megahal_interface::force_noL_noR_cmd\" : n'apprend pas + ne répond pas si flags \003\00307$::megahal_interface::force_noL_noR_auth\003"
			}
			if { ![::megahal_interface::handle_command $text] } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 la ligne est une commande ne faisant pas partie des commandes autorisées ( \00307$text\00314 )\003"
			} else {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 la ligne n'est pas une commande ou fait partie des commandes autorisées.\003"
			}
		}
	}
	# ---------------------------------------------------------------------------
	if {
		((([::tcl::string::match "$::megahal_interface::force_L_R_cmd*" $text])
		&& ([::megahal_interface::matchattr_ $user_global_flags $user_local_flags $::megahal_interface::force_L_R_auth]))
		|| (([::tcl::string::match "$::megahal_interface::force_L_noR_cmd*" $text])
		&& ([::megahal_interface::matchattr_ $user_global_flags $user_local_flags $::megahal_interface::force_L_noR_auth])))
		|| (([channel get $chan megahal_learn])
		&& ([lsearch -nocase $::megahal_interface::learn_exclusion_list $nick] == -1)
		&& ([lsearch -nocase -exact $::megahal_interface::learn_exclusion_list $hand] == -1)
		&& !(($::megahal_interface::learn_forbidden_auth ne "")
		&& ((($::megahal_interface::learn_forbidden_global_flags ne "")
		&& ([regexp "\[$::megahal_interface::learn_forbidden_global_flags\]" "-$user_global_flags"]))
		|| (($::megahal_interface::learn_forbidden_local_flags ne "")
		&& ([regexp "\[$::megahal_interface::learn_forbidden_local_flags\]" "-$user_local_flags"]))))
		&& (([regexp "\[$::megahal_interface::learn_global_flags\]" "-$user_global_flags"])
		|| ([regexp "\[$::megahal_interface::learn_local_flags\]" "-$user_local_flags"]))
		&& ($forbidden_word eq "")
		&& (!$::megahal_interface::floodlock_learn($clean_chan,$clean_nick))
		&& ([set num_words [llength [split $text]]] >= $::megahal_interface::minlearnwords)
		&& ((!$::megahal_interface::maxlearnwords) || (($::megahal_interface::maxlearnwords)
		&& ($num_words <= $::megahal_interface::maxlearnwords)))
		&& ($coin <= $::megahal_interface::learnrate)
		&& !(([::tcl::string::match "$::megahal_interface::force_noL_R_cmd*" $text])
		&& ([::megahal_interface::matchattr_ $user_global_flags $user_local_flags $::megahal_interface::force_noL_R_auth]))
		&& !(([::tcl::string::match "$::megahal_interface::force_noL_noR_cmd*" $text])
		&& ([::megahal_interface::matchattr_ $user_global_flags $user_local_flags $::megahal_interface::force_noL_noR_auth]))
		&& ([::megahal_interface::handle_command $text]))
	} then {
		return 1
	} else {
		if {
			(($::megahal_interface::DEBUGMODE_chan eq "*")
			|| ($chan eq $::megahal_interface::DEBUGMODE_chan))
			&& ([lindex $::megahal_interface::DEBUGMODE 1])
		} then {
			::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \002\00305i!i\003\00304!i!\003\002\00314 L'apprentissage n'a pas été autorisé après passage en revue des critères.\003"
		}
		return 0
	}
}

 ###############################################################################
### Autorisation d'apprendre ? (2ème passe : on vérifie qu'après le passage de
### la moulinette, la ligne ne commence pas par une commande et est encore assez
### longue pour être apprise)
### (retourne 1 pour oui, 0 pour non)
 ###############################################################################
proc ::megahal_interface::is_learn_allowed_2nd_pass {nick host hand chan user_global_flags user_local_flags text text_to_learn} {
	# ---------------------------------------------------------------------------
	if {
		(($::megahal_interface::DEBUGMODE_chan eq "*")
		|| ($chan eq $::megahal_interface::DEBUGMODE_chan))
		&& ($::megahal_interface::DEBUGMODE != 0)
	} then {
		if { [lindex $::megahal_interface::DEBUGMODE 0] } {
			::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00306i!i\003\00313!i!\003\00314 dump \003is_learn_allowed_2nd_pass\00314 : $nick | $host | $hand ([chattr $hand $chan]) | $chan | $text | $text_to_learn\003"
		}
		if { [lindex $::megahal_interface::DEBUGMODE 1] } {
			::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00310i!i\003\00311!i!\003\00314 ENUMERATION DES CRITERES D'APPRENTISSAGE (2EME PASSE)\003"
			if { [::tcl::string::match "$::megahal_interface::force_L_R_cmd*" $text] } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 la ligne commence par \"$::megahal_interface::force_L_R_cmd\" : \003\00303\002apprentissage forcé\002\003\00314 + réponse forcée si flags \003\00307$::megahal_interface::force_L_R_auth\003"
			} elseif { [::tcl::string::match "$::megahal_interface::force_L_noR_cmd*" $text] } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 la ligne commence par \"$::megahal_interface::force_L_noR_cmd\" : \003\00303\002apprentissage forcé\002\003\00314 + ne répond pas si flags \003\00307$::megahal_interface::force_L_noR_auth\003"
			}
			if { [set num_words [llength [split $text_to_learn]]] >= $::megahal_interface::minlearnwords } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 La phrase a une longueur supérieure ou égale à \$minlearnwords (\003\00307$num_words \003\00314>=\003\00307 $::megahal_interface::minlearnwords\003\00314)\003"
			} else {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 La phrase a une longueur inférieure à \$minlearnwords (\003\00307$num_words \003\00314<\003\00307 $::megahal_interface::minlearnwords\003\00314)\003"
			}
			if { $::megahal_interface::maxlearnwords } {
				if { $num_words <= $::megahal_interface::maxlearnwords } {
					::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 La phrase a une longueur inférieure ou égale à \$maxlearnwords (\003\00307$num_words \003\00314<=\003\00307 $::megahal_interface::maxlearnwords\003\00314)\003"
				} else {
					::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 La phrase a une longueur supérieure à \$maxlearnwords (\003\00307$num_words \003\00314>\003\00307 $::megahal_interface::maxlearnwords\003\00314)\003"
				}
			}
			if { ![::megahal_interface::handle_command $text_to_learn] } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 la ligne est une commande ne faisant pas partie des commandes autorisées ( \00307$text_to_learn\00314 )\003"
			} else {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 la ligne n'est pas une commande ou fait partie des commandes autorisées.\003"
			}
		}
	}
	# ---------------------------------------------------------------------------
	if {
		(([::tcl::string::match "$::megahal_interface::force_L_R_cmd*" $text])
		&& ([::megahal_interface::matchattr_ $user_global_flags $user_local_flags $::megahal_interface::force_L_R_auth]))
		|| (([::tcl::string::match "$::megahal_interface::force_L_noR_cmd*" $text])
		&& ([::megahal_interface::matchattr_ $user_global_flags $user_local_flags $::megahal_interface::force_L_noR_auth]))
		|| (([set num_words [llength [split $text_to_learn]]] >= $::megahal_interface::minlearnwords)
		&& ((!$::megahal_interface::maxlearnwords) || (($::megahal_interface::maxlearnwords)
		&& ($num_words <= $::megahal_interface::maxlearnwords)))
		&& ([::megahal_interface::handle_command $text_to_learn]))
	} then {
		return 1
	} else {
		if {
			(($::megahal_interface::DEBUGMODE_chan eq "*")
			|| ($chan eq $::megahal_interface::DEBUGMODE_chan))
			&& ([lindex $::megahal_interface::DEBUGMODE 1])
		} then {
			::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \002\00305i!i\003\00304!i!\003\002\00314 L'apprentissage n'a pas été autorisé après passage en revue des critères.\003"
		}
		return 0
	}
}

 ###############################################################################
### Autorisation de répondre ? (1ère passe : avant appel de Responder)
### (retourne 1 pour oui, 0 pour non)
 ###############################################################################
proc ::megahal_interface::is_talk_allowed_1st_pass {nick clean_nick host hand chan clean_chan user_global_flags user_local_flags text} {
	if { ![::tcl::info::exists ::megahal_interface::shutup($clean_chan)] } {
		set ::megahal_interface::shutup($clean_chan) 0
	}
	if { ![::tcl::info::exists ::megahal_interface::floodlock_reply($clean_chan,$clean_nick)] } {
		set ::megahal_interface::floodlock_reply($clean_chan,$clean_nick) 0
	}
	# ---------------------------------------------------------------------------
	if {
		(($::megahal_interface::DEBUGMODE_chan eq "*")
		|| ($chan eq $::megahal_interface::DEBUGMODE_chan))
		&& ($::megahal_interface::DEBUGMODE != 0)
	} then {
		if { [lindex $::megahal_interface::DEBUGMODE 0] } {
			::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00306i!i\003\00313!i!\003\00314 dump \003is_talk_allowed_1st_pass\00314 : $nick | $clean_nick | $host | $hand ([chattr $hand $chan]) | $chan | $clean_chan | $text\003"
		}
		if { [lindex $::megahal_interface::DEBUGMODE 2] } {
			::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00310i!i\003\00311!i!\003\00314 ENUMERATION DES CRITERES DE REPONSE (1ERE PASSE)\003"
			if { [::tcl::string::match "$::megahal_interface::force_L_R_cmd*" $text] } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 la ligne commence par \"$::megahal_interface::force_L_R_cmd\" : apprentissage forcé + \003\00303\002réponse forcée\002\003\00314 si flags \003\00307$::megahal_interface::force_L_R_auth\003"
			} elseif { [::tcl::string::match "$::megahal_interface::force_noL_R_cmd*" $text] } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 la ligne commence par \"$::megahal_interface::force_noL_R_cmd\" : n'apprend pas + \003\00303\002réponse forcée\002\003\00314 si flags \003\00307$::megahal_interface::force_noL_R_auth\003"
			} elseif { [::tcl::string::match "$::megahal_interface::force_L_noR_cmd*" $text] } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 la ligne commence par \"$::megahal_interface::force_L_noR_cmd\" : apprentissage forcé + ne répond pas si flags \003\00307$::megahal_interface::force_L_noR_auth\003"
			} elseif { [::tcl::string::match "$::megahal_interface::force_noL_noR_cmd*" $text] } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 la ligne commence par \"$::megahal_interface::force_noL_noR_cmd\" : n'apprend pas + ne répond pas si flags \003\00307$::megahal_interface::force_noL_noR_auth\003"
			}
			if {
				([lsearch -nocase $::megahal_interface::reply_exclusion_list $nick] != -1)
				|| ([lsearch -nocase -exact $::megahal_interface::reply_exclusion_list $hand] != -1)
			} then {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 ${nick}/$hand est présent dans la liste \$reply_exclusion_list (\00307$::megahal_interface::reply_exclusion_list\003\00314)\003"
			} else {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 ${nick}/$hand n'est pas présent dans la liste \$reply_exclusion_list\003"
			}
			if { !$::megahal_interface::shutup($clean_chan) } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 Le mode \"ta gueule\" n'est pas actif sur $chan\003"
			} else {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 Le mode \"ta gueule\" est actif sur $chan\003"
			}
			if { !$::megahal_interface::floodlock_reply($clean_chan,$clean_nick) } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 Le mode \"floodlock_reply\" n'est pas actif pour $nick sur $chan\003"
			} else {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 Le mode \"floodlock_reply\" est actif pour $nick sur $chan\003"
			}
			if { ![::megahal_interface::flood $chan "check"] } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 L'antiflood n'a pas été déclenché sur $chan\003"
			} else {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 L'antiflood a été déclenché sur $chan\003"
			}
			if {
				(($::megahal_interface::reply_forbidden_auth ne "")
				&& ((($::megahal_interface::reply_forbidden_global_flags ne "")
				&& ([regexp "\[$::megahal_interface::reply_forbidden_global_flags\]" "-$user_global_flags"]))
				|| (($::megahal_interface::reply_forbidden_local_flags ne "")
				&& ([regexp "\[$::megahal_interface::reply_forbidden_local_flags\]" "-$user_local_flags"]))))
			} then {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 ${nick}/$hand a des autorisations rédhibitoires pour que l'I.A. lui réponde (\00307${user_global_flags}|$user_local_flags\00314)\003"
			} else {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 ${nick}/$hand n'a pas d'autorisations rédhibitoires pour que l'I.A. lui réponde (\00307${user_global_flags}|$user_local_flags\00314)\003"
			}
			if {
				([regexp "\[$::megahal_interface::reply_global_flags\]" "-$user_global_flags"])
				|| ([regexp "\[$::megahal_interface::reply_local_flags\]" "-$user_local_flags"])
			} then {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 ${nick}/$hand a les privilèges requis pour que l'I.A. lui réponde (\00307${user_global_flags}|$user_local_flags\00314)\003"
			} else {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 ${nick}/$hand n'a pas les privilèges requis pour que l'I.A. lui réponde (\00307${user_global_flags}|$user_local_flags\00314)\003"
			}
			if { !$::megahal_interface::allow_replies_to_commands } {
				if { [::megahal_interface::is_command $text] } {
					::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 la ligne est une commande et on n'autorise pas les réponses aux commandes ( \00307$text\00314 )\003"
				} else {
					::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 la ligne n'est pas une commande.\003"
				}
			}
		}
	}
	# ---------------------------------------------------------------------------
	if {
		((([::tcl::string::match "$::megahal_interface::force_L_R_cmd*" $text])
		&& ([::megahal_interface::matchattr_ $user_global_flags $user_local_flags $::megahal_interface::force_L_R_auth]))
		|| (([::tcl::string::match "$::megahal_interface::force_noL_R_cmd*" $text])
		&& ([::megahal_interface::matchattr_ $user_global_flags $user_local_flags $::megahal_interface::force_noL_R_auth])))
		|| (([lsearch -nocase $::megahal_interface::reply_exclusion_list $nick] == -1)
		&& ([lsearch -nocase -exact $::megahal_interface::reply_exclusion_list $hand] == -1)
		&& (!$::megahal_interface::shutup($clean_chan))
		&& (!$::megahal_interface::floodlock_reply($clean_chan,$clean_nick))
		&& (![::megahal_interface::flood $chan check])
		&& !(($::megahal_interface::reply_forbidden_auth ne "")
		&& ((($::megahal_interface::reply_forbidden_global_flags ne "")
		&& ([regexp "\[$::megahal_interface::reply_forbidden_global_flags\]" "-$user_global_flags"]))
		|| (($::megahal_interface::reply_forbidden_local_flags ne "")
		&& ([regexp "\[$::megahal_interface::reply_forbidden_local_flags\]" "-$user_local_flags"]))))
		&& (([regexp "\[$::megahal_interface::reply_global_flags\]" "-$user_global_flags"])
		|| ([regexp "\[$::megahal_interface::reply_local_flags\]" "-$user_local_flags"]))
		&& (($::megahal_interface::allow_replies_to_commands)
		|| ((!$::megahal_interface::allow_replies_to_commands)
		&& (![::megahal_interface::is_command $text])))
		&& !(([::tcl::string::match "$::megahal_interface::force_L_noR_cmd*" $text])
		&& ([::megahal_interface::matchattr_ $user_global_flags $user_local_flags $::megahal_interface::force_L_noR_auth]))
		&& !(([::tcl::string::match "$::megahal_interface::force_noL_noR_cmd*" $text])
		&& ([::megahal_interface::matchattr_ $user_global_flags $user_local_flags $::megahal_interface::force_noL_noR_auth])))
	 } then {
		return 1
	} else {
		if {
			(($::megahal_interface::DEBUGMODE_chan eq "*")
			|| ($chan eq $::megahal_interface::DEBUGMODE_chan))
			&& ([lindex $::megahal_interface::DEBUGMODE 2])
		} then {
			::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \002\00305i!i\003\00304!i!\003\002\00314 La parole n'a pas été autorisée après passage en revue des critères.\003"
		}
		return 0
	}
}

 ###############################################################################
### Autorisation de répondre ? (2ème passe : après appel de Responder et
### vérification que le mode TAGUEULE n'a pas été déclenché)
### (retourne 1 pour oui, 0 pour non)
 ###############################################################################
proc ::megahal_interface::is_talk_allowed_2nd_pass {nick host hand chan user_global_flags user_local_flags text} {
	set coin [rand 101]
	set triggered ""
	# On cherche si la phrase contient un mot clé.
	foreach word $::megahal_interface::trigger_words {
		if { [regexp -nocase "(^|\[^a-z\])[regsub -all {\W} [set word [subst $word]] {\\&}](\[^a-z\]|$)" $text] } {
			set triggered $word
		}
	}
	# ---------------------------------------------------------------------------
	if {
		(($::megahal_interface::DEBUGMODE_chan eq "*")
		|| ($chan eq $::megahal_interface::DEBUGMODE_chan))
		&& ($::megahal_interface::DEBUGMODE != 0)
	} then {
		if { [lindex $::megahal_interface::DEBUGMODE 0] } {
			::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00306i!i\003\00313!i!\003\00314 dump \003is_talk_allowed_2nd_pass\00314 : $nick | $host | $hand ([chattr $hand $chan]) | $chan | $text\003"
		}
		if { [lindex $::megahal_interface::DEBUGMODE 2] } {
			::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00310i!i\003\00311!i!\003\00314 ENUMERATION DES CRITERES DE REPONSE (2EME PASSE)\003"
			if { [::tcl::string::match "$::megahal_interface::force_L_R_cmd*" $text] } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 la ligne commence par \"$::megahal_interface::force_L_R_cmd\" : apprentissage forcé + \003\00303\002réponse forcée\002\003\00314 si flags \003\00307$::megahal_interface::force_L_R_auth\003"
			} elseif { [::tcl::string::match "$::megahal_interface::force_noL_R_cmd*" $text] } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 la ligne commence par \"$::megahal_interface::force_noL_R_cmd\" : n'apprend pas + \003\00303\002réponse forcée\002\003\00314 si flags \003\00307$::megahal_interface::force_noL_R_auth\003"
			}
			if { [llength $::megahal_interface::talk_queue] < $::megahal_interface::max_talk_queue } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 La file d'attente contient \003\00307[llength $::megahal_interface::talk_queue]\003\00314/\003\00307$::megahal_interface::max_talk_queue\003\00314 entrées\003"
			} else {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 La file d'attente est pleine (\003\00307[llength $::megahal_interface::talk_queue]\003\00314/\003\00307$::megahal_interface::max_talk_queue\003\00314)\003"
			}
			if { $::megahal_interface::use_responder } {
				if { $::megahal_interface::check_responder } {
					::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 Responder a répondu à \003\00307$text\003"
				} else {
					::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 Responder n'a pas répondu\003"
				}
			}
			::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00314i!i\003\00315!i!\003\00314 tirage d'un nombre aléatoire entre 1 et 100 afin de déterminer si le bot a le droit de répondre : \003\00307$coin\003"
			if {
				([channel get $chan megahal_respond])
				&& ($triggered ne "")
			} then {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 au moins un mot clé présent dans la liste \$trigger_words a été matché (\003\00307 $triggered \003\00314)\003"
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 le bot a \003\00307$::megahal_interface::keyreplyrate%\003\00314 de chances de répondre si un mot clé est prononcé (flag +megahal_respond).\003"
			} else {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 aucun mot clé n'a été matché ou flag -megahal_respond.\003"
			}
			if { [channel get $chan megahal_chatter] } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 Le bot a \003\00307$::megahal_interface::replyrate%\003\00314 de chances de répondre à tout (flag +megahal_chatter).\003"
			} else {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 Le bot n'a pas la permission de parler librement (flag -megahal_chatter).\003"
			}
		}
	}
	# ---------------------------------------------------------------------------
	if {
		((([::tcl::string::match "$::megahal_interface::force_L_R_cmd*" $text])
		&& ([::megahal_interface::matchattr_ $user_global_flags $user_local_flags $::megahal_interface::force_L_R_auth]))
		|| (([::tcl::string::match "$::megahal_interface::force_noL_R_cmd*" $text])
		&& ([::megahal_interface::matchattr_ $user_global_flags $user_local_flags $::megahal_interface::force_noL_R_auth])))
		|| (([llength $::megahal_interface::talk_queue] < $::megahal_interface::max_talk_queue)
		&& (!$::megahal_interface::check_responder)
		&& ((([channel get $chan megahal_respond])
		&& ($triggered ne "")
		&& ($coin <= $::megahal_interface::keyreplyrate))
		|| (([channel get $chan megahal_chatter])
		&& ($coin <= $::megahal_interface::replyrate))))
	} then {
		return 1
	} else {
		if {
			(($::megahal_interface::DEBUGMODE_chan eq "*")
			|| ($chan eq $::megahal_interface::DEBUGMODE_chan))
			&& ([lindex $::megahal_interface::DEBUGMODE 2])
		} then {
			::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \002\00305i!i\003\00304!i!\003\002\00314 La parole n'a pas été autorisée après passage en revue des critères.\003"
		}
		return 0
	}
}

 ###############################################################################
### Autorisation de répondre ? (3ème passe : après passage de la moulinette,
### vérification que la réponse ne commence pas par une commande)
### (retourne 1 pour oui, 0 pour non)
 ###############################################################################
proc ::megahal_interface::is_talk_allowed_3rd_pass {nick host hand chan text} {
	# ---------------------------------------------------------------------------
	if {
		(($::megahal_interface::DEBUGMODE_chan eq "*")
		|| ($chan eq $::megahal_interface::DEBUGMODE_chan))
		&& ($::megahal_interface::DEBUGMODE != 0)
	} then {
		if { [lindex $::megahal_interface::DEBUGMODE 0] } {
			::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00306i!i\003\00313!i!\003\00314 dump \003is_talk_allowed_3rd_pass\00314 : $nick | $host | $hand ([chattr $hand $chan]) | $chan | $text\003"
		}
		if { [lindex $::megahal_interface::DEBUGMODE 2] } {
			::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00310i!i\003\00311!i!\003\00314 ENUMERATION DES CRITERES DE REPONSE (3EME PASSE)\003"
			if { ![::megahal_interface::handle_command $text] } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 la réponse contient une commande ne faisant pas partie des commandes autorisées ( \00307[lindex [split $text] 0]\00314 )\003"
			} else {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 la réponse n'est pas une commande ou fait partie des commandes autorisées.\003"
			}
		}
	}
	# ---------------------------------------------------------------------------
	if { [::megahal_interface::handle_command $text] } {
		return 1
	} else {
		if {
			(($::megahal_interface::DEBUGMODE_chan eq "*")
			|| ($chan eq $::megahal_interface::DEBUGMODE_chan))
			&& ([lindex $::megahal_interface::DEBUGMODE 2])
		} then {
			::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \002\00305i!i\003\00304!i!\003\002\00314 La parole n'a pas été autorisée après passage en revue des critères.\003"
		}
		return 0
	}
}

 ###############################################################################
### Remplacement de la commande matchattr, vu que matchattr $hand -|- retourne 0
### si $hand = *
 ###############################################################################
proc ::megahal_interface::matchattr_ {user_global_flags user_local_flags authorizations} {
	regexp {(.*)\|(.*)} $authorizations {} cmd_global_flags cmd_local_flags
	if {
		([regexp "\[$cmd_global_flags\]" "-$user_global_flags"])
		|| ([regexp "\[$cmd_local_flags\]" "-$user_local_flags"])
	} then {
		return 1
	} else {
		return 0
	}
}

 ###############################################################################
### Est-ce une commande et a-t-on l'autorisation de l'apprendre/utiliser ?
### (voir variables $command_prefixes et $allowed_commands)
### (retourne 1 si l'autorisation est donnée, sinon 0)
 ###############################################################################
proc ::megahal_interface::handle_command {text} {
	regsub "^(\\$::megahal_interface::force_L_R_cmd|\\$::megahal_interface::force_noL_R_cmd|\\$::megahal_interface::force_L_noR_cmd|\\$::megahal_interface::force_noL_noR_cmd)" $text "" text
	foreach command $::megahal_interface::allowed_commands {
		if { [::tcl::string::match $command* $text] } {
			return 1
		}
	}	
	foreach symbol [split $::megahal_interface::command_prefixes ""] {
		if { [::megahal_interface::is_command $text] } {
			return 0
		}
	}
	return 1
}

 ###############################################################################
### Est-ce une commande ? (retourne 1 si oui, sinon 0)
 ###############################################################################
proc ::megahal_interface::is_command {text} {
	foreach symbol [split $::megahal_interface::command_prefixes ""] {
		if { [::tcl::string::match $symbol* $text] } {
			return 1
		}
	}
	return 0
}

 ###############################################################################
### Apprentissage
 ###############################################################################
proc ::megahal_interface::learn {nick clean_nick chan clean_chan text} {
	if {
		(($::megahal_interface::DEBUGMODE_chan eq "*")
		|| ($chan eq $::megahal_interface::DEBUGMODE_chan))
		&& ($::megahal_interface::DEBUGMODE != 0)
	} then {
		if { [lindex $::megahal_interface::DEBUGMODE 0] } {
			::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00306i!i\003\00313!i!\003\00314 dump \003learn\00314 : $nick | $clean_nick | $chan | $clean_chan | $text\003"
		}
		if { [lindex $::megahal_interface::DEBUGMODE 1] } {
			::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00314i!i\003\00315!i!\003\00314 appris\00307 $text \00314de \00307$nick\003"
		}
	}
	set ::megahal_interface::floodlock_learn($clean_chan,$clean_nick) 1
	after [expr {$::megahal_interface::learn_interval * 1000}] [list ::megahal_interface::unfloodlock_learn $clean_chan $clean_nick]
	::megahal_learn $text
	return $text
}

 ###############################################################################
### Parole
 ###############################################################################
proc ::megahal_interface::talk {chan clean_chan nick clean_nick source reply} {
	if {
		(($::megahal_interface::DEBUGMODE_chan eq "*")
		|| ($chan eq $::megahal_interface::DEBUGMODE_chan))
		&& ([lindex $::megahal_interface::DEBUGMODE 0])
	} then {
		::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00306i!i\003\00313!i!\003\00314 dump \003talk\00314 : $chan | $clean_chan | $nick | $clean_nick | $source | $reply\003"
	}
	# On lance un timer qui servira à savoir si le bot a déjà répondu à $nick
	# il y a moins de $::megahal_interface::reply_interval secondes, afin d'éviter
	# plusieurs réponses rapprochées à la même personne.
	set ::megahal_interface::floodlock_reply($clean_chan,$clean_nick) 1
	after [expr {$::megahal_interface::reply_interval * 1000}] [list ::megahal_interface::unfloodlock_reply $clean_chan $clean_nick]
	# Affichage d'une réponse neutre avant la réponse principale si $2nd_neutral_reply est activé
	if {
		($::megahal_interface::2nd_neutral_reply)
		&& ($source eq "internal")
		&& ([set coin [rand 101]] <= $::megahal_interface::2nd_neutral_reply_rate)
		&& ([set coin2 [rand 2]])
	} then {
		# Remarque : le 1er argument signifie "réponse ajoutée par Responder"
		# (0=non 1=oui)
		lappend ::megahal_interface::talk_queue [list 0 $chan [subst [lindex $::megahal_interface::2nd_neutral_pre_reply_list [rand [llength $::megahal_interface::2nd_neutral_pre_reply_list]]]]]
	}
	# On retarde la réponse pour simuler la vitesse de frappe
	# (coeff * sqrt(nombre de caractères) + offset)
	# On ajoute la réponse du bot dans la file d'attente, elle sera traitée après
	# le délai.
	lappend ::megahal_interface::talk_queue [list 0 $chan $reply]
	# Affichage d'une réponse neutre après la réponse principale si
	# $2nd_neutral_reply est activé;
	if {
		($::megahal_interface::2nd_neutral_reply)
		&& ($source eq "internal")
		&& ($coin <= $::megahal_interface::2nd_neutral_reply_rate)
		&& !($coin2)
	} then {
		lappend ::megahal_interface::talk_queue [list 0 $chan [subst [lindex $::megahal_interface::2nd_neutral_post_reply_list [rand [llength $::megahal_interface::2nd_neutral_post_reply_list]]]]]
	}
	if { !$::megahal_interface::delayed_talk_running } {
		::megahal_interface::delayed_talk
	}
	if {
		(($::megahal_interface::DEBUGMODE_chan eq "*")
		|| ($chan eq $::megahal_interface::DEBUGMODE_chan))
		&& ([lindex $::megahal_interface::DEBUGMODE 2])
	} then {
		::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00314i!i\003\00315!i!\003 \00314queue de réponses ([llength $::megahal_interface::talk_queue]): $::megahal_interface::talk_queue\003"
	}
}

 ###############################################################################
### Traitement de la file d'attente de parole
 ###############################################################################
proc ::megahal_interface::delayed_talk {} {
	# Si la file d'attente de réponses est vide, on arrête.
	if { ![llength $::megahal_interface::talk_queue] } {
		set ::megahal_interface::delayed_talk_running 0
		return
	} else {
		set ::megahal_interface::delayed_talk_running 1
	}
	lassign [lindex $::megahal_interface::talk_queue 0] is_from_responder chan
	# Si la réponse ne provient pas de Responder...
	if { !$is_from_responder } {
		regsub -all {[\}\{\[\]\$"\\]} [lindex $::megahal_interface::talk_queue 0 2] {\\&} reply
		set output "puthelp \"PRIVMSG $chan :$reply\""
		set delay [expr {round(($::megahal_interface::reply_speed_coeff * sqrt([::tcl::string::length $reply])) + $::megahal_interface::reply_speed_offset) * 1000}]
		# Le 1er argument est le type (0=N/A 1=normal 2=notice 3=/me)
		# Le 2ème argument signifie "ajouter au log ?" (0=non 1=oui)
		after $delay ::megahal_interface::display_response [list 1 1 $chan $output $reply]
	# Si la réponse provient de Responder...
	} else {
		regsub -all {[\}\{\[\]\$"\\]} [join [lindex $::megahal_interface::talk_queue 0 2]] {\\&} reply
		set first_word ""
		regexp {([^ ]*) (.*)} $reply {} first_word leftovers
		switch -exact -- [::tcl::string::tolower $first_word] {
			"/putserv" {
				set output "putserv \"$leftovers\""
				set delay 0
				after $delay ::megahal_interface::display_response [list 0 0 $chan $output "-"]
			}
			"/notice" {
				regexp {([^ ]*) (.*)} $leftovers {} target leftovers
				set output "puthelp \"NOTICE $target :$leftovers\""
				set delay [expr {round(($::megahal_interface::reply_speed_coeff * sqrt([::tcl::string::length $leftovers])) + $::megahal_interface::reply_speed_offset) * 1000}]
				if { ![::tcl::string::first "#" $target] } {
					after $delay ::megahal_interface::display_response [list 2 1 $chan $output $leftovers]
				} else {
					after $delay ::megahal_interface::display_response [list 0 0 $chan $output "-"]
				}
			}
			"/me" {
				regexp {([^ ]*) (.*)} $leftovers {} target leftovers
				set output "puthelp \"PRIVMSG $target :\\001ACTION $leftovers\\001\""
				set delay [expr {round(($::megahal_interface::reply_speed_coeff * sqrt([::tcl::string::length $leftovers])) + $::megahal_interface::reply_speed_offset) * 1000}]
				if { ![::tcl::string::first "#" $target] } {
					after $delay ::megahal_interface::display_response [list 3 1 $chan $output $leftovers]
				} else {
					after $delay ::megahal_interface::display_response [list 0 0 $chan $output "-"]
				}
			}
			"/msg" {
				regexp {([^ ]*) (.*)} $leftovers {} target leftovers
				set output "puthelp \"PRIVMSG $target :$leftovers\""
				set delay [expr {round(($::megahal_interface::reply_speed_coeff * sqrt([::tcl::string::length $leftovers])) + $::megahal_interface::reply_speed_offset) * 1000}]
				if { ![::tcl::string::first "#" $target] } {
					after $delay ::megahal_interface::display_response [list 1 1 $chan $output $leftovers]
				} else {
					after $delay ::megahal_interface::display_response [list 0 0 $chan $output "-"]
				}
			}
			default {
				set output "puthelp \"PRIVMSG $chan :$reply\""
				set delay [expr {round(($::megahal_interface::reply_speed_coeff * sqrt([::tcl::string::length $reply])) + $::megahal_interface::reply_speed_offset) * 1000}]
				after $delay ::megahal_interface::display_response [list 1 1 $chan $output $reply]
			}
		}
	}
	if {
		(($::megahal_interface::DEBUGMODE_chan eq "*")
		|| ($chan eq $::megahal_interface::DEBUGMODE_chan))
		&& ([lindex $::megahal_interface::DEBUGMODE 2])
	} then {
		::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00314i!i\003\00315!i!\003 \00314Réponse dans [expr {$delay / 1000}]s \00314--$chan-->\003 $output\003"
	}
 	return
}

 ###############################################################################
### Affichage d'une réponse sur un chan
 ###############################################################################
proc ::megahal_interface::display_response {type add_to_log chan output reply} {
	eval $output
	# On écrit dans le log du chan ce que le bot dit car le logger interne ne le
	# fait pas.
	if { $add_to_log } {
		switch -exact -- $type {
			"1" {
				putloglev p $chan "<$::botnick> $reply"
			}
			"2" {
				putloglev p $chan "-${::botnick}:${chan}- $reply"
			}				
			"3" {
				putloglev p $chan "* $::botnick $reply"
			}
		}
	}
	# on élimine la 1ère réponse de la file d'attente car elle a été traitée
	set ::megahal_interface::talk_queue [lreplace $::megahal_interface::talk_queue 0 0]
	::megahal_interface::delayed_talk
	return
}

 ###############################################################################
### Suppression d'un floodlock_learn (floodlock_learn = MegaHAL n'apprend plus
### rien venant de $nick)
 ###############################################################################
proc ::megahal_interface::unfloodlock_learn {chan nick} {
	if { [::tcl::info::exists ::megahal_interface::floodlock_learn($chan,$nick)] } {
		unset ::megahal_interface::floodlock_learn($chan,$nick)
	}
	return
}

 ###############################################################################
### Suppression d'un floodlock_reply (floodlock_reply = MegaHAL ne répond plus à
### $nick)
 ###############################################################################
proc ::megahal_interface::unfloodlock_reply {chan nick} {
	if { [::tcl::info::exists ::megahal_interface::floodlock_reply($chan,$nick)] } {
		unset ::megahal_interface::floodlock_reply($chan,$nick)
	}
	return
}

 ###############################################################################
### Suppression du mode "TAGUEULE"
 ###############################################################################
proc ::megahal_interface::unshutup {chan} {
	if { [::tcl::info::exists ::megahal_interface::shutup($chan)] } {
		if {
			(($::megahal_interface::DEBUGMODE_chan eq "*")
			|| ($chan eq $::megahal_interface::DEBUGMODE_chan))
			&& ([lindex $::megahal_interface::DEBUGMODE 5])
			&& ($megahal_interface::shutup($chan))
		} then {
			::megahal_interface::display_output log - - "\00304\[MEGAHAL\] \002Mode TAGUEULE désactivé sur $chan après [set ::megahal_interface::shutup_time]mn\002\003"
		}
		unset ::megahal_interface::shutup($chan)
	}
	return
}

 ###############################################################################
### Affichage de l'aide en fonction des autorisations
 ###############################################################################
proc ::megahal_interface::pub_help {nick host hand chan arg} {
	::megahal_interface::help $nick $host $hand $chan 0 - $arg
}
proc ::megahal_interface::dcc_help {hand idx arg} {
	::megahal_interface::help [set nick [hand2nick $hand]] [getchanhost $nick] $hand - 1 $idx $arg
}
proc ::megahal_interface::help {nick host hand chan is_dcc idx arg} {
	if {
		(!$is_dcc)
		&& (![channel get $chan megahal])
	} then {
		return
	}
	if { $is_dcc } {
		set user_global_flags [chattr $hand]
		set user_local_flags $user_global_flags
	} else {
		regexp {(.*) (.*)} [split [chattr $hand $chan] "|"] {} user_global_flags user_local_flags
		if {$hand eq "*"} {
			set user_local_flags "-"
			set user_global_flags "-"
		}
	}
	if { $::megahal_interface::help_mode } {
		set help_mode "PRIVMSG"
	} else {
		set help_mode "NOTICE"
	}
	set cmd_prefix_list {masterswitch learnstate respondstate chatterstate replyrate keyreplyrate forget forgetword seekstatement countword learnfile savebrain reloadbrain reloadphrases trimbrain lobotomy restorebrain chanstatus braininfo memusage treesize viewbranch make_words debug_output getwordsymbol moulinex_in moulinex_out megaver force_L_R force_noL_R force_L_noR force_noL_noR}
	foreach command $cmd_prefix_list {
		regexp {(.*)\|(.*)} [set ::megahal_interface::[subst $command]_auth] {} cmd_global_flags cmd_local_flags
		if {
			([regexp "\[$cmd_global_flags\]" "-$user_global_flags"])
			|| ([regexp "\[$cmd_local_flags\]" "-$user_local_flags"])
		} then {
			set cmd_allowed 1
		} else {
			set cmd_allowed 0
		}
		if { $cmd_allowed } {
			if { ![::tcl::info::exists help_list] } {
				lappend help_list "\037Commandes de l'Interface MegaHAL\037 :"
			} elseif { $help_list ne "" } {
				lappend help_list " \00307|\003 "
			}
			switch -- $command {
				"masterswitch" { lappend help_list "\002.[set ::megahal_interface::masterswitch_cmd]\002\ \00314<\003on\00314/\003off\00314>\003 : active/désactive l'I.A. sur le chan en cours" }
				"learnstate" { lappend help_list "\002.[set ::megahal_interface::learnstate_cmd]\002 \00314<\003on\00314/\003off\00314>\003 : active/désactive l'apprentissage sur le chan en cours" }
				"respondstate" { lappend help_list "\002.[set ::megahal_interface::respondstate_cmd]\002 \00314<\003on\00314/\003off\00314>\003 : active/désactive la réponse sur détection de mots clés sur le chan en cours" }
				"chatterstate" { lappend help_list "\002.[set ::megahal_interface::chatterstate_cmd]\002 \00314<\003on\00314/\003off\00314>\003 : active/désactive la libre expression sur le chan en cours" }
				"replyrate" { lappend help_list "\002.[set ::megahal_interface::replyrate_cmd]\002 \00314\[\003taux de réponse\00314\]\003 : interrogation/réglage du taux de réponse général sur le chan en cours" }
				"keyreplyrate" { lappend help_list "\002.[set ::megahal_interface::keyreplyrate_cmd]\002 \00314\[\003taux de réponse\00314\]\003 : interrogation/réglage du taux de réponse en cas d'utilisation de mot clé sur le chan en cours" }
				"forget" { lappend help_list "\002.[set ::megahal_interface::forget_cmd]\002 \00314<\003phrase\00314>\003 : force l'I.A. à oublier une phrase" }
				"forgetword" { lappend help_list "\002.[set ::megahal_interface::forgetword_cmd]\002 \00314<\003mot\00314>\003 : force l'I.A. à oublier toutes les occurrences d'un mot (toutes les phrases contenant ce mot seront également oubliées)" }
				"seekstatement" { lappend help_list "\002.[set ::megahal_interface::seekstatement_cmd]\002 \00314<\003phrase\00314>\003 : vérifie si l'I.A. connait une phrase donnée" }
				"countword" { lappend help_list "\002.[set ::megahal_interface::countword_cmd]\002 \00314<\003mot\00314>\003 : vérifie si l'I.A. connait un mot donné et en compte toutes les occurrences." }
				"learnfile" { lappend help_list "\002.[set ::megahal_interface::learnfile_cmd]\002 \00314<\003chemin/fichier\00314>\003 : apprend le contenu d'un fichier à l'I.A." }
				"savebrain" { lappend help_list "\002.[set ::megahal_interface::savebrain_cmd]\002 : sauvegarde l'I.A." }
				"reloadbrain" { lappend help_list "\002.[set ::megahal_interface::reloadbrain_cmd]\002 : recharge l'I.A." }
				"reloadphrases" { lappend help_list "\002.[set ::megahal_interface::reloadphrases_cmd]\002 : recharge les phrases" }
				"trimbrain" { lappend help_list "\002.[set ::megahal_interface::trimbrain_cmd]\002 \00314\[\003nombre de nodes\00314\]\003 : élague l'I.A.; si le nombre de nodes n'est pas spécifié, utilise la valeur de \$::maxsize" }
				"lobotomy" { lappend help_list "\002.[set ::megahal_interface::lobotomy_cmd]\002 : effectue un lavage de cerveau." }
				"restorebrain" { lappend help_list "\002.[set ::megahal_interface::restorebrain_cmd]\002 : recharge un backup de l'I.A. (après un $::megahal_interface::lobotomy_cmd)" }
				"chanstatus" { lappend help_list "\002.[set ::megahal_interface::chanstatus_cmd]\002 : affiche le statut de l'I.A." } 
				"braininfo" { lappend help_list "\002.[set ::megahal_interface::braininfo_cmd]\002 : affiche des informations sur l'I.A." }
				"memusage" { lappend help_list "\002.[set ::megahal_interface::memusage_cmd]\002 : affiche une estimation de la quantité de mémoire utilisée par l'I.A." }
				"treesize" { lappend help_list "\002.[set ::megahal_interface::treesize_cmd]\002 : affiche des statistiques sur une branche ou une sous-branche" }
				"viewbranch" { lappend help_list "\002.[set ::megahal_interface::viewbranch_cmd]\002 : affiche le contenu d'une branche ou d'une sous-branche" }
				"make_words" { lappend help_list "\002.[set ::megahal_interface::make_words_cmd]\002 : retourne une phrase spécifiée, telle qu'elle sera mémorisée par l'I.A., en mettant en évidence les caractères \"glue\" servant à empêcher la dissociation de ce qui les entoure." }
				"debug_output" { lappend help_list "\002.[set ::megahal_interface::debug_output_cmd]\002 : soumet une phrase à make_words, puis a make_output dans le but de voir l'impact du module MegaHAL sur la construction de la phrase s'il essayait de la restituer" }
				"getwordsymbol" { lappend help_list "\002.[set ::megahal_interface::getwordsymbol_cmd]\002 : retourne l'index (numérique) d'un mot, qui pourra ensuite être utilisé avec .viewbranch pour voir les associations liées à ce mot" }
				"moulinex_in" { lappend help_list "\002.[set ::megahal_interface::moulinex_in_cmd]\002 : soumet une phrase au traitement par la moulinette entrante de l'Interface MegaHAL, afin de voir de quelle façon elle serait modifiée lors de l'apprentissage" }
				"moulinex_out" { lappend help_list "\002.[set ::megahal_interface::moulinex_out_cmd]\002 : soumet une phrase au traitement par la moulinette sortante de l'Interface MegaHAL, afin de voir de quelle façon elle serait modifiée si le bot s'en resservait" }
				"megaver" { lappend help_list "\002.[set ::megahal_interface::megaver_cmd]\002 : affiche la version du module et de l'interface" }
				"force_L_R" { lappend help_list "\002[set ::megahal_interface::force_L_R_cmd]\002\00314<\003phrase\00314>\003 : force MegaHAL à apprendre + répondre" }
				"force_noL_R" { lappend help_list "\002[set ::megahal_interface::force_noL_R_cmd]\002\00314<\003phrase\00314>\003 : force MegaHAL à ne pas apprendre + répondre" }
				"force_L_noR" { lappend help_list "\002[set ::megahal_interface::force_L_noR_cmd]\002\00314<\003phrase\00314>\003 : force MegaHAL à apprendre + ne pas répondre" }
				"force_noL_noR" { lappend help_list "\002[set ::megahal_interface::force_noL_noR_cmd]\002\00314<\003phrase\00314>\003 : force MegaHAL à ne pas apprendre + ne pas répondre" }
			}
			if { [::tcl::string::length [set help_list [join $help_list]]] > 275 } {
				if { $is_dcc } {
					::megahal_interface::add_to_long_message_queue $nick $idx - $help_list
				} else {
					::megahal_interface::add_to_long_message_queue $nick - NOTICE $help_list
				}
				set help_list ""
			}
		}
	}
	if { $help_list ne "" } {
		if { $is_dcc } {
			::megahal_interface::add_to_long_message_queue $nick $idx - $help_list
		} else {
			::megahal_interface::add_to_long_message_queue $nick - NOTICE $help_list
		}
	}
}

 ###############################################################################
### Ajout d'une ligne à la file d'attente non-prioritaire dédiée à l'affichage
### de l'aide.
 ###############################################################################
proc ::megahal_interface::add_to_long_message_queue {nick idx mode data} {
	lappend ::megahal_interface::long_message_queue [list $nick $idx $mode $data]
	if { !$::megahal_interface::long_message_queue_running } {
		set ::megahal_interface::long_message_queue_running 1
		::megahal_interface::process_long_message_queue
	}
}

 ###############################################################################
### Traitement de la file d'attente non-prioritaire dédiée à l'affichage de
### l'aide.
 ###############################################################################
proc ::megahal_interface::process_long_message_queue {} {
	# Si la file d'attente "help" n'est pas vide, on reporte à plus tard.
	if { [queuesize help] > 0	} {
		utimer 2 ::megahal_interface::process_long_message_queue
		return
	} else {
		lassign [lindex $::megahal_interface::long_message_queue 0] nick idx mode data
		if { $mode eq "NOTICE" } {
			::megahal_interface::display_output help NOTICE $nick $data
		} else {
			::megahal_interface::display_output dcc - $idx $data
		}
		# On élimine le 1er message de la file d'attente car il a été traité.
		set ::megahal_interface::long_message_queue [lreplace $::megahal_interface::long_message_queue 0 0]
		# Si la file d'attente est vide, on arrête.
		if { ![llength $::megahal_interface::long_message_queue] } {
			set ::megahal_interface::long_message_queue_running 0
			return
		} else {
			after 0 ::megahal_interface::process_long_message_queue
		}
	}
}

 ###############################################################################
### Gestion du flag +/-megahal
 ###############################################################################
proc ::megahal_interface::pub_masterswitch {nick host hand chan arg} {
	if {
		([llength $arg] != 1)
		|| (($arg ne "on")
		&& ($arg ne "off"))
	} then {
		::megahal_interface::display_output help PRIVMSG $chan "\037Syntaxe\037 : \002$::megahal_interface::masterswitch_cmd\002 \00314<\003on\00314/\003off\00314>\003 \00307|\003 Active/désactive l'I.A. sur $chan."
		return
	} elseif { $arg eq "on" } {
		if { [channel get $chan megahal] == 0 } {
			channel set $chan +megahal
			::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}L'I.A. est maintenant activée sur $chan."
		} else {
			::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}L'I.A. est déjà activée sur $chan."
		}
	} elseif { $arg eq "off" } {
		if { [channel get $chan megahal] == 1 } {
			channel set $chan -megahal
			::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}L'I.A. est maintenant désactivée sur $chan."
		} else {
			::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}L'I.A. est déjà désactivée sur $chan."
		}
	}
}

 ###############################################################################
### Gestion du flag +/-megahal_learn
 ###############################################################################
proc ::megahal_interface::pub_learnstate {nick host hand chan arg} {
	if { ![channel get $chan megahal] } {
		return
	} else {
		if {
			([llength $arg] != 1)
			|| ($arg ni {on off})
		} then {
			::megahal_interface::display_output help PRIVMSG $chan "\037Syntaxe\037 : \002$::megahal_interface::learnstate_cmd\002 \00314<\003on\00314/\003off\00314>\003 \00307|\003 Active/désactive l'apprentissage sur $chan."
			return
		} elseif { $arg eq "on" } {
			if { [channel get $chan megahal_learn] == 0 } {
				channel set $chan +megahal_learn
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}L'apprentissage est maintenant activé sur $chan (\003\003${::megahal_interface::secondary_color}[set ::megahal_interface::learnrate]%\003\003${::megahal_interface::main_color} de chances)."
			} else {
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}L'apprentissage est déjà activé sur $chan (\003\003${::megahal_interface::secondary_color}[set ::megahal_interface::learnrate]%\003\003${::megahal_interface::main_color} de chances)."
			}
		} elseif { $arg eq "off" } {
			if { [channel get $chan megahal_learn] == 1 } {
				channel set $chan -megahal_learn
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}L'apprentissage est maintenant désactivé sur $chan."
			} else {
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}L'apprentissage est déjà désactivé sur $chan."
			}
		}
	}
}

 ###############################################################################
### Gestion du flag +/-megahal_respond
 ###############################################################################
proc ::megahal_interface::pub_respondstate {nick host hand chan arg} {
	if { ![channel get $chan megahal] } {
		return
	} else {
		if {
			([llength $arg] != 1)
			|| ($arg ni {on off})
		} then {
			::megahal_interface::display_output help PRIVMSG $chan "\037Syntaxe\037 : \002$::megahal_interface::respondstate_cmd\002 \00314<\003on\00314/\003off\00314>\003 \00307|\003 Active/désactive la réponse sur détection de mots clés sur $chan."
			return
		} elseif { $arg eq "on" } {
			if { [channel get $chan megahal_respond] == 0 } {
				channel set $chan +megahal_respond
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}La réponse sur détection de mots clés est maintenant activée sur $chan (\003\003${::megahal_interface::secondary_color}[set ::megahal_interface::keyreplyrate]%\003\003${::megahal_interface::main_color} de chances)."
			} else {
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}La réponse sur détection de mots clés est déjà activée sur $chan (\003\003${::megahal_interface::secondary_color}[set ::megahal_interface::keyreplyrate]%\003\003${::megahal_interface::main_color} de chances)."
			}
		} elseif { $arg eq "off" } {
			if { [channel get $chan megahal_respond] == 1 } {
				channel set $chan -megahal_respond
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}La réponse sur détection de mots clés est maintenant désactivée sur $chan."
			} else {
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}La réponse sur détection de mots clés est déjà désactivée sur $chan."
			}
		}
	}
}

 ###############################################################################
### Gestion du flag +/-megahal_chatter
 ###############################################################################
proc ::megahal_interface::pub_chatterstate {nick host hand chan arg} {
	if { ![channel get $chan megahal] } {
		return
	} else {
		if {
			([llength $arg] != 1)
			|| ($arg ni {on off})
		} then {
			::megahal_interface::display_output help PRIVMSG $chan "\037Syntaxe\037 : \002$::megahal_interface::chatterstate_cmd\002 \00314<\003on\00314/\003off\00314>\003 \00307|\003 Active/désactive la libre expression sur $chan."
			return
		} elseif { $arg eq "on" } {
			if { [channel get $chan megahal_chatter] == 0 } {
				channel set $chan +megahal_chatter
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}La libre expression est maintenant activée sur $chan (\003\003${::megahal_interface::secondary_color}[set ::megahal_interface::replyrate]%\003\003${::megahal_interface::main_color} de chances)."
			} else {
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}La libre expression est déjà activée sur $chan (\003\003${::megahal_interface::secondary_color}[set ::megahal_interface::replyrate]%\003\003${::megahal_interface::main_color} de chances)."
			}
		} elseif { $arg eq "off" } {
			if { [channel get $chan megahal_chatter] == 1 } {
				channel set $chan -megahal_chatter
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}La libre expression est maintenant désactivée sur $chan."
			} else {
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}La libre expression est déjà désactivée sur $chan."
			}
		}
	}
}

 ###############################################################################
### Interrogation / réglage du taux de réponse général
 ###############################################################################
proc ::megahal_interface::pub_replyrate {nick host hand chan arg} {
	if { ![channel get $chan megahal] } {
		return
	} else {
	 if { $arg == "" } {
 		::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}Taux de réponses actuellement défini à \003\003${::megahal_interface::secondary_color}[set ::megahal_interface::replyrate]%"
 	} else {
		 set ::megahal_interface::replyrate $arg
		 ::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}Taux de réponses défini à \003\003${::megahal_interface::secondary_color}[set ::megahal_interface::replyrate]%"
	 }
	}
}

 ###############################################################################
### Interrogation / réglage du taux de réponse en cas d'utilisation de mot clé
 ###############################################################################
proc ::megahal_interface::pub_keyreplyrate {nick host hand chan arg} {
	if { ![channel get $chan megahal] } {
		return
	} else {
	 if { $arg == "" } {
 		::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}Taux de réponses si mot clé détecté actuellement défini à \003\003${::megahal_interface::secondary_color}[set ::megahal_interface::keyreplyrate]%"
 	} else {
		 variable keyreplyrate $arg
		 ::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}Taux de réponses si mot clé détecté défini à \003\003${::megahal_interface::secondary_color}[set ::megahal_interface::keyreplyrate]%"
	 }
	}
}

 ###############################################################################
### Elagage/sauvegarde automatique de la personnalité
 ###############################################################################
proc ::megahal_interface::auto_savebrain {min hour day month year} {
	trimbrain $::maxsize
	if { $::megahal_interface::verbose_automatisms } {
		::megahal_interface::display_output log - - "\00314\[$::megahal_interface::scriptname\]\003 Personnalité élaguée."
	}
	savebrain
	if { $::megahal_interface::verbose_automatisms } {
		::megahal_interface::display_output log - - "\00314\[$::megahal_interface::scriptname\]\003 Personnalité sauvegardée."
	}
}
proc ::megahal_interface::on_event_savebrain {type} {
	trimbrain $::maxsize
	::megahal_interface::display_output log - - "\00314\[$::megahal_interface::scriptname\]\003 Personnalité élaguée."
	savebrain
	::megahal_interface::display_output log - - "\00314\[$::megahal_interface::scriptname\]\003 Personnalité sauvegardée."
	if {
		($type eq "prerestart")
		|| ($type eq "prerehash")
	} then {
		::megahal_interface::uninstall
	}
}

 ###############################################################################
### Sauvegarde manuelle de la personnalité
 ###############################################################################
proc ::megahal_interface::pub_savebrain {nick host hand chan arg} {
	if { ![channel get $chan megahal] } {
		return
	} else {
		savebrain
		::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}Personnalité sauvegardée."
	}
}
proc ::megahal_interface::dcc_savebrain {hand idx arg} {
	savebrain
	::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}Personnalité sauvegardée."
}

 ###############################################################################
### Re-lecture de la personnalité à partir du fichier brain
 ###############################################################################
proc ::megahal_interface::pub_reloadbrain {nick host hand chan arg} {
	if { ![channel get $chan megahal] } {
		return
	} else {
		reloadbrain
		::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}Personnalité rechargée."
	}
}
proc ::megahal_interface::dcc_reloadbrain {hand idx arg} {
	reloadbrain
	::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}Personnalité rechargée."
}

 ###############################################################################
### Re-lecture des phrases (fichier .phr)
 ###############################################################################
proc ::megahal_interface::pub_reloadphrases {nick host hand chan arg} {
	if { ![channel get $chan megahal] } {
		return
	} else {
		reloadphrases
		::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}Phrases rechargées."
	}
}
proc ::megahal_interface::dcc_reloadphrases {hand idx arg} {
	reloadphrases
	::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}Phrases rechargées."
}

 ###############################################################################
### Elagage manuel du cerveau
 ###############################################################################
proc ::megahal_interface::pub_trimbrain {nick host hand chan arg} {
	::megahal_interface::trimbrain_proc $nick $host $hand $chan 0 - $arg
}
proc ::megahal_interface::dcc_trimbrain {hand idx arg} {
	::megahal_interface::trimbrain_proc [set nick [hand2nick $hand]] [getchanhost $nick] $hand - 1 $idx $arg
}
proc ::megahal_interface::trimbrain_proc {nick host hand chan is_dcc idx arg} {
	if {
		(!$is_dcc)
		&& (![channel get $chan megahal])
	} then {
		return
	}
	set arg [lindex $arg 0]
	if {
		($arg == "")
		|| !([::tcl::string::is digit $arg])
	} then {
		set arg $::maxsize
	}
	trimbrain $arg
	set message "\003${::megahal_interface::main_color}Personnalité élaguée à\003 \003${::megahal_interface::secondary_color}[set arg]\003 \003${::megahal_interface::main_color}noeuds d'association."
	if { $is_dcc } {
		::megahal_interface::display_output dcc - $idx $message
	} else {
		::megahal_interface::display_output help PRIVMSG $chan "$message"
	}
}

 ###############################################################################
### Création d'un backup puis effacement complet de la personnalité
 ###############################################################################
proc ::megahal_interface::pub_lobotomy {nick host hand chan arg} {
	::megahal_interface::lobotomy $nick $host $hand $chan 0 - $arg
}
proc ::megahal_interface::dcc_lobotomy {hand idx arg} {
	::megahal_interface::lobotomy [set nick [hand2nick $hand]] [getchanhost $nick] $hand - 1 $idx $arg
}
proc ::megahal_interface::lobotomy {nick host hand chan is_dcc idx arg} {
	if {
		(!$is_dcc)
		&& (![channel get $chan megahal])
	} then {
		return
	}
	savebrain
	if { [file exists megahal.brn] } {
		if { [file exists megahal.brn.old] } {
			file delete -force megahal.brn.old
		}
		file rename -force megahal.brn megahal.brn.old
	}
	if { [file exists megahal.dic] } {
		if { [file exists megahal.dic.old] } {
			file delete -force megahal.dic.old
		}
		file rename -force megahal.dic megahal.dic.old
	}
	if { [file exists megahal.phr] } {
		if { [file exists megahal.phr.old] } {
			file delete -force megahal.phr.old
		}
		file rename -force megahal.phr megahal.phr.old
	}
	reloadbrain
	savebrain
	set message "\003${::megahal_interface::main_color}Lobotomie effectuée. Création d'une nouvelle personnalité..."
	if { $is_dcc } {
		::megahal_interface::display_output dcc - $idx $message
	} else {
		::megahal_interface::display_output help PRIVMSG $chan "$message"
	}
}

 ###############################################################################
### Restauration d'un backup de la personnalité après une lobotomie
 ###############################################################################
proc ::megahal_interface::pub_restorebrain {nick host hand chan arg} {
	::megahal_interface::restorebrain $nick $host $hand $chan 0 - $arg
}
proc ::megahal_interface::dcc_restorebrain {hand idx arg} {
	::megahal_interface::restorebrain [set nick [hand2nick $hand]] [getchanhost $nick] $hand - 1 $idx $arg
}
proc ::megahal_interface::restorebrain {nick host hand chan is_dcc idx arg} {
	if {
		(!$is_dcc)
		&& (![channel get $chan megahal])
	} then {
		return
	}
  if {
  	([file exists megahal.brn.old])
  	&& ([file exists megahal.dic.old])
  	&& ([file exists megahal.phr.old])
  } then {
    file delete -force megahal.brn
    file copy -force megahal.brn.old megahal.brn
    file delete -force megahal.dic
    file copy -force megahal.dic.old megahal.dic
    file delete -force megahal.phr
    file copy -force megahal.phr.old megahal.phr
    reloadbrain
		set message "\003${::megahal_interface::main_color}L'ancienne personnalité a été restaurée."
		if { $is_dcc } {
			::megahal_interface::display_output dcc - $idx $message
		} else {
    	::megahal_interface::display_output help PRIVMSG $chan "$message"
    }
  } else {
		set message "\003${::megahal_interface::main_color}L'ancienne personnalité n'a pas été trouvée ou est incomplète."
		if { $is_dcc } {
			::megahal_interface::display_output dcc - $idx $message
		} else {
	    ::megahal_interface::display_output help PRIVMSG $chan "$message"
		}
  }
}

 ###############################################################################
### Oublier une phrase
 ###############################################################################
proc ::megahal_interface::pub_forget {nick host hand chan arg} {
	if { ![channel get $chan megahal] } {
		return
	} else {
		if { $arg eq "" } {
			::megahal_interface::display_output help PRIVMSG $chan "\037Syntaxe\037 : \002${::megahal_interface::pub_command_prefix}$::megahal_interface::forget_cmd\002 \00314<\003phrase\00314>\003 \00307|\003 Force l'I.A. à oublier une phrase."
		} else {
			if { $::megahal_interface::substitute_all_nicks } {
				set arg [::megahal_interface::substitute_nicks "sentence" $chan $arg]
			}
			set arg [::tcl::string::map {\031 \047} $arg]
			set result [::megahal_search $arg 1]
			if { $result eq "" } {
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}Je ne connais pas de phrase ressemblant à ça."
			} else {
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}J'ai trouvé\003 \003${::megahal_interface::secondary_color}[set result]\003\003${::megahal_interface::main_color}, je vais tenter de l'oublier."
			}
		}
	}
}
proc ::megahal_interface::dcc_forget {hand idx arg} {
	if { $arg eq "" } {
		::megahal_interface::display_output dcc - $idx "\037Syntaxe\037 : \002.$::megahal_interface::forget_cmd\002 \00314<\003phrase\00314>\003 \00307|\003 Force l'I.A. à oublier une phrase."
	} else {
		set arg [::tcl::string::map {\031 \047} $arg]
		set result [::megahal_search $arg 1]
		if { $result eq "" } {
			::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}Je ne connais pas de phrase ressemblant à ça."
		} else {
			::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}J'ai trouvé\003 \003${::megahal_interface::secondary_color}[set result]\003\003${::megahal_interface::main_color}, je vais tenter de l'oublier."
		}
	}
}

 ###############################################################################
### Oublier toutes les occurrences d'un mot
 ###############################################################################
proc ::megahal_interface::pub_forgetword {nick host hand chan arg} {
	if { ![channel get $chan megahal] } {
		return
	} else {
		if { [set arg [lindex [split $arg] 0]] eq "" } {
			::megahal_interface::display_output help PRIVMSG $chan "\037Syntaxe\037 : \002${::megahal_interface::pub_command_prefix}$::megahal_interface::forgetword_cmd\002 \00314<\003mot\00314>\003 \00307|\003 Force l'I.A. à oublier toutes les occurrences d'un mot. Veuillez noter que toutes les phrases contenant ce mot seront également oubliées."
		} else {
			if { $::megahal_interface::substitute_all_nicks } {
				set arg [::megahal_interface::substitute_nicks "word" $chan $arg]
			}
			set arg [::tcl::string::map {\031 \047} $arg]
			set result [::megahal_searchword $arg 1]
			if { !$result } {
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}Je ne connais pas ce mot."
			} else {
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}J'ai trouvé\003 \003${::megahal_interface::secondary_color}[set arg]\003 \003${::megahal_interface::main_color}dans\003 \003${::megahal_interface::secondary_color}[set result]\003 \003${::megahal_interface::main_color}[::megahal_interface::plural $result "association" "associations"]. Toutes les occurrences ont été oubliées."
			}
		}
	}
}
proc ::megahal_interface::dcc_forgetword {hand idx arg} {
	if { [set arg [lindex [split $arg] 0]] eq "" } {
		::megahal_interface::display_output dcc - $idx "\037Syntaxe\037 : \002.$::megahal_interface::forgetword_cmd\002 \00314<\003mot\00314>\003 \00307|\003 Force l'I.A. à oublier toutes les occurrences d'un mot. Veuillez noter que toutes les phrases contenant ce mot seront également oubliées."
	} else {
		set arg [::tcl::string::map {\031 \047} $arg]
		set result [::megahal_searchword $arg 1]
		if { !$result } {
			::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}Je ne connais pas ce mot."
		} else {
			::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}J'ai trouvé\003 \003${::megahal_interface::secondary_color}[set arg]\003 \003${::megahal_interface::main_color}dans\003 \003${::megahal_interface::secondary_color}[set result]\003 \003${::megahal_interface::main_color}[::megahal_interface::plural $result "association" "associations"]. Toutes les occurrences ont été oubliées."
		}
	}
}

 ###############################################################################
### Vérifier si l'I.A. connaît une phrase donnée
 ###############################################################################
proc ::megahal_interface::pub_seekstatement {nick host hand chan arg} {
	if { ![channel get $chan megahal] } {
		return
	} else {
		if { $arg eq "" } {
			::megahal_interface::display_output help PRIVMSG $chan "\037Syntaxe\037 : \002${::megahal_interface::pub_command_prefix}$::megahal_interface::seekstatement_cmd\002 \00314<\003phrase\00314>\003 \00307|\003 Recherche dans le cerveau de l'I.A. si une phrase donnée est connue."
		} else {
			if { $::megahal_interface::substitute_all_nicks } {
				set arg [::megahal_interface::substitute_nicks "sentence" $chan $arg]
			}
			set arg [::tcl::string::map {\031 \047} $arg]
			set result [::megahal_search $arg 0]
			if { $result eq "" } {
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}Je ne connais pas de phrase ressemblant à ça."
			} else {
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}J'ai trouvé\003 \003${::megahal_interface::secondary_color}[set result]"
			}
		}
	}
}
proc ::megahal_interface::dcc_seekstatement {hand idx arg} {
	if { $arg eq "" } {
		::megahal_interface::display_output dcc - $idx "\037Syntaxe\037 : \002.$::megahal_interface::seekstatement_cmd\002 \00314<\003phrase\00314>\003 \00307|\003 Recherche dans le cerveau de l'I.A. si une phrase donnée est connue."
	} else {
		set arg [::tcl::string::map {\031 \047} $arg]
		set result [::megahal_search $arg 0]
		if { $result eq "" } {
			::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}Je ne connais pas de phrase ressemblant à ça."
		} else {
			::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}J'ai trouvé\003 \003${::megahal_interface::secondary_color}[set result]"
		}
	}
}

 ###############################################################################
### Compter le nombre d'associations pour un mot donné
 ###############################################################################
proc ::megahal_interface::pub_countword {nick host hand chan arg} {
	if { ![channel get $chan megahal] } {
		return
	} else {
		if { $arg eq "" } {
			::megahal_interface::display_output help PRIVMSG $chan "\037Syntaxe\037 : \002${::megahal_interface::pub_command_prefix}$::megahal_interface::countword_cmd\002 \00314<\003mot\00314>\003 \00307|\003 Compte le nombre d'associations pour un mot donné."
		} else {
			if { $::megahal_interface::substitute_all_nicks } {
				set arg [::megahal_interface::substitute_nicks "word" $chan $arg]
			}
			set arg [::tcl::string::map {\031 \047} $arg]
			set result [::megahal_searchword $arg 0]
			if { !$result } {
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}Je ne connais pas ce mot."
			} else {
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}J'ai trouvé\003 \003${::megahal_interface::secondary_color}[set arg]\003 \003${::megahal_interface::main_color}dans\003 \003${::megahal_interface::secondary_color}[set result]\003 \003${::megahal_interface::main_color}[::megahal_interface::plural $result "association" "associations"]."
			}
		}
	}
}
proc ::megahal_interface::dcc_countword {hand idx arg} {
	if { $arg eq "" } {
		::megahal_interface::display_output dcc - $idx "\037Syntaxe\037 : \002.$::megahal_interface::countword_cmd\002 \00314<\003mot\00314>\003 \00307|\003 Compte le nombre d'associations pour un mot donné."
	} else {
		set arg [::tcl::string::map {\031 \047} $arg]
		set result [::megahal_searchword $arg 0]
		if { !$result } {
			::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}Je ne connais pas ce mot."
		} else {
			::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}J'ai trouvé\003 \003${::megahal_interface::secondary_color}[set arg]\003 \003${::megahal_interface::main_color}dans\003 \003${::megahal_interface::secondary_color}[set result]\003 \003${::megahal_interface::main_color}[::megahal_interface::plural $result "association" "associations"]."
		}
	}
}

 ###############################################################################
### Apprend le contenu d'un fichier à l'I.A.
 ###############################################################################
proc ::megahal_interface::pub_learnfile {nick host hand chan arg} {
	::megahal_interface::learnfile_proc $nick $host $hand $chan 0 - $arg
}
proc ::megahal_interface::dcc_learnfile {hand idx arg} {
	::megahal_interface::learnfile_proc [set nick [hand2nick $hand]] [getchanhost $nick] $hand - 1 $idx $arg
}
proc ::megahal_interface::learnfile_proc {nick host hand chan is_dcc idx arg} {
	if {
		(!$is_dcc)
		&& (![channel get $chan megahal])
	} then {
		return
	}
	if { $arg eq "" } {
		if { $is_dcc } {
			::megahal_interface::display_output dcc - $idx "\037Syntaxe\037 : \002.$::megahal_interface::learnfile_cmd\002 \00314<\003nom et emplacement du fichier\00314>\003 \00307|\003 Apprend le contenu d'un fichier à l'I.A."
		} else {
			::megahal_interface::display_output help PRIVMSG $chan "\037Syntaxe\037 : \002${::megahal_interface::pub_command_prefix}$::megahal_interface::learnfile_cmd\002 \00314<\003nom et emplacement du fichier\00314>\003 \00307|\003 Apprend le contenu d'un fichier à l'I.A."
		}
		return
	}
	if { [file readable $arg] } {
		learnfile $arg
		set message "\003${::megahal_interface::main_color}Le contenu du fichier\003 \003${::megahal_interface::secondary_color}[set arg]\003 \003${::megahal_interface::main_color}a été appris."
		if { $is_dcc } {
			::megahal_interface::display_output dcc - $idx $message
		} else {
			::megahal_interface::display_output help PRIVMSG $chan "$message"
		}
	} else {
		set message "\003${::megahal_interface::main_color}Le fichier\003 \003${::megahal_interface::secondary_color}[set arg]\003 \003${::megahal_interface::main_color}n'existe pas ou je n'ai pas les autorisations nécessaires pour y accéder."
		if { $is_dcc } {
			::megahal_interface::display_output dcc - $idx $message
		} else {
			::megahal_interface::display_output help PRIVMSG $chan "$message"
		}
	}
}

 ###############################################################################
### Affiche des informations sur l'I.A.
 ###############################################################################
proc ::megahal_interface::pub_braininfo {nick host hand chan arg} {
	if { ![channel get $chan megahal] } {
		return
	} else {
		set for [treesize -1 0]
		set back [treesize -1 1]
		set output "\003${::megahal_interface::main_color}Je connais actuellement\003 \003${::megahal_interface::secondary_color}[lindex $for 0]\003 \003${::megahal_interface::main_color}mots organisés en\003 \003${::megahal_interface::secondary_color}[expr {[lindex $for 1]+[lindex $back 1]}]\003 \003${::megahal_interface::main_color}noeuds d'association."
		if {[file exists megahal.brn.old]} {
			append output " \003${::megahal_interface::main_color}Mon apprentissage a débuté le\003 \003${::megahal_interface::secondary_color}[strftime "%d/%m/%Y\003 \003${::megahal_interface::main_color}à\003 \003${::megahal_interface::secondary_color}%Hh%M" [file mtime megahal.brn.old]]\003\003${::megahal_interface::main_color}."
		}
		::megahal_interface::display_output help PRIVMSG $chan $output
		if { ![channel get $chan megahal_chatter] } {
	 		set output "\003${::megahal_interface::main_color}Sur \003\003${::megahal_interface::secondary_color}$chan\003\003${::megahal_interface::main_color}, ma libre expression est désactivée, "
		} else {
			set output "\003${::megahal_interface::main_color}Sur \003\003${::megahal_interface::secondary_color}$chan\003\003${::megahal_interface::main_color}, j'ai\003 \003${::megahal_interface::secondary_color}[set ::megahal_interface::replyrate]%\003 \003${::megahal_interface::main_color}de chances de répondre à tout, "
		}
		if { ![channel get $chan megahal_respond] } {
			append output "je ne réagis pas lorsqu'on parle de moi, "
		} else {
			append output "j'ai \003\003${::megahal_interface::secondary_color}[set ::megahal_interface::keyreplyrate]%\003 \003${::megahal_interface::main_color}de chances de répondre quand on parle de moi, "
		}
		if { ![channel get $chan megahal_learn] } {
			append output "et je n'apprends pas."
		} else {
			append output "et j'ai\003 \003${::megahal_interface::secondary_color}[set ::megahal_interface::learnrate]%\003 \003${::megahal_interface::main_color}de chances d'apprendre ce que vous dites si la phrase fait au moins\003 \003${::megahal_interface::secondary_color}[set ::megahal_interface::minlearnwords]\003 \003${::megahal_interface::main_color}mots"
			if { $::megahal_interface::maxlearnwords > 0 } {
				append output " et au plus\003 \003${::megahal_interface::secondary_color}[set ::megahal_interface::maxlearnwords]\003 \003${::megahal_interface::main_color}mots."
			} else {
				append output "."
			}
		}
		::megahal_interface::display_output help PRIVMSG $chan $output
		if {
			([channel get $chan megahal_chatter])
			|| ([channel get $chan megahal_respond])
		} then {
			::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}Les phrases que je construis ne dépassent jamais\003 \003${::megahal_interface::secondary_color}[set ::maxreplywords]\003 \003${::megahal_interface::main_color}mots, sont choisies dans un contexte d'une profondeur de\003 \003${::megahal_interface::secondary_color}[set ::mega_order]\003 \003${::megahal_interface::main_color}niveaux et l'improvisation est\003 \003${::megahal_interface::secondary_color}[if { $::surprise } { set dummy "activée" } { set dummy "désactivée" }]\003\003${::megahal_interface::main_color}."
		}
	}
}

 ###############################################################################
### Affiche le statut des flags sur le chan en cours
### (megahal megahal_learn megahal_chatter megahal_respond)
 ###############################################################################
proc ::megahal_interface::pub_chanstatus {nick host hand chan arg} {
	::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}Statut des flags sur le chan \002$chan\002 : \003\003${::megahal_interface::secondary_color}[::megahal_interface::flagstate [channel get $chan megahal]]megahal [::megahal_interface::flagstate [channel get $chan megahal_learn]]megahal_learn [::megahal_interface::flagstate [channel get $chan megahal_chatter]]megahal_chatter [::megahal_interface::flagstate [channel get $chan megahal_respond]]megahal_respond"
}
proc ::megahal_interface::flagstate {value} {
	if { !$value } {
		return "-"
	} else {
		return "+"
	}
}

 ###############################################################################
### Affiche une estimation de la quantité de mémoire utilisée par l'I.A.
 ###############################################################################
proc ::megahal_interface::pub_memusage {nick host hand chan arg} {
	::megahal_interface::memusage $nick $host $hand $chan 0 - $arg
}
proc ::megahal_interface::dcc_memusage {hand idx arg} {
	::megahal_interface::memusage [set nick [hand2nick $hand]] [getchanhost $nick] $hand - 1 $idx $arg
}
proc ::megahal_interface::memusage {nick host hand chan is_dcc idx arg} {
	if {
		(!$is_dcc)
		&& (![channel get $chan megahal])
	} then {
		return
	}
	set message "\003${::megahal_interface::main_color}Estimation de la quantité de mémoire utilisée par l'I.A. :\003 \003${::megahal_interface::secondary_color}[::megahal_interface::octet_formatting [::megahal_expmem]]\003\003${::megahal_interface::main_color}."
	if { $is_dcc } {
		::megahal_interface::display_output dcc - $idx $message
	} else {
		::megahal_interface::display_output help PRIVMSG $chan "$message"
	}
}

 ###############################################################################
### Affiche des statistiques sur une branche ou une sous-branche dans le cerveau
### de l'I.A. (nombre de branches (mots), nombre de noeuds d'association, nombre
### de branches au niveau supérieur/inférieur, compteur d'utilisation).
### Si un numéro de branche est spécifié, affiche une sous-branche des 2
### arborescences principales.
### Il est possible de spécifier si vous souhaitez la branche parente ou la
### branche fille.
 ###############################################################################
proc ::megahal_interface::pub_treesize {nick host hand chan arg} {
	if { ![channel get $chan megahal] } {
		return
	} else {
		if { $arg eq "" } {
			::megahal_interface::display_output help PRIVMSG $chan "\037Syntaxe\037 : \002${::megahal_interface::pub_command_prefix}$::megahal_interface::treesize_cmd\002 \00314<\003n° de branche\00314> \[\003parente/fille (1/0)\00314\]\003 \00307|\003 Affiche des statistiques sur une branche ou une sous-branche dans le cerveau de l'I.A. (nombre de branches (mots), nombre de noeuds d'association, nombre de branches au niveau supérieur/inférieur, compteur d'utilisation). Si un numéro de branche est spécifié, affiche une sous-branche des 2 arborescences principales."
		} else {
			::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}[::treesize $arg]"
		}
	}
}
proc ::megahal_interface::dcc_treesize {hand idx arg} {
	if { $arg eq "" } {
		::megahal_interface::display_output dcc - $idx "\037Syntaxe\037 : \002.[set ::megahal_interface::treesize_cmd]\002 \00314<\003n° de branche\00314> \[\003parente/fille (1/0)\00314\]\003 \00307|\003 Affiche des statistiques sur une branche ou une sous-branche dans le cerveau de l'I.A. (nombre de branches (mots), nombre de noeuds d'association, nombre de branches au niveau supérieur/inférieur, compteur d'utilisation). Si un numéro de branche est spécifié, affiche une sous-branche des 2 arborescences principales."
	} else {
		::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}[::treesize $arg]"
	}
}

 ###############################################################################
### Affiche le contenu d'une branche ou d'une sous-branche dans le cerveau de
### l'I.A.
 ###############################################################################
proc ::megahal_interface::pub_viewbranch {nick host hand chan arg} {
	if { ![channel get $chan megahal] } {
		return
	} else {
		if { $arg eq "" } {
			::megahal_interface::display_output help PRIVMSG $chan "\037Syntaxe\037 : \002${::megahal_interface::pub_command_prefix}$::megahal_interface::viewbranch_cmd\002 \00314<\003n° de branche\00314> \[\003parente/fille (1/0)\00314\]\003 \00307|\003 Affiche le contenu d'une branche ou d'une sous-branche dans le cerveau de l'I.A."
		} else {
			set output [split [::viewbranch $arg] "\n"]
			if { [::tcl::string::match "Branche *" [join $output]] } {
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}[join $output]"
			} else {
				if { [set num_elements [expr {[llength $output] - 1}]] > $::megahal_interface::pub_viewbranch_max } {
					::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}Cette branche comporte [set num_elements] [::megahal_interface::plural $num_elements "élément" "éléments"], mais l'affichage d'une branche sur un chan est limité à $::megahal_interface::pub_viewbranch_max [::megahal_interface::plural $::megahal_interface::pub_viewbranch_max "ligne" "lignes"]."
				} else {
					::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}[set num_elements] [::megahal_interface::plural $num_elements "élément" "éléments"] dans cette branche :"
					foreach element [split [::viewbranch $arg] "\n"] {
						if { $element ne "" } {
							::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}[set element]"
						}
					}
				}
			}
		}
	}
}
proc ::megahal_interface::dcc_viewbranch {hand idx arg} {
	if { $arg eq "" } {
		::megahal_interface::display_output dcc - $idx "\037Syntaxe\037 : \002$::megahal_interface::viewbranch_cmd\002 \00314<\003n° de branche\00314> \[\003parente/fille (1/0)\00314\]\003 \00307|\003 Affiche le contenu d'une branche ou d'une sous-branche dans le cerveau de l'I.A."
	} else {
		set output [split [::viewbranch $arg] "\n"]
		if { [::tcl::string::match "Branche *" [join $output]] } {
			::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}[join $output]"
		} else {
			::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}[set num_elements [expr {[llength $output] - 1}]] [::megahal_interface::plural $num_elements "élément" "éléments"] dans cette branche :"
			foreach element [split [::viewbranch $arg] "\n"] {
				if { $element ne "" } {
					::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}[set element]"
				}
			}
		}
	}
}

 ###############################################################################
### Retourne une phrase spécifiée, telle qu'elle sera mémorisée par l'I.A., en
### mettant en évidence les caractères "glue" servant à empêcher la
### dissociation de ce qui les entoure
 ###############################################################################
proc ::megahal_interface::pub_make_words {nick host hand chan arg} {
	if { ![channel get $chan megahal] } {
		return
	} else {
		if { $arg eq "" } {
			::megahal_interface::display_output help PRIVMSG $chan "\037Syntaxe\037 : \002${::megahal_interface::pub_command_prefix}$::megahal_interface::make_words_cmd\002 \00314<\003phrase\00314>\003 \00307|\003 retourne une phrase spécifiée, telle qu'elle sera mémorisée par l'I.A., en mettant en évidence les caractères \"glue\" servant à empêcher la dissociation de ce qui les entoure."
		} else {
			::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}[::tcl::string::map "\" \037\" \"\00307|\003\003${::megahal_interface::main_color}\"" [join [::megahal_make_words [::tcl::string::map {\031 \047} $arg]]]]"
		}
	}
}
proc ::megahal_interface::dcc_make_words {hand idx arg} {
	if { $arg eq "" } {
		::megahal_interface::display_output dcc - $idx "\037Syntaxe\037 : \002.$::megahal_interface::make_words_cmd\002 \00314<\003phrase\00314>\003 \00307|\003 retourne une liste des mots contenus dans la phrase spécifiée, telle qu'elle sera mémorisée par l'I.A."
	} else {
		::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}[::megahal_make_words [::tcl::string::map {\031 \047} $arg]]"
	}
}

 ###############################################################################
### Soumet une phrase à make_words, puis a make_output dans le but de voir
### l'impact du module MegaHAL sur la construction de la phrase s'il essayait
### de la restituer.
 ###############################################################################
proc ::megahal_interface::pub_debug_output {nick host hand chan arg} {
	if { ![channel get $chan megahal] } {
		return
	} else {
		if { $arg eq "" } {
			::megahal_interface::display_output help PRIVMSG $chan "\037Syntaxe\037 : \002${::megahal_interface::pub_command_prefix}$::megahal_interface::debug_output_cmd\002 \00314<\003phrase\00314>\003 \00307|\003 soumet une phrase à make_words, puis a make_output dans le but de voir l'impact du module MegaHAL sur la construction de la phrase s'il essayait de la restituer."
		} else {
			::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}[::megahal_debug_output [::tcl::string::map {\031 \047} $arg]]"
		}
	}
}
proc ::megahal_interface::dcc_debug_output {hand idx arg} {
	if { $arg eq "" } {
		::megahal_interface::display_output dcc - $idx "\037Syntaxe\037 : \002.$::megahal_interface::debug_output_cmd\002 \00314<\003phrase\00314>\003 \00307|\003 soumet une phrase à make_words, puis a make_output dans le but de voir l'impact du module MegaHAL sur la construction de la phrase s'il essayait de la restituer."
	} else {
		::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}[::megahal_debug_output [::tcl::string::map {\031 \047} $arg]]"
	}
}

 ###############################################################################
### Retourne l'index (numérique) d'un mot, qui pourra ensuite être utilisé avec
### .viewbranch pour voir les associations liées à ce mot.
 ###############################################################################
proc ::megahal_interface::pub_getwordsymbol {nick host hand chan arg} {
	if { ![channel get $chan megahal] } {
		return
	} else {
		if { $arg eq "" } {
			::megahal_interface::display_output help PRIVMSG $chan "\037Syntaxe\037 : \002${::megahal_interface::pub_command_prefix}$::megahal_interface::getwordsymbol_cmd\002 \00314<\003mot\00314>\003 \00307|\003 retourne l'index (numérique) d'un mot, qui pourra ensuite être utilisé avec .viewbranch pour voir les associations liées à ce mot."
		} else {
			::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}[::megahal_getwordsymbol [::tcl::string::map {\031 \047} $arg]]"
		}
	}
}
proc ::megahal_interface::dcc_getwordsymbol {hand idx arg} {
	if { $arg eq "" } {
		::megahal_interface::display_output dcc - $idx "\037Syntaxe\037 : \002.$::megahal_interface::getwordsymbol_cmd\002 \00314<\003mot\00314>\003 \00307|\003 retourne l'index (numérique) d'un mot, qui pourra ensuite être utilisé avec .viewbranch pour voir les associations liées à ce mot."
	} else {
		::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}[::megahal_getwordsymbol [::tcl::string::map {\031 \047} $arg]]"
	}
}

 ###############################################################################
### Soumet une phrase au traitement par la moulinette entrante de l'Interface
### MegaHAL, afin de voir de quelle façon elle serait modifiée lors de
### l'apprentissage.
 ###############################################################################
proc ::megahal_interface::pub_moulinex_in {nick host hand chan arg} {
	if { ![channel get $chan megahal] } {
		return
	} else {
		if { $arg eq "" } {
			::megahal_interface::display_output help PRIVMSG $chan "\037Syntaxe\037 : \002${::megahal_interface::pub_command_prefix}$::megahal_interface::moulinex_in_cmd\002 \00314<\003phrase\00314>\003 \00307|\003 soumet une phrase au traitement par la moulinette entrante de l'Interface MegaHAL, afin de voir de quelle façon elle serait modifiée lors de l'apprentissage."
		} else {
			::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}[::megahal_interface::moulinex_in learn $nick $chan [::tcl::string::map {\031 \047} $arg]]"
		}
	}
}
proc ::megahal_interface::dcc_moulinex_in {hand idx arg} {
	if { $arg eq "" } {
		::megahal_interface::display_output dcc - $idx "\037Syntaxe\037 : \002.$::megahal_interface::moulinex_in_cmd\002 \00314<\003phrase\00314>\003 \00307|\003 soumet une phrase au traitement par la moulinette entrante de l'Interface MegaHAL, afin de voir de quelle façon elle serait modifiée lors de l'apprentissage."
	} else {
		::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}[::megahal_interface::moulinex_in learn [hand2nick $hand] - [::tcl::string::map {\031 \047} $arg]]"
	}
}

 ###############################################################################
### Soumet une phrase au traitement par la moulinette sortante de l'Interface
### MegaHAL, afin de voir de quelle façon elle serait modifiée si le bot s'en
### resservait.
 ###############################################################################
proc ::megahal_interface::pub_moulinex_out {nick host hand chan arg} {
	if { ![channel get $chan megahal] } {
		return
	} else {
		if { $arg eq "" } {
			::megahal_interface::display_output help PRIVMSG $chan "\037Syntaxe\037 : \002${::megahal_interface::pub_command_prefix}$::megahal_interface::moulinex_out_cmd\002 \00314<\003phrase\00314>\003 \00307|\003 soumet une phrase au traitement par la moulinette sortante de l'Interface MegaHAL, afin de voir de quelle façon elle serait modifiée si le bot s'en resservait."
			return
		} else {
			::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}[::megahal_interface::moulinex_out $nick $hand $chan "@" [::tcl::string::map {\031 \047} $arg]]"
		}
	}
}
proc ::megahal_interface::dcc_moulinex_out {hand idx arg} {
	if { $arg eq "" } {
		::megahal_interface::display_output dcc - $idx "\037Syntaxe\037 : \002.$::megahal_interface::moulinex_out_cmd\002 \00314<\003phrase\00314>\003 \00307|\003 soumet une phrase au traitement par la moulinette sortante de l'Interface MegaHAL, afin de voir de quelle façon elle serait modifiée si le bot s'en resservait."
		return
	} else {
		::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}[::megahal_interface::moulinex_out [hand2nick $hand] $hand - "@" [::tcl::string::map {\031 \047} $arg]]"
	}
}

 ###############################################################################
### Affiche la version du module et de l'interface.
 ###############################################################################
proc ::megahal_interface::pub_megaver {nick host hand chan arg} {
	if { ![channel get $chan megahal] } {
		return
	} else {
		::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}module MegaHAL v3.5 par Zev ^Baron^ Toledano et Jason Hutchens - Artixed Edition\003 \003${::megahal_interface::secondary_color}|\003 \003${::megahal_interface::main_color}Interface MegaHAL v[set ::megahal_interface::version] ©2007-2016 Menz Agitat"
	}
}
proc ::megahal_interface::dcc_megaver {hand idx arg} {
	::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}module MegaHAL v3.5 par Zev ^Baron^ Toledano et Jason Hutchens - Artixed Edition\003 \003${::megahal_interface::secondary_color}|\003 \003${::megahal_interface::main_color}Interface MegaHAL v[set ::megahal_interface::version] ©2007-2016 Menz Agitat"
}

 ###############################################################################
### Accord au singulier ou au pluriel.
 ###############################################################################
proc ::megahal_interface::plural {value singular plural} {
	if {
		($value >= 2)
		|| ($value <= -2)
	} then {
		return $plural
	} else {
		return $singular
	}
}

 ###############################################################################
### Suppression espaces en double, espaces en début/fin de ligne, codes de
### couleur / gras / souligné / ...
 ###############################################################################
proc ::megahal_interface::strip_codes_trim_spaces {text} { 
	return [::tcl::string::trim [regsub -all {\s+} [::tcl::string::map {"\017" ""} [stripcodes abcgru $text]] " "]]
}

 ###############################################################################
### Neutralisation des caractères qui choquent Tcl.
 ###############################################################################
proc ::megahal_interface::neutralize_special_chars {data} {
	return [::tcl::string::map {"\[" "@1" "\]" "@2" "\\" "@3" "\|" "@4" "\{" "@5" "\}" "@6" "\^" "@7" "\$" "@8"} $data]
}

 ###############################################################################
### Restauration des caractères qui choquent Tcl.
 ###############################################################################
proc ::megahal_interface::restore_special_chars {data} {
	return [::tcl::string::map {"@1" "\[" "@2" "\]" "@3" "\\" "@4" "\|" "@5" "\{" "@6" "\}" "@7" "\^" "@8" "\$"} $data]
}

 ###############################################################################
### Conversion octets en Ko/Mo/Go/To/Po
 ###############################################################################
proc ::megahal_interface::octet_formatting {value} {
	if { $value < 1000 } {
		return "[set value] octets"
	}
	foreach unit {Ko Mo Go To Po} {
		set value [expr {$value / 1024.}]
		if { $value < 1000 } {
			return [format %1.2f $value]$unit
		}
	}
}

 ###############################################################################
### Mélange aléatoire des éléments d'une liste
 ###############################################################################
proc ::megahal_interface::randomize_list {data} {
	set list_length [llength $data]
	for { set counter 1 } { $counter <= $list_length } { incr counter } {
		set index [rand [expr {$list_length - $counter + 1}]]
		lappend randomized_list [lindex $data $index]
		set data [lreplace $data $index $index]
	}
	return $randomized_list
}

 ###############################################################################
### Contrôle du flood
### Le paramètre action peut valoir "check" ou "add_instance"
### (retourne 1 si flood détecté, 0 sinon)
 ###############################################################################
proc ::megahal_interface::flood {chan action} {
	variable instance
	set chan [::megahal_interface::neutralize_special_chars $chan]
	if { ![::tcl::info::exists instance($chan)] } {
		set instance($chan) 0
	}
	set max_instances [lindex $::megahal_interface::floodlimiter 0]
	set instance_length [expr {[lindex $::megahal_interface::floodlimiter 1] * 1000}]
	if { $action eq "check" } { 
		if { $instance($chan) >= $max_instances } {
			if {
				(($::megahal_interface::DEBUGMODE_chan eq "*")
				|| ($chan eq $::megahal_interface::DEBUGMODE_chan))
				&& ([lindex $::megahal_interface::DEBUGMODE 6])
			} then {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 flood détecté sur $chan -> instances \003\00307$::megahal_interface::instance($chan) \003\00314 >= \003\00307$::megahal_interface::floodlimiter\003"
			}
			return 1
		} else {
			return 0
		}
	} else {
		incr instance($chan)
		after $instance_length [list ::megahal_interface::antiflood_close_instance $chan]
		if {
			(($::megahal_interface::DEBUGMODE_chan eq "*")
			|| ($chan eq $::megahal_interface::DEBUGMODE_chan))
			&& ([lindex $::megahal_interface::DEBUGMODE 6])
		} then {
			::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00314i!i\003\00315!i!\003\00314 instance anti-flood \003\00307+1\003\00314 sur $chan -> \003\00307$::megahal_interface::instance($chan)\003\00314. (limite : $::megahal_interface::floodlimiter)\003"
		}
		return "+"
	}
}
proc ::megahal_interface::antiflood_close_instance {chan} {
  variable instance
  if {
  	([::tcl::info::exists instance($chan)])
  	&& ($instance($chan) > 0)
  } then {
  	incr instance($chan) -1
  }
}

 ###############################################################################
### Traitement des données avant apprentissage ou soumission à getreply
 ###############################################################################
proc ::megahal_interface::moulinex_in {mode nick chan text} {
	if {
		(($::megahal_interface::DEBUGMODE_chan eq "*")
		|| ($chan eq $::megahal_interface::DEBUGMODE_chan))
		&& ([lindex $::megahal_interface::DEBUGMODE 0])
	} then {
		::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00306i!i\003\00313!i!\003\00314 dump \003moulinex_in\00314 : $mode | $nick | $chan | $text\003"
	}
	regsub -all {\W} $::botnick {\\&} regexpable_botnick
	# On filtre "$::botnick>" "$::botnick:" "$::botnick," ... en début de phrase.
	regsub -nocase "^\[@&~%\+\]?[set regexpable_botnick]\\s?(\[^a-z\\s\]+)\\s?" $text "" text
	# On filtre les timestamp de la forme [timestamp] et (timestamp) dans les
	# copier/coller.
	regsub -all {(\[|\()[0-9:\.]+(\]|\))} $text "" text
	# On filtre les pseudos de la forme <nick> dans les copier/coller.
	regsub -all {^(\s+)?(<|\()[^(>|\))]*(>|\))} $text "" text
	# On filtre les pseudos de type HL en début de ligne comme "pseudo >" ou
	# "pseudo :" ...
	if { [regexp {^\s?@?([^\s]+)\s?[>\|:,~»]+(.*)} $text {} match] } {
		if {
			(($chan ne "-")
			&& ([onchan $match $chan]))
			|| ([onchan $match])
		} then {
			set text [::tcl::string::trimleft [regsub {^\s?@?[^\s]+\s?(>+|:|,|~|»)(.*)} $text {\2}]]
		}
	}
	# Ajout d'un "¤ " en début de ligne (il nous servira de repère dans les string
	# map).
	set text "¤ $text"
	# Ajout d'un "." en fin de ligne (il nous servira de repère dans les string
	# map).
	if { [::tcl::string::index $text end] ne "." } {
		set text "$text."
	}
	# Substitutions diverses vous pouvez utiliser les variables $::botnick,
	# $::nick, $nick et $chan.
	set text [::tcl::string::map -nocase [list\
		"" ""
	] $text]
	# On supprime le "¤ " en début de ligne.
	regsub {^¤ } $text "" text
	# On supprime le "." en fin de ligne sauf s'il est précédé d'un autre "."
	regsub {([^\.])\.$} $text {\1} text
	# Supprime la plupart des $::botnick restants dans le texte, sauf quand la
	# construction de la phrase le rend indispensable.
	regsub -all -nocase "(^| |')(((de|avec|via|mon|ton|son|vers|sur|sous|par|pour|contre|en|dans|ce|le|une?|et|à|a|est?|nom+es?|ap+el+e?s?|nom est|dit) $regexpable_botnick)|$regexpable_botnick)\s?(\[\\.\\?,!:;=\]|\\^+|\[:X;=8>\]\[<D\\(\\)\\\[\\\]\\{\\}p\]|$)" $text {\1\3 \5} text
	regsub -all -nocase "^$regexpable_botnick (?!ne\\s|n'|l'|m'|t'|s'|se\\s|est\\s|sera|était|va\\s|allait|ira\\s|fait\\s|fera|ferait|faisait|me\\s|te\\s|se\\s|met|a\\s|avait|aura|perd|peut|veut|voulait|voudra|appren|dit|dira|disait)" $text "" text
	if {
		($::megahal_interface::substitute_all_nicks)
		&& ($chan ne "-")
	} then {
		# On repère si la phrase contient des nicks de personnes présentes sur le
		# chan, et si oui on remplace par oooooousernickmd5oooooo (le md5 sert à ne
		# pas avoir des centaines de fois l'entrée "oooooousernickoooooo" dans le
		# brain, auquel cas il aurait un poids énorme et serait souvent utilisé par
		# l'I.A. pour construire des phrases.
		set text [::megahal_interface::substitute_nicks "sentence" $chan $text]
	}
	return $text
}

 ###############################################################################
### Traitement des réponses avant affichage
 ###############################################################################
proc ::megahal_interface::moulinex_out {nick hand chan targetnick text} {
	if {
		(($::megahal_interface::DEBUGMODE_chan eq "*")
		|| ($chan eq $::megahal_interface::DEBUGMODE_chan))
		&& ([lindex $::megahal_interface::DEBUGMODE 0])
	} then {
		::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00306i!i\003\00313!i!\003\00314 dump \003moulinex_out\00314 : $nick | $chan | $targetnick | $text\003"
	}
	set unmodified_text $text
	regsub -all {\W} $::botnick {\\&} regexpable_botnick
	# Supprime Botnick en début de phrase si suivi par > : , . ...
	regsub -nocase "^@?$regexpable_botnick ?(>+|:|~|»|,|\\.+) ?" $text "" text
	# Ajout d'un "¤ " en début de ligne (il nous servira de repère dans les string
	# map).
	set text "¤ $text"
	# Ajout d'un "." en fin de ligne (il nous servira de repère dans les string
	# map).
	if { [::tcl::string::index $text end] ne "." } {
		set text "$text."
	}
	# Substitution du nick de l'Eggdrop par le nick de la personne à qui il répond.
	if { [rand 101] <= $::megahal_interface::nickswitchrate } {
		set text [::tcl::string::map -nocase "$::botnick [split $nick]" $text]
	}
	# Substitutions diverses vous pouvez utiliser les variables $::botnick,
	# $::nick, $nick et $chan.
	set text [::tcl::string::map -nocase [list\
		"I am utterly speechless!"							"\003${::megahal_interface::main_color}les mots me manquent...\003"\
		"I forgot what I was going to say!"			"\003${::megahal_interface::main_color}j'ai... oublié ce que je voulais dire\003"\
		"¤ pourquoi tan"												"¤ pourquoi tan"\
		"¤ pourquoi"														"parce que"\
	] $text]
	# Correction de la casse/soulignement de certains smileys et des fautes
	# courantes.
	set text [::tcl::string::map -nocase {
		" oo "																	" oO "
		" oo."																	" oO."
		" oo'"																	" oO'"
		" oo'."																	" oO'."
		"o.o"																		"o.O"
		"o_o"																		"o_O"
		"xd"																		"XD"
		"x)"																		"X)"
		"x]"																		"X]"
		":d"																		":D"
		"=d"																		"=D"
		"¬¬"																		"\037¬¬\037"
		",."																		"."
		" susi "																" suis "
		"sa va"																	"ça va"
	} $text]
	set userlist [::megahal_interface::randomize_list [chanlist $chan]]
	if { ($::megahal_interface::substitute_all_nicks) && ($chan ne "-") } {
		# On remplace les oooooousernickoooooo par des nicks aléatoires pris sur le
		# chan.
		if { [set index_list [lsearch -all [set split_text [split $text]] {*oooooousernick*oooooo*}]] != -1 } {
			if {
				([lsearch -nocase [subst $::megahal_interface::nick_substitution_exclusion_list] $nick] != -1)
				|| ([lsearch -nocase -exact [subst $::megahal_interface::nick_substitution_exclusion_list] $hand] != -1)
			} then {
				set interlocutor_is_excluded_from_substitution 1
			} else {
				set interlocutor_is_excluded_from_substitution 0
			}
			set userindex 0
			set targetnick_substitued 0
			set interlocutor_nick_substitued 0
			foreach index $index_list {
				while {
					([lsearch -nocase [subst $::megahal_interface::nick_substitution_exclusion_list] [lindex $userlist $userindex]] != -1)
					|| ($targetnick eq [lindex $userlist $userindex])
					|| ($::botnick eq [lindex $userlist $userindex])
				} {
					incr userindex
				}
				# Il y a "$substitute_by_interlocutor_nick_rate"% de chances pour que
				# oooooousernickoooooo soit remplacé par le nick de l'interlocuteur,
				# sauf s'il est présent dans $nick_substitution_exclusion_list.
				if {
					!($interlocutor_is_excluded_from_substitution)
					&& !($interlocutor_nick_substitued)
					&& (($targetnick_substitued) || ($targetnick eq "@") || ([::tcl::string::equal -nocase $targetnick $::nick]))
					&& ([set coin [rand 101]] <= $::megahal_interface::substitute_by_interlocutor_nick_rate)
				} then {
					lset split_text $index $nick
					set interlocutor_nick_substitued 1
				# Si un nick a été cité dans la phrase d'origine et qu'il ne s'agit pas
				# de celui de l'Eggdrop, il sera réutilisé dans la réponse.
				} elseif {
					(!$targetnick_substitued)
					&& ($targetnick ne "@")
					&& !([::tcl::string::equal -nocase $targetnick $::nick])
				} then {
					lset split_text $index $targetnick
					set targetnick_substitued 1
				} else {
					lset split_text $index [lindex $userlist $userindex]
					incr userindex
				}
			}
			set text [join $split_text]
		}
	}
	# Si nécessaire, on corrige la casse des caractères dans les nicks des
	# personnes présentes sur le chan.
	if { $chan ne "-" } {
	foreach current_nick $userlist {
		set text [::tcl::string::map {"  " " "} [::tcl::string::map -nocase [list\
				" $current_nick " " $current_nick " " $current_nick." " $current_nick."\
				"¤$current_nick " "¤$current_nick " "¤$current_nick." "¤$current_nick."\
				".$current_nick " ".$current_nick " ".$current_nick." ".$current_nick."\
				" $current_nick;" " $current_nick;" "¤$current_nick;" "¤$current_nick;"\
				";$current_nick " ";$current_nick " ";$current_nick." ";$current_nick."\
				" $current_nick," " $current_nick," "¤$current_nick," "¤$current_nick,"\
				",$current_nick " ",$current_nick " ",$current_nick." ",$current_nick."\
				" $current_nick:" " $current_nick:" "¤$current_nick:" "¤$current_nick:"\
				":$current_nick " ":$current_nick " ":$current_nick." ":$current_nick."\
				" $current_nick!" " $current_nick!" "¤$current_nick!" "¤$current_nick!"\
				"!$current_nick " "!$current_nick " "!$current_nick." "!$current_nick."\
				" $current_nick?" " $current_nick?" "¤$current_nick?" "¤$current_nick?"\
				"?$current_nick " "?$current_nick " "?$current_nick." "?$current_nick."\
			] [::tcl::string::map {" " "  "} $text]]]
		}
	}
	# On supprime le "¤ " en début de ligne.
	regsub {^¤ } $text "" text
	# On supprime le "." en fin de ligne sauf s'il est précédé d'un autre "."
	regsub {([^\.])\.$} $text {\1} text
	# Supprime la plupart des $::botnick restants dans la réponse, sauf quand la
	# construction de la phrase le rend indispensable.
	regsub -all -nocase "(^| )(((de|avec|via|mon|ton|son|vers|sur|sous|par|pour|contre|en|dans|ce|le|une?|et|à|a|est?|nom+es?|ap+el+e?s?|nom est|dit) $regexpable_botnick)|$regexpable_botnick) ?(\[\\.\\?,!:;=\]|\\^+|\[:X;8>\]\[<D\\(\\)\\\[\\\]\\{\\}p\]|$)" $text {\1\3 \5} text
	regsub -all -nocase "^$regexpable_botnick " $text "" text
	# Ajoute un espace devant ? et ! s'il n'y en a pas.
	regsub -all {([^\s!\?])\s?(\?|!)} $text {\1 \2} text
	# Supprime l'espace devant . , et ; s'il y en a un, sauf s'il fait partie d'un
	# smiley.
	regsub -all {([^\s])\s?(\.|,|;)([^)(\-pP\[\]dDoO<>])} $text {\1\2\3} text
	if {
		(($::megahal_interface::DEBUGMODE_chan eq "*")
		|| ($chan eq $::megahal_interface::DEBUGMODE_chan))
		&& ([lindex $::megahal_interface::DEBUGMODE 4])
		&& ([::tcl::string::compare -nocase [::tcl::string::map {"." "" ";" "" "," "" ":" "" "!" "" "?" ""} $text] [::tcl::string::map {"." "" ";" "" "," "" ":" "" "!" "" "?" ""} $unmodified_text]] != 0)
		&& ($chan ne "-")
	} then {
		::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00307\[$chan\]\003 \00314 $unmodified_text\003"
		::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00304--talk-->\003\00315 $text\003"
	}
	return $text
}

 ###############################################################################
### Substitution des nicks par oooooousernick$hashoooooo
 ###############################################################################
proc ::megahal_interface::substitute_nicks {type chan text} {
	foreach current_nick [chanlist $chan] {
		if { [lsearch -nocase [subst $::megahal_interface::nick_substitution_exclusion_list] $current_nick] != -1 } {
			continue
		} elseif { $type eq "sentence" } {
			regsub -all -nocase "(^|\[^a-z\])[regsub -all {\W} $current_nick {\\&}](\[^a-z\]|$)" $text "\\1oooooousernick[md5 $current_nick]oooooo\\2" text
		} else {
			regsub -all -nocase "^[regsub -all {\W} $current_nick {\\&}]$" $text "oooooousernick[md5 $current_nick]oooooo" text
		}
	}
	return $text
}

 ###############################################################################
### Gestion des couleurs, filtrage des codes de couleur/gras/soulignement si le
### mode +c est détecté sur le chan, ou si la couleur est désactivée
### manuellement
 ###############################################################################
proc ::megahal_interface::code {code chan} {
	if {
		!($::megahal_interface::use_colors)
		|| ($code eq "")
		|| (($chan ne "-")
		&& ([::tcl::string::match *c* [lindex [split [getchanmode $chan]] 0]]))
	} then {
		return ""
	} else {
		switch -- $code {
			mc { return "\003[set ::megahal_interface::main_color]" }
			sc { return "\003[set ::megahal_interface::secondary_color]" }
			b { return "\002" }
			u { return "\037" }
			r { return "\026" }
			e { return "\003" }
			s { return "\017" }
			default { return "\003$code" }
		}
	}
}

 ###############################################################################
### Affichage d'un texte, filtrage des styles si nécessaire.
### * queue peut valoir help, quick, now, serv, dcc, log ou loglev
### * method peut valoir PRIVMSG ou NOTICE et sera ignoré si queue vaut dcc ou
###      loglev
### * target peut être un nick, un chan ou un idx, et sera ignoré si queue vaut
###      loglev
 ###############################################################################
proc ::megahal_interface::display_output {queue method target text} {
	if {
		!($::megahal_interface::use_colors)
		|| (!([::tcl::string::first "#" $target])
		&& ([::tcl::string::match *c* [lindex [split [getchanmode $target]] 0]]))
		|| (($queue eq "dcc")
		&& (![matchattr [idx2hand $target] h]))
	} then {
		# Remarque : l'aller-retour d'encodage permet de contourner un bug d'Eggdrop
		# qui corromp le charset dans certaines conditions lors de l'utilisation de
		# regsub sur une chaîne de caractères.
		regsub -all "\017" [stripcodes abcgru [encoding convertto utf-8 [encoding convertfrom utf-8 $text]]] "" text
	}
	switch -- $queue {
		help - quick - now - serv {
			put$queue "$method $target :$text"
		}
		dcc {
			putdcc $target $text
		}
		loglev {
			putloglev o * $text
		}
		log {
			putlog $text
		}
	}
}

 ###############################################################################
### Si l'Eggdrop vient juste de se connecter au serveur, l'I.A. est activée
### après un délai afin d'éviter l'encombrement des files d'attente de messages.
 ###############################################################################
proc ::megahal_interface::resume_on_connect {args} {
	after [expr {$::megahal_interface::IA_activation_delay * 1000}] {
		bind pubm - * ::megahal_interface::process_pub_msg
		bind ctcp - ACTION ::megahal_interface::process_ctcp_action
	}
	return
}

 ###############################################################################
### Si l'Eggdrop est déconnecté du serveur, l'I.A. est mise en pause.
 ###############################################################################
proc ::megahal_interface::pause_on_disconnect {args} {
	if { [binds ::megahal_interface::process_pub_msg] ne "" } {
		unbind pubm - * ::megahal_interface::process_pub_msg
	}
	if { [binds ::megahal_interface::process_ctcp_action] ne "" } {
		unbind ctcp - ACTION ::megahal_interface::process_ctcp_action
	}
	return
}

 ###############################################################################
### Backup quotidien des bases de données
 ###############################################################################
proc ::megahal_interface::backup_db {min hour day month year} {
	if { $::megahal_interface::verbose_automatisms } {
		::megahal_interface::display_output log - - "\003${::megahal_interface::main_color}\[$::megahal_interface::scriptname\]\003 Sauvegarde des bases de données..."
	}
	if { [file exists "megahal.brn"] } {
		file copy -force "megahal.brn" "megahal.brn.bak"
	}
	if { [file exists "megahal.dic"] } {
		file copy -force "megahal.dic" "megahal.dic.bak"
	}
	if { [file exists "megahal.phr"] } {
		file copy -force "megahal.phr" "megahal.phr.bak"
	}
}

 ###############################################################################
### Mise en minuscules, y compris les caractères accentués
 ###############################################################################
proc ::megahal_interface::tolower {text} {
	return [::tcl::string::tolower [::tcl::string::map {
		"À" "à" "Â" "â" "Ä" "ä"
		"É" "é" "È" "è" "Ê" "ê" "Ë" "ë"
		"Î" "î" "Ï" "ï"
		"Ô" "ô" "Ö" "ö"
		"Ù" "ù" "Û" "û" "Ü" "ü"
		"Ç" "ç" "Ñ" "ñ" "Ã" "ã" "Õ" "õ"
	} $text]]
}

 ###############################################################################
### Binds
 ###############################################################################
namespace eval ::megahal_interface {
	bind pub $help_auth "[set pub_command_prefix][set help_cmd]" ::megahal_interface::pub_help
	bind dcc $help_auth $help_cmd ::megahal_interface::dcc_help
	bind pub $masterswitch_auth "[set pub_command_prefix][set masterswitch_cmd]" ::megahal_interface::pub_masterswitch
	bind pub $learnstate_auth "[set pub_command_prefix][set learnstate_cmd]" ::megahal_interface::pub_learnstate
	bind pub $respondstate_auth "[set pub_command_prefix][set respondstate_cmd]" ::megahal_interface::pub_respondstate
	bind pub $chatterstate_auth "[set pub_command_prefix][set chatterstate_cmd]" ::megahal_interface::pub_chatterstate
	bind pub $replyrate_auth "[set pub_command_prefix][set replyrate_cmd]" ::megahal_interface::pub_replyrate
	bind pub $keyreplyrate_auth "[set pub_command_prefix][set keyreplyrate_cmd]" ::megahal_interface::pub_keyreplyrate
	bind pub $forget_auth "[set pub_command_prefix][set forget_cmd]" ::megahal_interface::pub_forget
	bind dcc $forget_auth $forget_cmd ::megahal_interface::dcc_forget
	bind pub $forgetword_auth "[set pub_command_prefix][set forgetword_cmd]" ::megahal_interface::pub_forgetword
	bind dcc $forgetword_auth $forgetword_cmd ::megahal_interface::dcc_forgetword
	bind pub $seekstatement_auth "[set pub_command_prefix][set seekstatement_cmd]" ::megahal_interface::pub_seekstatement
	bind dcc $seekstatement_auth $seekstatement_cmd ::megahal_interface::dcc_seekstatement
	bind pub $countword_auth "[set pub_command_prefix][set countword_cmd]" ::megahal_interface::pub_countword
	bind dcc $countword_auth $countword_cmd ::megahal_interface::dcc_countword
	bind pub $learnfile_auth "[set pub_command_prefix][set learnfile_cmd]" ::megahal_interface::pub_learnfile
	bind dcc $learnfile_auth $learnfile_cmd ::megahal_interface::dcc_learnfile
	bind pub $savebrain_auth "[set pub_command_prefix][set savebrain_cmd]" ::megahal_interface::pub_savebrain
	bind dcc $savebrain_auth $savebrain_cmd ::megahal_interface::dcc_savebrain
	bind pub $reloadbrain_auth "[set pub_command_prefix][set reloadbrain_cmd]" ::megahal_interface::pub_reloadbrain
	bind dcc $reloadbrain_auth $reloadbrain_cmd ::megahal_interface::dcc_reloadbrain
	bind pub $reloadphrases_auth "[set pub_command_prefix][set reloadphrases_cmd]" ::megahal_interface::pub_reloadphrases
	bind dcc $reloadphrases_auth $reloadphrases_cmd ::megahal_interface::dcc_reloadphrases
	bind pub $trimbrain_auth "[set pub_command_prefix][set trimbrain_cmd]" ::megahal_interface::pub_trimbrain
	bind dcc $trimbrain_auth $trimbrain_cmd ::megahal_interface::dcc_trimbrain
	bind pub $lobotomy_auth "[set pub_command_prefix][set lobotomy_cmd]" ::megahal_interface::pub_lobotomy
	bind dcc $lobotomy_auth $lobotomy_cmd ::megahal_interface::dcc_lobotomy
	bind pub $restorebrain_auth "[set pub_command_prefix][set restorebrain_cmd]" ::megahal_interface::pub_restorebrain
	bind dcc $restorebrain_auth $restorebrain_cmd ::megahal_interface::dcc_restorebrain
	bind pub $chanstatus_auth "[set pub_command_prefix][set chanstatus_cmd]" ::megahal_interface::pub_chanstatus
	bind pub $braininfo_auth "[set pub_command_prefix][set braininfo_cmd]" ::megahal_interface::pub_braininfo
	bind pub $memusage_auth "[set pub_command_prefix][set memusage_cmd]" ::megahal_interface::pub_memusage
	bind dcc $memusage_auth $memusage_cmd ::megahal_interface::dcc_memusage
	bind pub $treesize_auth "[set pub_command_prefix][set treesize_cmd]" ::megahal_interface::pub_treesize
	bind dcc $treesize_auth $treesize_cmd ::megahal_interface::dcc_treesize
	bind pub $viewbranch_auth "[set pub_command_prefix][set viewbranch_cmd]" ::megahal_interface::pub_viewbranch
	bind dcc $viewbranch_auth $viewbranch_cmd ::megahal_interface::dcc_viewbranch
	bind pub $make_words_auth "[set pub_command_prefix][set make_words_cmd]" ::megahal_interface::pub_make_words
	bind dcc $make_words_auth $make_words_cmd ::megahal_interface::dcc_make_words
	bind pub $debug_output_auth "[set pub_command_prefix][set debug_output_cmd]" ::megahal_interface::pub_debug_output
	bind dcc $debug_output_auth $debug_output_cmd ::megahal_interface::dcc_debug_output
	bind pub $getwordsymbol_auth "[set pub_command_prefix][set getwordsymbol_cmd]" ::megahal_interface::pub_getwordsymbol
	bind dcc $getwordsymbol_auth $getwordsymbol_cmd ::megahal_interface::dcc_getwordsymbol
	bind pub $moulinex_in_auth "[set pub_command_prefix][set moulinex_in_cmd]" ::megahal_interface::pub_moulinex_in
	bind dcc $moulinex_in_auth $moulinex_in_cmd ::megahal_interface::dcc_moulinex_in
	bind pub $moulinex_out_auth "[set pub_command_prefix][set moulinex_out_cmd]" ::megahal_interface::pub_moulinex_out
	bind dcc $moulinex_out_auth $moulinex_out_cmd ::megahal_interface::dcc_moulinex_out
	bind pub $megaver_auth "[set pub_command_prefix][set megaver_cmd]" ::megahal_interface::pub_megaver
	bind dcc $megaver_auth $megaver_cmd ::megahal_interface::dcc_megaver
	bind cron - $::megahal_interface::auto_savebrain_cron ::megahal_interface::auto_savebrain
	bind time - "[lindex $::megahal_interface::backuptime 1] [lindex $::megahal_interface::backuptime 0] * * *" ::megahal_interface::backup_db
	# Binds destinés à forcer une sauvegarde du brain au cas où il arrive quelque
	# chose à l'Eggdrop qui pourrait provoquer la perte du brain non-sauvegardé.
	bind evnt - prerehash ::megahal_interface::on_event_savebrain
	bind evnt - prerestart ::megahal_interface::on_event_savebrain
	bind evnt - sigquit ::megahal_interface::on_event_savebrain
	bind evnt - sighup ::megahal_interface::on_event_savebrain
	bind evnt - sigterm ::megahal_interface::on_event_savebrain
	bind evnt - sigill ::megahal_interface::on_event_savebrain
	bind evnt - disconnect-server ::megahal_interface::on_event_savebrain
	# Bind destiné à activer l'I.A. après un délai à la connection au serveur.
	bind evnt - init-server ::megahal_interface::resume_on_connect
	# Bind destiné à mettre l'I.A. en pause en cas de déconnection du serveur.
	bind evnt - disconnect-server ::megahal_interface::pause_on_disconnect
	# Si l'Eggdrop est déjà connecté au serveur, l'I.A. est immédiatement
	# disponible.
	if { $::server ne "" } {
		bind pubm - * ::megahal_interface::process_pub_msg
		bind ctcp - ACTION ::megahal_interface::process_ctcp_action
	}
}


putlog "$::megahal_interface::scriptname v$::megahal_interface::version (©2007-2016 Menz Agitat) a été chargé"
