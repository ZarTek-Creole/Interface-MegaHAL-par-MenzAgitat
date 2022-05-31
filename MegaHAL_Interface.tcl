 ##############################################################################
#
# Interface MegaHAL
# v4.1.0 (02/04/2016)  �2007-2016 Menz Agitat
# pour MegaHAL v8 (module v3.5) Artixed Edition
#
# IRC: irc.epiknet.org  #boulets / #eggdrop
#
# Mes scripts sont t�l�chargeables sur http://www.eggdrop.fr
# Retrouvez aussi toute l'actualit� de mes releases sur
# http://www.boulets.oqp.me/tcl/scripts/index.html
#
# Remerciements � Artix et � Galdinx pour les coups de main, et � Miocastoor
# pour quelques id�es.
#
 ##############################################################################

#
# Description
#
# Interface MegaHAL est une interface pour le module MegaHAL d�velopp� par
# Zev ^Baron^ Toledano et modifi� par Artix, d'apr�s l'I.A. de Jason Hutchens.
# Ce script ne fonctionnera correctement qu'avec la version 3.5 du module
# MegaHAL modifi� par Artix (Artixed Edition); elle est normalement fournie avec
# si vous avez r�cup�r� ce script au bon endroit.
# Remarque : si vous choisissez de ne pas utiliser la version fournie du module
# et que vous avez des probl�mes, ne venez pas m'en parler.
#
# Le but de cette interface est d'accro�tre le contr�le que vous avez sur
# MegaHAL et d'ajouter de nombreuses fonctionnalit�s et am�liorations dont
# vous trouverez une description dans le fichier documentation.txt inclus.
#
 ##############################################################################

#
# Licence
#
#		Cette cr�ation est mise � disposition selon le Contrat
#		Attribution-NonCommercial-ShareAlike 3.0 Unported disponible en ligne
#		http://creativecommons.org/licenses/by-nc-sa/3.0/ ou par courrier postal �
#		Creative Commons, 171 Second Street, Suite 300, San Francisco, California
#		94105, USA.
#		Vous pouvez �galement consulter la version fran�aise ici :
#		http://creativecommons.org/licenses/by-nc-sa/3.0/deed.fr
#
 ###############################################################################

if {[::tcl::info::commands ::megahal_interface::uninstall] eq "::megahal_interface::uninstall"} { ::megahal_interface::uninstall }
if { [regsub -all {\.} [lindex $::version 0] ""] < 1620 } { putloglev o * "\00304\[Interface MegaHAL - erreur\]\003 La version de votre Eggdrop est\00304 ${::version}\003; Interface MegaHAL ne fonctionnera correctement que sur les Eggdrops version 1.6.20 ou sup�rieure." ; return }
if { [::tcl::info::tclversion] < 8.5 } { putloglev o * "\00304\002\[Interface MegaHAL - Erreur\]\002\003 Interface MegaHAL n�cessite que Tcl 8.5 (ou plus) soit install� pour fonctionner. Votre version actuelle de Tcl est \00304\002$tcl_version\002\003." ; return }
if { [lsearch -index 0 [modules] "megahal"] == -1 } {
	putloglev o * "\00304\002\[Interface MegaHAL - Erreur\]\002\003 Vous devez charger le module MegaHAL \002avant\002 l'Interface MegaHAL. Tentative de chargement du module..."
	catch { loadmodule megahal }
	if { [lsearch -index 0 [modules] "megahal"] == -1 } { putloglev o * "\00304\002\[Interface MegaHAL - Erreur\]\002\003 Le module MegaHAL n'a pas pu �tre charg�, abandon du chargement de l'Interface MegaHAL." ; return }
}
if { [::tcl::info::commands *pub:.megaseek] ne "" } {
	putloglev o * "\00304\002\[Interface MegaHAL - Erreur\]\002\003 Vous utilisez une version du module MegaHAL ant�rieure � la v3.5. Vous devez imp�rativement utiliser la version fournie avec cette interface pour qu'elle puisse fonctionner." ; return
} elseif { [::tcl::info::commands megahal_searchword] eq "" } {
	putloglev o * "\00304\002\[Interface MegaHAL - Erreur\]\002\003 La version du module MegaHAL que vous utilisez n'est pas une \"Artixed Edition\". Vous devez imp�rativement utiliser la version fournie avec cette interface pour qu'elle puisse fonctionner." ; return
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
	# On d�sactive l'apprentissage conventionnel du module MegaHAL car l'interface
	# MegaHAL contr�le cet aspect par ses propres moyens.
	learningmode off
	# On enl�ve les binds que le module MegaHAL a install� afin de pouvoir mettre
	# les n�tres.
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
	# Construction d'une liste qui sera utilis�e par le string map du mode
	# "TAGUEULE".
	foreach trigger $::megahal_interface::shutup_triggers {
		lappend ::megahal_interface::shutup_trigger_list [subst $trigger] "!-shutup-!"
	}
	unset ::megahal_interface::shutup_triggers
	set ::megahal_interface::floodlimiter [split $::megahal_interface::floodlimiter ":"]
	# Proc�dure de d�sinstallation : le script se d�sinstalle totalement avant
	# chaque rehash ou � chaque relecture au moyen de la commande "source" ou
	# autre.
	proc uninstall {args} {
		putlog "D�sallocation des ressources de l'${::megahal_interface::scriptname}..."
		foreach binding [lsearch -inline -all -regexp [binds *[set ns [::tcl::string::range [namespace current] 2 end]]*] " \{?(::)?$ns"] {
			unbind [lindex $binding 0] [lindex $binding 1] [lindex $binding 2] [lindex $binding 4]
		}
		package forget MegaHAL_Interface
		namespace delete ::megahal_interface
	}
}

 ###############################################################################
### Traitement des donn�es re�ues.
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
	# regsub sur une cha�ne de caract�res.
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
	# retrouver le contenu de la requ�te dans la r�ponse.
	if { [::megahal_interface::is_talk_allowed_1st_pass $nick $clean_nick $host $hand $chan $clean_chan $user_global_flags $user_local_flags $text] } {
		if { $::megahal_interface::use_responder } {
			# On d�finit � 0 la variable de test permettant de savoir si Responder a
			# r�pondu ou pas.
			variable check_responder 0
			# On appelle Responder pour voir s'il a quelque chose � dire.
			::responder::process $nick $host $hand $chan $text
			# Si Responder a r�pondu � $nick, on le note pour l'antiflood.
			if { $::megahal_interface::check_responder } {
				::megahal_interface::flood $chan add_instance
				variable floodlock_reply
				set floodlock_reply($clean_chan,$clean_nick) 1
				after [expr {$::megahal_interface::reply_interval * 1000}] [list ::megahal_interface::unfloodlock_reply $clean_chan $clean_nick]
			}
		}
		# On d�tecte s'il est demand� au bot de se taire.
		if { [::tcl::string::match -nocase "*!-shutup-!*" [::tcl::string::map -nocase $::megahal_interface::shutup_trigger_list $text]] == 1 } {
			# ---------------------------------------------------------------------------
			if {
				(($::megahal_interface::DEBUGMODE_chan eq "*")
				|| ($chan eq $::megahal_interface::DEBUGMODE_chan))
				&& ([lindex $::megahal_interface::DEBUGMODE 2])
			} then {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00306i!i\003\00313!i!i!i!\003\00314 Il a �t� demand� au bot de se taire."
				if {
					([regexp "\[$::megahal_interface::shutup_global_flags\]" "-$user_global_flags"])
					|| ([regexp "\[$::megahal_interface::shutup_local_flags\]" "-$user_local_flags"])
				} then {
					::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 ${nick}/$hand a les privil�ges requis pour demander au bot de se taire (\00307${user_global_flags}|$user_local_flags\00314)\003"
				} else {
					::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 ${nick}/$hand n'a pas les privil�ges requis demander au bot de se taire (\00307${user_global_flags}|$user_local_flags\00314)\003"
				}
				if {
					(($::megahal_interface::shutup_forbidden_auth ne "")
					&& ((($::megahal_interface::shutup_forbidden_global_flags ne "")
					&& ([regexp "\[$::megahal_interface::shutup_forbidden_global_flags\]" "-$user_global_flags"]))
					|| (($::megahal_interface::shutup_forbidden_local_flags ne "")
					&& ([regexp "\[$::megahal_interface::shutup_forbidden_local_flags\]" "-$user_local_flags"]))))
				} then {
					::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 ${nick}/$hand a des autorisations r�dhibitoires pour pouvoir demander au bot de se taire (\00307${user_global_flags}|$user_local_flags\00314)\003"
				} else {
					::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 ${nick}/$hand n'a pas d'autorisations r�dhibitoires pour pouvoir demander au bot de se taire (\00307${user_global_flags}|$user_local_flags\00314)\003"
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
					::megahal_interface::display_output log - - "\00304\[MEGAHAL\] \002Mode TAGUEULE activ� pour $::megahal_interface::shutup_time minutes sur $chan\002\003"
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
			# Si un nick est cit� et a �t� substitu� dans ce que l'utilisateur a dit,
			# on le note dans $targetnick afin de pouvoir le r�utiliser dans la
			# r�ponse.
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
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 la r�ponse contient une commande ne faisant pas partie des commandes autoris�es ( \00307[lindex [split $reply] 0]\00314 )\003"
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
### Autorisation d'apprendre ? (1�re passe)
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
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 la ligne commence par \"$::megahal_interface::force_L_R_cmd\" : \003\00303\002apprentissage forc�\002\003\00314 + r�ponse forc�e si flags \003\00307$::megahal_interface::force_L_R_auth\003"
			} elseif { [::tcl::string::match "$::megahal_interface::force_L_noR_cmd*" $text] } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 la ligne commence par \"$::megahal_interface::force_L_noR_cmd\" : \003\00303\002apprentissage forc�\002\003\00314 + ne r�pond pas si flags \003\00307$::megahal_interface::force_L_noR_auth\003"
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
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 ${nick}/$hand est pr�sent dans la liste \$learn_exclusion_list (\00307$::megahal_interface::learn_exclusion_list\003\00314)\003"
			} else {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 ${nick}/$hand n'est pas pr�sent dans la liste \$learn_exclusion_list\003"
			}
			if {
				(($::megahal_interface::learn_forbidden_auth ne "")
				&& ((($::megahal_interface::learn_forbidden_global_flags ne "")
				&& ([regexp "\[$::megahal_interface::learn_forbidden_global_flags\]" "-$user_global_flags"]))
				|| (($::megahal_interface::learn_forbidden_local_flags ne "")
				&& ([regexp "\[$::megahal_interface::learn_forbidden_local_flags\]" "-$user_local_flags"]))))
			} then {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 ${nick}/$hand a des autorisations r�dhibitoires pour pouvoir apprendre � l'I.A. (\00307${user_global_flags}|$user_local_flags\00314)\003"
			} else {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 ${nick}/$hand n'a pas d'autorisations r�dhibitoires pour pouvoir apprendre � l'I.A. (\00307${user_global_flags}|$user_local_flags\00314)\003"
			}
			if {
				([regexp "\[$::megahal_interface::learn_global_flags\]" "-$user_global_flags"])
				|| ([regexp "\[$::megahal_interface::learn_local_flags\]" "-$user_local_flags"])
			} then {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 ${nick}/$hand a les privil�ges requis pour apprendre � l'I.A. (\00307${user_global_flags}|$user_local_flags\00314)\003"
			} else {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 ${nick}/$hand n'a pas les privil�ges requis pour apprendre � l'I.A. (\00307${user_global_flags}|$user_local_flags\00314)\003"
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
			::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00314i!i\003\00315!i!\003\00314 tirage d'un nombre al�atoire entre 1 et 100 afin de d�terminer si le bot a le droit d'apprendre : \003\00307$coin\003"

			if { [set num_words [llength [split $text]]] >= $::megahal_interface::minlearnwords } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 La phrase a une longueur sup�rieure ou �gale � \$minlearnwords (\003\00307$num_words \003\00314>=\003\00307 $::megahal_interface::minlearnwords\003\00314)\003"
			} else {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 La phrase a une longueur inf�rieure � \$minlearnwords (\003\00307$num_words \003\00314<\003\00307 $::megahal_interface::minlearnwords\003\00314)\003"
			}
			if { $::megahal_interface::maxlearnwords } {
				if { $num_words <= $::megahal_interface::maxlearnwords } {
					::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 La phrase a une longueur inf�rieure ou �gale � \$maxlearnwords (\003\00307$num_words \003\00314<=\003\00307 $::megahal_interface::maxlearnwords\003\00314)\003"
				} else {
					::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 La phrase a une longueur sup�rieure � \$maxlearnwords (\003\00307$num_words \003\00314>\003\00307 $::megahal_interface::maxlearnwords\003\00314)\003"
				}
			}
			if { $coin <= $::megahal_interface::learnrate } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 le bot a \003\00307$::megahal_interface::learnrate%\003\00314 de chances d'apprendre.\003"
			} else {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 le bot a \003\00307$::megahal_interface::learnrate%\003\00314 de chances d'apprendre.\003"
			}
			if { [::tcl::string::match "$::megahal_interface::force_noL_R_cmd*" $text] } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 la ligne commence par \"$::megahal_interface::force_noL_R_cmd\" : n'apprend pas + r�ponse forc�e si flags \003\00307$::megahal_interface::force_noL_R_auth\003"
			} elseif { [::tcl::string::match "$::megahal_interface::force_noL_noR_cmd*" $text] } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 la ligne commence par \"$::megahal_interface::force_noL_noR_cmd\" : n'apprend pas + ne r�pond pas si flags \003\00307$::megahal_interface::force_noL_noR_auth\003"
			}
			if { ![::megahal_interface::handle_command $text] } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 la ligne est une commande ne faisant pas partie des commandes autoris�es ( \00307$text\00314 )\003"
			} else {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 la ligne n'est pas une commande ou fait partie des commandes autoris�es.\003"
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
			::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \002\00305i!i\003\00304!i!\003\002\00314 L'apprentissage n'a pas �t� autoris� apr�s passage en revue des crit�res.\003"
		}
		return 0
	}
}

 ###############################################################################
