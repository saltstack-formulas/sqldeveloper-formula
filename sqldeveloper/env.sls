{%- from 'sqldeveloper/settings.sls' import sqldeveloper with context %}

sqldeveloper-config:
  file.managed:
    - name: /etc/profile.d/sqldeveloper.sh
    - source: salt://sqldeveloper/files/sqldeveloper.sh
    - template: jinja
    - mode: 644
    - user: root
    - group: root
    - context:
      orahome: {{ sqldeveloper.orahome }}/sqldeveloper

# Add sqldeveloper home to alternatives system
sqldeveloperhome-alt-install:
  alternatives.install:
    - name: sqldeveloper-home
    - link: {{ sqldeveloper.orahome }}/sqldeveloper
    - path: {{ sqldeveloper.sqldeveloper_real_home }}
    - priority: {{ sqldeveloper.alt_priority }}

# Set sqldeveloper alternatives
sqldeveloperhome-alt-set:
  alternatives.set:
  - name: sqldeveloper-home
  - path: {{ sqldeveloper.sqldeveloper_real_home }}
  - require:
    - alternatives: sqldeveloperhome-alt-install
  - onchanges:
    - alternatives: sqldeveloperhome-alt-install

# Add sqldeveloper to alternatives system
sqldeveloper-alt-install:
  alternatives.install:
    - name: sqldeveloper
    - link: {{ sqldeveloper.sqldeveloper_symlink }}
    - path: {{ sqldeveloper.sqldeveloper_realcmd }}
    - priority: {{ sqldeveloper.alt_priority }}
    - require:
      - alternatives: sqldeveloperhome-alt-set
    - onchanges:
      - alternatives: sqldeveloperhome-alt-install
      - alternatives: sqldeveloperhome-alt-set

sqldeveloper-alt-set:
  alternatives.set:
  - name: sqldeveloper
  - path: {{ sqldeveloper.sqldeveloper_realcmd }}
  - require:
    - alternatives: sqldeveloper-alt-install
  - onchanges:
    - alternatives: sqldeveloper-alt-install

