module Sentry
  class AsymmetricSentry
    attr_reader   :private_key_file
    attr_reader   :public_key_file
    attr_accessor :symmetric_algorithm
    @@default_private_key_file = nil
    @@default_public_key_file = nil
    @@default_symmetric_algorithm = nil

    # available options:
    # * <tt>:private_key_file</tt> - encrypted private key file
    # * <tt>:public_key_file</tt>  - public key file
    # * <tt>:symmetric_algorithm</tt> - algorithm to use for SymmetricSentry
    def initialize(options = {})
      @public_key = @private_key = nil
      self.private_key_file = options[:private_key_file]
      self.public_key_file  = options[:public_key_file] || @@default_public_key_file
      @symmetric_algorithm = options[:symmetric_algorithm] || @@default_symmetric_algorithm
    end
  
    def encrypt(data)
      raise NoPublicKeyError unless public?
      rsa = public_rsa
      return rsa.public_encrypt(data)
    end

    def decrypt_large_from_base64(data, key=nil)
      chunk_length = public_rsa.max_encryptable_length + 11 # 11 is magic padding for RSA encoding
      b64_decoded = Base64.decode64(data)
      padding_length = b64_decoded[0]
      data = b64_decoded[1, data.length]
      return (0...data.length).step(chunk_length).inject("") { |accum, idx| accum + decrypt_with_padding(data.slice(idx, chunk_length), padding_length, key)}
    end

    def chunk_size(padding_length)
      return public_rsa.max_encryptable_length - padding_length
    end
    
    def encrypt_large_to_base64(data)
      padding_length = 8
      chunk_length = chunk_size(padding_length)
      return Base64.encode64(padding_length.chr + (0...data.length).step(chunk_length).inject("") {|accum, idx| accum + encrypt_with_padding( data.slice(idx, chunk_length), padding_length)} )
    end

    def decrypt_with_padding(data, padding_length, key=nil)
      decrypted = decrypt(data, key)
      return decrypted[0, decrypted.length - padding_length]
    end

    def encrypt_with_padding(data, padding_length)
      encrypt(data + rand_string(padding_length))
    end

    @@CHARS = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a

    def rand_string(length=8)
      s=''
      length.times{ s << @@CHARS[rand(@@CHARS.length)] }
      s
    end
  
    def encrypt_to_base64(data)
      Base64.encode64(encrypt(data))
    end
  
    def decrypt(data, key = nil)
      raise NoPrivateKeyError unless private?
      rsa = private_rsa(key)
      return rsa.private_decrypt(data)
    end
  
    def decrypt_from_base64(data, key = nil)
      decrypt(Base64.decode64(data), key)
    end
  
    def private_key_file=(file)
      @private_key_file = file and load_private_key
    end
  
    def public_key_file=(file)
      @public_key_file = file and load_public_key
    end
  
    def public?
      return true unless @public_key.nil?
      load_public_key and return @public_key
    end
  
    def private?
      return true unless @private_key.nil?
      load_private_key and return @private_key
    end

    class << self
      # * <tt>:key</tt> - secret password
      # * <tt>:symmetric_algorithm</tt> - symmetrical algorithm to use
      def save_random_rsa_key(private_key_file, public_key_file, options = {})
        rsa = OpenSSL::PKey::RSA.new(512)
        public_key = rsa.public_key
        private_key = options[:key].to_s.empty? ? 
          rsa.to_s :
          SymmetricSentry.new(:algorithm => options[:symmetric_algorithm]).encrypt_to_base64(rsa.to_s, options[:key])
        File.open(public_key_file, 'w')  { |f| f.write(public_key) }
        File.open(private_key_file, 'w') { |f| f.write(private_key) }
      end

      def encrypt(data)
        self.new.encrypt(data)
      end
  
      def encrypt_to_base64(data)
        self.new.encrypt_to_base64(data)
      end

      def encrypt_large_to_base64(data)
        self.new.encrypt_large_to_base64(data)
      end
  
      def decrypt(data, key = nil)
        self.new.decrypt(data, key)
      end
  
      def decrypt_large_from_base64(data, key = nil)
         self.new.decrypt_large_from_base64(data, key)
      end
      
      def decrypt_from_base64(data, key = nil)
        self.new.decrypt_from_base64(data, key)
      end

      # cattr_accessor would be lovely
      def default_private_key_file
        @@default_private_key_file
      end
      
      def default_private_key_file=(value)
        @@default_private_key_file = value
      end
      
      def default_public_key_file
        @@default_public_key_file
      end
      
      def default_public_key_file=(value)
        @@default_public_key_file = value
      end
      
      def default_symmetric_algorithm
        @@default_symmetric_algorithm
      end
      
      def default_symmetric_algorithm=(value)
        @@default_symmetric_algorithm = value
      end
    end
  
    private
    def encryptor
      @encryptor ||= SymmetricSentry.new(:algorithm => @symmetric_algorithm)
    end

    def load_private_key
      @private_rsa = nil
      @private_key_file ||= @@default_private_key_file
      if @private_key_file and File.file?(@private_key_file)
        @private_key = File.open(@private_key_file) { |f| f.read }
      end
      return @private_key
    end
  
    def load_public_key
      @public_rsa = nil
      @public_key_file ||= @@default_public_key_file
      if @public_key_file and File.file?(@public_key_file)
        @public_key = File.open(@public_key_file) { |f| f.read }
      end
    end

    # retrieves private rsa from encrypted private key
    def private_rsa(key = nil)
      return @private_rsa ||= OpenSSL::PKey::RSA.new(@private_key) unless key
      OpenSSL::PKey::RSA.new(encryptor.decrypt_from_base64(@private_key, key))
    end

    # retrieves public rsa
    def public_rsa
      @public_rsa ||= OpenSSL::PKey::RSA.new(@public_key)
    end
  end
end