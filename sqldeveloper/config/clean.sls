# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import sqldeveloper with context %}

   {%- if sqldeveloper.pkg.use_upstream_macapp %}
       {%- set sls_package_clean = tplroot ~ '.macapp.clean' %}
   {%- else %}
       {%- set sls_package_clean = tplroot ~ '.archive.clean' %}
   {%- endif %}

include:
  - {{ sls_package_clean }}

sqldeveloper-config-clean-file-absent:
  file.absent:
    - names:
      - /tmp/dummy_list_item
      - {{ sqldeveloper.dir.homes ~ '/' ~ sqldeveloper.identity.user ~ '/.sqldeveloper' }}
               {%- if sqldeveloper.environ_file %}
      - {{ sqldeveloper.environ_file }}
               {%- endif %}
               {%- if grains.kernel|lower == 'linux' %}
      - {{ sqldeveloper.linux.desktop_file }}
               {%- elif grains.os == 'MacOS' %}
      - {{ sqldeveloper.dir.homes }}/{{ sqldeveloper.identity.user }}/Desktop/{{ sqldeveloper.pkg.name }}
               {%- endif %}
    - require:
      - sls: {{ sls_package_clean }}
