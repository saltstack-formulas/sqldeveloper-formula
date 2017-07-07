{%- from 'sqldeveloper/settings.sls' import sqldeveloper with context %}

{#- require a source_url - there may be no default download location for sqldeveloper #}

{%- if sqldeveloper.source_url is defined %}

  {%- set archive_file = sqldeveloper.prefix + '/' + sqldeveloper.source_url.split('/') | last %}
  {%- set extract_dir  = sqldeveloper.prefix + '/sqldeveloper' %} 

sqldeveloper-libaio1:
  pkg.installed:
    - name: libaio1

sqldeveloper-install-dir:
  file.directory:
    - names:
      - {{ sqldeveloper.prefix }}
      - {{ sqldeveloper.orahome }}
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

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
    - if_missing: {{ extract_dir }}
    - onchanges:
      - cmd: download-sqldeveloper-archive
  file.absent:
    - name: {{ sqldeveloper.sqldeveloper_real_home }}
    - require:
      - archive: unpack-sqldeveloper-archive-to-realhome
  cmd.run:
    - name: mv {{ extract_dir }} {{ sqldeveloper.sqldeveloper_real_home }}
    - require:
      - file: unpack-sqldeveloper-archive-to-realhome

update-sqldeveloper-home-symlink:
  file.symlink:
    - name: {{ sqldeveloper.orahome }}/sqldeveloper
    - target: {{ sqldeveloper.sqldeveloper_real_home }}
    - force: True
    - require:
      - cmd: unpack-sqldeveloper-archive-to-realhome

remove-sqldeveloper-archive:
  file.absent:
    - name: {{ archive_file }}

include:
  - sqldeveloper.env

{%- endif %}
