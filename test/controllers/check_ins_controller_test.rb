require 'test_helper'

class CheckInsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @check_in = check_ins(:one)
  end

  test "should get index" do
    get check_ins_url
    assert_response :success
  end

  test "should get new" do
    get new_check_in_url
    assert_response :success
  end

  test "should create check_in" do
    assert_difference('CheckIn.count') do
      post check_ins_url, params: { check_in: { account_id: @check_in.account_id, name: @check_in.name, schedule_period: @check_in.schedule_period, time: @check_in.time, user_id: @check_in.user_id, weekday: @check_in.weekday } }
    end

    assert_redirected_to check_in_url(CheckIn.last)
  end

  test "should show check_in" do
    get check_in_url(@check_in)
    assert_response :success
  end

  test "should get edit" do
    get edit_check_in_url(@check_in)
    assert_response :success
  end

  test "should update check_in" do
    patch check_in_url(@check_in), params: { check_in: { account_id: @check_in.account_id, name: @check_in.name, schedule_period: @check_in.schedule_period, time: @check_in.time, user_id: @check_in.user_id, weekday: @check_in.weekday } }
    assert_redirected_to check_in_url(@check_in)
  end

  test "should destroy check_in" do
    assert_difference('CheckIn.count', -1) do
      delete check_in_url(@check_in)
    end

    assert_redirected_to check_ins_url
  end
end
