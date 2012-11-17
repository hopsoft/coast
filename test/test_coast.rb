require "rubygems"
require "bundler"
Bundler.require(:default, :test)
require "active_support/all"
require File.join(File.dirname(__FILE__), "..", "lib", "coast")

class TestCoast < MicroTest::Test

  RESTFUL_METHODS = %w(index show new edit create update destroy)
  ITEM_METHODS    = %w(show new edit create update destroy)
  UI_METHODS      = %w(new edit)
  READ_METHODS    = %w(index show)
  MUTATE_METHODS  = %w(create update destroy)

  # Creates a mock ActiveRecord instance.
  def self.mock_model
    mock = MicroMock.make.new
    mock.stub(:destroy) { @destroyed = true }
    mock.stub(:destroyed?) { @destroyed }
    mock.stub(:update_attributes) { |*args| @attributes_updated = true }
    mock.stub(:save) { |*args| @saved = true }
    mock.stub(:table_name) { "mocks" }
    mock.class.stub(:find) { |*args| TestCoast.mock_model }
    mock.class.stub(:all) { [1..5].map { TestCoast.mock_model } }
    mock
  end

  # Creates a mock ActionDispatch::Request instance.
  def self.mock_request
    mock = MicroMock.make.new
    mock.stub(:request) { MicroMock.make.new }
    mock.stub(:params) { @params ||= {} }
    mock.stub(:flash) { @flash ||= {} }
    # mock.stub(:root_url) { "/" }
    mock
  end

  # Creates a mock ActionController instance.
  def self.mock_controller
    mock = MicroMock.make.new
    mock.class.send :include, Coast
    mock.stub(:authorize!) { |*args| @authorize_invoked = true }
    mock.stub(:respond_to) { |&block| @responded = true; block.call(format) }
    mock.stub(:render) { |*args| @performed = @rendered = true }
    mock.stub(:redirect_to) { |*args| @redirected = true; render }
    mock.stub(:request) { @request ||= TestCoast.mock_request }
    mock.stub(:params) { request.params }
    mock.stub(:flash) { request.flash }
    mock.stub(:performed?) { @performed }
    mock.stub(:responded?) { @responded }
    mock.stub(:rendered?) { @rendered }
    mock.stub(:format) { @format ||= TestCoast.mock_format }
    mock.stub(:root_url) { "/" }
    mock
  end

  # Creates a mock format object.
  def self.mock_format
    mock = MicroMock.make.new
    mock.stub(:html) { |&block| @html = true; block.call if block }
    mock.stub(:xml) { |&block| @xml = true; block.call if block }
    mock.stub(:json) { |&block| @json = true; block.call if block }
    mock
  end

  before do
    @mock_model = TestCoast.mock_model
    @mock_controller = TestCoast.mock_controller
    @mock_controller.class.set_resourceful_model @mock_model.class
  end

  test ".set_authorize_method" do
    @mock_controller.class.set_authorize_method :authorize!
    assert @mock_controller.class.authorize_method == :authorize!
  end

  test ".authorize_method=" do
    @mock_controller.class.set_authorize_method :authorize!
    assert @mock_controller.class.authorize_method == :authorize!
  end

  test ".set_resourceful_model" do
    model = Object.new
    @mock_controller.class.set_resourceful_model model
    assert @mock_controller.class.resourceful_model == model
  end

  test ".resourceful_model=" do
    model = Object.new
    @mock_controller.class.resourceful_model = model
    assert @mock_controller.class.resourceful_model == model
  end

  test "set before callbacks" do
    RESTFUL_METHODS.each do |method|
      assert !@mock_controller.respond_to?("before_#{method}")
      @mock_controller.class.before(method) {}
      assert @mock_controller.respond_to?("before_#{method}")
    end
  end

  test "set respond_to callbacks" do
    RESTFUL_METHODS.each do |method|
      assert !@mock_controller.respond_to?("respond_to_#{method}")
      @mock_controller.class.respond_to(method) {}
      assert @mock_controller.respond_to?("respond_to_#{method}")
    end
  end

  test "set after callbacks" do
    RESTFUL_METHODS.each do |method|
      assert !@mock_controller.respond_to?("after_#{method}")
      @mock_controller.class.after(method) {}
      assert @mock_controller.respond_to?("after_#{method}")
    end
  end

  test "RESTful methods exist" do
    RESTFUL_METHODS.each do |method|
      assert @mock_controller.respond_to?(method)
    end
  end

  RESTFUL_METHODS.each do |method|

    test "<#{method}> responds and renders" do
      @mock_controller.send(method)
      assert @mock_controller.responded?
      assert @mock_controller.rendered?
    end

    test "<#{method}> renders for the formats html, xml, json" do
      @mock_controller.send(method)
      assert(@mock_controller.format.instance_eval { @html })
      assert(@mock_controller.format.instance_eval { @xml })
      assert(@mock_controller.format.instance_eval { @json })
    end

  #     it "invokes the callbacks before, respond_to, after" do
  #       callbacks = []

  #       Coast::TestableController.class_eval do
  #         before(method) { callbacks << :before }
  #         respond_to(method) { callbacks << :respond_to }
  #         after(method) { callbacks << :after }
  #       end

  #       controller = Coast::TestableController.new
  #       controller.send(method)
  #       assert callbacks.include?(:before), "Did not invoke the before callback"
  #       assert callbacks.include?(:respond_to), "Did not invoke the respond_to callback"
  #       assert callbacks.include?(:after), "Did not invoke the after callback"
  #     end

  #     it "allows :respond_to callback to perform the render" do
  #       Coast::TestableController.respond_to(method) { @performed = true }
  #       controller = Coast::TestableController.new
  #       controller.send(method)
  #       assert controller.responded? == false, "Did not allow :respond_to callback to perform the render"
  #     end

  #     it "invokes the authorize_method when set" do
  #       Coast::TestableController.authorize_method = :authorize!
  #       controller = Coast::TestableController.new
  #       controller.send(:index)
  #       assert controller.authorize_invoked?, "Did not invoke the authorize_method"
  #     end

  #   end
  end

  # ITEM_METHODS.each do |method|
  #   describe "##{method}" do
  #     before do
  #       reset
  #     end

  #     it "allows :before callback to set the item" do
  #       item = Object.new
  #       Coast::TestableController.before(:index) { @resourceful_item = item }
  #       controller = Coast::TestableController.new
  #       controller.index
  #       assert controller.instance_eval { @resourceful_item } == item, "Did not allow :before callback to set the resourceful_item"
  #     end

  #     it "sets a custom named instance variable for the item" do
  #       item = Object.new
  #       Coast::TestableController.before(:index) { @resourceful_item = item }
  #       controller = Coast::TestableController.new
  #       controller.index
  #       variable = controller.instance_eval { instance_variable_get(item_instance_var_name) }
  #       assert variable != nil, "Did not set a custom instance variable for the item"
  #       assert variable == item, "Did not set a custom instance variable for the item to the correct value"
  #     end

  #   end
  # end

  # MUTATE_METHODS.each do |method|
  #   describe "##{method}" do
  #     before do
  #       reset
  #     end

  #     it "redirects" do
  #       controller = Coast::TestableController.new
  #       controller.send(method)
  #       assert controller.redirected?, "Did not redirect"
  #     end
  #   end
  # end


  # describe "#index" do
  #   before do
  #     reset
  #   end

  #   it "allows :before callback to set the list" do
  #     list = [ Object.new ]
  #     Coast::TestableController.before(:index) { @resourceful_list = list }
  #     controller = Coast::TestableController.new
  #     controller.index
  #     assert controller.instance_eval { @resourceful_list } == list, "Did not allow :before callback to set the resourceful_list"
  #   end

  #   it "sets a custom named instance variable for the item" do
  #     list = [ Object.new ]
  #     Coast::TestableController.before(:index) { @resourceful_list = list }
  #     controller = Coast::TestableController.new
  #     controller.index
  #     variable = controller.instance_eval { instance_variable_get(list_instance_var_name) }
  #     assert variable != nil, "Did not set a custom instance variable for the item"
  #     assert variable == list, "Did not set a custom instance variable for the item to the correct value"
  #   end
  # end

end
