# -*- coding: utf-8 -*-
# vim: ft=sls

    {% if grains.kernel|lower == 'linux' %}
       {%- set tplroot = tpldir.split('/')[0] %}
       {%- from tplroot ~ "/map.jinja" import sqldeveloper as s with context %}
           {% if s.linux.altpriority|int > 0 and grains.os_family not in ('Arch',) %}

sqldeveloper-linuxenv-home-alternatives-install:
  alternatives.install:
    - name: sqldeveloperhome
    - link: /opt/sqldeveloper
    - path: {{ s.path }}
    - priority: {{ s.linux.altpriority }}
    - retry: {{ s.retry_option|json }}

sqldeveloper-linuxenv-home-alternatives-set:
  alternatives.set:
    - name: sqldeveloperhome
    - path: {{ s.path }}
    - onchanges:
      - alternatives: sqldeveloper-linuxenv-home-alternatives-install
    - retry: {{ s.retry_option|json }}

sqldeveloper-linuxenv-executable-alternatives-install:
  alternatives.install:
    - name: sqldeveloper
    - link: {{ s.linux.symlink }}
    - path: {{ s.path }}/{{ s.command }}
    - priority: {{ s.linux.altpriority }}
    - require:
      - alternatives: sqldeveloper-linuxenv-home-alternatives-install
      - alternatives: sqldeveloper-linuxenv-home-alternatives-set
    - retry: {{ s.retry_option|json }}

sqldeveloper-linuxenv-executable-alternatives-set:
  alternatives.set:
    - name: sqldeveloper
    - path: {{ s.path }}/{{ s.command }}
    - onchanges:
      - alternatives: sqldeveloper-linuxenv-executable-alternatives-install
    - retry: {{ s.retry_option|json }}

          {%- else %}

sqldeveloper-linuxenv-alternatives-install-unapplicable:
  file.symlink:
    - name: /opt/sqldeveloper
    - target: {{ s.path }}
    - onlyif: test -d {{ s.path }}
    - force: True
  test.show_notification:
    - text: |
        Linux alternatives are turned off (s.linux.altpriority=0),
        or not applicable on {{ grains.os or grains.os_family }} OS.

          {% endif %}
    {% endif %}
