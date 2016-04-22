# PuppetX::Cisco::AutoGen - automatically generate getter/setter methods
#
# April 2015
#
# Copyright (c) 2015-2016 Cisco and/or its affiliates.
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

module PuppetX
  module Cisco
    # PuppetX::Cisco::AutoGen - automatically generate getter/setter methods
    class AutoGen
      # "nu_name" refers to node_utils
      def self.mk_puppet_methods(mtype, klass, nu_name, props)
        case mtype
        when :array_flat
          mk_puppet_getters_array_flat(klass, nu_name, props)
          mk_puppet_setters_array_flat(klass, nu_name, props)
        when :non_bool
          mk_puppet_getters_non_bool(klass, nu_name, props)
          mk_puppet_setters_non_bool(klass, nu_name, props)
        when :bool
          mk_puppet_getters_bool(klass, nu_name, props)
          mk_puppet_setters_bool(klass, nu_name, props)
        end
      end

      # Auto-generator for puppet single-level array-based GETTER methods
      # These properties expect a flat array but optionally support a string
      # of space-separated values in the manifest.
      def self.mk_puppet_getters_array_flat(klass, nu_name, props)
        props.each do |prop|
          klass.instance_eval do
            # def foo_array_flat
            #   return @property_hash[:foo_array_flat] if @resource[:foo_array_flat].nil?
            #   if @resource[:foo_array_flat][0] == :default &&
            #      @property_hash[:foo_array_flat] == @nu.default_foo_array_flat
            #     return [:default]
            #   else
            #     @property_hash[:foo_array_flat]
            #   end
            # end
            define_method(prop) do
              return @property_hash[prop] if @resource[prop].nil?
              if @resource[prop][0] == :default &&
                 @property_hash[prop] == instance_variable_get(nu_name).send("default_#{prop}")
                return [:default]
              else
                @property_hash[prop]
              end
            end
          end
        end
      end # mk_puppet_getters_array_flat

      # Auto-generator for puppet single-level array-based SETTER methods.
      # These properties expect a flat array but optionally support a string
      # of space-separated values in the manifest; however, munge will transform
      # the string into a nested array, hence the flatten.
      def self.mk_puppet_setters_array_flat(klass, nu_name, props)
        props.each do |prop|
          klass.instance_eval do
            # def foo_array_flat=(val)
            #   fail '@property_flush not defined' if
            #     @property_flush.nil?
            #   val = @nu.default_foo_array_flat if
            #     val == :default
            #   @property_flush[:foo_array_flat] = val.flatten
            # end
            define_method("#{prop}=") do |val|
              fail '@property_flush not defined' if
                instance_variable_get(:@property_flush).nil?
              val = instance_variable_get(nu_name).send("default_#{prop}") if
                val == [:default]
              @property_flush[prop] = val.flatten
            end
          end
        end
      end # mk_puppet_setters_array_flat

      # Auto-generator for puppet non-boolean-based GETTER methods
      def self.mk_puppet_getters_non_bool(klass, nu_name, props)
        props.each do |prop|
          klass.instance_eval do
            # Generate GETTER method; e.g.
            # def foo
            #   return :default if
            #     @resource[:foo] == :default &&
            #     @property_hash[:foo] == @nu.default_foo
            #   @property_hash[:foo]
            # end
            define_method(prop) do
              return :default if
                @resource[prop] == :default &&
                @property_hash[prop] == instance_variable_get(nu_name).send("default_#{prop}")
              @property_hash[prop]
            end
          end
        end
      end

      # Auto-generator for puppet non-boolean-based SETTER methods
      def self.mk_puppet_setters_non_bool(klass, nu_name, props)
        props.each do |prop|
          klass.instance_eval do
            # Generate SETTER method; e.g.
            # def foo=(val)
            #   if val == :default
            #     val = @nu.default_foo
            #   end
            #   @property_flush[:foo] = val
            # end
            define_method("#{prop}=")do |val|
              fail '@property_flush not defined' if
                instance_variable_get(:@property_flush).nil?
              if val == :default
                val = instance_variable_get(nu_name).send("default_#{prop}")
              end
              @property_flush[prop] = val
            end
          end
        end
      end

      # Auto-generator for puppet boolean-based GETTER methods
      def self.mk_puppet_getters_bool(klass, nu_name, props)
        props.each do |prop|
          klass.instance_eval do
            # Generate GETTER method; e.g.
            # def foo
            #   val = @nu.foo
            #   return :default if
            #     @resource[foo] == :default and
            #     val == @nu_name.default_foo
            #   if val.nil?
            #     @property_hash[prop] = nil
            #   else
            #     @property_hash[prop] = val ? :true : :false
            #   end
            # end
            define_method(prop) do
              val = instance_variable_get(nu_name).send(prop)
              return :default if
                @resource[prop] == :default &&
                val == instance_variable_get(nu_name).send("default_#{prop}")
              if val.nil?
                @property_hash[prop] = nil
              else
                @property_hash[prop] = val ? :true : :false
              end
            end
          end
        end
      end

      # Auto-generator for puppet boolean-based SETTER methods
      def self.mk_puppet_setters_bool(klass, nu_name, props)
        props.each do |prop|
          klass.instance_eval do
            # Generate SETTER method; e.g.
            # def foo=
            #   if val == :default
            #     @property_flush[foo] = @nu_name.default_foo
            #   else
            #     @property_flush[prop] = (val == :true)
            #   end
            # end
            define_method("#{prop}=") do |val|
              fail '@property_flush not defined' if
                instance_variable_get(:@property_flush).nil?
              if val == :default
                @property_flush[prop] = instance_variable_get(nu_name).send("default_#{prop}")
              else
                @property_flush[prop] = (val == :true)
              end
            end
          end
        end
      end
    end
  end
end
