# -*- coding: utf-8 -*-
# vim: ft=sls

    {%- if grains.os_family == 'MacOS' %}

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import sqldeveloper with context %}

sqldeveloper-macos-app-clean-files:
  file.absent:
    - names:
      - {{ sqldeveloper.path }}
      - {{ sqldeveloper.dir.tmp }}
      - /Applications/{{ sqldeveloper.pkg.name }}.app

    {%- else %}

sqldeveloper-macos-app-clean-unavailable:
  test.show_notification:
    - text: |
        The sqldeveloper macpackage is only available on MacOS

    {%- endif %}
