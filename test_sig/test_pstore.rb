require_relative "test_helper"

require 'pstore'
require 'tmpdir'

class PStoreSingletonTest < Test::Unit::TestCase
  include TestHelper

  library 'pstore'
  testing "singleton(::PStore)"

  def setup
    @tmpdir = Dir.mktmpdir
    @path = File.join(@tmpdir, 't.store')
  end

  def teardown
    FileUtils.remove_entry(@tmpdir)
  end

  def test_new
    assert_send_type  "(String) -> PStore",
                      PStore, :new, @path
    assert_send_type  "(String, bool) -> PStore",
                      PStore, :new, @path, true
    assert_send_type  "(String, thread_safe: bool) -> PStore",
                      PStore, :new, @path, thread_safe: true
    assert_send_type  "(String, ultra_safe: bool) -> PStore",
                      PStore, :new, @path, ultra_safe: true
    assert_send_type  "(String, follow_symlink: bool) -> PStore",
                      PStore, :new, @path, follow_symlink: false
    assert_send_type  "(String, bool, ultra_safe: bool, follow_symlink: bool) -> PStore",
                      PStore, :new, @path, true, ultra_safe: true, follow_symlink: false
  end
end

class PStoreTest < Test::Unit::TestCase
  include TestHelper

  library 'pstore'
  testing "::PStore[Symbol, Integer]"

  # Yield a pristine store for use in examples.
  def example_store
    Dir.mktmpdir do |dir|
      store = PStore.new(File.join(dir, 't.store'))
      store.transaction do
        store[:foo] = 0
        store[:bar] = 1
        store[:baz] = 2
      end
      yield store
    end
  end

  def test_aref
    example_store do |store|
      store.transaction do
        assert_send_type  "(Symbol) -> Integer",
                          store, :[], :foo
        assert_send_type  "(Symbol) -> nil",
                          store, :[], :nope
      end
    end
  end

  def test_aset
    example_store do |store|
      store.transaction do
        assert_send_type  "(Symbol, Integer) -> Integer",
                          store, :[]=, :bat, 3
      end
    end
  end

  # Exiting the transaction block by throw cannot be tested with
  # assert_send_type, so test the documented error case instead.
  def test_abort
    example_store do |store|
      assert_send_type_error  "() -> void", PStore::Error,
                              store, :abort
    end
  end

  # Exiting the transaction block by throw cannot be tested with
  # assert_send_type, so test the documented error case instead.
  def test_commit
    example_store do |store|
      assert_send_type_error  "() -> void", PStore::Error,
                              store, :commit
    end
  end

  def test_delete
    example_store do |store|
      store.transaction do
        assert_send_type  "(Symbol) -> Integer",
                          store, :delete, :foo
        assert_send_type  "(Symbol) -> nil",
                          store, :delete, :nope
      end
    end
  end

  def test_fetch
    example_store do |store|
      store.transaction do
        assert_send_type  "(Symbol) -> Integer",
                          store, :fetch, :baz
        assert_send_type  "(Symbol, nil) -> nil",
                          store, :fetch, :nope, nil
      end
    end
  end

  def test_key?
    example_store do |store|
      store.transaction do
        assert_send_type  "(Symbol) -> bool",
                          store, :key?, :foo
      end
    end
  end

  def test_root?
    example_store do |store|
      store.transaction do
        assert_send_type  "(Symbol) -> bool",
                          store, :root?, :foo
      end
    end
  end

  def test_keys
    example_store do |store|
      store.transaction do
        assert_send_type  "() -> Array[Symbol]",
                          store, :keys
      end
    end
  end

  def test_roots
    example_store do |store|
      store.transaction do
        assert_send_type  "() -> Array[Symbol]",
                          store, :roots
      end
    end
  end

  def test_path
    example_store do |store|
      assert_send_type  "() -> String",
                        store, :path
    end
  end

  def test_transaction
    example_store do |store|
      assert_send_type  "() { (PStore[Symbol, Integer]) -> Array[Symbol] } -> Array[Symbol]",
                        store, :transaction do |st| st.keys end
      assert_send_type  "(bool) { (PStore[Symbol, Integer]) -> Integer } -> Integer",
                        store, :transaction, true do |st| st.fetch(:foo) end
    end
  end

  def test_ultra_safe
    example_store do |store|
      assert_send_type  "() -> bool",
                        store, :ultra_safe
    end
  end

  def test_ultra_safe=
    example_store do |store|
      assert_send_type  "(bool) -> bool",
                        store, :ultra_safe=, true
    end
  end
end
