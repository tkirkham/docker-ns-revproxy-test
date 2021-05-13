########################################################################
# Sample config file for NaviServer
########################################################################

# set http_port  [expr {[info exists env(NS_HTTP_PORT)]  ? $env(NS_HTTP_PORT) : 8080}]
# set https_port [expr {[info exists env(NS_HTTPS_PORT)] ? $env(NS_HTTPS_PORT) : ""}]
set port 18091
set address "0.0.0.0"  ;# one might use as well for IPv6: set address ::

set home [file dirname [file dirname [info nameofexecutable]]]
set logroot		/web/logs

########################################################################
# Global settings (for all servers)
########################################################################

ns_section ns/parameters {
    ns_param    home                $home
    ns_param    tcllibrary          tcl
    ns_param    serverlog           ${logroot}/error-be.log

}

ns_section ns/servers {
    ns_param default "Backend"
}

#
# Global modules (for all servers)
#
ns_section ns/modules {
    ns_param    nssock              nssock
}
ns_section ns/module/nssock {
    ns_param    defaultserver            default
    ns_param    port                     $port
    ns_param    address                  $address     ;# Space separated list of IP addresses
    ns_param    maxinput                 500MB        ;# default: 1MB, maximum size for inputs (uploads)
    ns_param    closewait                0s           ;# default: 2s; timeout for close on socket
    #
    # Spooling Threads
    #
    #ns_param   spoolerthreads          1       ;# default: 0; number of upload spooler threads
    ns_param    maxupload               1MB     ;# default: 0, when specified, spool uploads larger than this value to a temp file
    ns_param    writerthreads           1       ;# default: 0, number of writer threads
}

#
# Server mapping: define which DNS name maps to which NaviServer server configuration.
#
ns_section ns/module/nssock/servers {
    ns_param default    localhost
    ns_param default    [ns_info hostname]
}

########################################################################
#  Settings for the "default" server
########################################################################

ns_section ns/server/default {
    ns_param    enabletclpages      true  ;# default: false
    ns_param    connsperthread      1000  ;# default: 0; number of connections (requests) handled per thread
    ns_param    minthreads          5     ;# default: 1; minimal number of connection threads
    ns_param    maxthreads          100   ;# default: 10; maximal number of connection threads
    ns_param    maxconnections      100   ;# default: 100; number of allocated connection structures
    ns_param    rejectoverrun       true  ;# default: false; send 503 when thread pool queue overruns
}

ns_section ns/server/default/modules {
    ns_param    nslog               nslog
}

ns_section ns/server/default/fastpath {
    ns_param    pagedir             pages-backend
}

set ::env(RANDFILE) $home/.rnd
set ::env(HOME) $home
set ::env(LANG) en_US.UTF-8
#
# For debugging, you might activate one of the following flags
#
#ns_logctl severity Debug(ns:driver) on
#ns_logctl severity Debug(request) on
#ns_logctl severity Debug(task) on
#ns_logctl severity Debug(sql) on
#ns_logctl severity Debug on
