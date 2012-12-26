#encoding: utf-8
require 'forwardable'
require 'set'



###########################################
#
#  Nœud de l'arbre
#
###########################################
class Node
  extend Forwardable
  include TreeMethods

  def initialize(args={})
    @args=args.dup
    @parent=args[:parent]

    @bbox=args.fetch(:domain)
    @Eval_Class=args[:evaluator_class]
    @value=args.fetch(:value) {@Eval_Class.new(bbox.center).compute}

    fail "Node initialized without data !" unless @Eval_Class or @value

    if parent
      @depth=parent.depth+1
    else
      @depth=0
    end
    @children=Set.new
    @connected=args.fetch(:connected) {Set.new}
  end

  # Délégation
  def_delegators :@bbox, :center, :corner
  # Accesseurs
  attr_reader :parent, :value, :depth, :children, :bbox, :Eval_Class, :connected

  #
  # # Subdivision d'une cellule
  #
  def subdivide
    return if depth > 5

    (0..2**(bbox.size)-1).each do |i|
      small_box=bbox.divide(i)
      args=@args.dup.merge({parent: self, domain: small_box})

      new_born=Node.new(args)

      add_child new_born
    end

    # Mise à jour des nœuds des mailles voisines
    connected.each do |cn|
      cn.update_connected self
    end

    # Remplissage de la liste des voisins pour chaque fils
    self.children.each do |child|
      child.compute_connected( self.children + self.connected)
    end

  end



  def is_critical? tol
    connected.each do |vv|
      next if vv.object_id==self.object_id
      return true if (vv.value-value).abs > tol
    end
    false
  end



  # Est-ce que la maille correspondant au nœud est connectée à l'argument?
  def intersects? other_node
    bbox.intersects? other_node.bbox
  end

  # Met à jour la liste des mailles connectées après une subdivision
  def update_connected other_node
    other_node.children.each do |cnc|
      @connected << cnc if self.intersects? cnc
    end
    @connected.delete(other_node)
  end

  # calcule la liste des voisins connectés à partir des voisins du père et des jumeaux
  def compute_connected liste
    @connected=Set.new
    liste.each do |el|
      @connected << el if self.intersects? el
    end
    @connected.delete(self)
  end


  #
  # # Ajout d'un fils
  #
  private
  def add_child(child)
    @children << child
  end
end
