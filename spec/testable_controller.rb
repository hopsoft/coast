require "forwardable"

module Coast
  class TestableController
    include Coast
    attr_accessor :html, :xml, :json

    extend Forwardable
    def_delegator :@mock, :request
    def_delegator :@mock, :params
    def_delegator :@mock, :flash
    def_delegator :@mock, :root_url

    def initialize
      @mock = Coast::Mock.new
      @mock.expect(:request, Coast::Mock.new)
      @mock.expect(:params, {})
      @mock.expect(:flash, {})
      @mock.expect(:root_url, "/")

      @format = Coast::Mock.new
      @format.expect_with_block(:html, nil) { |&b| @html = true; b.call if b }
      @format.expect_with_block(:xml, nil) { |&b| @xml = true; b.call if b }
      @format.expect_with_block(:json, nil) { |&b| @json = true; b.call if b }
    end

    define_method(:responded?) { !!@responded }
    define_method(:rendered?) { !!@rendered }
    define_method(:redirected?) { !!@redirected }
    define_method(:performed?) { !!@performed }
    define_method(:authorize_invoked?) { !!@authorize_invoked }

    def authorize!(*args)
      @authorize_invoked = true
    end

    def respond_to
      @responded = true
      yield @format
    end

    def render(*args)
      @performed = true
      @rendered = true
    end

    def redirect_to(*args)
      render
      @redirected = true
    end

  end
end
