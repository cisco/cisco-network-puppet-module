require 'hocon'
require 'hocon/config_syntax'
require 'pathname'
require 'puppet/resource_api'
require 'puppet/resource_api/type_definition'
require 'puppet/resource_api/data_type_handling'
require 'puppet/util/network_device'
# Copyright (c) 2013-2019 Cisco and/or its affiliates.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# This is monkey patches for patching in transport conversion
# from RSAPI transport work which is in 1.8.x, whereas
# puppet 6.0.x has 1.6.x
module Puppet::ResourceApi
  # monkey patch for the transport context for continued
  # module support
  class BaseContext
    attr_reader :type

    def initialize(definition)
      if definition.is_a?(Hash)
        # this is only for backwards compatibility
        @type = Puppet::ResourceApi::TypeDefinition.new(definition)
      elsif definition.is_a? Puppet::ResourceApi::BaseTypeDefinition
        @type = definition
      else
        #:nocov:
        raise ArgumentError, 'BaseContext requires definition to be a child of Puppet::ResourceApi::BaseTypeDefinition, not <%{actual_type}>' % { actual_type: definition.class }
        #:nocov:
      end
    end

    #:nocov:
    # patch for returning the device
    # in the context.transport calls
    def transport
      device.transport
    end
    #:nocov:
  end
  # pre-declare class
  class BaseTypeDefinition; end

  # RSAPI Transport schema
  class TransportSchemaDef < BaseTypeDefinition
    def initialize(definition)
      super(definition, :connection_info)
    end

    def validate(resource)
      # enforce mandatory attributes
      missing_attrs = []

      attributes.each do |name, _options|
        type = @data_type_cache[attributes[name][:type]]

        if resource[name].nil? && !(type.instance_of? Puppet::Pops::Types::POptionalType)
          missing_attrs << name
        end
      end

      error_msg = "The following mandatory attributes were not provided:\n    *  " + missing_attrs.join(", \n    *  ")
      raise Puppet::ResourceError, error_msg if missing_attrs.any?
    end

    def notify_schema_errors(message)
      # do nothing to satisfy tasks
    end
  end

  # Base RSAPI schema Object
  class BaseTypeDefinition
    attr_reader :definition, :attributes

    def initialize(definition, attr_key)
      @data_type_cache = {}
      validate_schema(definition, attr_key)
      # store the validated definition
      @definition = definition
    end

    def name
      definition[:name]
    end

    def namevars
      @namevars ||= attributes.select { |_name, options|
        options.key?(:behaviour) && options[:behaviour] == :namevar
      }.keys
    end

    def validate_schema(definition, attr_key) # rubocop:disable Metrics/AbcSize
      raise Puppet::DevError, '%{type_class} must be a Hash, not `%{other_type}`' % { type_class: self.class.name, other_type: definition.class } unless definition.is_a?(Hash)
      @attributes = definition[attr_key]
      raise Puppet::DevError, '%{type_class} must have a name' % { type_class: self.class.name } unless definition.key? :name
      raise Puppet::DevError, '%{type_class} must have `%{attr_key}`' % { type_class: self.class.name, attrs: attr_key } unless definition.key? attr_key
      unless attributes.is_a?(Hash)
        #:nocov:
        raise Puppet::DevError, '`%{name}.%{attrs}` must be a hash, not `%{other_type}`' % {
          name: definition[:name], attrs: attr_key, other_type: attributes.class
        }
        #:nocov:
      end

      attributes.each do |key, attr|
        raise Puppet::DevError, "`#{definition[:name]}.#{key}` must be a Hash, not a #{attr.class}" unless attr.is_a? Hash
        raise Puppet::DevError, "`#{definition[:name]}.#{key}` has no type" unless attr.key? :type
        Puppet.warning("`#{definition[:name]}.#{key}` has no docs") unless attr.key? :desc

        # validate the type by attempting to parse into a puppet type
        @data_type_cache[attributes[key][:type]] ||=
          Puppet::ResourceApi::DataTypeHandling.parse_puppet_type(
            key,
            attributes[key][:type],
          )

        # Validate international spelling of behavior
        next unless attr[:behavior]
        #:nocov:
        if attr[:behaviour]
          raise Puppet::DevError, "the '#{key}' attribute has both a `behavior` and a `behaviour`, only use one"
        end
        attr[:behaviour] = attr[:behavior]
        attr.delete(:behavior)
        #:nocov:
      end
    end

    # validates a resource hash against its type schema
    def check_schema(resource, message_prefix=nil)
      namevars.each do |namevar|
        #:nocov:
        if resource[namevar].nil?
          raise Puppet::ResourceError, "`#{name}.get` did not return a value for the `#{namevar}` namevar attribute"
        end
        #:nocov:
      end

      message_prefix = 'Provider returned data that does not match the Type Schema' if message_prefix.nil?
      message = "#{message_prefix} for `#{name}[#{resource[namevars.first]}]`"

      rejected_keys = check_schema_keys(resource)
      bad_values = check_schema_values(resource)

      unless rejected_keys.empty?
        #:nocov:
        message += "\n Unknown attribute:\n"
        rejected_keys.each { |key, _value| message += "    * #{key}\n" }
        #:nocov:
      end
      unless bad_values.empty?
        message += "\n Value type mismatch:\n"
        bad_values.each { |key, value| message += "    * #{key}: #{value}\n" }
      end

      return if rejected_keys.empty? && bad_values.empty?

      notify_schema_errors(message)
    end

    # Returns an array of keys that where not found in the type schema
    # No longer modifies the resource passed in
    def check_schema_keys(resource)
      rejected = []
      resource.reject { |key| rejected << key if key != :title && attributes.key?(key) == false }
      rejected
    end

    # Returns a hash of keys and values that are not valid
    # does not modify the resource passed in
    def check_schema_values(resource)
      bad_vals = {}
      resource.each do |key, value|
        next unless attributes[key]
        type = @data_type_cache[attributes[key][:type]]
        is_sensitive = (attributes[key].key?(:sensitive) && (attributes[key][:sensitive] == true))
        error_message = Puppet::ResourceApi::DataTypeHandling.try_validate(
          type,
          value,
          '',
        )
        if is_sensitive
          bad_vals[key] = '<< redacted value >> ' + error_message unless error_message.nil?
        else
          bad_vals[key] = value unless error_message.nil?
        end
      end
      bad_vals
    end
  end

  def register_transport(schema)
    Puppet::ResourceApi::Transport.register(schema)
  end
  module_function :register_transport
