# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import sqldeveloper with context %}

    {%- if grains.kernel|lower in ('linux',) and sqldeveloper.linux.install_desktop_file %}
           {%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

include:
  - {{ tplroot ~ '.archive.install' }}

sqldeveloper-config-file-file-managed-desktop-shortcut_file:
  file.managed:
    - name: {{ sqldeveloper.linux.desktop_file }}
    - source: {{ files_switch(['shortcut.desktop.jinja'],
                              lookup='sqldeveloper-config-file-file-managed-desktop-shortcut_file'
                 )
              }}
    - mode: 644
    - user: {{ sqldeveloper.identity.user }}
    - makedirs: True
    - template: jinja
    - context:
        appname: {{ sqldeveloper.pkg.name }}
        edition: ''
        command: {{ sqldeveloper.command|json }}
        path: {{ sqldeveloper.path }}
    - onlyif: test -f {{ sqldeveloper.path }}/{{ sqldeveloper.command }}
    - require:
      - sls: {{ tplroot ~ '.archive.install' }}

    {%- endif %}
