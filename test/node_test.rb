
require 'bundler/setup'
require 'minitest/autorun'
require 'minitest/pride'
require 'sojourner'


describe Node do
  before :each do
    @domain=BoundingBox.new [[0,1],[0,1]]
    @nd=Node.new(domain: @domain, value: 0.0)
  end

  it 'should have children when dividing' do
    @nd.subdivide

    @nd.children.size.must_equal 2**@domain.size
  end

  it 'should have no connected nodes when root' do
    @nd.connected.empty?.must_equal true
  end

  it 'should manage the connected list' do
    @nd.subdivide

    @nd.children.each { |child|
      cset=@nd.children.select {|el| el.object_id != child.object_id}
      child.connected.size.must_equal cset.size
      child.connected.include?(child).must_equal false
    }
  end

end
