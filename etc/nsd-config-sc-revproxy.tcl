########################################################################
# Sample config file for NaviServer
########################################################################

# set http_port  [expr {[info exists env(NS_HTTP_PORT)]  ? $env(NS_HTTP_PORT) : 8080}]
# set https_port [expr {[info exists env(NS_HTTPS_PORT)] ? $env(NS_HTTPS_PORT) : ""}]
set http_port  18099
set https_port 48099
set address "0.0.0.0"  ;# one might use as well for IPv6: set address ::

set home [file dirname [file dirname [info nameofexecutable]]]
set logroot		/web/logs

########################################################################
# Global settings (for all servers)
########################################################################

ns_section ns/parameters {
    ns_param    home                $home
    ns_param    tcllibrary          tcl
    ns_param    serverlog           ${logroot}/error-rp-sc.log
}

ns_section ns/servers {
    ns_param default "Reverse proxy"
}

#
# Global modules (for all servers)
#
ns_section ns/modules {
    if {$https_port ne ""} { ns_param nsssl nsssl }
    if {$http_port ne ""}  { ns_param nssock nssock }
}

ns_section ns/module/nssock {
    ns_param    defaultserver            default
    ns_param    port                     $http_port
    ns_param    address                  $address     ;# Space separated list of IP addresses
    ns_param    maxinput                 500MB        ;# default: 1MB, maximum size for inputs (uploads)
    ns_param    closewait                0s           ;# default: 2s; timeout for close on socket
    #
    # Spooling Threads
    #
    #ns_param   spoolerthreads		1	;# default: 0; number of upload spooler threads
    ns_param    maxupload		1MB     ;# default: 0, when specified, spool uploads larger than this value to a temp file
    ns_param    writerthreads		1	;# default: 0, number of writer threads
}

ns_section ns/module/nsssl {
    ns_param    defaultserver            default
    ns_param    port                     $https_port
    ns_param    address                  $address     ;# Space separated list of IP addresses
    ns_param    maxinput                 500MB        ;# default: 1MB, maximum size for inputs (uploads)
    ns_param    closewait                0s           ;# default: 2s; timeout for close on socket
    #
    # ciphers, protocols and certificate
    #
    ns_param ciphers	"ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:ECDH+3DES:DH+3DES:RSA+AESGCM:RSA+AES:RSA+3DES:!aNULL:!MD5:!RC4"
    ns_param protocols	"!SSLv2:!SSLv3"
    ns_param certificate /web/certs/testcert.pem

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

ns_section "ns/server/default/modules" {
    ns_param    nslog               nslog
}

ns_section "ns/server/default/fastpath" {
    ns_param    pagedir             pages-revproxy
}

ns_section ns/server/default/modules {
    ns_param revproxy   tcl
}
ns_log notice "HI THERE"
ns_section ns/server/default/module/revproxy {
    ns_param filters {
        ns_register_filter postauth GET    /* ::revproxy::upstream -target http://127.0.0.1:18091/
        ns_register_filter postauth POST   /* ::revproxy::upstream -target http://127.0.0.1:18091/
        ns_register_filter postauth PUT    /* ::revproxy::upstream -target http://127.0.0.1:18091/
  }
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
ns_logctl severity Debug(connchan) 1
