{% set p  = salt['pillar.get']('sqldeveloper', {}) %}
{% set g  = salt['grains.get']('sqldeveloper', {}) %}

{%- set orarelease = salt['pillar.get']('oracle_release', '12_2') %}
{%- set orahome    = salt['pillar.get']('oracle_home', '/opt/oracle/' ~ orarelease ~ '/' ) %}

{%- set release    = g.get('release', p.get('release', '4')) %}
{%- set major      = g.get('major', p.get('major', '2'))  %}
{%- set minor      = g.get('minor', p.get('minor', '0'))  %}
{%- set version    = g.get('version', p.get('version', release ~ '.' ~ major ~ '.' ~ minor ~ '.17.089.1709' )) %}

{########## YOU MUST CHANGE THIS URL TO YOUR LOCAL MIRROR ####### #}
{%- set mirror  = 'http://download.oracle.com/otn/java/sqldeveloper/' %}

{%- set default_connections_url = 'undefined' %}
{%- set default_archive_type    = 'zip' %}
{%- set default_prefix          = '/usr/share/oracle/' ~ orarelease ~ '/' %}
{%- set default_source_url      = mirror ~ '/sqldeveloper-' ~ version ~ '-no-jre.' ~ default_archive_type %}
  ###### Hash for version 4.2.0.17 linux binary ####
{%- set default_source_hash     = 'md5=158f54967e563a013b9656918e628427' %}

{%- set source_url              = g.get('source_url', p.get('source_url', default_source_url )) %}
{%- if source_url == default_source_url %}
  {%- set source_hash           = default_source_hash %}
{%- else %}
  {%- set source_hash           = g.get('source_hash', p.get('source_hash', default_source_hash )) %}
{%- endif %}

{%- set default_dl_opts         = ' -s ' %}
{%- set default_unpack_opts     = 'o' %}
{%- set default_symlink         = '/usr/bin/sqldeveloper' %}
{%- set default_real_home       = default_prefix ~ 'sqldeveloper' %}
{%- set default_alt_priority    = '30' %}

{%- set connections_url         = g.get('connections_url', p.get('connections_url', default_connections_url )) %}
{%- set prefix                  = g.get('prefix', p.get('prefix', default_prefix )) %}
{%- set dl_opts                 = g.get('dl_opts', p.get('dl_opts', default_dl_opts )) %}
{%- set unpack_opts             = g.get('unpack_opts', p.get('unpack_opts', default_unpack_opts )) %}
{%- set archive_type            = g.get('archive_type', p.get('archive_type', default_archive_type )) %}
{%- set symlink                 = g.get('symlink', p.get('symlink', default_symlink )) %}
{%- set alt_priority            = g.get('alt_priority', p.get('alt_priority', default_alt_priority )) %}
{%- set real_home               = g.get('real_home', p.get('real_home', default_real_home )) %}
{%- set realcmd                 = real_home ~ '/sqldeveloper/bin/sqldeveloper' %}

{%- set sqldeveloper = {} %}
{%- do sqldeveloper.update( {   'orahome'           : orahome,
                                'major'             : major,
                                'minor'             : minor,
                                'version'           : version,
                                'source_url'        : source_url,
                                'source_hash'       : source_hash,
                                'connections_url'   : connections_url,
                                'prefix'            : prefix,
                                'dl_opts'           : dl_opts,
                                'unpack_opts'       : unpack_opts,
                                'archive_type'      : archive_type,
                                'symlink'           : symlink,
                                'alt_priority'      : alt_priority,
                                'real_home'         : real_home,
                                'realcmd'           : realcmd,
                        }) %}
