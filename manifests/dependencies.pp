# @summary Manage odoo dependencies
#
# @api private
class odoo::dependencies {
  assert_private()

  unless $odoo::version == 'system' {
    stdlib::ensure_packages($odoo::pip_package)

    package { 'python3-pdfminer':
      ensure => installed,
    }

    case $facts.get('os.name') {
      'debian': {
        case $facts.get('os.release.major') {
          '11': {
            $odoo_dependencies = []
            $odoo_pip_packages = {}
          }
          '12': {
            $odoo_dependencies = []
            $odoo_pip_packages = {}
          }
          default: {
            notice { "Please contribute support for Debian ${facts.get('os.release.full')}": }
            $odoo_dependencies = []
            $odoo_pip_packages = {}
          }
        }
      }
      'ubuntu': {
        case $facts.get('os.release.full') {
          '20.04': {
            $odoo_dependencies = []
            $odoo_pip_packages = {}
          }
          '22.04': {
            $odoo_dependencies = []
            $odoo_pip_packages = {}
          }
          '24.04': {
            $odoo_dependencies = [
              'python3-lxml-html-clean',
            ]
            $odoo_pip_packages = {}
          }
          default: {
            notice { "Please contribute support for ubuntu ${facts.get('os.release.full')}": }
            $odoo_dependencies = []
            $odoo_pip_packages = {}
          }
        }
      }
      default: {
        notice { "Please contribute support for ${facts.get('os.name')}": }
        $odoo_dependencies = []
        $odoo_pip_packages = {}
      }
    }

    package { $odoo_dependencies:
      ensure => installed,
    }

    $odoo_pip_packages.each |$name, $options| {
      package { $name:
        provider => $odoo::pip_provider,
        require  => Package[$odoo::pip_package],
        *        => $options,
      }
    }

    if versioncmp($odoo::version, '11.0') >= 0 {
      # These dependencies are only listed on the Odoo 13 page:
      # https://www.odoo.com/documentation/13.0/setup/install.html
      # Odoo 10.0 depends on the python-xlwt package (old version), so install
      # the pip module on Odoo 11 and better.
      unless (
        (fact('os.name') == 'debian' and versioncmp(fact('os.release.full'), '12.0') >= 0) or
        (fact('os.name') == 'ubuntu' and versioncmp(fact('os.release.full'), '24.04') >= 0)
      ) {
        package { 'xlwt':
          ensure   => '1.3.0',
          provider => $odoo::pip_provider,
          require  => Package[$odoo::pip_package],
          notify   => Class['odoo::service'],
        }
      }
    }
  }
}
