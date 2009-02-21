# Copyright (c) 2007 Revolution Health Group LLC. All rights reserved.

module ActiveRecord; module Acts; end; end 

module ActiveRecord::Acts::ActsAsSecure
  
  require 'yaml'
    
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
            
    def acts_as_secure(options = {})
      parse_options!(options)
      add_callbacks
      extend(ActsAsSecureClassMethods)
      send(:include, InstanceMethods)
    end
          
  private
            
    def parse_options!(options)
      @secure_except = filter_secure_columns(options.delete(:except))
      @secure_only = filter_secure_columns(options.delete(:only))
      @secure_storage_type = options.delete(:storage_type) || :text
      @secure_crypto_provider = options.delete(:crypto_provider)
      fail("Unknown option(s): #{ options.keys.join(', ') }") unless options.empty?
    end
    
    def add_callbacks
      before_save :encrypt_secure_columns
      after_save :decrypt_secure_columns
      after_find :decrypt_secure_columns
      define_method(:after_find) { } 
      secure_column_symbols.each {|col| serialize col}
    end

    def filter_secure_columns(*names)
      names.flatten.collect(&:to_s)
    end
    
    def secure_column_symbols
      cols = columns.reject { |col| !@secure_only.include?(col.name) }
      cols.reject { |col| (col.type != @secure_storage_type) || @secure_except.include?(col.name) }
      c_sym = []
      cols.each { |col| c_sym.push(col.name.to_sym) }
      c_sym
    end
        
    module ActsAsSecureClassMethods
      
      def inherited(sub)

        [:secure_except, :secure_storage_type, :secure_crypto_provider].each do |p|
          sub.instance_variable_set("@#{ p }", instance_variable_get("@#{ p }"))
        end

        super

      end
      
      def with_crypto_provider(provider)
        begin
          original_provider = @secure_crypto_provider
          @secure_crypto_provider = provider
          yield
        ensure
          @secure_crypto_provider = original_provider
        end
      end

      def secure_columns
        cols = columns.reject { |col| !@secure_only.include?(col.name) }
        cols.reject { |col| (col.type != @secure_storage_type) || @secure_except.include?(col.name) }
      end

      def secure_crypto_provider
        @secure_crypto_provider
      end
      
      def update_pk_password(pk_password)
        @secure_crypto_provider.pk_password = pk_password
      end
    end
    
    
    module InstanceMethods

      def encrypt_secure_columns
        self.class.secure_columns.each do |col|
          unless self[col.name].nil?
            enc = secure_encrypt(self[col.name])
            self[col.name] = enc unless enc.nil?
          end
        end
      end
      
      def decrypt_secure_columns
        self.class.secure_columns.each do |col|
          unless self[col.name].nil?
            dec = secure_decrypt(self[col.name])
            self[col.name] = dec unless dec.nil?            
          end
        end
      end
            
    private
      
      def secure_encrypt(arg)
        secure_crypto_provider.encrypt(arg)
      end 
           
      def secure_decrypt(arg)
        begin
          secure_crypto_provider.decrypt(arg)
        rescue Exception => ex
          raise "Failed to decode the field. Incorrect key?: #{ex.message}"
        end
      end
      
      def secure_crypto_provider
        self.class.secure_crypto_provider || fail('No crypto provider defined')
      end
      
    end
    
  end
  
end

ActiveRecord::Base.send(:include, ActiveRecord::Acts::ActsAsSecure)