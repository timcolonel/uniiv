require 'test_helper'

class ContactusFormControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  test 'Should get new' do
    get :new
    assert_response :success
  end

  test 'Should create contactus form' do

    assert_difference 'ContactusForm.count' do
      get :create, :contactus_form => {:email => 'test@example.com', :content => 'Test content'}
      assert_response :redirect
    end
  end
end
