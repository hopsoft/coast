require "forwardable"

module Coast
  class TestableModel
    extend Forwardable

    def initialize(*args)
    end

    def self.table_name
      "testable_models"
    end

    def self.find(id)
      TestableModel.new
    end

    def self.all
      [TestableModel.new, TestableModel.new, TestableModel.new]
    end

    define_method(:saved?) { !!@saved }
    define_method(:destroyed?) { !!@destroyed }
    define_method(:attributes_updated?) { !!@attributes_updated }

    def destroy
      @destroyed = true
    end

    def update_attributes(*args)
      @attributes_updated = true
    end

    def save
      @saved = true
    end

  end
end
