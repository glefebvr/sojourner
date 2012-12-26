#encoding: utf-8
require 'forwardable'

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

  def_delegators :@bounds, :to_s, :size


  # Origine de la boite
  # @return [Array<Float>] Coordonnées du coin inférieur de la boite
  def origin
    bounds.map{ |coord| coord[0]}
  end

  # Centre de la boite
  # @return [Array<Float>] Coordonnées du centre de la boite
  def center
    bounds.map{ |coord| (coord[0]+coord[1])/2.0}
  end

  # Longueurs de la boite
  # @return [Array<Float>] Longueurs des arêtes
  def lengths
    bounds.map{ |coord| (coord[1]-coord[0]).abs}
  end


  # Coins
  # @param [FixNum] num Numéro du coin que l'on veut
  # @return
  def corner(num)
    shifts=[]
    cnum=num
    (0..size-1).each do |dim|
      shifts << cnum.modulo(2)
      cnum=cnum/2
     end
    lshifts=self.lengths.zip(shifts).map {|a,b| a*b}
    origin.zip(lshifts).map{|a,b| a+b}
   end

  # Nombre de coins de la boite
  # @return [FixNum]
  def num_corners
    2**size
  end

  # Renvoie les coins
  # @return [Array<Array<Float>>] Coordonnées des coins
  def corners
    cc=[]

    (0..num_corners-1).each do |i|
      cc << corner(i)
    end
    cc
  end

  #
  ## Teste si un point est dans la boite
  # @param [Array<Float>] coords Point à tester
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
     new_center=seed_coords.zip(lshifts).map{ |a,b| a+b}
     new_bounds=[]
     pos=0
     new_center.each { |cc|
       new_bounds << [cc-0.25*lengths[pos], cc+0.25*lengths[pos]]
       pos+=1
     }
     BoundingBox.new(new_bounds)
   end
   attr_reader :bounds
   end
