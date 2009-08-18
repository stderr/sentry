require 'abstract_unit'

class RsaKeyTest < Test::Unit::TestCase
  def setup
    @public_key = OpenSSL::PKey::RSA.new(File.open(File.dirname(__FILE__) + '/keys/encrypted_public') { |f| f.read })
  end

  def test_can_find_max_encoded_length_for_key
    assert_equal 53, @public_key.max_encryptable_length
  end
end
