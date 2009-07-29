require 'abstract_unit'
require 'fixtures/user'

class AsymmetricSentryCallbackTest < ActiveSupport::TestCase
  fixtures :users

  def setup
    super
    @str = 'sentry'
    @key = 'secret'
    @public_key_file = File.dirname(__FILE__) + '/keys/public'
    @private_key_file = File.dirname(__FILE__) + '/keys/private'
    @encrypted_public_key_file = File.dirname(__FILE__) + '/keys/encrypted_public'
    @encrypted_private_key_file = File.dirname(__FILE__) + '/keys/encrypted_private'

    @orig = 'sentry'
    Sentry::AsymmetricSentry.default_public_key_file = @public_key_file
    Sentry::AsymmetricSentry.default_private_key_file = @private_key_file
    Sentry::SymmetricSentry.default_key = @key
  end

  def test_should_encrypt_creditcard
    u = User.create :login => 'jones'
    u.creditcard = @orig
    assert u.save
    assert !u.crypted_creditcard.empty?
  end

  def test_should_deal_with_before_typecast
    u = User.create :login => 'jones'
    u.creditcard = "123123"
    assert_equal "123123", u.creditcard_before_type_cast
    assert u.save
    u.reload
    assert_equal "123123", u.creditcard_before_type_cast
  end

  def test_should_decrypt_creditcard
    assert_equal @orig, users(:user_1).creditcard
  end

  def test_should_not_decrypt_encrypted_creditcard_with_invalid_key
    assert_nil users(:user_2).creditcard
    assert_nil users(:user_2).creditcard(@key)
    use_encrypted_keys
    assert_nil users(:user_1).creditcard
  end

  def test_should_not_decrypt_encrypted_creditcard
    use_encrypted_keys
    assert_nil users(:user_2).creditcard
    assert_nil users(:user_2).creditcard('other secret')
  end

  def test_should_encrypt_encrypted_creditcard
    use_encrypted_keys
    u = User.create :login => 'jones'
    u.creditcard = @orig
    assert u.save
    assert !u.crypted_creditcard.empty?
  end

  def test_should_decrypt_encrypted_creditcard
    use_encrypted_keys
    assert_equal @orig, users(:user_2).creditcard(@key)
  end

  def use_encrypted_keys
    Sentry::AsymmetricSentry.default_public_key_file = @encrypted_public_key_file
    Sentry::AsymmetricSentry.default_private_key_file = @encrypted_private_key_file
  end
end