### Autorisation d'apprendre ? (2�me passe : on v�rifie qu'apr�s le passage de
### la moulinette, la ligne ne commence pas par une commande et est encore assez
### longue pour �tre apprise)
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
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 la ligne commence par \"$::megahal_interface::force_L_R_cmd\" : \003\00303\002apprentissage forc�\002\003\00314 + r�ponse forc�e si flags \003\00307$::megahal_interface::force_L_R_auth\003"
			} elseif { [::tcl::string::match "$::megahal_interface::force_L_noR_cmd*" $text] } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 la ligne commence par \"$::megahal_interface::force_L_noR_cmd\" : \003\00303\002apprentissage forc�\002\003\00314 + ne r�pond pas si flags \003\00307$::megahal_interface::force_L_noR_auth\003"
			}
			if { [set num_words [llength [split $text_to_learn]]] >= $::megahal_interface::minlearnwords } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 La phrase a une longueur sup�rieure ou �gale � \$minlearnwords (\003\00307$num_words \003\00314>=\003\00307 $::megahal_interface::minlearnwords\003\00314)\003"
			} else {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 La phrase a une longueur inf�rieure � \$minlearnwords (\003\00307$num_words \003\00314<\003\00307 $::megahal_interface::minlearnwords\003\00314)\003"
			}
			if { $::megahal_interface::maxlearnwords } {
				if { $num_words <= $::megahal_interface::maxlearnwords } {
					::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 La phrase a une longueur inf�rieure ou �gale � \$maxlearnwords (\003\00307$num_words \003\00314<=\003\00307 $::megahal_interface::maxlearnwords\003\00314)\003"
				} else {
					::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 La phrase a une longueur sup�rieure � \$maxlearnwords (\003\00307$num_words \003\00314>\003\00307 $::megahal_interface::maxlearnwords\003\00314)\003"
				}
			}
			if { ![::megahal_interface::handle_command $text_to_learn] } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 la ligne est une commande ne faisant pas partie des commandes autoris�es ( \00307$text_to_learn\00314 )\003"
			} else {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 la ligne n'est pas une commande ou fait partie des commandes autoris�es.\003"
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
			::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \002\00305i!i\003\00304!i!\003\002\00314 L'apprentissage n'a pas �t� autoris� apr�s passage en revue des crit�res.\003"
		}
		return 0
	}
}

 ###############################################################################
### Autorisation de r�pondre ? (1�re passe : avant appel de Responder)
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
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 la ligne commence par \"$::megahal_interface::force_L_R_cmd\" : apprentissage forc� + \003\00303\002r�ponse forc�e\002\003\00314 si flags \003\00307$::megahal_interface::force_L_R_auth\003"
			} elseif { [::tcl::string::match "$::megahal_interface::force_noL_R_cmd*" $text] } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 la ligne commence par \"$::megahal_interface::force_noL_R_cmd\" : n'apprend pas + \003\00303\002r�ponse forc�e\002\003\00314 si flags \003\00307$::megahal_interface::force_noL_R_auth\003"
			} elseif { [::tcl::string::match "$::megahal_interface::force_L_noR_cmd*" $text] } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 la ligne commence par \"$::megahal_interface::force_L_noR_cmd\" : apprentissage forc� + ne r�pond pas si flags \003\00307$::megahal_interface::force_L_noR_auth\003"
			} elseif { [::tcl::string::match "$::megahal_interface::force_noL_noR_cmd*" $text] } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 la ligne commence par \"$::megahal_interface::force_noL_noR_cmd\" : n'apprend pas + ne r�pond pas si flags \003\00307$::megahal_interface::force_noL_noR_auth\003"
			}
			if {
				([lsearch -nocase $::megahal_interface::reply_exclusion_list $nick] != -1)
				|| ([lsearch -nocase -exact $::megahal_interface::reply_exclusion_list $hand] != -1)
			} then {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 ${nick}/$hand est pr�sent dans la liste \$reply_exclusion_list (\00307$::megahal_interface::reply_exclusion_list\003\00314)\003"
			} else {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 ${nick}/$hand n'est pas pr�sent dans la liste \$reply_exclusion_list\003"
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
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 L'antiflood n'a pas �t� d�clench� sur $chan\003"
			} else {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 L'antiflood a �t� d�clench� sur $chan\003"
			}
			if {
				(($::megahal_interface::reply_forbidden_auth ne "")
				&& ((($::megahal_interface::reply_forbidden_global_flags ne "")
				&& ([regexp "\[$::megahal_interface::reply_forbidden_global_flags\]" "-$user_global_flags"]))
				|| (($::megahal_interface::reply_forbidden_local_flags ne "")
				&& ([regexp "\[$::megahal_interface::reply_forbidden_local_flags\]" "-$user_local_flags"]))))
			} then {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 ${nick}/$hand a des autorisations r�dhibitoires pour que l'I.A. lui r�ponde (\00307${user_global_flags}|$user_local_flags\00314)\003"
			} else {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 ${nick}/$hand n'a pas d'autorisations r�dhibitoires pour que l'I.A. lui r�ponde (\00307${user_global_flags}|$user_local_flags\00314)\003"
			}
			if {
				([regexp "\[$::megahal_interface::reply_global_flags\]" "-$user_global_flags"])
				|| ([regexp "\[$::megahal_interface::reply_local_flags\]" "-$user_local_flags"])
			} then {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 ${nick}/$hand a les privil�ges requis pour que l'I.A. lui r�ponde (\00307${user_global_flags}|$user_local_flags\00314)\003"
			} else {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 ${nick}/$hand n'a pas les privil�ges requis pour que l'I.A. lui r�ponde (\00307${user_global_flags}|$user_local_flags\00314)\003"
			}
			if { !$::megahal_interface::allow_replies_to_commands } {
				if { [::megahal_interface::is_command $text] } {
					::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 la ligne est une commande et on n'autorise pas les r�ponses aux commandes ( \00307$text\00314 )\003"
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
			::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \002\00305i!i\003\00304!i!\003\002\00314 La parole n'a pas �t� autoris�e apr�s passage en revue des crit�res.\003"
		}
		return 0
	}
}

 ###############################################################################
### Autorisation de r�pondre ? (2�me passe : apr�s appel de Responder et
### v�rification que le mode TAGUEULE n'a pas �t� d�clench�)
### (retourne 1 pour oui, 0 pour non)
 ###############################################################################
