#/packages/acs-lang/tcl/lang-message-procs.tcl
ad_library {

    Routines for displaying web pages in multiple languages
    <p>
    This is free software distributed under the terms of the GNU Public
    License.  Full text of the license is available from the GNU Project:
    http://www.fsf.org/copyleft/gpl.html

    @creation-date 10 September 2000
    @author Jeff Davis (davis@arsdigita.com)
    @author Bruno Mattarollo (bruno.mattarollo@ams.greenpeace.org)
    @author Peter Marklund (peter@collaboraid.biz)
    @author Lars Pind (lars@collaboraid.biz)
    @cvs-id $Id: lang-message-procs.tcl,v 1.13 2002/11/12 22:34:19 peterm Exp $
}

namespace eval lang::message {

    ad_proc -public register { 
        locale
        package_key
        message_key
        message
    } { 
        Registers a message in a given locale or language.
        Inserts the message key into the database if it
        doesn't already exists. Inserts the message itself
        in the given locale into the database if it doesn't
        exist and updates it if it does. Also updates the
        cache with the message.
    
        @author Jeff Davis (davis@arsdigita.com)
        @author Bruno Mattarollo (bruno.mattarollo@ams.greenpeace.org)
        @author Christian Hvid

        @see _mr
        
        @param locale        Locale or language of the message. If a language is supplied,
                             the default locale for the language is looked up. 

        @param package_key   The package key of the package that the message belongs to.
        @param message_key   The key that identifies the message within the package.
        @param message       The message text
    } { 
        # Create a globally unique key for the cache
        set key "${message_key}"

        # Insert the message key into the database if it doesn't
        # already exist
         set key_exists_p [db_string message_key_exists_p {}]

         if { ! $key_exists_p } {
             db_dml insert_message_key {}
         }

        # Check if the $lang parameter is a language or a locale
        if { [string length $locale] == 2 } {
            # It seems to be a language (iso codes are 2 characters)
            # We don't do a more throughout check since this is not
            # invoked by users.
            # let's get the default locale for that language
            set locale [util_memoize [list ad_locale_locale_from_lang $locale]]
        } 

#         if { $key_exists_p } {
#             # The message key exists so register has been invoked before with
#             # this key. Check that embedded variables are unchanged in the new message.

#             # Attempt to get the en_US message from the cache, or get a message
#             # in any locale from the database for variable comparison
#             if { [nsv_exists lang_message_en_us $key] } { 
#                 set existing_en_us_message [nsv_get lang_message_en_US $key]
#             } else {
#                 set existing_en_us_message [db_string select_an_existing_message {}]
#             }

#             set missing_vars_list [get_missing_embedded_vars $existing_en_us_message $message]
#             if { [llength $missing_vars_list] != 0 } {
#                 error "The following variables are in the en_US message for key $message_key but not in the new message \"$message\" in locale $locale : $missing_vars_list"
#             }
#         }
    
        # Check the cache
        if { [nsv_exists lang_message_$locale $key] } { 
            # Update existing message
            set old_message [nsv_get lang_message_$locale $key]

            if { ![string equal $message $old_message] } {

                # changed message ... update.

                # Trying to avoid hitting Oracle bug#2011927
    
                if { [empty_string_p [string trim $message]] } {
                    db_dml lang_message_null_update {}
                } else { 
                    db_dml lang_message_update {} -clobs [list $message]
                }
                nsv_set lang_message_$locale $key $message
            }
        } else { 
            # Insert new message
            ns_log Debug "lang::message::register - Inserting into database message: $locale $key" 
            db_transaction {
                # As above, avoiding the bug#2011927 from Oracle.
    
                if { [empty_string_p [string trim $message]] } {
                    db_dml lang_message_insert_null_msg {}
                } else {
                    # LARS:
                    # We may need to have two different lines here, one for
                    # Oracle w/clobs, one for PG w/o clobs.
                    db_dml lang_message_insert {} -clobs [list $message]
                }
                nsv_set lang_message_$locale $key $message
            }
        }
    }

