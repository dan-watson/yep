require 'bundler'
require 'minitest/autorun'

Bundler.require

require 'yep'

class TestYep < Minitest::Test
  Yep::Container.add(:hash, Hash)
  Yep::Container.add(:string, String)
  Yep::Container.add(:math, Math, Yep::Container::SINGLETON)

  def test_resolve_instance_always_returns_a_new_object
    assert Yep::Container.resolve(:hash).object_id !=
      Yep::Container.resolve(:hash).object_id
  end

  def test_resolve_singleton_always_returns_the_same_object
    assert Yep::Container.resolve(:math).object_id ==
      Yep::Container.resolve(:math).object_id
  end

  def test_resolve_should_raise_error_when_a_dependency_is_not_found
    assert_raises Yep::Container::CannotResolveError do
      Yep::Container.resolve(:foo)
    end
  end

  def test_add_cannot_add_the_same_key_more_than_once
    assert_raises Yep::Container::AlreadyAddedError do
      Yep::Container.add(:hash, Hash)
    end
  end

  class Injected
    extend Yep::Inject

    inject(:math)
    inject(:string)

    module ClassMethods
      def instance
        @instance ||= new
      end
    end

    extend ClassMethods
  end

  Injected.enable_dependency_mocks!

  def test_injector_injects_dependency
    assert Injected.instance.math == Math
  end

  def test_injector_caches_the_injected_dependency
    assert Injected.instance.string.object_id ==
      Injected.instance.string.object_id
  end

  def test_injector_can_be_mocked
    Injected.instance.mock(:math, Hash)

    assert Injected.instance.math == Hash
  end

  def test_injector_can_be_unmocked
    Injected.instance.mock(:math, Hash)

    assert Injected.instance.math == Hash

    Injected.instance.unmock(:math)

    assert Injected.instance.math == Math
  end
end
