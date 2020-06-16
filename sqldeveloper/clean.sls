# -*- coding: utf-8 -*-
# vim: ft=sls

    {%- if grains.kernel|lower in ('linux', 'darwin',) %}
        {%- set tplroot = tpldir.split('/')[0] %}
        {%- from tplroot ~ "/map.jinja" import sqldeveloper with context %}

include:
  - .{{ 'macapp' if sqldeveloper.pkg.use_upstream_macapp else 'archive' }}.clean
  - .config.clean
  - .linuxenv.clean

    {%- else %}

sqldeveloper-not-available-to-install:
  test.show_notification:
    - text: |
        The sqldeveloper package is unavailable for {{ salt['grains.get']('finger', grains.os_family) }}

    {%- endif %}
