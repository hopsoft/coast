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

  # Creates a mock model instance [ActiveRecord::Base].
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

  # Creates a mock request instance [ActionDispatch::Request].
  def self.mock_request
    mock = MicroMock.make.new
    mock.stub(:request) { @request ||= MicroMock.make.new }
    mock.stub(:params) { @params ||= {} }
    mock.stub(:flash) { @flash ||= {} }
    mock
  end

  # Creates a mock controller instance [ActionController::Base].
  def self.mock_controller
    mock = MicroMock.make.new
    mock.class.send :include, Coast
    mock.stub(:authorize!) { |*args| @authorize_invoked = true }
    mock.stub(:authorize_invoked?) { @authorize_invoked }
    mock.stub(:respond_to) { |&block| @responded = true; block.call(format) }
    mock.stub(:responded?) { @responded }
    mock.stub(:render) { |*args| @performed = @rendered = true }
    mock.stub(:performed?) { @performed }
    mock.stub(:rendered?) { @rendered }
    mock.stub(:redirect_to) { |*args| @redirected = true; render }
    mock.stub(:redirected?) { @redirected }
    mock.stub(:request) { @request ||= TestCoast.mock_request }
    mock.stub(:params) { request.params }
    mock.stub(:flash) { request.flash }
    mock.stub(:format) { @format ||= TestCoast.mock_format }
    mock.stub(:root_url) { "/" }
    mock
  end

  # Creates a mock format instance [ActionController::MimeResponds::Collector].
  def self.mock_format
    mock = MicroMock.make.new
    mock.stub(:html) { |&block| @html = true; block.call if block }
    mock.stub(:xml) { |&block| @xml = true; block.call if block }
    mock.stub(:json) { |&block| @json = true; block.call if block }
    mock
  end

  before do
    @model = TestCoast.mock_model
    @controller = TestCoast.mock_controller
    @controller.class.set_resourceful_model @model.class
  end

  test ".set_authorize_method" do
    @controller.class.set_authorize_method :authorize!
    assert @controller.class.authorize_method == :authorize!
  end

  test ".authorize_method=" do
    @controller.class.set_authorize_method :authorize!
    assert @controller.class.authorize_method == :authorize!
  end

  test ".set_resourceful_model" do
    model = Object.new
    @controller.class.set_resourceful_model model
    assert @controller.class.resourceful_model == model
  end

  test ".resourceful_model=" do
    model = Object.new
    @controller.class.resourceful_model = model
    assert @controller.class.resourceful_model == model
  end

  test "set before callbacks" do
    RESTFUL_METHODS.each do |method|
      assert !@controller.respond_to?("before_#{method}")
      @controller.class.before(method) {}
      assert @controller.respond_to?("before_#{method}")
    end
  end

  test "set respond_to callbacks" do
    RESTFUL_METHODS.each do |method|
      assert !@controller.respond_to?("respond_to_#{method}")
      @controller.class.respond_to(method) {}
      assert @controller.respond_to?("respond_to_#{method}")
    end
  end

  test "set after callbacks" do
    RESTFUL_METHODS.each do |method|
      assert !@controller.respond_to?("after_#{method}")
      @controller.class.after(method) {}
      assert @controller.respond_to?("after_#{method}")
    end
  end

  test "RESTful methods exist" do
    RESTFUL_METHODS.each do |method|
      assert @controller.respond_to?(method)
    end
  end

  RESTFUL_METHODS.each do |method|

    test "<#{method}> responds and renders" do
      @controller.send(method)
      assert @controller.responded?
      assert @controller.rendered?
    end

    test "<#{method}> renders for the formats html, xml, json" do
      @controller.send(method)
      assert(@controller.format.instance_eval { @html })
      assert(@controller.format.instance_eval { @xml })
      assert(@controller.format.instance_eval { @json })
    end

    test "<#{method}> invokes before, respond_to, after callbacks" do
      callbacks = []
      @controller.class.before(method) { callbacks << :before }
      @controller.class.respond_to(method) { callbacks << :respond_to }
      @controller.class.after(method) { callbacks << :after }
      @controller.send(method)
      assert callbacks.include?(:before)
      assert callbacks.include?(:respond_to)
      assert callbacks.include?(:after)
    end

    test "<#{method}> allows :respond_to callback to perform the render" do
      @controller.class.respond_to(method) { @performed = true }
      @controller.send(method)
      assert @controller.performed?
      assert !@controller.responded?
    end

    test "<#{method}> invokes the authorize_method when set" do
      @controller.class.authorize_method = :authorize!
      @controller.send(method)
      assert @controller.authorize_invoked?
    end

  end

  ITEM_METHODS.each do |method|
    test "<#{method}> allows :before callback to set the resourceful_item" do
      item = TestCoast.mock_model
      @controller.class.before(method) { @resourceful_item = item }
      @controller.send(method)
      assert @controller.instance_eval { @resourceful_item.object_id } == item.object_id
    end

    test "<#{method}> sets a custom named instance variable for the item" do
      item = TestCoast.mock_model
      @controller.class.before(method) { @resourceful_item = item }
      @controller.send(method)
      variable = @controller.instance_eval { instance_variable_get(item_instance_var_name) }
      assert variable.object_id == item.object_id
    end
  end

  MUTATE_METHODS.each do |method|
    test "<#{method}> redirects" do
      @controller.send(method)
      assert @controller.redirected?
    end
  end

  test "<index> allows :before callback to set the list" do
    list = TestCoast.mock_model.class.all
    @controller.class.before(:index) { @resourceful_list = list }
    @controller.index
    assert @controller.instance_eval{ @resourceful_list }.object_id == list.object_id
  end

  test "<index> sets a custom named instance variable for the item" do
    list = TestCoast.mock_model.class.all
    @controller.class.before(:index) { @resourceful_list = list }
    @controller.index
    variable = @controller.instance_eval { instance_variable_get(list_instance_var_name) }
    assert variable.object_id == list.object_id
  end

end