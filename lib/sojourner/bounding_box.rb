#encoding: utf-8
require 'forwardable'

class Point
  extend Forwardable
  include Enumerable

  def initialize coords
    @coords=coords
  end

  attr_reader :coords
  def_delegators :@coords, :[], :[]=, :each

  def to_s
    coords.to_s
  end

  def == other_point
    coords==other_point.coords
  end

  def dist other_point
    square=coords.zip(other_point.coords).map{|a,b| (a-b)**2}.inject(&:+)
    Math::sqrt(square)
  end

end
###########################################
#
#  Bounding box
#
###########################################
class BoundingBox
  extend Forwardable

  def initialize(rect)
    @bounds=rect
  end

  attr_reader :bounds
  def_delegators :@bounds, :to_s, :size


  # Origine de la boite
  # @return [Point] Coordonnées du coin inférieur de la boite
  def origin
    Point.new(bounds.map{ |coord| coord[0]})
  end

  # Centre de la boite
  # @return [Array<Float>] Coordonnées du centre de la boite
  def center
    Point.new(bounds.map{ |coord| (coord[0]+coord[1])/2.0})
  end

  # Longueurs de la boite
  # @return [Array<Float>] Longueurs des arêtes
  def lengths
    bounds.map{ |coord| (coord[1]-coord[0]).abs}
  end

  # Volume de la boite
  # @return [Float] Volume de la boite
  def volume
    lengths.inject(&:*)
  end

  # Coins
  # @param [FixNum] num Numéro du coin que l'on veut
  # @return [Point] Le coin demandé
  def corner(num)
    shifts=[]
    cnum=num
    (0..size-1).each do |dim|
      shifts << cnum.modulo(2)
      cnum=cnum/2
     end
    lshifts=self.lengths.zip(shifts).map {|a,b| a*b}
    Point.new(origin.zip(lshifts).map{|a,b| a+b})
   end

  # Nombre de coins de la boite
  # @return [FixNum]
  def num_corners
    2**size
  end

  # Renvoie les coins
  # @return [Array<Point>] Coordonnées des coins
  def corners
    cc=[]

    (0..num_corners-1).each do |i|
      cc << corner(i)
    end
    cc
  end

  # Renvoie les faces (2D ou 3D seulement)
  # @param [Array<Array<FixNum>>] Tableau des indices de coins composant les faces
  def faces
    return [[0,1,3,2]] if size==2
    return [[0,1,3,2], [0,1,5,4], [0,2,6,4], [4,5,7,6],[2,3,7,6],[1,3,7,5]] if size==3
    fail "Numérotation des faces non implémentée en dim > 3"
  end

  #
  ## Teste si un point est dans la boite
  # @param [Point] coords Point à tester
  # @return [Boolean] Est-ce que la boite contient le point?
  def contains? coords
    bounds.zip(coords) { |b,c|
      return false if c < b[0] or c > b[1]
    }
    true
  end

   #
   ## Teste si deux boites s'intersectent
   # @param [BoundingBox] bbox Boite avec laquelle on veut tester
   # @return [Boolean] Est-ce que les boites ont au moins un point en commun
   def intersects? bbox
     # Cas où la boite courante est plus petite que bbox
     inc_corners=0
     corners.each do |c|
       inc_corners+=1 if bbox.contains? c
       return true if inc_corners >= 1
     end

     # Cas où la boite courante est plus grande
     inc_corners=0
     bbox.corners.each do |c|
       inc_corners+=1 if self.contains? c
       return true if inc_corners >= 1
     end

     false
   end

   #
   # # Division en sous-domaine (indépendant de la dimension)
   #
   def divide(num)
     # On construit la coordonnée du centre du premier sous-domaine
     side_lengths=lengths.map{ |d| 0.25*d}
     seed_coords=origin.zip(side_lengths).map{|x,l| x+l}

     # On se déplace pour obtenir le centre du domaine recherché
     shifts=[]
     cnum=num
     (0..size-1).each do |dim|
       shifts << cnum.modulo(2)
       cnum=cnum/2
     end
     lshifts=lengths.zip(shifts).map {|a,b| 0.5*a*b}
     new_center=Point.new(seed_coords.zip(lshifts).map{ |a,b| a+b})
     new_bounds=[]
     pos=0
     new_center.each { |cc|
       new_bounds << [cc-0.25*lengths[pos], cc+0.25*lengths[pos]]
       pos+=1
     }
     BoundingBox.new(new_bounds)
   end

  def dist other_box
    center.dist(other_box.center)
  end
end
