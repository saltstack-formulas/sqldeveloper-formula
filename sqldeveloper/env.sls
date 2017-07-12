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
    - require:
      - update-sqldeveloper-home-symlink

# Add sqldeveloper to alternatives system
sqldeveloperhome-alt-install:
  alternatives.install:
    - name: sqldeveloper-home
    - link: {{ sqldeveloper.orahome }}/sqldeveloper
    - path: {{ sqldeveloper.sqldeveloper_real_home }}
    - priority: 30
    - require:
      - update-sqldeveloper-home-symlink

sqldeveloper-alt-install:
  alternatives.install:
    - name: sqldeveloper
    - link: {{ sqldeveloper.sqldeveloper_symlink }}
    - path: {{ sqldeveloper.sqldeveloper_realcmd }}
    - priority: 30
    - onlyif: test -d {{ sqldeveloper.sqldeveloper_real_home }}
    - require:
      - update-sqldeveloper-home-symlink

# Set sqldeveloper alternatives
sqldeveloperhome-alt-set:
  alternatives.set:
  - name: sqldeveloper-home
  - path: {{ sqldeveloper.sqldeveloper_real_home }}
  - require:
    - sqldeveloperhome-alt-install

sqldeveloper-alt-set:
  alternatives.set:
  - name: sqldeveloper
  - path: {{ sqldeveloper.sqldeveloper_realcmd }}
  - require:
    - sqldeveloper-alt-install

# source PATH with JAVA_HOME
source_sqldeveloper_file:
  cmd.run:
  - name: source /etc/profile
  - cwd: /root
  - require:
    - update-sqldeveloper-home-symlink