proc ::megahal_interface::is_talk_allowed_2nd_pass {nick host hand chan user_global_flags user_local_flags text} {
	set coin [rand 101]
	set triggered ""
	# On cherche si la phrase contient un mot cl�.
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
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 la ligne commence par \"$::megahal_interface::force_L_R_cmd\" : apprentissage forc� + \003\00303\002r�ponse forc�e\002\003\00314 si flags \003\00307$::megahal_interface::force_L_R_auth\003"
			} elseif { [::tcl::string::match "$::megahal_interface::force_noL_R_cmd*" $text] } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 la ligne commence par \"$::megahal_interface::force_noL_R_cmd\" : n'apprend pas + \003\00303\002r�ponse forc�e\002\003\00314 si flags \003\00307$::megahal_interface::force_noL_R_auth\003"
			}
			if { [llength $::megahal_interface::talk_queue] < $::megahal_interface::max_talk_queue } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 La file d'attente contient \003\00307[llength $::megahal_interface::talk_queue]\003\00314/\003\00307$::megahal_interface::max_talk_queue\003\00314 entr�es\003"
			} else {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 La file d'attente est pleine (\003\00307[llength $::megahal_interface::talk_queue]\003\00314/\003\00307$::megahal_interface::max_talk_queue\003\00314)\003"
			}
			if { $::megahal_interface::use_responder } {
				if { $::megahal_interface::check_responder } {
					::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 Responder a r�pondu � \003\00307$text\003"
				} else {
					::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 Responder n'a pas r�pondu\003"
				}
			}
			::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00314i!i\003\00315!i!\003\00314 tirage d'un nombre al�atoire entre 1 et 100 afin de d�terminer si le bot a le droit de r�pondre : \003\00307$coin\003"
			if {
				([channel get $chan megahal_respond])
				&& ($triggered ne "")
			} then {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 au moins un mot cl� pr�sent dans la liste \$trigger_words a �t� match� (\003\00307 $triggered \003\00314)\003"
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 le bot a \003\00307$::megahal_interface::keyreplyrate%\003\00314 de chances de r�pondre si un mot cl� est prononc� (flag +megahal_respond).\003"
			} else {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 aucun mot cl� n'a �t� match� ou flag -megahal_respond.\003"
			}
			if { [channel get $chan megahal_chatter] } {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 Le bot a \003\00307$::megahal_interface::replyrate%\003\00314 de chances de r�pondre � tout (flag +megahal_chatter).\003"
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
			::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \002\00305i!i\003\00304!i!\003\002\00314 La parole n'a pas �t� autoris�e apr�s passage en revue des crit�res.\003"
		}
		return 0
	}
}

 ###############################################################################
### Autorisation de r�pondre ? (3�me passe : apr�s passage de la moulinette,
### v�rification que la r�ponse ne commence pas par une commande)
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
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 la r�ponse contient une commande ne faisant pas partie des commandes autoris�es ( \00307[lindex [split $text] 0]\00314 )\003"
			} else {
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00303i!i\003\00309!i!\003\00314 la r�ponse n'est pas une commande ou fait partie des commandes autoris�es.\003"
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
			::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \002\00305i!i\003\00304!i!\003\002\00314 La parole n'a pas �t� autoris�e apr�s passage en revue des crit�res.\003"
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
### (retourne 1 si l'autorisation est donn�e, sinon 0)
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
	# On lance un timer qui servira � savoir si le bot a d�j� r�pondu � $nick
	# il y a moins de $::megahal_interface::reply_interval secondes, afin d'�viter
	# plusieurs r�ponses rapproch�es � la m�me personne.
	set ::megahal_interface::floodlock_reply($clean_chan,$clean_nick) 1
	after [expr {$::megahal_interface::reply_interval * 1000}] [list ::megahal_interface::unfloodlock_reply $clean_chan $clean_nick]
	# Affichage d'une r�ponse neutre avant la r�ponse principale si $2nd_neutral_reply est activ�
	if {
		($::megahal_interface::2nd_neutral_reply)
		&& ($source eq "internal")
		&& ([set coin [rand 101]] <= $::megahal_interface::2nd_neutral_reply_rate)
		&& ([set coin2 [rand 2]])
	} then {
		# Remarque : le 1er argument signifie "r�ponse ajout�e par Responder"
		# (0=non 1=oui)
		lappend ::megahal_interface::talk_queue [list 0 $chan [subst [lindex $::megahal_interface::2nd_neutral_pre_reply_list [rand [llength $::megahal_interface::2nd_neutral_pre_reply_list]]]]]
	}
	# On retarde la r�ponse pour simuler la vitesse de frappe
	# (coeff * sqrt(nombre de caract�res) + offset)
	# On ajoute la r�ponse du bot dans la file d'attente, elle sera trait�e apr�s
	# le d�lai.
	lappend ::megahal_interface::talk_queue [list 0 $chan $reply]
	# Affichage d'une r�ponse neutre apr�s la r�ponse principale si
	# $2nd_neutral_reply est activ�;
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
		::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00314i!i\003\00315!i!\003 \00314queue de r�ponses ([llength $::megahal_interface::talk_queue]): $::megahal_interface::talk_queue\003"
	}
}

 ###############################################################################
### Traitement de la file d'attente de parole
 ###############################################################################
