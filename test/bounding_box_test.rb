
require 'bundler/setup'
require 'minitest/autorun'
require 'minitest/pride'
require 'sojourner'



describe BoundingBox do
  before :each do
    @rect=[[0,1],[1,2],[2,3],[4,5]]
  end

  it 'should compute the origin' do
    bb=BoundingBox.new(@rect)
    origin=bb.origin

    origin.must_equal Point.new([0,1,2,4])
  end

  it 'should compute the center' do
    bb=BoundingBox.new(@rect)
    coords_center=bb.center

    coords_center.must_equal Point.new([0.5,1.5,2.5,4.5])
  end

  it 'should compute the lengths' do
    bb=BoundingBox.new([[0,1],[1,3],[5,8]])
    lengths=bb.lengths

    lengths.must_equal [1,2,3]
  end

  it 'should be able to check if a point is inside' do
    bb=BoundingBox.new(@rect)

    pt_inside=Point.new([0.333, 1.1,2.9, 4.1515])
    bb.contains?(pt_inside).must_equal true

    pt_outside=Point.new([0.33,1.1, 3.1, 4.1515])
    bb.contains?(pt_outside).must_equal false
  end

  it 'should be able to check whether two boxes intersects' do
    bb=BoundingBox.new(@rect)

    bb_intersect=BoundingBox.new([[0.1,0.2],[1,3],[2,3],[4,5]])

    bb.intersects?(bb_intersect).must_equal true
    bb_intersect.intersects?(bb).must_equal true

    bb_dnintersect=BoundingBox.new([[-1,-0.5],[-1,-0.4],[18,36],[1515,1517]])
    bb.intersects?(bb_dnintersect).must_equal false
    bb_dnintersect.intersects?(bb).must_equal false
  end

  it 'should consider a point as an intersection' do
    bb=BoundingBox.new([[0,1],[0,1]])
    bb2=BoundingBox.new([[1,2],[1,2]])
    bb.intersects?(bb2).must_equal true
  end

  # Pour être compatible avec l'ordre VTK (http://www.vtk.org/VTK/img/file-formats.pdf)
  it 'should order correctly the vertices (2D)' do
    bb_2D=BoundingBox.new([[0,1],[0,1]])

    corners=bb_2D.corners

    corners[0].must_equal Point.new([0.0,0.0])
    corners[1].must_equal Point.new([1.0,0.0])
    corners[3].must_equal Point.new([1.0,1.0])
    corners[2].must_equal Point.new([0.0,1.0])
  end

  # Pour être compatible avec l'ordre VTK (http://www.vtk.org/VTK/img/file-formats.pdf)
  it 'should order correctly the vertices (3D)' do

    bb_3D=BoundingBox.new([[0,1],[0,1],[0,1]])
    corners=bb_3D.corners
    corners[0].must_equal Point.new([0.0,0.0,0.0])
    corners[1].must_equal Point.new([1.0,0.0,0.0])
    corners[2].must_equal Point.new([0.0,1.0,0.0])
    corners[3].must_equal Point.new([1.0,1.0,0.0])
    corners[4].must_equal Point.new([0.0,0.0,1.0])
    corners[5].must_equal Point.new([1.0,0.0,1.0])
    corners[6].must_equal Point.new([0.0,1.0,1.0])
    corners[7].must_equal Point.new([1.0,1.0,1.0])

  end
end
