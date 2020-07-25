# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import sqldeveloper as s with context %}

    {%- if 'xmlfile' in s.prefs and s.prefs.xmlfile %}
        {% set file= s.dir.homes ~ '/' ~ s.identity.user ~ '/' ~ s.prefs.xmlfile %}
        {%- if s.pkg.use_upstream_macapp %}
            {%- set sls_package_install = tplroot ~ '.macapp.install' %}
        {%- else %}
            {%- set sls_package_install = tplroot ~ '.archive.install' %}
        {%- endif %}

include:
  - {{ sls_package_install }}

-config-file-managed-prefs_file:
  cmd.run:
    - name: curl -L -o {{ file }} {{ s.prefs.xmlurl }}
    - runas: {{ s.identity.user }}
    - if_missing: {{ s.prefs.xmlfile }}
    - retry: {{ s.retry_option|json }}
    - onlyif: {{ s.prefs.xmlurl }}
    - require:
      - sls: {{ sls_package_install }}

    {%- endif %}