proc ::megahal_interface::delayed_talk {} {
	# Si la file d'attente de r�ponses est vide, on arr�te.
	if { ![llength $::megahal_interface::talk_queue] } {
		set ::megahal_interface::delayed_talk_running 0
		return
	} else {
		set ::megahal_interface::delayed_talk_running 1
	}
	lassign [lindex $::megahal_interface::talk_queue 0] is_from_responder chan
	# Si la r�ponse ne provient pas de Responder...
	if { !$is_from_responder } {
		regsub -all {[\}\{\[\]\$"\\]} [lindex $::megahal_interface::talk_queue 0 2] {\\&} reply
		set output "puthelp \"PRIVMSG $chan :$reply\""
		set delay [expr {round(($::megahal_interface::reply_speed_coeff * sqrt([::tcl::string::length $reply])) + $::megahal_interface::reply_speed_offset) * 1000}]
		# Le 1er argument est le type (0=N/A 1=normal 2=notice 3=/me)
		# Le 2�me argument signifie "ajouter au log ?" (0=non 1=oui)
		after $delay ::megahal_interface::display_response [list 1 1 $chan $output $reply]
	# Si la r�ponse provient de Responder...
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
		::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00314i!i\003\00315!i!\003 \00314R�ponse dans [expr {$delay / 1000}]s \00314--$chan-->\003 $output\003"
	}
 	return
}

 ###############################################################################
### Affichage d'une r�ponse sur un chan
 ###############################################################################
proc ::megahal_interface::display_response {type add_to_log chan output reply} {
	eval $output
	# On �crit dans le log du chan ce que le bot dit car le logger interne ne le
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
	# on �limine la 1�re r�ponse de la file d'attente car elle a �t� trait�e
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
### Suppression d'un floodlock_reply (floodlock_reply = MegaHAL ne r�pond plus �
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
			::megahal_interface::display_output log - - "\00304\[MEGAHAL\] \002Mode TAGUEULE d�sactiv� sur $chan apr�s [set ::megahal_interface::shutup_time]mn\002\003"
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
				"masterswitch" { lappend help_list "\002.[set ::megahal_interface::masterswitch_cmd]\002\ \00314<\003on\00314/\003off\00314>\003 : active/d�sactive l'I.A. sur le chan en cours" }
				"learnstate" { lappend help_list "\002.[set ::megahal_interface::learnstate_cmd]\002 \00314<\003on\00314/\003off\00314>\003 : active/d�sactive l'apprentissage sur le chan en cours" }
				"respondstate" { lappend help_list "\002.[set ::megahal_interface::respondstate_cmd]\002 \00314<\003on\00314/\003off\00314>\003 : active/d�sactive la r�ponse sur d�tection de mots cl�s sur le chan en cours" }
				"chatterstate" { lappend help_list "\002.[set ::megahal_interface::chatterstate_cmd]\002 \00314<\003on\00314/\003off\00314>\003 : active/d�sactive la libre expression sur le chan en cours" }
				"replyrate" { lappend help_list "\002.[set ::megahal_interface::replyrate_cmd]\002 \00314\[\003taux de r�ponse\00314\]\003 : interrogation/r�glage du taux de r�ponse g�n�ral sur le chan en cours" }
				"keyreplyrate" { lappend help_list "\002.[set ::megahal_interface::keyreplyrate_cmd]\002 \00314\[\003taux de r�ponse\00314\]\003 : interrogation/r�glage du taux de r�ponse en cas d'utilisation de mot cl� sur le chan en cours" }
				"forget" { lappend help_list "\002.[set ::megahal_interface::forget_cmd]\002 \00314<\003phrase\00314>\003 : force l'I.A. � oublier une phrase" }
				"forgetword" { lappend help_list "\002.[set ::megahal_interface::forgetword_cmd]\002 \00314<\003mot\00314>\003 : force l'I.A. � oublier toutes les occurrences d'un mot (toutes les phrases contenant ce mot seront �galement oubli�es)" }
				"seekstatement" { lappend help_list "\002.[set ::megahal_interface::seekstatement_cmd]\002 \00314<\003phrase\00314>\003 : v�rifie si l'I.A. connait une phrase donn�e" }
				"countword" { lappend help_list "\002.[set ::megahal_interface::countword_cmd]\002 \00314<\003mot\00314>\003 : v�rifie si l'I.A. connait un mot donn� et en compte toutes les occurrences." }
				"learnfile" { lappend help_list "\002.[set ::megahal_interface::learnfile_cmd]\002 \00314<\003chemin/fichier\00314>\003 : apprend le contenu d'un fichier � l'I.A." }
				"savebrain" { lappend help_list "\002.[set ::megahal_interface::savebrain_cmd]\002 : sauvegarde l'I.A." }
				"reloadbrain" { lappend help_list "\002.[set ::megahal_interface::reloadbrain_cmd]\002 : recharge l'I.A." }
				"reloadphrases" { lappend help_list "\002.[set ::megahal_interface::reloadphrases_cmd]\002 : recharge les phrases" }
				"trimbrain" { lappend help_list "\002.[set ::megahal_interface::trimbrain_cmd]\002 \00314\[\003nombre de nodes\00314\]\003 : �lague l'I.A.; si le nombre de nodes n'est pas sp�cifi�, utilise la valeur de \$::maxsize" }
				"lobotomy" { lappend help_list "\002.[set ::megahal_interface::lobotomy_cmd]\002 : effectue un lavage de cerveau." }
				"restorebrain" { lappend help_list "\002.[set ::megahal_interface::restorebrain_cmd]\002 : recharge un backup de l'I.A. (apr�s un $::megahal_interface::lobotomy_cmd)" }
				"chanstatus" { lappend help_list "\002.[set ::megahal_interface::chanstatus_cmd]\002 : affiche le statut de l'I.A." } 
				"braininfo" { lappend help_list "\002.[set ::megahal_interface::braininfo_cmd]\002 : affiche des informations sur l'I.A." }
				"memusage" { lappend help_list "\002.[set ::megahal_interface::memusage_cmd]\002 : affiche une estimation de la quantit� de m�moire utilis�e par l'I.A." }
				"treesize" { lappend help_list "\002.[set ::megahal_interface::treesize_cmd]\002 : affiche des statistiques sur une branche ou une sous-branche" }
				"viewbranch" { lappend help_list "\002.[set ::megahal_interface::viewbranch_cmd]\002 : affiche le contenu d'une branche ou d'une sous-branche" }
				"make_words" { lappend help_list "\002.[set ::megahal_interface::make_words_cmd]\002 : retourne une phrase sp�cifi�e, telle qu'elle sera m�moris�e par l'I.A., en mettant en �vidence les caract�res \"glue\" servant � emp�cher la dissociation de ce qui les entoure." }
				"debug_output" { lappend help_list "\002.[set ::megahal_interface::debug_output_cmd]\002 : soumet une phrase � make_words, puis a make_output dans le but de voir l'impact du module MegaHAL sur la construction de la phrase s'il essayait de la restituer" }
				"getwordsymbol" { lappend help_list "\002.[set ::megahal_interface::getwordsymbol_cmd]\002 : retourne l'index (num�rique) d'un mot, qui pourra ensuite �tre utilis� avec .viewbranch pour voir les associations li�es � ce mot" }
				"moulinex_in" { lappend help_list "\002.[set ::megahal_interface::moulinex_in_cmd]\002 : soumet une phrase au traitement par la moulinette entrante de l'Interface MegaHAL, afin de voir de quelle fa�on elle serait modifi�e lors de l'apprentissage" }
				"moulinex_out" { lappend help_list "\002.[set ::megahal_interface::moulinex_out_cmd]\002 : soumet une phrase au traitement par la moulinette sortante de l'Interface MegaHAL, afin de voir de quelle fa�on elle serait modifi�e si le bot s'en resservait" }
				"megaver" { lappend help_list "\002.[set ::megahal_interface::megaver_cmd]\002 : affiche la version du module et de l'interface" }
				"force_L_R" { lappend help_list "\002[set ::megahal_interface::force_L_R_cmd]\002\00314<\003phrase\00314>\003 : force MegaHAL � apprendre + r�pondre" }
				"force_noL_R" { lappend help_list "\002[set ::megahal_interface::force_noL_R_cmd]\002\00314<\003phrase\00314>\003 : force MegaHAL � ne pas apprendre + r�pondre" }
				"force_L_noR" { lappend help_list "\002[set ::megahal_interface::force_L_noR_cmd]\002\00314<\003phrase\00314>\003 : force MegaHAL � apprendre + ne pas r�pondre" }
				"force_noL_noR" { lappend help_list "\002[set ::megahal_interface::force_noL_noR_cmd]\002\00314<\003phrase\00314>\003 : force MegaHAL � ne pas apprendre + ne pas r�pondre" }
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
### Ajout d'une ligne � la file d'attente non-prioritaire d�di�e � l'affichage
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
### Traitement de la file d'attente non-prioritaire d�di�e � l'affichage de
### l'aide.
 ###############################################################################
proc ::megahal_interface::process_long_message_queue {} {
	# Si la file d'attente "help" n'est pas vide, on reporte � plus tard.
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
		# On �limine le 1er message de la file d'attente car il a �t� trait�.
		set ::megahal_interface::long_message_queue [lreplace $::megahal_interface::long_message_queue 0 0]
		# Si la file d'attente est vide, on arr�te.
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
		::megahal_interface::display_output help PRIVMSG $chan "\037Syntaxe\037 : \002$::megahal_interface::masterswitch_cmd\002 \00314<\003on\00314/\003off\00314>\003 \00307|\003 Active/d�sactive l'I.A. sur $chan."
		return
	} elseif { $arg eq "on" } {
		if { [channel get $chan megahal] == 0 } {
			channel set $chan +megahal
			::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}L'I.A. est maintenant activ�e sur $chan."
		} else {
			::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}L'I.A. est d�j� activ�e sur $chan."
		}
	} elseif { $arg eq "off" } {
		if { [channel get $chan megahal] == 1 } {
			channel set $chan -megahal
			::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}L'I.A. est maintenant d�sactiv�e sur $chan."
		} else {
			::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}L'I.A. est d�j� d�sactiv�e sur $chan."
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
			::megahal_interface::display_output help PRIVMSG $chan "\037Syntaxe\037 : \002$::megahal_interface::learnstate_cmd\002 \00314<\003on\00314/\003off\00314>\003 \00307|\003 Active/d�sactive l'apprentissage sur $chan."
			return
		} elseif { $arg eq "on" } {
			if { [channel get $chan megahal_learn] == 0 } {
				channel set $chan +megahal_learn
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}L'apprentissage est maintenant activ� sur $chan (\003\003${::megahal_interface::secondary_color}[set ::megahal_interface::learnrate]%\003\003${::megahal_interface::main_color} de chances)."
			} else {
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}L'apprentissage est d�j� activ� sur $chan (\003\003${::megahal_interface::secondary_color}[set ::megahal_interface::learnrate]%\003\003${::megahal_interface::main_color} de chances)."
			}
		} elseif { $arg eq "off" } {
			if { [channel get $chan megahal_learn] == 1 } {
				channel set $chan -megahal_learn
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}L'apprentissage est maintenant d�sactiv� sur $chan."
			} else {
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}L'apprentissage est d�j� d�sactiv� sur $chan."
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
			::megahal_interface::display_output help PRIVMSG $chan "\037Syntaxe\037 : \002$::megahal_interface::respondstate_cmd\002 \00314<\003on\00314/\003off\00314>\003 \00307|\003 Active/d�sactive la r�ponse sur d�tection de mots cl�s sur $chan."
			return
		} elseif { $arg eq "on" } {
			if { [channel get $chan megahal_respond] == 0 } {
				channel set $chan +megahal_respond
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}La r�ponse sur d�tection de mots cl�s est maintenant activ�e sur $chan (\003\003${::megahal_interface::secondary_color}[set ::megahal_interface::keyreplyrate]%\003\003${::megahal_interface::main_color} de chances)."
			} else {
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}La r�ponse sur d�tection de mots cl�s est d�j� activ�e sur $chan (\003\003${::megahal_interface::secondary_color}[set ::megahal_interface::keyreplyrate]%\003\003${::megahal_interface::main_color} de chances)."
			}
		} elseif { $arg eq "off" } {
			if { [channel get $chan megahal_respond] == 1 } {
				channel set $chan -megahal_respond
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}La r�ponse sur d�tection de mots cl�s est maintenant d�sactiv�e sur $chan."
			} else {
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}La r�ponse sur d�tection de mots cl�s est d�j� d�sactiv�e sur $chan."
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
			::megahal_interface::display_output help PRIVMSG $chan "\037Syntaxe\037 : \002$::megahal_interface::chatterstate_cmd\002 \00314<\003on\00314/\003off\00314>\003 \00307|\003 Active/d�sactive la libre expression sur $chan."
			return
		} elseif { $arg eq "on" } {
			if { [channel get $chan megahal_chatter] == 0 } {
				channel set $chan +megahal_chatter
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}La libre expression est maintenant activ�e sur $chan (\003\003${::megahal_interface::secondary_color}[set ::megahal_interface::replyrate]%\003\003${::megahal_interface::main_color} de chances)."
			} else {
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}La libre expression est d�j� activ�e sur $chan (\003\003${::megahal_interface::secondary_color}[set ::megahal_interface::replyrate]%\003\003${::megahal_interface::main_color} de chances)."
			}
		} elseif { $arg eq "off" } {
			if { [channel get $chan megahal_chatter] == 1 } {
				channel set $chan -megahal_chatter
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}La libre expression est maintenant d�sactiv�e sur $chan."
			} else {
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}La libre expression est d�j� d�sactiv�e sur $chan."
			}
		}
	}
}

 ###############################################################################
### Interrogation / r�glage du taux de r�ponse g�n�ral
 ###############################################################################
proc ::megahal_interface::pub_replyrate {nick host hand chan arg} {
	if { ![channel get $chan megahal] } {
		return
	} else {
	 if { $arg == "" } {
 		::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}Taux de r�ponses actuellement d�fini � \003\003${::megahal_interface::secondary_color}[set ::megahal_interface::replyrate]%"
 	} else {
		 set ::megahal_interface::replyrate $arg
		 ::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}Taux de r�ponses d�fini � \003\003${::megahal_interface::secondary_color}[set ::megahal_interface::replyrate]%"
	 }
	}
}

 ###############################################################################
### Interrogation / r�glage du taux de r�ponse en cas d'utilisation de mot cl�
 ###############################################################################
proc ::megahal_interface::pub_keyreplyrate {nick host hand chan arg} {
	if { ![channel get $chan megahal] } {
		return
	} else {
	 if { $arg == "" } {
 		::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}Taux de r�ponses si mot cl� d�tect� actuellement d�fini � \003\003${::megahal_interface::secondary_color}[set ::megahal_interface::keyreplyrate]%"
 	} else {
		 variable keyreplyrate $arg
		 ::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}Taux de r�ponses si mot cl� d�tect� d�fini � \003\003${::megahal_interface::secondary_color}[set ::megahal_interface::keyreplyrate]%"
	 }
	}
}

 ###############################################################################
### Elagage/sauvegarde automatique de la personnalit�
 ###############################################################################
