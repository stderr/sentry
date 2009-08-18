#Copyright (c) 2005 Rick Olson
#
#Permission is hereby granted, free of charge, to any person obtaining
#a copy of this software and associated documentation files (the
#"Software"), to deal in the Software without restriction, including
#without limitation the rights to use, copy, modify, merge, publish,
#distribute, sublicense, and/or sell copies of the Software, and to
#permit persons to whom the Software is furnished to do so, subject to
#the following conditions:
#
#The above copyright notice and this permission notice shall be
#included in all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
#NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
#LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
#OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
#WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'openssl'
require 'base64'
require 'sentry/symmetric_sentry'
require 'sentry/asymmetric_sentry'
require 'sentry/sha_sentry'
require 'sentry/symmetric_sentry_callback'
require 'sentry/asymmetric_sentry_callback'

module Sentry
  class NoKeyError < StandardError
  end
  class NoPublicKeyError < StandardError
  end
  class NoPrivateKeyError < StandardError
  end
  mattr_accessor :default_key
end

begin
  require 'active_record/sentry'
  ActiveRecord::Base.class_eval do
    include ActiveRecord::Sentry
  end
rescue NameError
  nil
end

class OpenSSL::PKey::RSA
  def max_encryptable_length
    @max_encryption_length ||= calc_max_encrypted_length
  end

  private

  def calc_max_encrypted_length
    upper_bound = 4*1024
    test_length = upper_bound / 2
    while test_length != (upper_bound - 1)
      probe = "a" * test_length
      begin
        self.public_encrypt(probe)
        test_length = test_length + ((upper_bound - test_length) / 2)
      rescue Exception => e
        upper_bound = test_length
        test_length = test_length / 2
      end
    end
    return test_length
  end
end
