
require 'bundler/setup'
require 'minitest/autorun'
require 'sojourner'

describe BoundingBox do
  before :each do
    @rect=[[0,1],[1,2],[2,3],[4,5]]
  end

  it 'should compute the origin' do
    bb=BoundingBox.new(@rect)
    origin=bb.origin

    origin.must_equal [0,1,2,4]
  end

  it 'should compute the center' do
    bb=BoundingBox.new(@rect)
    coords_center=bb.center

    coords_center.must_equal [0.5,1.5,2.5,4.5]
  end

  it 'should compute the lengths' do
    bb=BoundingBox.new(@rect)
    lengths=bb.lengths

    lengths.must_equal [1,1,1,1]
  end

  it 'should be able to check if a point is inside' do
    bb=BoundingBox.new(@rect)

    pt_inside=[0.333, 1.1,2.9, 4.1515]
    bb.contains?(pt_inside).must_equal true

    pt_outside=[0.33,1.1, 3.1, 4.1515]
    bb.contains?(pt_outside).must_equal false
  end

  it 'should be able to check whether two boxes intersects' do
    bb=BoundingBox.new(@rect)

    bb_intersect=BoundingBox.new([[0.1,0.2],[1,3],[2,3],[4,5]])

    bb.intersects?(bb_intersect).must_equal true

    bb_dnintersect=BoundingBox.new([[-1,-0.5],[-1,-0.4],[18,36],[1515,1517]])
    bb.intersects?(bb_dnintersect).must_equal false
  end

end


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

  it 'should create the right number of nodes for a 1D linear evaluator' do
    class Linear1D_Evaluator
      def initialize(params)
        @params=params
      end

      def compute
        @params.first
      end

    end
  end
end