end

# Remote target transport API
module Puppet::ResourceApi::Transport
  def register(schema)
    raise Puppet::DevError, 'requires a hash as schema, not `%{other_type}`' % { other_type: schema.class } unless schema.is_a? Hash
    raise Puppet::DevError, 'requires a `:name`' unless schema.key? :name
    raise Puppet::DevError, 'requires `:desc`' unless schema.key? :desc
    raise Puppet::DevError, 'requires `:connection_info`' unless schema.key? :connection_info
    raise Puppet::DevError, '`:connection_info` must be a hash, not `%{other_type}`' % { other_type: schema[:connection_info].class } unless schema[:connection_info].is_a?(Hash)

    init_transports
    unless @transports[@environment][schema[:name]].nil?
      #:nocov:
      raise Puppet::DevError, 'Transport `%{name}` is already registered for `%{environment}`' % {
        name:        schema[:name],
        environment: @environment,
      }
      #:nocov:
    end
    @transports[@environment][schema[:name]] = Puppet::ResourceApi::TransportSchemaDef.new(schema)
  end
  module_function :register

  # retrieve a Hash of transport schemas, keyed by their name.
  def list
    init_transports
    Marshal.load(Marshal.dump(@transports[@environment]))
  end
  module_function :list

  def connect(name, connection_info)
    validate(name, connection_info)
    require "puppet/transport/#{name}"
    class_name = name.split('_').map { |e| e.capitalize }.join
    Puppet::Transport.const_get(class_name).new(get_context(name), wrap_sensitive(name, connection_info))
  end
  module_function :connect

  def inject_device(name, transport)
    #:nocov:
    transport_wrapper = Puppet::ResourceApi::Transport::Wrapper.new(name, transport)

    if Puppet::Util::NetworkDevice.respond_to?(:set_device)
      Puppet::Util::NetworkDevice.set_device(name, transport_wrapper)
    else
      Puppet::Util::NetworkDevice.instance_variable_set(:@current, transport_wrapper)
    end
    #:nocov:
  end
  module_function :inject_device

  def self.validate(name, connection_info)
    init_transports
    require "puppet/transport/schema/#{name}" unless @transports[@environment].key? name
    transport_schema = @transports[@environment][name]
    if transport_schema.nil?
      #:nocov:
      raise Puppet::DevError, 'Transport for `%{target}` not registered with `%{environment}`' % {
        target:      name,
        environment: @environment,
      }
      #:nocov:
    end
    message_prefix = 'The connection info provided does not match the Transport Schema'
    transport_schema.check_schema(connection_info, message_prefix)
    transport_schema.validate(connection_info)
  end
  private_class_method :validate

  def self.get_context(name)
    require 'puppet/resource_api/puppet_context'
    Puppet::ResourceApi::PuppetContext.new(@transports[@environment][name])
  end
  private_class_method :get_context

  def self.init_transports
    lookup = Puppet.lookup(:current_environment) if Puppet.respond_to? :lookup
    @environment =  if lookup.nil?
                      #:nocov:
                      :transports_default
                      #:nocov:
                    else
                      lookup.name
                    end
    @transports ||= {}
    @transports[@environment] ||= {}
  end
  private_class_method :init_transports

  def self.wrap_sensitive(name, connection_info)
    transport_schema = @transports[@environment][name]
    if transport_schema
      transport_schema.definition[:connection_info].each do |attr_name, options|
        if options.key?(:sensitive) && (options[:sensitive] == true) && connection_info.key?(attr_name)
          connection_info[attr_name] = Puppet::Pops::Types::PSensitiveType::Sensitive.new(connection_info[attr_name])
        end
      end
    end
    connection_info
  end
  private_class_method :wrap_sensitive
