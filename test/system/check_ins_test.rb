require "application_system_test_case"

class CheckInsTest < ApplicationSystemTestCase
  setup do
    @check_in = check_ins(:one)
  end

  test "visiting the index" do
    visit check_ins_url
    assert_selector "h1", text: "Check Ins"
  end

  test "creating a Check in" do
    visit check_ins_url
    click_on "New Check In"

    fill_in "Account", with: @check_in.account_id
    fill_in "Name", with: @check_in.name
    fill_in "Schedule period", with: @check_in.schedule_period
    fill_in "Time", with: @check_in.time
    fill_in "User", with: @check_in.user_id
    fill_in "Weekday", with: @check_in.weekday
    click_on "Create Check in"

    assert_text "Check in was successfully created"
    click_on "Back"
  end

  test "updating a Check in" do
    visit check_ins_url
    click_on "Edit", match: :first

    fill_in "Account", with: @check_in.account_id
    fill_in "Name", with: @check_in.name
    fill_in "Schedule period", with: @check_in.schedule_period
    fill_in "Time", with: @check_in.time
    fill_in "User", with: @check_in.user_id
    fill_in "Weekday", with: @check_in.weekday
    click_on "Update Check in"

    assert_text "Check in was successfully updated"
    click_on "Back"
  end

  test "destroying a Check in" do
    visit check_ins_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Check in was successfully destroyed"
  end
end