    ad_proc -private get_missing_embedded_vars {
        existing_message
        new_message
    } {
        Returns a list of variables that are in an existing message and should
        also be in a new message with the same key but a different locale.
        The set of embedded variables in the messages for a certain key
        should be identical across locales.

        @param existing_message The existing message with vars that should
                                also be in the new message
        @param new_message      The new message that we are checking for
                                consistency.

        @return The list of variables in the existing en_US message
                that are missing in the new message.

        @author Peter Marklund (peter@collaboraid.biz)
        @creation-date 12 November 2002
    } {
        # Loop over the vars in the en_US message
        set missing_variable_list [list]
        set remaining_message $existing_message
        while { [regexp [embedded_vars_regexp] $remaining_message match before_percent \
                                                                              percent_match \
                                                                              remaining_message] } {
            if { [string equal $percent_match "%%"] } {
                # A quoted percentage sign - ignore
                continue
            } else {
                # A variable - check that it is in the new message
                if { ![regexp "(?:^|\[^%]\)${percent_match}" $new_message match] } {
                    # The variable is missing
                    set variable_name [string range $percent_match 1 end-1]                    
                    lappend missing_variable_list $variable_name
                }
            }
        }

        return $missing_variable_list
    }

    ad_proc -private format {
        localized_message
        {value_array_list {}}
        {upvar_level 3}
    } {
        Substitute all occurencies of %array_key%
        in the given localized message with the value from a lookup in the value_array_list
        with array_key (what's between the percentage sings). If value_array_list is not
        provided then attempt to fetch variable values the number of levels up given by
        upvar_level (defaults to 3 because this proc is typically invoked from the underscore
        lookup proc). 

        Here is an example:

        set localized_message "The %frog% jumped across the %fence%. About 50% of the time, he stumbled, or maybe it was %%20 %times%."
        set value_list {frog frog fence fence}

        puts "[format $localized_message $value_list]"
        
        The output from the example is:

        The frog jumped across the fence. About 50% of the time, he stumbled, or maybe it was %20 %times%.
    } {        

        array set value_array $value_array_list
        set value_array_keys [array names value_array]
        set remaining_message $localized_message
        set formated_message ""
        while { [regexp [embedded_vars_regexp] $remaining_message match before_percent percent_match remaining_message] } {
    
            append formated_message $before_percent
    
            if { [string equal $percent_match "%%"] } {
                # A quoted percent sign
                append formated_message "%"
            } else {
                set variable_key [string range $percent_match 1 end-1]

                if { [llength $value_array_list] > 0 } {
                    # A substitution list is provided, the key should be in there
                    
                    if { [lsearch -exact $value_array_keys $variable_key] == -1 } {
                        ns_log Warning "lang::message::format: The value_array_list \"$value_array_list\" does not contain the variable name $variable_key found in the message: $localized_message"
                    
                        # There is no value available to do the substitution with
                        # so don't substitute at all
                        append formated_message $percent_match
                    } else {
                        # Do the substitution
                    
                        append formated_message [lindex [array get value_array $variable_key] 1]
                    }
                } else {
                    # No substitution list provided - attempt to fetch variable value
                    # from scope calling lang::message::lookup
                    upvar $upvar_level $variable_key variable_value

                    append formated_message $variable_value
                }
            }
        }

        # Append text after the last match
        append formated_message $remaining_message
    
        return $formated_message
    }
    
    ad_proc -private embedded_vars_regexp {} {
        The regexp pattern used to loop over variables embedded in 
        message catalog texts.

        @author Peter Marklund (peter@collaboraid.biz)
        @creation-date 12 November 2002
    } {
        return {^(.*?)(%%|%[a-zA-Z_\.]+%)(.*)$}
    }

    ad_proc -public lookup {
        locale
        key
	chunk
        {substitution_list {}}
        {upvar_level 2}
    } {
        This proc is normally accessed through the _ procedure.
    
        Returns a translated string for the given locale and message key.
        If the user is a translator, inserts tags to link to the translator
        interface. This allows a translator to work from the context of a web page.

        @param locale             Locale (e.g., "en_US") or language (e.g., "en") string.
                                  If locale is the empty string ad_conn locale will be used
                                  if we are in an HTTP connection, otherwise the system locale
                                  (SiteWideLocale) will be used.
        @param key                Unique identifier for this message. Will be the same 
                                  identifier for each locale. All keys belong to a certain 
                                  package and should be prefixed with the package key of that package 
                                  on the format package_key.message_key (the dot is reserved for separating 
                                  the package key, the rest of the key should contain only alpha-numeric
                                  characters and underscores). If the key does not belong to 
                                  any particular package it should not contain a dot. A lookup
                                  is always attempted with the exact key given to this proc.
        @param default            Text to return if there is no message in the message catalog for
                                  the given locale. This argument is optional. If this argument is
                                  not provided or is the empty string then the text returned will
                                  be TRANSLATION MISSING - $key.
        @param substitution_list  A list of values to substitute into the message. This argument should
                                  only be given for certain messages that contain place holders (on the syntax
                                  %var_name%) for embedding variable values, see lang::message::format.
                                  If this list is not provided and the message has embedded variables,
                                  then the variable values can be fetched with upvar from the scope
                                  calling this proc (see upvar_level).

        @param upvar_level        If there are embedded variables and no substitution list provided, this
                                  parameter specifies how many levels up to fetch the values of the variables
                                  in the message. The reason the default is 2 is that the lookup proc is
                                  usually invoked by the underscore proc (_). Set upvar level to less than
                                  1 if you don't want variable interpolation to be done.
    
        @author Jeff Davis (davis@arsdigita.com), Henry Minsky (hqm@arsdigita.com)
        @author Peter Marklund (peter@collaboraid.biz)
        @see _
        
        @return A localized piece of text.
    } { 

	set return_value ""

        if { [empty_string_p $locale] } {
            # No locale provided

            if { [ad_conn isconnected] } {
                # We are in an HTTP connection (request) so use that locale
                set locale [ad_conn locale]
            } else {
                # There is no HTTP connection - resort to system locale
                set system_locale [parameter::get -package_id [apm_package_id_from_key acs-lang] -parameter SiteWideLocale]
                set locale $system_locale
            }
        } elseif { [string length $locale] == 2 } {
            # Only language provided

            # let's get the default locale for this language
            # The cache is flushed if the default locale for this language is
            # changed.
            set locale [util_memoize [list ad_locale_locale_from_lang $locale]]    
        } 
    

	set package_key_part "core-platform" ;#[ad_conn package_key]
	set message_key_part $key


	set return_url [ad_conn url]
	if { [ns_getform] != "" } {
	    append return_url "?[export_entire_form_as_url_vars]"
	}
	
	# return_url is already encoded and HTML quoted
	set translate_url "/admin/g11n/edit-localized-message?[export_vars { { message_key $message_key_part } { locales $locale } { package_key $package_key_part } return_url }]"

        if { [nsv_exists lang_message_$locale $key] } {
            # Message exists in the given locale

            set return_value [nsv_get lang_message_$locale $key]
            # Do any variable substitutions (interpolation of variables)
            if { [llength $substitution_list] > 0 || ($upvar_level >= 1 && [string first "%" $return_value] != -1) } {
                set return_value [lang::message::format $return_value $substitution_list [expr $upvar_level + 1]]
            }
            
            if { [lang::util::translator_mode_p] } {
		global i18n_msgs
		lappend i18n_msgs [list edit $locale $translate_url $message_key_part]
                # Translator mode - return a translation link
                #{append return_value "<a href=\"$translate_url\" title=\"Edit translation of $message_key_part in $locale\"><font color=\"green\"><b>o</b></font></a>"}
            }

        } else {
            # There is no entry in the message catalog for the given locale

                if { ![lang::util::translator_mode_p] } {
                    # We are not in translator mode

		    set return_value $chunk

                } else {
                    # Translator mode - return a translation link

		    if { [nsv_exists lang_message_en_US $key] } {
			# The key exists but there is no translation in the current locale
			set us_text [nsv_get lang_message_en_US $key]
			# Do any variable substitutions (interpolation of variables)
			if { [llength $substitution_list] > 0 || ($upvar_level >= 1 && [string first "%" $us_text] != -1) } {
			    set us_text [lang::message::format $us_text $substitution_list [expr $upvar_level + 1]]
			}
		    } else {
			set us_text $chunk
		    }
            

		    global i18n_msgs
		    lappend i18n_msgs [list new $locale $translate_url $message_key_part]
                    set return_value "$us_text"
                }

        }

        return $return_value
    }

    ad_proc -private translate { 
        msg
        locale
    } {
        Translates an English string into a different language
        using Babelfish.

        Warning - october 2002: This is broken.
        
        @author            Henry Minsky (hqm@mit.edu)
        
        @param msg         String to translate
        @param lang        Abbreviation for lang in which to translate string
        @return            Translated string
    } {
        set lang [string range $locale 0 2]
        set marker "XXYYZZXX. "
        set qmsg "$marker $msg"
        set url "http://babel.altavista.com/translate.dyn?doit=done&BabelFishFrontPage=yes&bblType=urltext&url="
        set babel_result [ns_httpget "$url&lp=$lang&urltext=[ns_urlencode $qmsg]"]
        set result_pattern "$marker (\[^<\]*)"
        if [regexp -nocase $result_pattern $babel_result ignore msg_tr] {
            regsub "$marker." $msg_tr "" msg_tr
            return [string trim $msg_tr]
        } else {
            error "Babelfish translation error"
        }
    }     


    ad_proc -private cache {} {
        Loads the entire message catalog from the database into the cache.
    } {
        # We segregate messages by language. It might reduce contention
        # if we segregage instead by package. Check for problems with ns_info locks.
        global message_cache_loaded_p
        set message_cache_loaded_p 1
        
        set i 0 
        db_foreach select_locale_keys {
	    select locale, package_key, message_key, message 
	    from   lang_messages
	} {
            nsv_set lang_message_$locale "${message_key}" $message
            incr i
        }
        
        db_release_unused_handles
        
        ns_log Notice "lang::message::cache - Initialized message cache with $i rows from database"
    }

}

#####
#
# Shorthand notation procs _ and _mr
#
#####

ad_proc -public _mr { locale key message } {

    Registers a message in a given locale or language.
    Inserts the message into the table lang_messages
    if it does not exist and updates if it does.

    For backward compability - it assumes that the key 
    is the concatenation of message and package key
    like this:

    package_key.message_key

    @author Jeff Davis (davis@arsdigita.com)
    
    @param locale  Abbreviation for language of the message or the locale.
    @param key     Unique identifier for this message. Will be the same identifier
                   for each language
    @param message Text of the message

    @see lang::message::register
} {

    regexp {^([^\.]+)\.([^\.]+)$} $key match package_key message_key
    return [lang::message::register $locale $package_key $message_key $message]
}

ad_proc -public _ {
    key
    {chunk ""}
    {locale ""}
    {substitution_list {}}
} {
    Short hand proc that invokes the lang::util::lookup proc. 
    Returns a localized text from the message catalog with the locale ad_conn locale
    if invoked within a request, or the system locale otherwise.
    
    @param key        Unique identifier for this message. Will be the same identifier
                      for each locale. The key is on the format package_key.message_key

    substitution_list A list of values to substitute into the message. This argument should
                      only be given for certain messages that contain place holders (on the syntax
                      %1:pretty_name%, %2:another_pretty_name% etc) for embedding variable values.
                      If the message contains variables that should be interpolated and this argument
                      is not provided then upvar will be used to fetch the varialbe values.

    @return           A localized message
    
    @author Jeff Davis (davis@arsdigita.com)
    @author Peter Marklund (peter@collaboraid.biz)
    @author Christian Hvid (chvid@collaboraid.biz)

    @see lang::message::lookup
} {

    if { [string equal $chunk ""] } { 
	set chunk $key
    }
    return [lang::message::lookup ${locale} $key $chunk "TRANSLATION MISSING" $substitution_list]
}
