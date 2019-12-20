Puppet::Type.newtype(:odoo_config) do
  ensurable

  newparam(:name, namevar: true) do
    desc 'setting name to manage from odoo.conf'
  end

  # rubocop:disable Lint/BooleanSymbol
  newproperty(:value) do
    desc 'The value of the setting to define'
    munge do |v|
      v.to_s.strip
    end

    def should_to_s(newvalue)
      if @resource[:show_diff] == :true && Puppet[:show_diff]
        newvalue
      elsif @resource[:show_diff] == :md5 && Puppet[:show_diff]
        '{md5}' + Digest::MD5.hexdigest(newvalue.to_s)
      else
        '[redacted sensitive information]'
      end
    end

    def is_to_s(value) # rubocop:disable Naming/PredicateName
      should_to_s(value)
    end
  end

  newparam(:show_diff) do
    desc 'Whether to display differences when the setting changes.'

    defaultto :true

    newvalues(:true, :md5, :false)

    munge do |value|
      @resource.munge_boolean_md5(value)
    end
  end

  def munge_boolean_md5(value)
    case value
    when true, :true, 'true', :yes, 'yes'
      :true
    when false, :false, 'false', :no, 'no'
      :false
    when :md5, 'md5'
      :md5
    else
      raise(_('expected a boolean value or :md5'))
    end
  end
  # rubocop:enable Lint/BooleanSymbol
end
