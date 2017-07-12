{%- from 'sqldeveloper/settings.sls' import sqldeveloper with context %}

{#- require a source_url - there may be no default download location for sqldeveloper #}

{%- if sqldeveloper.source_url is defined %}

  {%- set archive_file = sqldeveloper.prefix + '/' + sqldeveloper.source_url.split('/') | last %}

#runtime dependency
sqldeveloper-libaio1:
  pkg.installed:
    {%- if salt['grains.get']('os') == 'Ubuntu' %}
    - name: libaio1
    {%- else %}
    - name: libaio
    {%- endif %}

sqldeveloper-install-dir:
  file.directory:
    - names:
      - {{ sqldeveloper.prefix }}
      - {{ sqldeveloper.orahome }}
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

# curl fails (rc=23) if file exists
{{ archive_file }}:
  file.absent:
    - require_in:
      - download-sqldeveloper-archive

download-sqldeveloper-archive:
  cmd.run:
    - name: curl {{ sqldeveloper.dl_opts }} -o '{{ archive_file }}' '{{ sqldeveloper.source_url }}'
    - require:
      - sqldeveloper-install-dir

unpack-sqldeveloper-archive-to-realhome:
  archive.extracted:
    - name: {{ sqldeveloper.prefix }}
    - source: file://{{ archive_file }}
    {%- if sqldeveloper.source_hash %}
    - source_hash: md5={{ sqldeveloper.source_hash }}
    {%- endif %}
    - archive_format: {{ sqldeveloper.archive_type }}
    - options: {{ sqldeveloper.unpack_opts }}
    - user: root
    - group: root
    - onchanges:
      - cmd: download-sqldeveloper-archive
    - require:
      - download-sqldeveloper-archive

update-sqldeveloper-home-symlink:
  file.symlink:
    - name: {{ sqldeveloper.orahome }}/sqldeveloper
    - target: {{ sqldeveloper.sqldeveloper_real_home }}
    - force: True
    - require:
      - unpack-sqldeveloper-archive-to-realhome
      - sqldeveloper-desktop-entry

#### Example requiring 'user' definition in pillar ##
sqldeveloper-desktop-entry:
  file.managed:
    - source: salt://sqldeveloper/files/sqldeveloper.desktop
    - name: /home/{{ pillar['user'] }}/Desktop/sqldeveloper.desktop
    - user: {{ pillar['user'] }}
    - group: {{ pillar['user'] }}
    - mode: 755

remove-sqldeveloper-archive:
  file.absent:
    - name: {{ archive_file }}

include:
- .env

{%- endif %}
