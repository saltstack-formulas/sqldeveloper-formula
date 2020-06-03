# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import sqldeveloper with context %}

sqldeveloper-package-archive-clean-file-absent:
  file.absent:
    - names:
      - {{ sqldeveloper.path }}
      - /usr/local/bin/sqldeveloper
