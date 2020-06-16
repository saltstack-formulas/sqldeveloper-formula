# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import sqldeveloper with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

{%- if sqldeveloper.environ_file %}
    {%- if sqldeveloper.pkg.use_upstream_macapp %}
        {%- set sls_package_install = tplroot ~ '.macapp.install' %}
    {%- else %}
        {%- set sls_package_install = tplroot ~ '.archive.install' %}
    {%- endif %}

include:
  - {{ sls_package_install }}

sqldeveloper-config-file-file-managed-environ_file:
  file.managed:
    - name: {{ sqldeveloper.environ_file }}
    - source: {{ files_switch(['environ.sh.jinja'],
                              lookup='sqldeveloper-config-file-file-managed-environ_file'
                 )
              }}
    - mode: 644
    - user: {{ sqldeveloper.identity.rootuser }}
    - group: {{ sqldeveloper.identity.rootgroup }}
    - makedirs: True
    - template: jinja
    - context:
              {%- if sqldeveloper.pkg.use_upstream_macapp %}
        path: /Applications/{{ sqldeveloper.pkg.name }}.app/Contents/MacOS
              {%- else %}
        path: {{ sqldeveloper.path }}
              {%- endif %}
        environ: {{ '' if not sqldeveloper.environ else sqldeveloper.environ|json }}
    - require:
      - sls: {{ sls_package_install }}

{%- endif %}
