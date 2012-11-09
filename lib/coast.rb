# Makes any controller resourceful by providing the following actions:
# * new
# * edit
# * index
# * show
# * create
# * update
# * destroy
#
# There are 3 callbacks that you can leverage to manage the RESTful behavior:
# * before - Happens before any logic, just like a Rails before_filter.
#            Note that this callback is invoked before any authorization is applied
# * respond_to - Happens after CRUD operations but before rendering a response
# * after - Happens after any logic, just like a Rails after_filter
#
# You can hook into the controller's lifecycle like so:
#
#   before([action]) do
#     # logic here
#   end
#
#   respond_to([action]) do
#     # logic here
#   end
#
#   after([action]) do
#     # logic here
#   end
#
# Resourceful leans heavily on Rails naming conventions.
# If you are using Rails naming convetions, all this power is yours for free.
module Coast

  module ClassMethods

    def set_authorize_method(arg)
      @authorize_method = arg
    end
    alias :authorize_method= :set_authorize_method

    def authorize_method
      @authorize_method ||= :abstract_authorize
    end

    def set_resourceful_model(arg)
      @resourceful_model = arg
    end
    alias :resourceful_model= :set_resourceful_model

    def resourceful_model
      return @resourceful_model if @resourceful_model

      # try to determine the model based on convention
      name = self.name.gsub(/Controller$/i, "").classify
      # require the file to ensure the constant will be defined
      require "#{RAILS_ROOT}/app/models/#{name.underscore}" rescue nil
      @resourceful_model = Object.const_get(name)
    end

    def before(action, &callback)
      define_method "before_#{action}", &callback
    end

    def respond_to(action, &callback)
      define_method "respond_to_#{action}", &callback
    end

    def after(action, &callback)
      define_method "after_#{action}", &callback
    end

  end

  def self.included(mod)
    mod.extend(ClassMethods)
  end

  def abstract_authorize(*args); end

  # -----------------------------------------------------------------------------------------------
  # begin restful actions

  # begin UI actions
  def new
    invoke_callback(:before_new)
    @resourceful_item ||= resourceful_model.new
    send(self.class.authorize_method, :new, @resourceful_item, request)
    init_instance_variables
    invoke_callback(:respond_to_new)
    unless performed?
      respond_to do |format|
        format.html { render :new }
        format_json_and_xml(format, :message => I18n.t("coast.format_not_supported"))
      end
    end
    invoke_callback(:after_new)
  end

  def edit
    invoke_callback(:before_edit)
    @resourceful_item ||= resourceful_model.find(params[:id])
    send(self.class.authorize_method, :edit, @resourceful_item, request)
    init_instance_variables
    invoke_callback(:respond_to_edit)
    unless performed?
      respond_to do |format|
        format.html { render :edit }
        format_json_and_xml(format, :message => I18n.t("coast.format_not_supported"))
      end
    end
    invoke_callback(:after_edit)
  end
  # end UI actions

  # begin READ actions
  def index
    invoke_callback(:before_index)
    @resourceful_list ||= resourceful_model.all
    send(self.class.authorize_method, :index, @resourceful_list, request)
    init_instance_variables
    invoke_callback(:respond_to_index)
    unless performed?
      respond_to do |format|
        format.html { render :index }
        format_json_and_xml(format, @resourceful_list)
      end
    end
    invoke_callback(:after_index)
  end

  def show
    invoke_callback(:before_show)
    @resourceful_item ||= resourceful_model.find(params[:id])
    send(self.class.authorize_method, :show, @resourceful_item, request)
    init_instance_variables
    invoke_callback(:respond_to_show)
    unless performed?
      respond_to do |format|
        format.html { render :show }
        format_json_and_xml(format, @resourceful_item)
      end
    end
    invoke_callback(:after_show)
  end
  # end READ actions

  # begin MUTATING actions
  def create
    invoke_callback(:before_create)
    @resourceful_item ||= resourceful_model.new(params[resourceful_model.name.underscore])
    send(self.class.authorize_method, :create, @resourceful_item, request)
    init_instance_variables
    success = @skip_db_create || @resourceful_item.save
    invoke_callback(:respond_to_create)
    unless performed?
      respond_to do |format|
        if success
          flash[:notice] = I18n.t("coast.was_created", :model => resourceful_model.name)
          format.html { redirect_to(@resourceful_item) }
          format_json_and_xml(format, @resourceful_item, :status => :created, :location => @resourceful_item)
        else
          format.html { render :action => "new" }
          format_json_and_xml(format, @resourceful_item.errors, :status => :unprocessable_entity)
        end
      end
    end
    invoke_callback(:after_create)
  end

  def update
    invoke_callback(:before_update)
    @resourceful_item ||= resourceful_model.find(params[:id])
    send(self.class.authorize_method, :update, @resourceful_item, request)
    init_instance_variables
    success = @skip_db_update || @resourceful_item.update_attributes(params[resourceful_model.name.underscore])
    invoke_callback(:respond_to_update)
    unless performed?
      respond_to do |format|
        if success
          flash[:notice] = I18n.t("coast.was_updated", :model => resourceful_model.name)
          format.html { redirect_to(@resourceful_item) }
          format_json_and_xml(format, @resourceful_item)
        else
          format.html { render :action => "edit" }
          format_json_and_xml(format, @resourceful_item.errors, :status => :unprocessable_entity)
        end
      end
    end
    invoke_callback(:after_update)
  end

  def destroy
    invoke_callback(:before_destroy)
    @resourceful_item ||= resourceful_model.find(params[:id])
    send(self.class.authorize_method, :destroy, @resourceful_item, request)
    init_instance_variables
    @resourceful_item.destroy unless @skip_db_destroy
    invoke_callback(:respond_to_destroy)
    unless performed?
      flash[:notice] = I18n.t("coast.was_destroyed", :model => resourceful_model.name) if @resourceful_item.destroyed?
      respond_to do |format|
        format.html { redirect_to root_url }
        format_json_and_xml(format, @resourceful_item)
      end
    end
    invoke_callback(:after_destroy)
  end
  # end MUTATING actions

  # end restful actions
  # -----------------------------------------------------------------------------------------------

  protected

  def resourceful_model
    self.class.resourceful_model
  end

  def init_instance_variables
    instance_variable_set(item_instance_var_name, @resourceful_item) unless instance_variable_get(item_instance_var_name)
    instance_variable_set(list_instance_var_name, @resourceful_list) unless instance_variable_get(list_instance_var_name)
  end

  def item_instance_var_name
    return @item_instance_var_name if @item_instance_var_name
    name = resourceful_model.name.underscore.gsub("/", "_")
    @item_instance_var_name ||= "@#{name}"
  end

  def list_instance_var_name
    @list_instance_var_name ||= item_instance_var_name.pluralize
  end

  private

  def invoke_callback(name)
    send(name) if respond_to?(name)
  end

  def format_json_and_xml(format, data, options={})
    format.xml { render({:xml => data}.merge(options)) }
    format.json { render({:json => data}.merge(options)) }
  end

end
