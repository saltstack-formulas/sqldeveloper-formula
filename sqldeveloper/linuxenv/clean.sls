# -*- coding: utf-8 -*-
# vim: ft=sls

    {%- if grains.kernel|lower == 'linux' %}
        {%- set tplroot = tpldir.split('/')[0] %}
        {%- from tplroot ~ "/map.jinja" import sqldeveloper with context %}
        {%- if sqldeveloper.linux.altpriority|int > 0 and grains.os_family not in ('Arch',) %}

sqldeveloper-linuxenv-home-alternatives-clean:
  alternatives.remove:
    - name: sqldeveloperhome
    - path: {{ sqldeveloper.path }}
    - onlyif: update-alternatives --get-selections |grep ^sqldeveloperhome
sqldeveloper-linuxenv-executable-alternatives-clean:
  alternatives.remove:
    - name: sqldeveloper
    - path: {{ sqldeveloper.path }}/sqldeveloper
    - onlyif: update-alternatives --get-selections |grep ^sqldeveloper

        {%- else %}

sqldeveloper-linuxenv-alternatives-clean-unapplicable:
  test.show_notification:
    - text: |
        Linux alternatives are turned off (sqldeveloper.linux.altpriority=0),
        or not applicable on {{ grains.os or grains.os_family }} OS.

        {% endif %}
    {% endif %}
