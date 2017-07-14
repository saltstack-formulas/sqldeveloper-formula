=============
sqldeveloper-formula
=============

This formula will set up and configure Oracle SqlDeveloper software sourced from URL.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

Available states
================

.. contents::
    :local:

``sqldeveloper``
---------

Downloads archives from **sqldeveloper:source_url** and unpacks them to oracle_home.

``sqldeveloper.env``
-------------

Full support for linux alternatives system.
Adds /etc/profile.d/sqldeveloper.sh, setting SQLDEVELOPER_HOME, ORACLE_HOME, ./bin in user PATH.


Please see the pillar.example for configuration.

