module ActiveRecord # :nodoc:
  module Sentry
    def self.included(base) # :nodoc:
      base.extend ClassMethods
    end

    module ClassMethods
      def generates_crypted(attr_name, options = {})
        mode = options[:mode] || :asymmetric
        case mode
          #when :sha
          #  generates_crypted_hash_of(attr_name)
          when :asymmetric, :asymmetrical
            asymmetrically_encrypts(attr_name)
          #when :symmetric, :symmetrical
          #  symmetrically_encrypts(attr_name)
        end
      end

      #def generates_crypted_hash_of(attribute)
      #  before_validation ::Sentry::ShaSentry.new(attribute)
      #  attr_accessor attribute
      #end

      def asymmetrically_encrypts(attr_name, options = {})
        #temp_sentry = ::Sentry::AsymmetricSentryCallback.new(attr_name)
        #before_validation temp_sentry
        #after_save temp_sentry
        unless instance_methods.include?("#{attr_name}_with_decryption")
          define_read_methods

          define_method("#{attr_name}_with_decryption") do |*optional|
            begin
              return decrypted_values[attr_name] unless decrypted_values[attr_name].nil?
              crypted_value = self.send("#{attr_name}_without_decryption")
              return nil if crypted_value.nil?
              key = optional.shift || (options[:key].is_a?(Proc) ? options[:key].call : options[:key])
              decrypted_values[attr_name] = ::Sentry::AsymmetricSentry.decrypt_from_base64(crypted_value, key)
              return decrypted_values[attr_name]
            rescue
              nil
            end
          end

          alias_method_chain attr_name, :decryption
          alias_method "crypted_#{attr_name}", "#{attr_name}_without_decryption"
          alias_method "#{attr_name}_before_type_cast", "#{attr_name}_with_decryption"

          define_method("#{attr_name}_with_encryption=") do |value|
            decrypted_values[attr_name] = value
            self.send("#{attr_name}_without_encryption=", ::Sentry::SymmetricSentry.encrypt_to_base64(decrypted_values[attr_name]))
            nil
          end

          alias_method_chain "#{attr_name}=", :encryption
          #define_method("crypted_#{attr_name}") do
          #  self.attributes[attr_name.to_s]
          #end
          #
          private
          define_method(:decrypted_values) do
            @decrypted_values ||= {}
          end
        end
      end

      #def symmetrically_encrypts(attr_name)
      #  temp_sentry = ::Sentry::SymmetricSentryCallback.new(attr_name)
      #  before_validation temp_sentry
      #  after_save temp_sentry
      #
      #  define_method(attr_name) do
      #    send("#{attr_name}!") rescue nil
      #  end
      #
      #  define_method("#{attr_name}!") do
      #    return decrypted_values[attr_name] unless decrypted_values[attr_name].nil?
      #    return nil if send("crypted_#{attr_name}").nil?
      #    ::Sentry::SymmetricSentry.decrypt_from_base64(send("crypted_#{attr_name}"))
      #  end
      #
      #  define_method("#{attr_name}=") do |value|
      #    decrypted_values[attr_name] = value
      #    nil
      #  end
      #
      #  private
      #  define_method(:decrypted_values) do
      #    @decrypted_values ||= {}
      #  end
      #end
    end
  end
end
