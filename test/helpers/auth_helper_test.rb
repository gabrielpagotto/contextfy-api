require "test_helper"
require "jwt"

class AuthHelperTest < ActiveSupport::TestCase
  setup do
    @payload = { user_id: 1 }
    @secret_key = AuthHelper::JsonWebToken::SECRET_KEY
  end

  test "should encode a valid JWT token" do
    token = AuthHelper::JsonWebToken.encode(@payload)

    assert token.is_a?(String), "Token should be a string"
    assert_not_empty token, "Token should not be empty"
  end

  test "should decode a valid JWT token" do
    token = AuthHelper::JsonWebToken.encode(@payload)
    decoded_payload = AuthHelper::JsonWebToken.decode(token)

    assert_equal @payload[:user_id], decoded_payload[:user_id], "Decoded payload should contain the correct user_id"
  end

  test "should return nil for an invalid token" do
    invalid_token = "invalid.token.here"
    decoded_payload = AuthHelper::JsonWebToken.decode(invalid_token)

    assert_nil decoded_payload, "Invalid token should return nil"
  end

  test "should return nil for an expired token" do
    expired_payload = { user_id: 1, exp: 1.hour.ago.to_i }
    token = JWT.encode(expired_payload, @secret_key)
    decoded_payload = AuthHelper::JsonWebToken.decode(token)

    assert_nil decoded_payload, "Expired token should return nil"
  end
end
