require 'monitor'

module Yep
  class Container
    module ClassMethods
      def add(name, clazz, lifetime = Container::INSTANCE)
        instance.add(name: name, clazz: clazz, lifetime: lifetime)
      end

      def resolve(name)
        instance.resolve(name: name)
      end

      private

      def instance
        @instance ||= new
      end
    end

    extend ClassMethods
    include MonitorMixin

    INSTANCE = :instance
    SINGLETON = :singleton

    CannotResolveError = Class.new(StandardError)
    AlreadyAddedError = Class.new(StandardError)

    def initialize
      super
      @store ||= {}
    end

    def add(name:, clazz:, lifetime:)
      synchronize do
        raise(AlreadyAddedError, "Depenency with key #{name} already exists") \
          if store.key?(name)

        store[name] = {
          class: clazz,
          lifetime: lifetime
        }
      end
    end

    def resolve(name:)
      synchronize do
        object = store[name]
        raise(CannotResolveError, "No dependency is mapped to key #{name}") \
          if object.nil?

        object[:lifetime] == INSTANCE ? object[:class].new : object[:class]
      end
    end

    private

    attr_reader :store
  end
end
