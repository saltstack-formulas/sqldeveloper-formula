{% set p  = salt['pillar.get']('sqldeveloper', {}) %}
{% set g  = salt['grains.get']('sqldeveloper', {}) %}

{%- set sqldeveloper_home    = salt['grains.get']('sqldeveloper_home', salt['pillar.get']('sqldeveloper_home', '/opt/sqldeveloper')) %}

{%- set release              = g.get('release', p.get('release', '4' %}
{%- set minor                = g.get('minor', p.get('minor', '2'  %}
{%- set version		     = g.get('version', p.get('version', release + '.' + minor + '.0.17.089.1709' )) %}
{%- set version_name	     = 'sqldeveloper_' + release + '_' + minor %}
{%- set mirror               = 'http://download.oracle.com/otn/java/sqldeveloper' %}

{%- set default_prefix       = '/usr/share/oracle' %}
{%- set default_source_url   = mirror + '/sqldeveloper-' + version + '-no-jre.zip' %}
{%- set default_source_hash  = 'xxxxx' %}
{%- set default_archive_type = 'zip' %}

{%- set source_url           = g.get('source_url', p.get('source_url', default_source_url )) %}

{%- if source_url == default_source_url %}
  {%- set source_hash        = default_source_hash %}
{%- else %}
  {%- set source_hash        = g.get('source_hash', p.get('source_hash', '')) %}
{%- endif %}

{%- set default_dl_opts      = '-s --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie"' %}
{%- set default_unpack_opts  = '' %}
{%- set default_symlink	     = g.get('sqldeveloper_symlink', p.get('sqldeveloper_symlink', '/usr/bin/sqldeveloper' )) %}
{%- set default_realcmd	     = g.get('sqldeveloper_realcmd', p.get('sqldeveloper_realcmd', sqldeveloper_home + '/sqldeveloper')) %}

{%- set dl_opts		     = g.get('dl_opts', p.get('dl_opts', default_dl_opts)) %}
{%- set unpack_opts          = g.get('unpack_opts', p.get('unpack_opts', default_unpack_opts )) %}
{%- set archive_type	     = g.get('archive_format', p.get('archive_format', default_archive_type )) %}
{%- set prefix		     = g.get('prefix', p.get('prefix', default_prefix )) %}
{%- set sqldeveloper_symlink = g.get('sqldeveloper_symlink', p.get('sqldeveloper_symlink', default_symlink )) %}
{%- set sqldeveloper_realcmd = g.get('sqldeveloper_realcmd', p.get('sqldeveloper_realcmd', default_realcmd )) %}
{%- set sqldeveloper_real_home  = prefix + version_name %}

{%- set sqldeveloper = {} %}
{%- do sqldeveloper.update( {	'release'			: release,
				'minor'				: minor,
				'version'			: version,
				'source_url'			: source_url,
				'source_hash'			: source_hash,
			  	'sqldeveloper_home'		: sqldeveloper_home,
				'dl_opts'			: dl_opts,
				'unpack_opts'			: unpack_opts,
				'archive_type'			: archive_type,
				'prefix'			: prefix,
				'sqldeveloper_real_home'	: sqldeveloper_real_home,
				'sqldeveloper_symlink'		: sqldeveloper_symlink,
				'sqldeveloper_realcmd'		: sqldeveloper_realcmd,
		        }) %}
