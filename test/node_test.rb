
require 'bundler/setup'
require 'minitest/autorun'
require 'minitest/pride'
require 'sojourner'


describe Node do
  before :each do
    @domain=BoundingBox.new [[0,1],[0,1],[0,1],[0,1]]
  end

  it 'should have children when dividing' do
    nd=Node.new(domain: @domain, value: 0.0)
    nd.subdivide

    nd.children.size.must_equal 2**4
  end

end