proc ::megahal_interface::auto_savebrain {min hour day month year} {
	trimbrain $::maxsize
	if { $::megahal_interface::verbose_automatisms } {
		::megahal_interface::display_output log - - "\00314\[$::megahal_interface::scriptname\]\003 Personnalit� �lagu�e."
	}
	savebrain
	if { $::megahal_interface::verbose_automatisms } {
		::megahal_interface::display_output log - - "\00314\[$::megahal_interface::scriptname\]\003 Personnalit� sauvegard�e."
	}
}
proc ::megahal_interface::on_event_savebrain {type} {
	trimbrain $::maxsize
	::megahal_interface::display_output log - - "\00314\[$::megahal_interface::scriptname\]\003 Personnalit� �lagu�e."
	savebrain
	::megahal_interface::display_output log - - "\00314\[$::megahal_interface::scriptname\]\003 Personnalit� sauvegard�e."
	if {
		($type eq "prerestart")
		|| ($type eq "prerehash")
	} then {
		::megahal_interface::uninstall
	}
}

 ###############################################################################
### Sauvegarde manuelle de la personnalit�
 ###############################################################################
proc ::megahal_interface::pub_savebrain {nick host hand chan arg} {
	if { ![channel get $chan megahal] } {
		return
	} else {
		savebrain
		::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}Personnalit� sauvegard�e."
	}
}
proc ::megahal_interface::dcc_savebrain {hand idx arg} {
	savebrain
	::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}Personnalit� sauvegard�e."
}

 ###############################################################################
### Re-lecture de la personnalit� � partir du fichier brain
 ###############################################################################
proc ::megahal_interface::pub_reloadbrain {nick host hand chan arg} {
	if { ![channel get $chan megahal] } {
		return
	} else {
		reloadbrain
		::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}Personnalit� recharg�e."
	}
}
proc ::megahal_interface::dcc_reloadbrain {hand idx arg} {
	reloadbrain
	::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}Personnalit� recharg�e."
}

 ###############################################################################
### Re-lecture des phrases (fichier .phr)
 ###############################################################################
proc ::megahal_interface::pub_reloadphrases {nick host hand chan arg} {
	if { ![channel get $chan megahal] } {
		return
	} else {
		reloadphrases
		::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}Phrases recharg�es."
	}
}
proc ::megahal_interface::dcc_reloadphrases {hand idx arg} {
	reloadphrases
	::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}Phrases recharg�es."
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
	set message "\003${::megahal_interface::main_color}Personnalit� �lagu�e �\003 \003${::megahal_interface::secondary_color}[set arg]\003 \003${::megahal_interface::main_color}noeuds d'association."
	if { $is_dcc } {
		::megahal_interface::display_output dcc - $idx $message
	} else {
		::megahal_interface::display_output help PRIVMSG $chan "$message"
	}
}

 ###############################################################################
### Cr�ation d'un backup puis effacement complet de la personnalit�
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
	set message "\003${::megahal_interface::main_color}Lobotomie effectu�e. Cr�ation d'une nouvelle personnalit�..."
	if { $is_dcc } {
		::megahal_interface::display_output dcc - $idx $message
	} else {
		::megahal_interface::display_output help PRIVMSG $chan "$message"
	}
}

 ###############################################################################
### Restauration d'un backup de la personnalit� apr�s une lobotomie
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
		set message "\003${::megahal_interface::main_color}L'ancienne personnalit� a �t� restaur�e."
		if { $is_dcc } {
			::megahal_interface::display_output dcc - $idx $message
		} else {
    	::megahal_interface::display_output help PRIVMSG $chan "$message"
    }
  } else {
		set message "\003${::megahal_interface::main_color}L'ancienne personnalit� n'a pas �t� trouv�e ou est incompl�te."
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
			::megahal_interface::display_output help PRIVMSG $chan "\037Syntaxe\037 : \002${::megahal_interface::pub_command_prefix}$::megahal_interface::forget_cmd\002 \00314<\003phrase\00314>\003 \00307|\003 Force l'I.A. � oublier une phrase."
		} else {
			if { $::megahal_interface::substitute_all_nicks } {
				set arg [::megahal_interface::substitute_nicks "sentence" $chan $arg]
			}
			set arg [::tcl::string::map {\031 \047} $arg]
			set result [::megahal_search $arg 1]
			if { $result eq "" } {
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}Je ne connais pas de phrase ressemblant � �a."
			} else {
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}J'ai trouv�\003 \003${::megahal_interface::secondary_color}[set result]\003\003${::megahal_interface::main_color}, je vais tenter de l'oublier."
			}
		}
	}
}
proc ::megahal_interface::dcc_forget {hand idx arg} {
	if { $arg eq "" } {
		::megahal_interface::display_output dcc - $idx "\037Syntaxe\037 : \002.$::megahal_interface::forget_cmd\002 \00314<\003phrase\00314>\003 \00307|\003 Force l'I.A. � oublier une phrase."
	} else {
		set arg [::tcl::string::map {\031 \047} $arg]
		set result [::megahal_search $arg 1]
		if { $result eq "" } {
			::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}Je ne connais pas de phrase ressemblant � �a."
		} else {
			::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}J'ai trouv�\003 \003${::megahal_interface::secondary_color}[set result]\003\003${::megahal_interface::main_color}, je vais tenter de l'oublier."
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
			::megahal_interface::display_output help PRIVMSG $chan "\037Syntaxe\037 : \002${::megahal_interface::pub_command_prefix}$::megahal_interface::forgetword_cmd\002 \00314<\003mot\00314>\003 \00307|\003 Force l'I.A. � oublier toutes les occurrences d'un mot. Veuillez noter que toutes les phrases contenant ce mot seront �galement oubli�es."
		} else {
			if { $::megahal_interface::substitute_all_nicks } {
				set arg [::megahal_interface::substitute_nicks "word" $chan $arg]
			}
			set arg [::tcl::string::map {\031 \047} $arg]
			set result [::megahal_searchword $arg 1]
			if { !$result } {
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}Je ne connais pas ce mot."
			} else {
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}J'ai trouv�\003 \003${::megahal_interface::secondary_color}[set arg]\003 \003${::megahal_interface::main_color}dans\003 \003${::megahal_interface::secondary_color}[set result]\003 \003${::megahal_interface::main_color}[::megahal_interface::plural $result "association" "associations"]. Toutes les occurrences ont �t� oubli�es."
			}
		}
	}
}
proc ::megahal_interface::dcc_forgetword {hand idx arg} {
	if { [set arg [lindex [split $arg] 0]] eq "" } {
		::megahal_interface::display_output dcc - $idx "\037Syntaxe\037 : \002.$::megahal_interface::forgetword_cmd\002 \00314<\003mot\00314>\003 \00307|\003 Force l'I.A. � oublier toutes les occurrences d'un mot. Veuillez noter que toutes les phrases contenant ce mot seront �galement oubli�es."
	} else {
		set arg [::tcl::string::map {\031 \047} $arg]
		set result [::megahal_searchword $arg 1]
		if { !$result } {
			::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}Je ne connais pas ce mot."
		} else {
			::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}J'ai trouv�\003 \003${::megahal_interface::secondary_color}[set arg]\003 \003${::megahal_interface::main_color}dans\003 \003${::megahal_interface::secondary_color}[set result]\003 \003${::megahal_interface::main_color}[::megahal_interface::plural $result "association" "associations"]. Toutes les occurrences ont �t� oubli�es."
		}
	}
}

 ###############################################################################
### V�rifier si l'I.A. conna�t une phrase donn�e
 ###############################################################################
proc ::megahal_interface::pub_seekstatement {nick host hand chan arg} {
	if { ![channel get $chan megahal] } {
		return
	} else {
		if { $arg eq "" } {
			::megahal_interface::display_output help PRIVMSG $chan "\037Syntaxe\037 : \002${::megahal_interface::pub_command_prefix}$::megahal_interface::seekstatement_cmd\002 \00314<\003phrase\00314>\003 \00307|\003 Recherche dans le cerveau de l'I.A. si une phrase donn�e est connue."
		} else {
			if { $::megahal_interface::substitute_all_nicks } {
				set arg [::megahal_interface::substitute_nicks "sentence" $chan $arg]
			}
			set arg [::tcl::string::map {\031 \047} $arg]
			set result [::megahal_search $arg 0]
			if { $result eq "" } {
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}Je ne connais pas de phrase ressemblant � �a."
			} else {
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}J'ai trouv�\003 \003${::megahal_interface::secondary_color}[set result]"
			}
		}
	}
}
proc ::megahal_interface::dcc_seekstatement {hand idx arg} {
	if { $arg eq "" } {
		::megahal_interface::display_output dcc - $idx "\037Syntaxe\037 : \002.$::megahal_interface::seekstatement_cmd\002 \00314<\003phrase\00314>\003 \00307|\003 Recherche dans le cerveau de l'I.A. si une phrase donn�e est connue."
	} else {
		set arg [::tcl::string::map {\031 \047} $arg]
		set result [::megahal_search $arg 0]
		if { $result eq "" } {
			::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}Je ne connais pas de phrase ressemblant � �a."
		} else {
			::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}J'ai trouv�\003 \003${::megahal_interface::secondary_color}[set result]"
		}
	}
}

 ###############################################################################
### Compter le nombre d'associations pour un mot donn�
 ###############################################################################
proc ::megahal_interface::pub_countword {nick host hand chan arg} {
	if { ![channel get $chan megahal] } {
		return
	} else {
		if { $arg eq "" } {
			::megahal_interface::display_output help PRIVMSG $chan "\037Syntaxe\037 : \002${::megahal_interface::pub_command_prefix}$::megahal_interface::countword_cmd\002 \00314<\003mot\00314>\003 \00307|\003 Compte le nombre d'associations pour un mot donn�."
		} else {
			if { $::megahal_interface::substitute_all_nicks } {
				set arg [::megahal_interface::substitute_nicks "word" $chan $arg]
			}
			set arg [::tcl::string::map {\031 \047} $arg]
			set result [::megahal_searchword $arg 0]
			if { !$result } {
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}Je ne connais pas ce mot."
			} else {
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}J'ai trouv�\003 \003${::megahal_interface::secondary_color}[set arg]\003 \003${::megahal_interface::main_color}dans\003 \003${::megahal_interface::secondary_color}[set result]\003 \003${::megahal_interface::main_color}[::megahal_interface::plural $result "association" "associations"]."
			}
		}
	}
}
proc ::megahal_interface::dcc_countword {hand idx arg} {
	if { $arg eq "" } {
		::megahal_interface::display_output dcc - $idx "\037Syntaxe\037 : \002.$::megahal_interface::countword_cmd\002 \00314<\003mot\00314>\003 \00307|\003 Compte le nombre d'associations pour un mot donn�."
	} else {
		set arg [::tcl::string::map {\031 \047} $arg]
		set result [::megahal_searchword $arg 0]
		if { !$result } {
			::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}Je ne connais pas ce mot."
		} else {
			::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}J'ai trouv�\003 \003${::megahal_interface::secondary_color}[set arg]\003 \003${::megahal_interface::main_color}dans\003 \003${::megahal_interface::secondary_color}[set result]\003 \003${::megahal_interface::main_color}[::megahal_interface::plural $result "association" "associations"]."
		}
	}
}

 ###############################################################################
