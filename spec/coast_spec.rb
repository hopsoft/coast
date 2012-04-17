require "rubygems"

# fix MiniTest issue with 1.9
unless defined? Gem::Deprecate
  module Gem
    Deprecate = Module.new do
      include Deprecate
    end
  end
end

require "bundler/setup"
Bundler.require(:default, :test)
require "minitest/autorun"
require "active_support/all"

dirname = File.dirname(__FILE__)
require File.join(dirname, "mock")
Dir.glob(File.join(dirname, "..", "lib", "*.rb")) { |f| require f }
MODEL_PATH = File.join(dirname, "testable_model.rb")
CONTROLLER_PATH = File.join(dirname, "testable_controller.rb")
load MODEL_PATH
load CONTROLLER_PATH




describe Coast do
  RESTFUL_METHODS = %w(index show new edit create update destroy)
  ITEM_METHODS    = %w(show new edit create update destroy)
  UI_METHODS      = %w(new edit)
  READ_METHODS    = %w(index show)
  MUTATE_METHODS  = %w(create update destroy)

  # Resets the mock class defs.
  def reset
    Coast.send(:remove_const, :TestableController)
    Coast.send(:remove_const, :TestableModel)
    load MODEL_PATH
    load CONTROLLER_PATH
    Coast::TestableController.set_resourceful_model Coast::TestableModel
  end

  # class method tests ============================================================================

  describe :set_authorize_method do
    it "sets the method used to perform authorization checks" do
      reset
      Coast::TestableController.set_authorize_method :authorize!
      assert Coast::TestableController.authorize_method == :authorize!
    end
  end

  describe :authorize_method= do
    it "sets the method used to perform authorization checks" do
      reset
      Coast::TestableController.authorize_method = :authorize!
      assert Coast::TestableController.authorize_method == :authorize!
    end
  end

  describe :set_resourceful_model do
    it "sets the model that the controller manages" do
      reset
      model = Object.new
      Coast::TestableController.set_resourceful_model model
      assert Coast::TestableController.resourceful_model == model
    end
  end

  describe :resourceful_model= do
    it "sets the model that the controller manages" do
      reset
      model = Object.new
      Coast::TestableController.resourceful_model = model
      assert Coast::TestableController.resourceful_model == model
    end
  end

  def verify_callback_setter(event, action)
    reset
    Coast::TestableController.send(event, action, &(lambda {}))
    assert Coast::TestableController.new.respond_to?("#{event}_#{action}")
  end

  describe :before do
    it "stores a before callback for all RESTful actions" do
      RESTFUL_METHODS.each { |m| verify_callback_setter :before, m }
    end
  end

  describe :respond_to do
    it "stores a respond_to callback for all RESTful actions" do
      RESTFUL_METHODS.each { |m| verify_callback_setter :respond_to, m }
    end
  end

  describe :after do
    it "stores an after callback for all RESTful actions" do
      RESTFUL_METHODS.each { |m| verify_callback_setter :after, m }
    end
  end











  # instance method tests =========================================================================


  it "supports all RESTful methods" do
    reset
    controller = Coast::TestableController.new
    RESTFUL_METHODS.each { |m| controller.must_respond_to m }
  end

  # %w(index show new).each do |method|
  RESTFUL_METHODS.each do |method|
    describe "##{method}" do
      before do
        reset
      end

      it "responds and renders" do
        controller = Coast::TestableController.new
        controller.send(method)
        assert controller.responded?, "Did not respond"
        assert controller.rendered?, "Did not render"
      end

      it "renders for the formats html, xml, json" do
        controller = Coast::TestableController.new
        controller.send(method)
        assert controller.html, "Did not respond to the html format"
        assert controller.xml, "Did not respond to the xml format"
        assert controller.json, "Did not respond to the json format"
      end

      it "invokes the callbacks before, respond_to, after" do
        callbacks = []

        Coast::TestableController.class_eval do
          before(method) { callbacks << :before }
          respond_to(method) { callbacks << :respond_to }
          after(method) { callbacks << :after }
        end

        controller = Coast::TestableController.new
        controller.send(method)
        assert callbacks.include?(:before), "Did not invoke the before callback"
        assert callbacks.include?(:respond_to), "Did not invoke the respond_to callback"
        assert callbacks.include?(:after), "Did not invoke the after callback"
      end

      it "allows :respond_to callback to perform the render" do
        Coast::TestableController.respond_to(method) { @performed = true }
        controller = Coast::TestableController.new
        controller.send(method)
        assert controller.responded? == false, "Did not allow :respond_to callback to perform the render"
      end

      it "invokes the authorize_method when set" do
        Coast::TestableController.authorize_method = :authorize!
        controller = Coast::TestableController.new
        controller.send(:index)
        assert controller.authorize_invoked?, "Did not invoke the authorize_method"
      end

    end
  end

  ITEM_METHODS.each do |method|
    describe "##{method}" do
      before do
        reset
      end

      it "allows :before callback to set the item" do
        item = Object.new
        Coast::TestableController.before(:index) { @resourceful_item = item }
        controller = Coast::TestableController.new
        controller.index
        assert controller.instance_eval { @resourceful_item } == item, "Did not allow :before callback to set the resourceful_item"
      end

      it "sets a custom named instance variable for the item" do
        item = Object.new
        Coast::TestableController.before(:index) { @resourceful_item = item }
        controller = Coast::TestableController.new
        controller.index
        variable = controller.instance_eval { instance_variable_get(item_instance_var_name) }
        assert variable != nil, "Did not set a custom instance variable for the item"
        assert variable == item, "Did not set a custom instance variable for the item to the correct value"
      end

    end
  end

  MUTATE_METHODS.each do |method|
    describe "##{method}" do
      before do
        reset
      end

      it "redirects" do
        controller = Coast::TestableController.new
        controller.send(method)
        assert controller.redirected?, "Did not redirect"
      end
    end
  end


  describe "#index" do
    before do
      reset
    end

    it "allows :before callback to set the list" do
      list = [ Object.new ]
      Coast::TestableController.before(:index) { @resourceful_list = list }
      controller = Coast::TestableController.new
      controller.index
      assert controller.instance_eval { @resourceful_list } == list, "Did not allow :before callback to set the resourceful_list"
    end

    it "sets a custom named instance variable for the item" do
      list = [ Object.new ]
      Coast::TestableController.before(:index) { @resourceful_list = list }
      controller = Coast::TestableController.new
      controller.index
      variable = controller.instance_eval { instance_variable_get(list_instance_var_name) }
      assert variable != nil, "Did not set a custom instance variable for the item"
      assert variable == list, "Did not set a custom instance variable for the item to the correct value"
    end
  end

end
