# -*- coding: utf-8 -*-
# vim: ft=sls

    {%- if grains.os_family == 'MacOS' %}
        {%- set tplroot = tpldir.split('/')[0] %}
        {%- from tplroot ~ "/map.jinja" import sqldeveloper with context %}

sqldeveloper-package-macapp-install-prepare:
  pkg.installed:
    - names: {{ sqldeveloper.pkg.deps|json }}
  file.directory:
    - name: {{ sqldeveloper.pkg.macapp.name }}
    - user: {{ sqldeveloper.identity.rootuser }}
    - group: {{ sqldeveloper.identity.rootgroup }}
    - mode: 755
    - makedirs: True
    - clean: True
    - recurse:
        - user
        - group
        - mode

        {%- for name in sqldeveloper.pkg.wanted %}

sqldeveloper-package-macapp-install-{{ name }}:
  archive.extracted:
    - name: {{ sqldeveloper.pkg.macapp.name }}
    - source: {{ sqldeveloper.pkg.urls[name] }}
    - source_hash: {{ sqldeveloper.pkg.checksums[name] }}
    - trim_output: true
    - retry: {{ sqldeveloper.retry_option|json }}
    - user: {{ sqldeveloper.identity.rootuser }}
    - group: {{ sqldeveloper.identity.rootgroup }}
    - require:
      - pkg: sqldeveloper-package-macapp-install-prepare
      - file: sqldeveloper-package-macapp-install-prepare
    - require_in:
      - macpackage: sqldeveloper-macos-app-install-macpackage
    - onchanges_in:
      - macpackage: sqldeveloper-macos-app-install-macpackage

        {%- endfor %}

sqldeveloper-macos-app-install-macpackage:
  macpackage.installed:
    - name: {{ sqldeveloper.pkg.macapp.name }}/SQLDeveloper.app
    - store: False
    - dmg: False
    - app: True
    - force: True
    - allow_untrusted: True
    - require_in:
      - file: sqldeveloper-macos-app-install-macpackage
  file.managed:
    - name: /tmp/mac_shortcut.sh
    - source: salt://sqldeveloper/files/mac_shortcut.sh
    - mode: 755
    - template: jinja
    - context:
      appname: {{ sqldeveloper.pkg.name }}
      edition: {{ sqldeveloper.edition }}
      user: {{ sqldeveloper.identity.user }}
      homes: {{ sqldeveloper.dir.homes }}
  cmd.run:
    - name: /tmp/mac_shortcut.sh
    - runas: {{ sqldeveloper.identity.user }}
    - require:
      - file: sqldeveloper-macos-app-install-macpackage

    {%- else %}

sqldeveloper-macos-install-unavailable:
  test.show_notification:
    - text: |
        The sqldeveloper macpackage is only available on MacOS

    {%- endif %}