### Apprend le contenu d'un fichier � l'I.A.
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
			::megahal_interface::display_output dcc - $idx "\037Syntaxe\037 : \002.$::megahal_interface::learnfile_cmd\002 \00314<\003nom et emplacement du fichier\00314>\003 \00307|\003 Apprend le contenu d'un fichier � l'I.A."
		} else {
			::megahal_interface::display_output help PRIVMSG $chan "\037Syntaxe\037 : \002${::megahal_interface::pub_command_prefix}$::megahal_interface::learnfile_cmd\002 \00314<\003nom et emplacement du fichier\00314>\003 \00307|\003 Apprend le contenu d'un fichier � l'I.A."
		}
		return
	}
	if { [file readable $arg] } {
		learnfile $arg
		set message "\003${::megahal_interface::main_color}Le contenu du fichier\003 \003${::megahal_interface::secondary_color}[set arg]\003 \003${::megahal_interface::main_color}a �t� appris."
		if { $is_dcc } {
			::megahal_interface::display_output dcc - $idx $message
		} else {
			::megahal_interface::display_output help PRIVMSG $chan "$message"
		}
	} else {
		set message "\003${::megahal_interface::main_color}Le fichier\003 \003${::megahal_interface::secondary_color}[set arg]\003 \003${::megahal_interface::main_color}n'existe pas ou je n'ai pas les autorisations n�cessaires pour y acc�der."
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
		set output "\003${::megahal_interface::main_color}Je connais actuellement\003 \003${::megahal_interface::secondary_color}[lindex $for 0]\003 \003${::megahal_interface::main_color}mots organis�s en\003 \003${::megahal_interface::secondary_color}[expr {[lindex $for 1]+[lindex $back 1]}]\003 \003${::megahal_interface::main_color}noeuds d'association."
		if {[file exists megahal.brn.old]} {
			append output " \003${::megahal_interface::main_color}Mon apprentissage a d�but� le\003 \003${::megahal_interface::secondary_color}[strftime "%d/%m/%Y\003 \003${::megahal_interface::main_color}�\003 \003${::megahal_interface::secondary_color}%Hh%M" [file mtime megahal.brn.old]]\003\003${::megahal_interface::main_color}."
		}
		::megahal_interface::display_output help PRIVMSG $chan $output
		if { ![channel get $chan megahal_chatter] } {
	 		set output "\003${::megahal_interface::main_color}Sur \003\003${::megahal_interface::secondary_color}$chan\003\003${::megahal_interface::main_color}, ma libre expression est d�sactiv�e, "
		} else {
			set output "\003${::megahal_interface::main_color}Sur \003\003${::megahal_interface::secondary_color}$chan\003\003${::megahal_interface::main_color}, j'ai\003 \003${::megahal_interface::secondary_color}[set ::megahal_interface::replyrate]%\003 \003${::megahal_interface::main_color}de chances de r�pondre � tout, "
		}
		if { ![channel get $chan megahal_respond] } {
			append output "je ne r�agis pas lorsqu'on parle de moi, "
		} else {
			append output "j'ai \003\003${::megahal_interface::secondary_color}[set ::megahal_interface::keyreplyrate]%\003 \003${::megahal_interface::main_color}de chances de r�pondre quand on parle de moi, "
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
			::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}Les phrases que je construis ne d�passent jamais\003 \003${::megahal_interface::secondary_color}[set ::maxreplywords]\003 \003${::megahal_interface::main_color}mots, sont choisies dans un contexte d'une profondeur de\003 \003${::megahal_interface::secondary_color}[set ::mega_order]\003 \003${::megahal_interface::main_color}niveaux et l'improvisation est\003 \003${::megahal_interface::secondary_color}[if { $::surprise } { set dummy "activ�e" } { set dummy "d�sactiv�e" }]\003\003${::megahal_interface::main_color}."
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
### Affiche une estimation de la quantit� de m�moire utilis�e par l'I.A.
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
	set message "\003${::megahal_interface::main_color}Estimation de la quantit� de m�moire utilis�e par l'I.A. :\003 \003${::megahal_interface::secondary_color}[::megahal_interface::octet_formatting [::megahal_expmem]]\003\003${::megahal_interface::main_color}."
	if { $is_dcc } {
		::megahal_interface::display_output dcc - $idx $message
	} else {
		::megahal_interface::display_output help PRIVMSG $chan "$message"
	}
}

 ###############################################################################
### Affiche des statistiques sur une branche ou une sous-branche dans le cerveau
### de l'I.A. (nombre de branches (mots), nombre de noeuds d'association, nombre
### de branches au niveau sup�rieur/inf�rieur, compteur d'utilisation).
### Si un num�ro de branche est sp�cifi�, affiche une sous-branche des 2
### arborescences principales.
### Il est possible de sp�cifier si vous souhaitez la branche parente ou la
### branche fille.
 ###############################################################################
proc ::megahal_interface::pub_treesize {nick host hand chan arg} {
	if { ![channel get $chan megahal] } {
		return
	} else {
		if { $arg eq "" } {
			::megahal_interface::display_output help PRIVMSG $chan "\037Syntaxe\037 : \002${::megahal_interface::pub_command_prefix}$::megahal_interface::treesize_cmd\002 \00314<\003n� de branche\00314> \[\003parente/fille (1/0)\00314\]\003 \00307|\003 Affiche des statistiques sur une branche ou une sous-branche dans le cerveau de l'I.A. (nombre de branches (mots), nombre de noeuds d'association, nombre de branches au niveau sup�rieur/inf�rieur, compteur d'utilisation). Si un num�ro de branche est sp�cifi�, affiche une sous-branche des 2 arborescences principales."
		} else {
			::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}[::treesize $arg]"
		}
	}
}
proc ::megahal_interface::dcc_treesize {hand idx arg} {
	if { $arg eq "" } {
		::megahal_interface::display_output dcc - $idx "\037Syntaxe\037 : \002.[set ::megahal_interface::treesize_cmd]\002 \00314<\003n� de branche\00314> \[\003parente/fille (1/0)\00314\]\003 \00307|\003 Affiche des statistiques sur une branche ou une sous-branche dans le cerveau de l'I.A. (nombre de branches (mots), nombre de noeuds d'association, nombre de branches au niveau sup�rieur/inf�rieur, compteur d'utilisation). Si un num�ro de branche est sp�cifi�, affiche une sous-branche des 2 arborescences principales."
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
			::megahal_interface::display_output help PRIVMSG $chan "\037Syntaxe\037 : \002${::megahal_interface::pub_command_prefix}$::megahal_interface::viewbranch_cmd\002 \00314<\003n� de branche\00314> \[\003parente/fille (1/0)\00314\]\003 \00307|\003 Affiche le contenu d'une branche ou d'une sous-branche dans le cerveau de l'I.A."
		} else {
			set output [split [::viewbranch $arg] "\n"]
			if { [::tcl::string::match "Branche *" [join $output]] } {
				::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}[join $output]"
			} else {
				if { [set num_elements [expr {[llength $output] - 1}]] > $::megahal_interface::pub_viewbranch_max } {
					::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}Cette branche comporte [set num_elements] [::megahal_interface::plural $num_elements "�l�ment" "�l�ments"], mais l'affichage d'une branche sur un chan est limit� � $::megahal_interface::pub_viewbranch_max [::megahal_interface::plural $::megahal_interface::pub_viewbranch_max "ligne" "lignes"]."
				} else {
					::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}[set num_elements] [::megahal_interface::plural $num_elements "�l�ment" "�l�ments"] dans cette branche :"
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
		::megahal_interface::display_output dcc - $idx "\037Syntaxe\037 : \002$::megahal_interface::viewbranch_cmd\002 \00314<\003n� de branche\00314> \[\003parente/fille (1/0)\00314\]\003 \00307|\003 Affiche le contenu d'une branche ou d'une sous-branche dans le cerveau de l'I.A."
	} else {
		set output [split [::viewbranch $arg] "\n"]
		if { [::tcl::string::match "Branche *" [join $output]] } {
			::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}[join $output]"
		} else {
			::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}[set num_elements [expr {[llength $output] - 1}]] [::megahal_interface::plural $num_elements "�l�ment" "�l�ments"] dans cette branche :"
			foreach element [split [::viewbranch $arg] "\n"] {
				if { $element ne "" } {
					::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}[set element]"
				}
			}
		}
	}
}

 ###############################################################################
### Retourne une phrase sp�cifi�e, telle qu'elle sera m�moris�e par l'I.A., en
### mettant en �vidence les caract�res "glue" servant � emp�cher la
### dissociation de ce qui les entoure
 ###############################################################################
proc ::megahal_interface::pub_make_words {nick host hand chan arg} {
	if { ![channel get $chan megahal] } {
		return
	} else {
		if { $arg eq "" } {
			::megahal_interface::display_output help PRIVMSG $chan "\037Syntaxe\037 : \002${::megahal_interface::pub_command_prefix}$::megahal_interface::make_words_cmd\002 \00314<\003phrase\00314>\003 \00307|\003 retourne une phrase sp�cifi�e, telle qu'elle sera m�moris�e par l'I.A., en mettant en �vidence les caract�res \"glue\" servant � emp�cher la dissociation de ce qui les entoure."
		} else {
			::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}[::tcl::string::map "\" \037\" \"\00307|\003\003${::megahal_interface::main_color}\"" [join [::megahal_make_words [::tcl::string::map {\031 \047} $arg]]]]"
		}
	}
}
proc ::megahal_interface::dcc_make_words {hand idx arg} {
	if { $arg eq "" } {
		::megahal_interface::display_output dcc - $idx "\037Syntaxe\037 : \002.$::megahal_interface::make_words_cmd\002 \00314<\003phrase\00314>\003 \00307|\003 retourne une liste des mots contenus dans la phrase sp�cifi�e, telle qu'elle sera m�moris�e par l'I.A."
	} else {
		::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}[::megahal_make_words [::tcl::string::map {\031 \047} $arg]]"
	}
}

 ###############################################################################
