# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import sqldeveloper with context %}

sqldeveloper-package-archive-install-prepare:
  pkg.installed:
    - names: {{ sqldeveloper.pkg.deps|json }}
  file.directory:
    - name: {{ sqldeveloper.pkg.archive.name }}
    - user: {{ sqldeveloper.identity.rootuser }}
    - group: {{ sqldeveloper.identity.rootgroup }}
    - mode: 755
    - makedirs: True
    - clean: True
    - recurse:
        - user
        - group
        - mode

        {%- for name in sqldeveloper.pkg.wanted %}

sqldeveloper-package-archive-install-{{ name }}:
  archive.extracted:
    - name: {{ sqldeveloper.pkg.archive.name }}
    - source: {{ sqldeveloper.pkg.urls[name] }}
    - source_hash: {{ sqldeveloper.pkg.checksums[name] }}
    - trim_output: true
    - retry: {{ sqldeveloper.retry_option|json }}
    - user: {{ sqldeveloper.identity.rootuser }}
    - group: {{ sqldeveloper.identity.rootgroup }}
    - require:
      - pkg: sqldeveloper-package-archive-install-prepare
      - file: sqldeveloper-package-archive-install-prepare

        {%- endfor %}
        {%- if sqldeveloper.linux.altpriority|int == 0 or grains.os_family in ('Arch',)  %}

sqldeveloper-archive-install-file-symlink-sqldeveloper:
  file.symlink:
    - name: /usr/local/bin/sqldeveloper
    - target: {{ sqldeveloper.path }}/{{ sqldeveloper.command }}
    - force: True
    - onlyif: test -f {{ sqldeveloper.path }}/{{ sqldeveloper.command }}

        {%- endif %}
