# -*- coding: utf-8 -*-
# vim: ft=sls

    {% if grains.kernel|lower == 'linux' %}

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import sqldeveloper with context %}

          {% if sqldeveloper.linux.altpriority|int > 0 and grains.os_family not in ('Arch',) %}

sqldeveloper-linuxenv-home-alternatives-install:
  alternatives.install:
    - name: sqldeveloperhome
    - link: /opt/sqldeveloper
    - path: {{ sqldeveloper.path }}
    - priority: {{ sqldeveloper.linux.altpriority }}
    - retry: {{ sqldeveloper.retry_option|json }}

sqldeveloper-linuxenv-home-alternatives-set:
  alternatives.set:
    - name: sqldeveloperhome
    - path: {{ sqldeveloper.path }}
    - onchanges:
      - alternatives: sqldeveloper-linuxenv-home-alternatives-install
    - retry: {{ sqldeveloper.retry_option|json }}

sqldeveloper-linuxenv-executable-alternatives-install:
  alternatives.install:
    - name: sqldeveloper
    - link: {{ sqldeveloper.linux.symlink }}
    - path: {{ sqldeveloper.path }}/{{ sqldeveloper.command }}
    - priority: {{ sqldeveloper.linux.altpriority }}
    - require:
      - alternatives: sqldeveloper-linuxenv-home-alternatives-install
      - alternatives: sqldeveloper-linuxenv-home-alternatives-set
    - retry: {{ sqldeveloper.retry_option|json }}

sqldeveloper-linuxenv-executable-alternatives-set:
  alternatives.set:
    - name: sqldeveloper
    - path: {{ sqldeveloper.path }}/{{ sqldeveloper.command }}
    - onchanges:
      - alternatives: sqldeveloper-linuxenv-executable-alternatives-install
    - retry: {{ sqldeveloper.retry_option|json }}

          {%- else %}

sqldeveloper-linuxenv-alternatives-install-unapplicable:
  file.symlink:
    - name: /opt/sqldeveloper
    - target: {{ sqldeveloper.path }}
    - onlyif: test -d {{ sqldeveloper.path }}
    - force: True
  test.show_notification:
    - text: |
        Linux alternatives are turned off (sqldeveloper.linux.altpriority=0),
        or not applicable on {{ grains.os or grains.os_family }} OS.

          {% endif %}
    {% endif %}
