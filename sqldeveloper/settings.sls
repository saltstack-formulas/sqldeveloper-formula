{% set p  = salt['pillar.get']('sqldeveloper', {}) %}
{% set g  = salt['grains.get']('sqldeveloper', {}) %}

{%- set oracle_release = g.get('oracle_release', p.get('oracle_release', '12_2')) %}
{%- set orahome = salt['grains.get']('orahome', salt['pillar.get']('orahome', '/opt/oracle/' + oracle_release + '/' )) %}

{%- set release         = g.get('release', p.get('release', '4')) %}
{%- set minor           = g.get('minor', p.get('minor', '2'))  %}
{%- set version         = g.get('version', p.get('version', release + '.' + minor + '.0.17.089.1709' )) %}

## ######## YOU MUST CHANGE TO LOCAL MIRROR DUE TO LICENSE ACCEPTANCE/LOGIN REQ. ####### #}
{%- set mirror  = 'http://download.oracle.com/otn/java/sqldeveloper/' %}

{%- set default_archive_type = 'zip' %}
{%- set default_prefix       = '/usr/share/oracle/' + oracle_release + '/' %}
{%- set default_source_url   = mirror + '/sqldeveloper-' + version + '-no-jre.' + default_archive_type %}
{%- set default_source_hash  = 'md5=158f54967e563a013b9656918e628427' %}

{%- set source_url           = g.get('source_url', p.get('source_url', default_source_url )) %}
{%- if source_url == default_source_url %}
  {%- set source_hash        = default_source_hash %}
{%- else %}
  {%- set source_hash        = g.get('source_hash', p.get('source_hash', default_source_hash )) %}
{%- endif %}

{%- set default_dl_opts      = ' -s ' %}
{%- set default_symlink      = '/usr/bin/sqldeveloper' %}
{%- set default_real_home    = default_prefix + 'sqldeveloper' %}
{%- set default_alt_priority = '30' %}

{%- set prefix                 = g.get('prefix', p.get('prefix', default_prefix )) %}
{%- set dl_opts                = g.get('dl_opts', p.get('dl_opts', default_dl_opts )) %}
{%- set archive_type           = g.get('archive_type', p.get('archive_type', default_archive_type )) %}
{%- set sqldeveloper_symlink   = g.get('symlink', p.get('symlink', default_symlink )) %}
{%- set sqldeveloper_real_home = g.get('real_home', p.get('real_home', default_real_home )) %}
{%- set alt_priority           = g.get('alt_priority', p.get('alt_priority', default_alt_priority )) %}

{%- set sqldeveloper_realcmd   = sqldeveloper_real_home + '/sqldeveloper/bin/sqldeveloper' %}

{%- set sqldeveloper = {} %}
{%- do sqldeveloper.update( {   'release'               : release,
                                'minor'                 : minor,
                                'version'               : version,
                                'source_url'            : source_url,
                                'source_hash'           : source_hash,
                                'orahome'               : orahome,
                                'dl_opts'               : dl_opts,
                                'archive_type'          : archive_type,
                                'prefix'                : prefix,
                                'sqldeveloper_real_home': sqldeveloper_real_home,
                                'sqldeveloper_symlink'  : sqldeveloper_symlink,
                                'sqldeveloper_realcmd'  : sqldeveloper_realcmd,
                                'alt_priority'          : alt_priority,
                        }) %}
