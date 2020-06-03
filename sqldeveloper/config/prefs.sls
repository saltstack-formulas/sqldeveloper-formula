# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import sqldeveloper with context %}

{%- if 'xmlfile' in sqldeveloper.prefs and sqldeveloper.prefs.xmlfile %}
       {% set file= sqldeveloper.dir.homes ~ '/' ~ sqldeveloper.identity.user ~ '/' ~ sqldeveloper.prefs.xmlfile %}

       {%- if sqldeveloper.pkg.use_upstream_macapp %}
              {%- set sls_package_install = tplroot ~ '.macapp.install' %}
       {%- else %}
              {%- set sls_package_install = tplroot ~ '.archive.install' %}
       {%- endif %}

include:
  - {{ sls_package_install }}

-config-file-managed-prefs_file:
  cmd.run:
    - name: curl -L -o {{ file }} {{ sqldeveloper.prefs.xmlurl }}
    - runas: {{ sqldeveloper.identity.user }}
    - if_missing: {{ sqldeveloper.prefs.xmlfile }}
    - retry: {{ sqldeveloper.retry_option|json }}
    - onlyif: {{ sqldeveloper.prefs.xmlurl }}
    - require:
      - sls: {{ sls_package_install }}

{%- endif %}
