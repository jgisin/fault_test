require 'test_helper'

class PanelsControllerTest < ActionController::TestCase
  setup do
    @panel = panels(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:panels)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create panel" do
    assert_difference('Panel.count') do
      post :create, panel: { c_value: @panel.c_value, init_fault: @panel.init_fault, runs: @panel.runs, voltage: @panel.voltage, wire_length: @panel.wire_length }
    end

    assert_redirected_to panel_path(assigns(:panel))
  end

  test "should show panel" do
    get :show, id: @panel
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @panel
    assert_response :success
  end

  test "should update panel" do
    patch :update, id: @panel, panel: { c_value: @panel.c_value, init_fault: @panel.init_fault, runs: @panel.runs, voltage: @panel.voltage, wire_length: @panel.wire_length }
    assert_redirected_to panel_path(assigns(:panel))
  end

  test "should destroy panel" do
    assert_difference('Panel.count', -1) do
      delete :destroy, id: @panel
    end

    assert_redirected_to panels_path
  end
end
