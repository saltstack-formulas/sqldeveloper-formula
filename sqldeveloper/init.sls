{%- from 'sqldeveloper/settings.sls' import sqldeveloper with context %}

{#- require a source_url - there may be no default download location for sqldeveloper #}

{%- if sqldeveloper.source_url is defined %}

  {%- set archive_file = sqldeveloper.prefix + '/' + sqldeveloper.source_url.split('/') | last %}

#runtime dependency
sqldeveloper-libaio1:
  pkg.installed:
    {%- if salt['grains.get']('os') == 'Ubuntu' or salt['grains.get']('os') == 'SUSE' %}
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
sqldeveloper-remove-prev-archive:
  file.absent:
    - name: {{ archive_file }}
    - require:
      - file: sqldeveloper-install-dir

download-sqldeveloper-archive:
  cmd.run:
    - name: curl {{ sqldeveloper.dl_opts }} -o '{{ archive_file }}' '{{ sqldeveloper.source_url }}'
    - require:
      - file: sqldeveloper-remove-prev-archive

unpack-sqldeveloper-archive-to-realhome:
  archive.extracted:
    - name: {{ sqldeveloper.prefix }}
    - source: file://{{ archive_file }}
    - archive_format: {{ sqldeveloper.archive_type }}
  {%- if sqldeveloper.source_hash %}
    - source_hash: {{ sqldeveloper.source_hash }}
  {%- endif %}
  {% if grains['saltversioninfo'] < [2016, 11, 0] %}
    - if_missing: {{ sqldeveloper.sqldeveloper_realcmd }}
  {% endif %}
    - require:
      - cmd: download-sqldeveloper-archive
    - onchanges:
      - cmd: download-sqldeveloper-archive

update-sqldeveloper-home-symlink:
  file.symlink:
    - name: {{ sqldeveloper.orahome }}/sqldeveloper
    - target: {{ sqldeveloper.sqldeveloper_real_home }}
    - force: True
    - require:
      - archive: unpack-sqldeveloper-archive-to-realhome
    - onchanges:
      - archive: unpack-sqldeveloper-archive-to-realhome

sqldeveloper-desktop-entry:
  file.managed:
    - source: salt://sqldeveloper/files/sqldeveloper.desktop
    - name: /home/{{ pillar['user'] }}/Desktop/sqldeveloper.desktop
    - user: {{ pillar['user'] }}
  {% if salt['grains.get']('os_family') == 'Suse' or salt['grains.get']('os') == 'SUSE' %}
    - group: users
  {% else %}
    - group: {{ pillar['user'] }}
  {% endif %}
    - mode: 755
    - require:
      - archive: unpack-sqldeveloper-archive-to-realhome
    - onchanges:
      - archive: unpack-sqldeveloper-archive-to-realhome

remove-sqldeveloper-archive:
  file.absent:
    - name: {{ archive_file }}
    - require:
      - archive: unpack-sqldeveloper-archive-to-realhome
      
{%- endif %}
