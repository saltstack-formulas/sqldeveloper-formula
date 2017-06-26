{%- from 'sqldeveloper/settings.sls' import sqldeveloper with context %}

export SQLDEVELOPER_HOME={{ sqldeveloper.sqldeveloper_home }}
export PATH=$SQLDEVELOPER_HOME:$PATH
