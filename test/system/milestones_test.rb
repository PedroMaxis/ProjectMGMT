require "application_system_test_case"

class MilestonesTest < ApplicationSystemTestCase
  setup do
    @milestone = milestones(:one)
  end

  test "visiting the index" do
    visit milestones_url
    assert_selector "h1", text: "Milestones"
  end

  test "should create milestone" do
    visit milestones_url
    click_on "New milestone"

    fill_in "Description", with: @milestone.description
    fill_in "Due date", with: @milestone.due_date
    fill_in "Project", with: @milestone.project_id
    fill_in "Title", with: @milestone.title
    click_on "Create Milestone"

    assert_text "Milestone was successfully created"
    click_on "Back"
  end

  test "should update Milestone" do
    visit milestone_url(@milestone)
    click_on "Edit this milestone", match: :first

    fill_in "Description", with: @milestone.description
    fill_in "Due date", with: @milestone.due_date
    fill_in "Project", with: @milestone.project_id
    fill_in "Title", with: @milestone.title
    click_on "Update Milestone"

    assert_text "Milestone was successfully updated"
    click_on "Back"
  end

  test "should destroy Milestone" do
    visit milestone_url(@milestone)
    click_on "Destroy this milestone", match: :first

    assert_text "Milestone was successfully destroyed"
  end
end
