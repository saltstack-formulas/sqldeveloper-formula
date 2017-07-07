{%- from 'sqldeveloper/settings.sls' import sqldeveloper with context %}

export ORACLE_HOME={{ sqldeveloper.orahome }}
export SQLDEVELOPER_HOME={{ sqldeveloper.orahome }}/sqldeveloper
export PATH=${ORACLE_HOME}:${SQLDEVELOPER_HOME}:$PATH