### Soumet une phrase � make_words, puis a make_output dans le but de voir
### l'impact du module MegaHAL sur la construction de la phrase s'il essayait
### de la restituer.
 ###############################################################################
proc ::megahal_interface::pub_debug_output {nick host hand chan arg} {
	if { ![channel get $chan megahal] } {
		return
	} else {
		if { $arg eq "" } {
			::megahal_interface::display_output help PRIVMSG $chan "\037Syntaxe\037 : \002${::megahal_interface::pub_command_prefix}$::megahal_interface::debug_output_cmd\002 \00314<\003phrase\00314>\003 \00307|\003 soumet une phrase � make_words, puis a make_output dans le but de voir l'impact du module MegaHAL sur la construction de la phrase s'il essayait de la restituer."
		} else {
			::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}[::megahal_debug_output [::tcl::string::map {\031 \047} $arg]]"
		}
	}
}
proc ::megahal_interface::dcc_debug_output {hand idx arg} {
	if { $arg eq "" } {
		::megahal_interface::display_output dcc - $idx "\037Syntaxe\037 : \002.$::megahal_interface::debug_output_cmd\002 \00314<\003phrase\00314>\003 \00307|\003 soumet une phrase � make_words, puis a make_output dans le but de voir l'impact du module MegaHAL sur la construction de la phrase s'il essayait de la restituer."
	} else {
		::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}[::megahal_debug_output [::tcl::string::map {\031 \047} $arg]]"
	}
}

 ###############################################################################
### Retourne l'index (num�rique) d'un mot, qui pourra ensuite �tre utilis� avec
### .viewbranch pour voir les associations li�es � ce mot.
 ###############################################################################
proc ::megahal_interface::pub_getwordsymbol {nick host hand chan arg} {
	if { ![channel get $chan megahal] } {
		return
	} else {
		if { $arg eq "" } {
			::megahal_interface::display_output help PRIVMSG $chan "\037Syntaxe\037 : \002${::megahal_interface::pub_command_prefix}$::megahal_interface::getwordsymbol_cmd\002 \00314<\003mot\00314>\003 \00307|\003 retourne l'index (num�rique) d'un mot, qui pourra ensuite �tre utilis� avec .viewbranch pour voir les associations li�es � ce mot."
		} else {
			::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}[::megahal_getwordsymbol [::tcl::string::map {\031 \047} $arg]]"
		}
	}
}
proc ::megahal_interface::dcc_getwordsymbol {hand idx arg} {
	if { $arg eq "" } {
		::megahal_interface::display_output dcc - $idx "\037Syntaxe\037 : \002.$::megahal_interface::getwordsymbol_cmd\002 \00314<\003mot\00314>\003 \00307|\003 retourne l'index (num�rique) d'un mot, qui pourra ensuite �tre utilis� avec .viewbranch pour voir les associations li�es � ce mot."
	} else {
		::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}[::megahal_getwordsymbol [::tcl::string::map {\031 \047} $arg]]"
	}
}

 ###############################################################################
### Soumet une phrase au traitement par la moulinette entrante de l'Interface
### MegaHAL, afin de voir de quelle fa�on elle serait modifi�e lors de
### l'apprentissage.
 ###############################################################################
proc ::megahal_interface::pub_moulinex_in {nick host hand chan arg} {
	if { ![channel get $chan megahal] } {
		return
	} else {
		if { $arg eq "" } {
			::megahal_interface::display_output help PRIVMSG $chan "\037Syntaxe\037 : \002${::megahal_interface::pub_command_prefix}$::megahal_interface::moulinex_in_cmd\002 \00314<\003phrase\00314>\003 \00307|\003 soumet une phrase au traitement par la moulinette entrante de l'Interface MegaHAL, afin de voir de quelle fa�on elle serait modifi�e lors de l'apprentissage."
		} else {
			::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}[::megahal_interface::moulinex_in learn $nick $chan [::tcl::string::map {\031 \047} $arg]]"
		}
	}
}
proc ::megahal_interface::dcc_moulinex_in {hand idx arg} {
	if { $arg eq "" } {
		::megahal_interface::display_output dcc - $idx "\037Syntaxe\037 : \002.$::megahal_interface::moulinex_in_cmd\002 \00314<\003phrase\00314>\003 \00307|\003 soumet une phrase au traitement par la moulinette entrante de l'Interface MegaHAL, afin de voir de quelle fa�on elle serait modifi�e lors de l'apprentissage."
	} else {
		::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}[::megahal_interface::moulinex_in learn [hand2nick $hand] - [::tcl::string::map {\031 \047} $arg]]"
	}
}

 ###############################################################################
### Soumet une phrase au traitement par la moulinette sortante de l'Interface
### MegaHAL, afin de voir de quelle fa�on elle serait modifi�e si le bot s'en
### resservait.
 ###############################################################################
proc ::megahal_interface::pub_moulinex_out {nick host hand chan arg} {
	if { ![channel get $chan megahal] } {
		return
	} else {
		if { $arg eq "" } {
			::megahal_interface::display_output help PRIVMSG $chan "\037Syntaxe\037 : \002${::megahal_interface::pub_command_prefix}$::megahal_interface::moulinex_out_cmd\002 \00314<\003phrase\00314>\003 \00307|\003 soumet une phrase au traitement par la moulinette sortante de l'Interface MegaHAL, afin de voir de quelle fa�on elle serait modifi�e si le bot s'en resservait."
			return
		} else {
			::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}[::megahal_interface::moulinex_out $nick $hand $chan "@" [::tcl::string::map {\031 \047} $arg]]"
		}
	}
}
proc ::megahal_interface::dcc_moulinex_out {hand idx arg} {
	if { $arg eq "" } {
		::megahal_interface::display_output dcc - $idx "\037Syntaxe\037 : \002.$::megahal_interface::moulinex_out_cmd\002 \00314<\003phrase\00314>\003 \00307|\003 soumet une phrase au traitement par la moulinette sortante de l'Interface MegaHAL, afin de voir de quelle fa�on elle serait modifi�e si le bot s'en resservait."
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
		::megahal_interface::display_output help PRIVMSG $chan "\003${::megahal_interface::main_color}module MegaHAL v3.5 par Zev ^Baron^ Toledano et Jason Hutchens - Artixed Edition\003 \003${::megahal_interface::secondary_color}|\003 \003${::megahal_interface::main_color}Interface MegaHAL v[set ::megahal_interface::version] �2007-2016 Menz Agitat"
	}
}
proc ::megahal_interface::dcc_megaver {hand idx arg} {
	::megahal_interface::display_output dcc - $idx "\003${::megahal_interface::main_color}module MegaHAL v3.5 par Zev ^Baron^ Toledano et Jason Hutchens - Artixed Edition\003 \003${::megahal_interface::secondary_color}|\003 \003${::megahal_interface::main_color}Interface MegaHAL v[set ::megahal_interface::version] �2007-2016 Menz Agitat"
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
### Suppression espaces en double, espaces en d�but/fin de ligne, codes de
### couleur / gras / soulign� / ...
 ###############################################################################
proc ::megahal_interface::strip_codes_trim_spaces {text} { 
	return [::tcl::string::trim [regsub -all {\s+} [::tcl::string::map {"\017" ""} [stripcodes abcgru $text]] " "]]
}

 ###############################################################################
### Neutralisation des caract�res qui choquent Tcl.
 ###############################################################################
proc ::megahal_interface::neutralize_special_chars {data} {
	return [::tcl::string::map {"\[" "@1" "\]" "@2" "\\" "@3" "\|" "@4" "\{" "@5" "\}" "@6" "\^" "@7" "\$" "@8"} $data]
}

 ###############################################################################
### Restauration des caract�res qui choquent Tcl.
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
### M�lange al�atoire des �l�ments d'une liste
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
### Contr�le du flood
### Le param�tre action peut valoir "check" ou "add_instance"
### (retourne 1 si flood d�tect�, 0 sinon)
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
				::megahal_interface::display_output log - - "\00304\[MEGAHAL DEBUG\]\003 \00305i!i\003\00304!i!\003\00314 flood d�tect� sur $chan -> instances \003\00307$::megahal_interface::instance($chan) \003\00314 >= \003\00307$::megahal_interface::floodlimiter\003"
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
### Traitement des donn�es avant apprentissage ou soumission � getreply
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
	# On filtre "$::botnick>" "$::botnick:" "$::botnick," ... en d�but de phrase.
	regsub -nocase "^\[@&~%\+\]?[set regexpable_botnick]\\s?(\[^a-z\\s\]+)\\s?" $text "" text
	# On filtre les timestamp de la forme [timestamp] et (timestamp) dans les
	# copier/coller.
	regsub -all {(\[|\()[0-9:\.]+(\]|\))} $text "" text
	# On filtre les pseudos de la forme <nick> dans les copier/coller.
	regsub -all {^(\s+)?(<|\()[^(>|\))]*(>|\))} $text "" text
	# On filtre les pseudos de type HL en d�but de ligne comme "pseudo >" ou
	# "pseudo :" ...
	if { [regexp {^\s?@?([^\s]+)\s?[>\|:,~�]+(.*)} $text {} match] } {
		if {
			(($chan ne "-")
			&& ([onchan $match $chan]))
			|| ([onchan $match])
		} then {
			set text [::tcl::string::trimleft [regsub {^\s?@?[^\s]+\s?(>+|:|,|~|�)(.*)} $text {\2}]]
		}
	}
	# Ajout d'un "� " en d�but de ligne (il nous servira de rep�re dans les string
	# map).
	set text "� $text"
	# Ajout d'un "." en fin de ligne (il nous servira de rep�re dans les string
	# map).
	if { [::tcl::string::index $text end] ne "." } {
		set text "$text."
	}
	# Substitutions diverses vous pouvez utiliser les variables $::botnick,
	# $::nick, $nick et $chan.
	set text [::tcl::string::map -nocase [list\
		"" ""
	] $text]
	# On supprime le "� " en d�but de ligne.
	regsub {^� } $text "" text
	# On supprime le "." en fin de ligne sauf s'il est pr�c�d� d'un autre "."
	regsub {([^\.])\.$} $text {\1} text
	# Supprime la plupart des $::botnick restants dans le texte, sauf quand la
	# construction de la phrase le rend indispensable.
	regsub -all -nocase "(^| |')(((de|avec|via|mon|ton|son|vers|sur|sous|par|pour|contre|en|dans|ce|le|une?|et|�|a|est?|nom+es?|ap+el+e?s?|nom est|dit) $regexpable_botnick)|$regexpable_botnick)\s?(\[\\.\\?,!:;=\]|\\^+|\[:X;=8>\]\[<D\\(\\)\\\[\\\]\\{\\}p\]|$)" $text {\1\3 \5} text
	regsub -all -nocase "^$regexpable_botnick (?!ne\\s|n'|l'|m'|t'|s'|se\\s|est\\s|sera|�tait|va\\s|allait|ira\\s|fait\\s|fera|ferait|faisait|me\\s|te\\s|se\\s|met|a\\s|avait|aura|perd|peut|veut|voulait|voudra|appren|dit|dira|disait)" $text "" text
	if {
		($::megahal_interface::substitute_all_nicks)
		&& ($chan ne "-")
	} then {
		# On rep�re si la phrase contient des nicks de personnes pr�sentes sur le
		# chan, et si oui on remplace par oooooousernickmd5oooooo (le md5 sert � ne
		# pas avoir des centaines de fois l'entr�e "oooooousernickoooooo" dans le
		# brain, auquel cas il aurait un poids �norme et serait souvent utilis� par
		# l'I.A. pour construire des phrases.
		set text [::megahal_interface::substitute_nicks "sentence" $chan $text]
	}
	return $text
}

 ###############################################################################
