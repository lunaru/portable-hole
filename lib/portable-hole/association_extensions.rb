module Reamaze
  module PortableHole
    module AssociationExtensions
      def save
        do_save(false)
      end

      def save!
        do_save(true)
      end

      def []=(name, value)
        @association.owner.set_portable_value(@association.reflection.name, name, value)
      end

      def [](name)
        @association.owner.get_portable_value(@association.reflection.name, name)
      end

      def valid?
        valid = true
        proxy_target.each do |thing|
          thing.model_cache = @association.owner
          unless thing.valid?
            thing.errors.each{ |attr, msg| @association.owner.errors.add(@association.reflection.name, msg) }
            valid = false
          end
        end
        valid
      end

      # Private Methods
      private
        def do_save(with_bang)
          success = true
          proxy_target.each do |thing|
            thing.model_cache = @association.owner
            if with_bang
              thing.save!
            elsif thing.save == false
              # Delegate the errors to the proxy owner
              thing.errors.each { |attr,msg| @association.owner.errors.add(@association.reflection.name, msg) }
              success = false
            end
          end
          success
        end
    end
  end
end
