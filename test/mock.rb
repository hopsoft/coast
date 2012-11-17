# MiniTest::Mock # force to load so our methods don't get removed

# module Coast
#   class Mock < MiniTest::Mock

#     def expect_with_block(name, retval, args=[], &block)
#       expect(name, retval, args)

#       if block_given?
#         expected_calls = @expected_calls[name].select { |call| call[:args].size == args.size }
#         expected_calls.each do |call|
#           call[:block] = block
#         end
#       end

#       self
#     end

#     def method_missing(name, *args, &block)
#       expected_calls = @expected_calls[name].select { |call| call[:args].size == args.size }

#       return super unless expected_calls

#       expected_call = expected_calls.find do |call|
#         call[:args].zip(args).all? { |mod, a| mod === a or mod == a }
#       end

#       return super unless expected_call

#       if expected_call[:block]
#         expected_call[:block].call(*expected_call[:args], &block)
#         return expected_call[:retval]
#       end

#       super
#     end

#   end
# end
