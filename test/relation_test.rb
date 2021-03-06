require 'test_helper'

module Spike
  class RelationTest < MiniTest::Test

    def test_all
      stub_request(:get, 'http://sushi.com/recipes').to_return_json(data: [{ id: 1, title: 'Sushi' }, { id: 2, title: 'Nigiri' }], metadata: 'meta')

      recipes = Recipe.all

      assert_equal %w{ Sushi Nigiri }, recipes.map(&:title)
      assert_equal [1, 2], recipes.map(&:id)
      assert_equal 'meta', recipes.metadata
    end

    def test_chainable_where
      endpoint = stub_request(:get, 'http://sushi.com/recipes?status=published&per_page=3')

      Recipe.where(status: 'published').where(per_page: 3).to_a

      assert_requested endpoint
    end

    def test_chainable_class_method
      endpoint = stub_request(:get, 'http://sushi.com/recipes?status=published&per_page=3')

      Recipe.where(per_page: 3).published.to_a

      assert_requested endpoint
    end

    def test_prepended_chainable_class_method
      endpoint = stub_request(:get, 'http://sushi.com/recipes?status=published&per_page=3')

      Recipe.published.where(per_page: 3).to_a

      assert_requested endpoint
    end

    def test_scope_class_method
      endpoint = stub_request(:get, 'http://sushi.com/recipes?status=published&page=3')

      Recipe.published.page(3).to_a
      assert_requested endpoint
    end

    def test_scope_doesnt_get_stuck
      endpoint_1 = stub_request(:get, 'http://sushi.com/recipes?per_page=3&status=published')
      endpoint_2 = stub_request(:get, 'http://sushi.com/recipes?status=published')

      Recipe.where(status: 'published').where(per_page: 3).to_a
      Recipe.where(status: 'published').to_a
      assert_requested endpoint_1
      assert_requested endpoint_2
    end

    def test_create_scoped
      endpoint = stub_request(:post, 'http://sushi.com/recipes').with(body: { recipe: { title: 'Sushi', status: 'published' } })

      Recipe.published.create(title: 'Sushi')

      assert_requested endpoint
    end

    def test_cached_result
      endpoint_1 = stub_request(:get, 'http://sushi.com/recipes?status=published&per_page=3')
      endpoint_2 = stub_request(:get, 'http://sushi.com/recipes?status=published')

      recipes = Recipe.published.where(per_page: 3)
      recipes.any?
      recipes.to_a
      assert_requested endpoint_1, times: 1
      Recipe.published.to_a
      assert_requested endpoint_2, times: 1
    end
  end
end
