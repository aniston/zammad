# Copyright (C) 2012-2023 Zammad Foundation, https://zammad-foundation.org/

require 'rails_helper'
require 'rotp'

RSpec.describe Auth::TwoFactor do
  let(:user)     { create(:user) }
  let(:instance) { described_class.new(user) }

  before do
    Setting.set('two_factor_authentication_method_authenticator_app', true)
  end

  shared_examples 'responding to provided instance method' do |method|
    it "responds to '.#{method}'" do
      expect(instance).to respond_to(method)
    end
  end

  it_behaves_like 'responding to provided instance method', :enabled?
  it_behaves_like 'responding to provided instance method', :available_methods
  it_behaves_like 'responding to provided instance method', :enabled_methods
  it_behaves_like 'responding to provided instance method', :verify?
  it_behaves_like 'responding to provided instance method', :verify_configuration?
  it_behaves_like 'responding to provided instance method', :all_methods
  it_behaves_like 'responding to provided instance method', :method_object
  it_behaves_like 'responding to provided instance method', :user_methods
  it_behaves_like 'responding to provided instance method', :user_default_method
  it_behaves_like 'responding to provided instance method', :user_setup_required?
  it_behaves_like 'responding to provided instance method', :user_configured?

  shared_examples 'returning expected value' do |method, value, assertion: 'be'|
    context 'when checking array value', if: assertion == 'include' do
      it "returns expected value for '##{method}'" do
        expect(instance.method(method).call).to include(value)
      end
    end

    context 'when checking array value', if: assertion == 'be' do
      it "returns expected value for '##{method}'" do
        expect(instance.method(method).call).to be(value)
      end
    end
  end

  it_behaves_like 'returning expected value', :enabled?, true
  it_behaves_like 'returning expected value', :available_methods, Auth::TwoFactor::Method::AuthenticatorApp, assertion: 'include'
  it_behaves_like 'returning expected value', :enabled_methods, Auth::TwoFactor::Method::AuthenticatorApp, assertion: 'include'
  it_behaves_like 'returning expected value', :all_methods, Auth::TwoFactor::Method::AuthenticatorApp, assertion: 'include'

  describe '#method_object' do
    before { create(:'user/two_factor_preference', user: user) }

    it 'returns expected value' do
      expect(instance.method_object('authenticator_app')).to be_a(Auth::TwoFactor::Method::AuthenticatorApp)
    end
  end

  describe '#user_methods' do
    before { create(:'user/two_factor_preference', user: user) }

    it 'returns expected value' do
      expect(instance.user_methods).to include(Auth::TwoFactor::Method::AuthenticatorApp)
    end
  end

  describe '#user_default_method' do
    before { create(:'user/two_factor_preference', user: user) }

    it 'returns expected value' do
      expect(instance.user_default_method).to be_a(Auth::TwoFactor::Method::AuthenticatorApp)
    end
  end

  describe '#user_setup_required' do
    let(:user_role)     { create(:role, :agent) }
    let(:non_user_role) { create(:role, :agent) }
    let(:user)          { create(:user, roles: [user_role]) }

    context 'when the setup is required' do
      before do
        Setting.set('two_factor_authentication_enforce_role_ids', [user_role.id])
      end

      it 'returns expected value' do
        expect(instance.user_setup_required?).to be(true)
      end
    end

    context 'when the setup is not required' do
      before do
        Setting.set('two_factor_authentication_enforce_role_ids', [non_user_role.id])
      end

      it 'returns expected value' do
        expect(instance.user_setup_required?).to be(false)
      end
    end
  end

  describe '#user_configured' do
    before do
      Setting.set('two_factor_authentication_method_authenticator_app', true)
    end

    context 'when a method is configured' do
      before { create(:'user/two_factor_preference', user: user) }

      it 'returns expected value' do
        expect(instance.user_configured?).to be(true)
      end
    end

    context 'when a method is not configured' do
      it 'returns expected value' do
        expect(instance.user_configured?).to be(false)
      end
    end
  end

  describe '#verify' do
    let(:secret) { ROTP::Base32.random_base32 }
    let(:last_otp_at) { 1_256_953_732 } # 2009-10-31T01:48:52Z

    let(:two_factor_pref) do
      create(:'user/two_factor_preference',
             user:          user,
             method:        method,
             configuration: configuration)
    end

    let(:configuration) do
      {
        last_otp_at: last_otp_at,
        secret:      secret,
      }
    end

    before { two_factor_pref }

    context 'with authenticator app as method' do
      let(:method) { 'authenticator_app' }
      let(:code)   { ROTP::TOTP.new(secret).now }

      shared_examples 'returning true result' do
        it 'returns true result' do
          result = instance.verify?(method, code)

          expect(result).to be true
        end

        it 'updates last otp at timestamp' do
          instance.verify?(method, code)

          expect(user.two_factor_preferences.find_by(method: method).configuration[:last_otp_at]).to be > last_otp_at
        end
      end

      shared_examples 'returning false result' do
        it 'returns false result' do
          result = instance.verify?(method, code)

          expect(result).to be false
        end
      end

      context 'with valid code provided' do
        let(:code) { ROTP::TOTP.new(secret).now }

        it_behaves_like 'returning true result'
      end

      context 'with invalid code provided' do
        let(:code) { 'FOOBAR' }

        it_behaves_like 'returning false result'
      end

      context 'with no configured secret' do
        let(:code) { ROTP::TOTP.new(secret).now }
        let(:configuration) do
          {
            foo: 'bar',
          }
        end

        it_behaves_like 'returning false result'
      end

      context 'with no configured method' do
        let(:code)          { ROTP::TOTP.new(secret).now }
        let(:configuration) { nil }

        it_behaves_like 'returning false result'
      end
    end
  end
end
