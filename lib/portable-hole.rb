require 'portable-hole/helpers'
require 'portable-hole/association_extensions'
require 'portable-hole/hash'
require 'portable-value'

module Reamaze
  module PortableHole
    def self.included(base)
      base.send :extend, ClassMethods
    end

    # Make methods available to ActiveRecord in the class context
    module ClassMethods
      def portable_hole(eav = :data, options = {})
        send :include, InstanceMethods

        eav = Helpers.normalize(eav)

        # Create accessor methods to our configuration info
        class << self
          attr_accessor :eav_configuration unless method_defined?(:eav_configuration)
        end

        # Initialize the configuration to an empty hash
        self.eav_configuration = {} if self.eav_configuration.nil?

        # Redefining a configuration once defined should not be allowed
        raise ArgumentError, "#{self} class already has a portal_hole :#{eav} defined" if self.eav_configuration.has_key?(eav)

        eav_configuration[eav] = options

        class_eval <<-end_eval
          # Define the has_many relationship
          has_many :_#{eav}, 
            -> { where(context: '#{eav}').extending(AssociationExtensions) },
            :class_name => 'PortableValue',
            :as         => :model,
            :inverse_of => :model,
            :dependent  => :delete_all

          accepts_nested_attributes_for :_#{eav}, :allow_destroy => true

          def #{eav}
            h = Reamaze::PortableHole::PrefHash.new self, "_#{eav}"
            values = self._#{eav}
            values.each do |v|
              h[v.key] = v.value
            end
            h
          end

          def #{eav}=(hash)
            array = []
            hash = hash.stringify_keys

            deletables = self._#{eav}.reject {|x| hash.keys.include? x.key}

            hash.each do |k, v|
              current = self._#{eav}.detect {|x| x.key == k}
              if current.present?
                if v == '_destroy'
                  array << {:id => current.id, :key => k, :value => v, :_destroy => true}
                else
                  array << {:id => current.id, :key => k, :value => v}
                end
              else
                array << {:key => k, :value => v, :context => '#{eav}'}
              end
            end

            deletables.each do |x|
              array << {:id => x.id, :_destroy => true}
            end

            self._#{eav}_attributes = array
            hash
          end
        end_eval
      end
    end

    # Make methods available to ActiveRecord models in the instance context
    module InstanceMethods
      def set_preferential(preferential, name, value, do_preprocess = false)
        preferential = Helpers.normalize(preferential)
        name    = Helpers.normalize(name)

        # Invoke the association
        prefs = send(preferential)

        # If pref already exists, update it, otherwise add a new one
        pref = prefs.detect { |pref| pref.key == name }

        if pref.blank?
          pref = prefs.build :key      => name,
                             :value    => value,
                             :context  => preferential[1..-1]
        else
          pref.value = value
        end

        pref.value
      end

      def get_preferential(preferential, name, do_postprocess = false)
        preferential = Helpers.normalize(preferential)
        name         = Helpers.normalize(name)

        # Invoke the association
        prefs = send(preferential)

        # Try to find what they are looking for
        pref = prefs.detect{ |pref| pref.key == name }

        # If the pref isn't found, try to fallback on a default
        if pref.blank?
          value = nil
        else
          value = pref.value
        end

        value
      end
    end
  end
end

ActiveRecord::Base.send :include, Reamaze::PortableHole