end

#:nocov:
# Puppet::ResourceApi::Transport::Wrapper` to interface between the Util::NetworkDevice
class Puppet::ResourceApi::Transport::Wrapper
  attr_reader :transport, :schema

  def initialize(name, config_or_transport)
    # Check if the Puppet::Transport module exists
    # if it doesn't (RSAPI 1.6.x) then don't try to load
    # or set @transport
    begin
      Required::Module.const_get 'Puppet::Transport'
      if transport_class?(name, url_or_config_or_transport)
        @transport = url_or_config_or_transport
      end
    rescue NameError
      nil
    end

    @transport ||= Puppet::ResourceApi::Transport.connect(name, config_or_transport)
    @schema = Puppet::ResourceApi::Transport.list[name]
  end

  def transport_class?(name, transport)
    class_name = name.split('_').map { |e| e.capitalize }.join
    expected = Puppet::Transport.const_get(class_name).to_s
    expected == transport.class.to_s
  end

  def facts
    context = Puppet::ResourceApi::PuppetContext.new(@schema)
    # @transport.facts + custom_facts  # look into custom facts work by TP
    @transport.facts(context)
  end

  def respond_to_missing?(name, _include_private)
    (@transport.respond_to? name) || super
  end

  # From https://stackoverflow.com/a/11788082/4918
  def self.deep_symbolize(obj)
    return obj.each_with_object({}) { |(k, v), memo| memo[k.to_sym] = deep_symbolize(v); } if obj.is_a? Hash
    return obj.each_with_object([]) { |v, memo| memo << deep_symbolize(v); } if obj.is_a? Array
    obj
  end
end
#:nocov:
