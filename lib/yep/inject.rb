module Yep
  module Inject
    def inject(name)
      variable = "@#{name}"
      define_method(name) do
        unless instance_variable_defined?(variable)
          instance_variable_set(variable, Container.resolve(name))
        end

        instance_variable_get(variable)
      end
    end

    def enable_dependency_mocks!
      define_method(:mock) do |name, clazz|
        variable = "@#{name}"
        instance_variable_set(variable, clazz)
      end

      define_method(:unmock) do |name|
        variable = "@#{name}"
        instance_variable_set(variable, Container.resolve(name))
      end
    end
  end
end
