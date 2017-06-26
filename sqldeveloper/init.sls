{%- from 'sqldeveloper/settings.sls' import sqldeveloper with context %}

{#- require a source_url - there may be no default download location for sqldeveloper #}

{%- if sqldeveloper.source_url is defined %}

  {%- set archive_file = sqldeveloper.prefix + '/' + sqldeveloper.source_url.split('/') | last %}

libaio1:
  pkg.installed

sqldeveloper-install-dir:
  file.directory:
    - name: {{ sqldeveloper.prefix }}
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

download-sqldeveloper-archive:
  cmd.run:
    - name: curl {{ sqldeveloper.dl_opts }} -o '{{ archive_file }}' '{{ sqldeveloper.source_url }}'
    - unless: test -d {{ sqldeveloper.sqldeveloper_real_home }} || test -f {{ archive_file }}
    - require:
      - file: sqldeveloper-install-dir

unpack-sqldeveloper-archive:
  archive.extracted:
    - name: {{ sqldeveloper.prefix }}
    - source: file://{{ archive_file }}
    {%- if sqldeveloper.source_hash3 %}
    - source_hash: sha256={{ sqldeveloper.source_hash3 }}
    {%- endif %}
    - archive_format: {{ sqldeveloper.archive_type }}
    - options: {{ sqldeveloper.unpack_opts }}
    - user: root
    - group: root
    - if_missing: {{ sqldeveloper.sqldeveloper_real_home }}
    - onchanges:
      - cmd: download-instantclient-devel-tarball

update-sqldeveloper-home-symlink:
  file.symlink:
    - name: {{ sqldeveloper.sqldeveloper_home }}
    - target: {{ sqldeveloper.sqldeveloper_real_home }}
    - force: True
    - require:
      - unpack-instantclient-basic-tarball
      - unpack-instantclient-sqldeveloper-tarball
      - unpack-instantclient-devel-tarball

remove-instantclient-basic-tarball:
  file.absent:
    - name: {{ archive_file1 }}

remove-instantclient-sqldeveloper-tarball:
  file.absent:
    - name: {{ archive_file2 }}

remove-instantclient-devel-tarball:
  file.absent:
    - name: {{ archive_file3 }}

include:
  - sqldeveloper.env

{%- endif %}
