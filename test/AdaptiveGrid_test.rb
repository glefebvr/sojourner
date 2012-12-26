
require 'bundler/setup'
require 'minitest/autorun'
require 'minitest/pride'
require 'sojourner'


describe AdaptiveGrid do

  it 'should have 4 nodes for a constant evaluator' do
    class Constant_Evaluator
      def initialize(params)
        @params=params
      end

      def compute
        1.0
      end
    end

    domain=[[0,1],[0,1]]
    ag=AdaptiveGrid.new(bounds: domain, eval_class: Constant_Evaluator, tol: 1e-15)

    ag.size.must_equal 4

  end

  it 'should create the right number of nodes for a 1D linear evaluator (first direction)' do
    class Linear1D_Evaluator
      def initialize(params)
        @params=params
      end

      def compute
        @params.first
      end
    end

    domain=[[0,1],[0,1]]
    ag=AdaptiveGrid.new(bounds:domain, eval_class: Linear1D_Evaluator, tol: 0.015625)
    ag.refine_until_tolerance 0.015625

    ag.leaves.size.must_equal 4096
  end

  it 'should create the right number of nodes for a 1D linear evaluator (second direction)' do
    class Linear1D_Evaluator
      def initialize(params)
        @params=params
      end

      def compute
        @params[1]
      end
    end

    domain=[[0,1],[0,1]]
    ag=AdaptiveGrid.new(bounds:domain, eval_class: Linear1D_Evaluator, tol: 0.015625)
    ag.refine_until_tolerance 0.015625

    ag.leaves.size.must_equal 4096
  end
end