### Traitement des r�ponses avant affichage
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
	# Supprime Botnick en d�but de phrase si suivi par > : , . ...
	regsub -nocase "^@?$regexpable_botnick ?(>+|:|~|�|,|\\.+) ?" $text "" text
	# Ajout d'un "� " en d�but de ligne (il nous servira de rep�re dans les string
	# map).
	set text "� $text"
	# Ajout d'un "." en fin de ligne (il nous servira de rep�re dans les string
	# map).
	if { [::tcl::string::index $text end] ne "." } {
		set text "$text."
	}
	# Substitution du nick de l'Eggdrop par le nick de la personne � qui il r�pond.
	if { [rand 101] <= $::megahal_interface::nickswitchrate } {
		set text [::tcl::string::map -nocase "$::botnick [split $nick]" $text]
	}
	# Substitutions diverses vous pouvez utiliser les variables $::botnick,
	# $::nick, $nick et $chan.
	set text [::tcl::string::map -nocase [list\
		"I am utterly speechless!"							"\003${::megahal_interface::main_color}les mots me manquent...\003"\
		"I forgot what I was going to say!"			"\003${::megahal_interface::main_color}j'ai... oubli� ce que je voulais dire\003"\
		"� pourquoi tan"												"� pourquoi tan"\
		"� pourquoi"														"parce que"\
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
		"��"																		"\037��\037"
		",."																		"."
		" susi "																" suis "
		"sa va"																	"�a va"
	} $text]
	set userlist [::megahal_interface::randomize_list [chanlist $chan]]
	if { ($::megahal_interface::substitute_all_nicks) && ($chan ne "-") } {
		# On remplace les oooooousernickoooooo par des nicks al�atoires pris sur le
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
				# oooooousernickoooooo soit remplac� par le nick de l'interlocuteur,
				# sauf s'il est pr�sent dans $nick_substitution_exclusion_list.
				if {
					!($interlocutor_is_excluded_from_substitution)
					&& !($interlocutor_nick_substitued)
					&& (($targetnick_substitued) || ($targetnick eq "@") || ([::tcl::string::equal -nocase $targetnick $::nick]))
					&& ([set coin [rand 101]] <= $::megahal_interface::substitute_by_interlocutor_nick_rate)
				} then {
					lset split_text $index $nick
					set interlocutor_nick_substitued 1
				# Si un nick a �t� cit� dans la phrase d'origine et qu'il ne s'agit pas
				# de celui de l'Eggdrop, il sera r�utilis� dans la r�ponse.
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
	# Si n�cessaire, on corrige la casse des caract�res dans les nicks des
	# personnes pr�sentes sur le chan.
	if { $chan ne "-" } {
	foreach current_nick $userlist {
		set text [::tcl::string::map {"  " " "} [::tcl::string::map -nocase [list\
				" $current_nick " " $current_nick " " $current_nick." " $current_nick."\
				"�$current_nick " "�$current_nick " "�$current_nick." "�$current_nick."\
				".$current_nick " ".$current_nick " ".$current_nick." ".$current_nick."\
				" $current_nick;" " $current_nick;" "�$current_nick;" "�$current_nick;"\
				";$current_nick " ";$current_nick " ";$current_nick." ";$current_nick."\
				" $current_nick," " $current_nick," "�$current_nick," "�$current_nick,"\
				",$current_nick " ",$current_nick " ",$current_nick." ",$current_nick."\
				" $current_nick:" " $current_nick:" "�$current_nick:" "�$current_nick:"\
				":$current_nick " ":$current_nick " ":$current_nick." ":$current_nick."\
				" $current_nick!" " $current_nick!" "�$current_nick!" "�$current_nick!"\
				"!$current_nick " "!$current_nick " "!$current_nick." "!$current_nick."\
				" $current_nick?" " $current_nick?" "�$current_nick?" "�$current_nick?"\
				"?$current_nick " "?$current_nick " "?$current_nick." "?$current_nick."\
			] [::tcl::string::map {" " "  "} $text]]]
		}
	}
	# On supprime le "� " en d�but de ligne.
	regsub {^� } $text "" text
	# On supprime le "." en fin de ligne sauf s'il est pr�c�d� d'un autre "."
	regsub {([^\.])\.$} $text {\1} text
	# Supprime la plupart des $::botnick restants dans la r�ponse, sauf quand la
	# construction de la phrase le rend indispensable.
	regsub -all -nocase "(^| )(((de|avec|via|mon|ton|son|vers|sur|sous|par|pour|contre|en|dans|ce|le|une?|et|�|a|est?|nom+es?|ap+el+e?s?|nom est|dit) $regexpable_botnick)|$regexpable_botnick) ?(\[\\.\\?,!:;=\]|\\^+|\[:X;8>\]\[<D\\(\\)\\\[\\\]\\{\\}p\]|$)" $text {\1\3 \5} text
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
### mode +c est d�tect� sur le chan, ou si la couleur est d�sactiv�e
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
### Affichage d'un texte, filtrage des styles si n�cessaire.
### * queue peut valoir help, quick, now, serv, dcc, log ou loglev
### * method peut valoir PRIVMSG ou NOTICE et sera ignor� si queue vaut dcc ou
###      loglev
### * target peut �tre un nick, un chan ou un idx, et sera ignor� si queue vaut
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
		# regsub sur une cha�ne de caract�res.
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
### Si l'Eggdrop vient juste de se connecter au serveur, l'I.A. est activ�e
### apr�s un d�lai afin d'�viter l'encombrement des files d'attente de messages.
 ###############################################################################
proc ::megahal_interface::resume_on_connect {args} {
	after [expr {$::megahal_interface::IA_activation_delay * 1000}] {
		bind pubm - * ::megahal_interface::process_pub_msg
		bind ctcp - ACTION ::megahal_interface::process_ctcp_action
	}
	return
}

 ###############################################################################
### Si l'Eggdrop est d�connect� du serveur, l'I.A. est mise en pause.
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
### Backup quotidien des bases de donn�es
 ###############################################################################
proc ::megahal_interface::backup_db {min hour day month year} {
	if { $::megahal_interface::verbose_automatisms } {
		::megahal_interface::display_output log - - "\003${::megahal_interface::main_color}\[$::megahal_interface::scriptname\]\003 Sauvegarde des bases de donn�es..."
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
### Mise en minuscules, y compris les caract�res accentu�s
 ###############################################################################
proc ::megahal_interface::tolower {text} {
	return [::tcl::string::tolower [::tcl::string::map {
		"�" "�" "�" "�" "�" "�"
		"�" "�" "�" "�" "�" "�" "�" "�"
		"�" "�" "�" "�"
		"�" "�" "�" "�"
		"�" "�" "�" "�" "�" "�"
		"�" "�" "�" "�" "�" "�" "�" "�"
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
	# Binds destin�s � forcer une sauvegarde du brain au cas o� il arrive quelque
	# chose � l'Eggdrop qui pourrait provoquer la perte du brain non-sauvegard�.
	bind evnt - prerehash ::megahal_interface::on_event_savebrain
	bind evnt - prerestart ::megahal_interface::on_event_savebrain
	bind evnt - sigquit ::megahal_interface::on_event_savebrain
	bind evnt - sighup ::megahal_interface::on_event_savebrain
	bind evnt - sigterm ::megahal_interface::on_event_savebrain
	bind evnt - sigill ::megahal_interface::on_event_savebrain
	bind evnt - disconnect-server ::megahal_interface::on_event_savebrain
	# Bind destin� � activer l'I.A. apr�s un d�lai � la connection au serveur.
	bind evnt - init-server ::megahal_interface::resume_on_connect
	# Bind destin� � mettre l'I.A. en pause en cas de d�connection du serveur.
	bind evnt - disconnect-server ::megahal_interface::pause_on_disconnect
	# Si l'Eggdrop est d�j� connect� au serveur, l'I.A. est imm�diatement
	# disponible.
	if { $::server ne "" } {
		bind pubm - * ::megahal_interface::process_pub_msg
		bind ctcp - ACTION ::megahal_interface::process_ctcp_action
	}
}


putlog "$::megahal_interface::scriptname v$::megahal_interface::version (�2007-2016 Menz Agitat) a �t� charg�"
