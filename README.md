[![Build Status](http://img.shields.io/travis/cchurch/ansible-role-uwsgi.svg)](https://travis-ci.org/cchurch/ansible-role-uwsgi)
[![Galaxy](http://img.shields.io/badge/galaxy-cchurch.uwsgi-blue.svg)](https://galaxy.ansible.com/cchurch/uwsgi/)

uWSGI
=====

Install uWSGI in emperor mode and configure vassals. Requires Ansible 2.4 or
later.

Role Variables
--------------

**NOTE: Some variable names have changed since 0.2.x versions!**

The following variables are typically defined to customize this role:

- `uwsgi_install`: Method to use to install uWSGI; can be `"pkg"` (default) to
  use system package manager or `"pip"` to install via pip. Any other value
  assumes uWSGI is installed by other means.
- `uwsgi_version`: When `uwsgi_install == "pip"`, specify a version of uWSGI to
  install. Default is to install the latest version available.
- `uwsgi_virtualenv`: When `uwsgi_install == "pip"`, installs uWSGI into the
  specified virtualenv path.
- `uwsgi_vassals`: Create INI configuration files for any vassals specified.
  Must be a list of hashes, with each hash having at least a `name` key to
  specify file name. All keys and values are written to the INI file under the
  `[uwsgi]` section. Default is `[]`.
- `uwsgi_vassals_to_remove`: List of vassal names to remove; default is `[]`.

The following variables may be used to customize the configuration and paths
used for the uWSGI emperor:

- `uwsgi_emperor_tyrant`: Run emperor in tyrant mode.  Each vassal configuration
  file will be owned by the uid/gid specified in the vassal options and run as
  that user instead of the emperor user.  Default is `true` when
  `uwsgi_install == "pip"`, `false otherwise`.
- `uwsgi_conf_template`: Local template to use for generating the uWSGI emperor
  configuration. Default is set from `uwsgi_default_conf_templates[ansible_pkg_mgr]`,
  which evaluates to `"uwsgi.ini.j2"` on EL distributions and `"emperor.ini.j2"`
  on Ubuntu distributions.
- `uwsgi_conf_path`: Path to uWSGI emperor configuration file. Default is set
  from `uwsgi_default_conf_paths[ansible_pkg_mgr]`, which evaluates to
  `"/etc/uwsgi.ini"` on EL distributions and `"/etc/uwsgi-emperor/emperor.ini"`
  on Ubuntu distributions.
- `uwsgi_conf_force`: Whether to force overwriting the uWSGI emperor
  configuration file. Default is `false` to only create the file if it doesn't
  already exist.
- `uwsgi_vassal_path`: Path for uWSGI emperor to look for vassal configuration
  files. Default is set from `uwsgi_default_vassal_paths[ansible_pkg_mgr]`,
  which evaluates to `"/etc/uwsgi.d"` on EL distributions and
  `"/etc/uwsgi-emperor/vassals"` on Ubuntu distributions.

The following variables may be used to customize the packages installed to
support uWSGI:

- `uwsgi_os_packages`: List of system packages to install to support uWSGI.
  Default is set from `uwsgi_default_os_packages[uwsgi_install][ansible_pkg_mgr]`,
  which will install system packages when `uwsgi_install == "pkg"` and Python
  development dependences when `uwsgi_install == "pip"`.
- `uwsgi_pip_packages`: List of pip packages to install to support uWSGI when
  `uwsgi_install == "pip"`. Default is set from `uwsgi_default_pip_packages`,
  which evaluates to `["uwsgi"]`.
- `uwsgi_pip_executable`: Alternate name or path of pip used to install packages
  when `uwsgi_install == "pip"` and not installing into a virtualenv. Default is
  to let the `pip` module determine which pip executable to use.

The following variables may be used to customize the service configuration when
uWSGI is not installed via the system package manager and managed via upstart or
systemd:

- `uwsgi_user_group`: User/group information for running the uWSGI emperor.
  Default is set from `uwsgi_default_user_group[ansible_pkg_mgr]`, which creates
  `"uwsgi:uwsgi"` system user and group on EL distributions and
  `"www-data:www-data"` system user and group on Ubuntu distributions, the same
  as would be used by the system package version of uWSGI. The user/group hash
  may contain `name`, `comment`, `group`, `home`, `shell` and `system` keys,
  corresponding to the equivalent parameters to the Ansible `user` module.
- `uwsgi_service_name`: Name of uWSGI service. Default is set from
  `uwsgi_default_service_names[ansible_pkg_mgr]`, which evaluates to `"uwsgi"`
  for EL distributions and `"uwsgi-emperor"` for Ubuntu distributions.
- `uwsgi_bin`: Path to uWSGI binary to use for upstart or systemd configuration;
  will be determined automatically if not specified.
- `uwsgi_opts`: Command line options to be used when running uWSGI via
  upstart or systemd; defaults to running using the options specified in the
  uWSGI config file: `"--die-on-term --ini {{uwsgi_conf_path|quote}}"`.
- `uwsgi_use_upstart`: Boolean indicating whether to use upstart to create and
  manage the uWSGI service. It is undefined by default, and will only be enabled
  when uWSGI is not installed via the system package manager on distributions
  other than EL 7. It can be set to `false` to explicitly disable using upstart
  to manage the uWSGI service.
- `uwsgi_upstart_packages`: List of system packages to install to support
  running uWSGI via upstart. Default is set from
  `uwsgi_default_upstart_packages[ansible_pkg_mgr]`, which simply installs the
  `upstart` package.
- `uwsgi_upstart_description`: Description for uWSGI upstart service, default is
  `"uWSGI Server"`.
- `uwsgi_upstart_template`: Local template to use for generating the upstart
  uWSGI configuration; default is `"uwsgi-upstart.conf.j2"`.
- `uwsgi_upstart_path`: Path to install upstart uWSGI configuration; default is
  `"/etc/init/{{_uwsgi_service_name}}.conf"`.
- `uwsgi_use_systemd`: Boolean indicating whether to use systemd to create and
  manage the uWSGI service. It is undefined by default, and will only be enabled
  when uWSGI is not installed via the system package manager on EL 7
  distributions. It can be set to `false` to explicitly disable using systemd to
  manage the uWSGI service.
- `uwsgi_systemd_template`: Local template to use for generating the systemd
  uWSGI service; default is `"uwsgi.service.j2"`.
- `uwsgi_systemd_path`: Path to install system uWSGI server; default is
  `"/etc/systemd/system/{{_uwsgi_service_name}}.service"`.

Example Playbook
----------------

The following example playbook installs uWSGI via pip and configures a single
vassal running a Django site:

    - hosts: all
      roles:
        - role: cchurch.uwsgi
          vars:
            uwsgi_install: pip
            uwsgi_vassals:
              - name: example
                plugin: python
                chdir: /opt/example/src
                module: example.wsgi
                home: /opt/example/env
                env: DJANGO_SETTINGS_MODULE=example.settings
                processes: 4
                socket: 127.0.0.1:8000
                uid: example
                gid: example

License
-------

BSD

Author Information
------------------

Chris Church ([cchurch](https://github.com/cchurch))
