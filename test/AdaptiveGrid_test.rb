
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
    ag=AdaptiveGrid.new(bounds:domain, eval_class: Linear1D_Evaluator)
    ag.refine_until_tolerance 0.0625

    #ag.leaves.size.must_equal 256
    ag.leaves.each do |lf|
      lf.value.must_equal lf.center.first
      (lf.mean_value_over_connected-lf.value).abs.must_be :<=, 0.0625
    end
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

    domain=[[0,1],[0,1],[0,1]]
    ag=AdaptiveGrid.new(bounds:domain, eval_class: Linear1D_Evaluator)
    ag.refine_until_tolerance 0.05

    ag.save_as_polydata "grid"
    #ag.leaves.size.must_equal 256
    ag.leaves.each do |lf|
      lf.value.must_equal lf.center[1]
      (lf.mean_value_over_connected-lf.value).abs.must_be :<=, 0.05
    end
  end
end
