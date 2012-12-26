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
  def initialize(args={})
    @parent=args[:parent]
    @Eval_Class=args.fetch(:evaluator_class)
    @bbox=args.fetch(:domain)
    @tolerance=args.fetch(:tol)
    @value=@Eval_Class.new(bbox.center).compute
    if parent
      @depth=parent.depth+1
    else
      @depth=0
    end
    @children=Set.new
  end
  def_delegators :@bbox, :center, :corne
  #
  # # Subdivision d'une cellule
  #
  def subdivide
    return if depth > 5
    (0..2**(bbox.size)-1).each do |i|
      small_box=bbox.divide(i)
      new_born=Node.new(parent: self, domain: small_box, evaluator_class: @Eval_Class, tol: @tolerance)
      add_child new_born
    end
    children.each do |child|
      child.subdivide if child.is_critical? @tolerance
    end
  end
  def is_critical? tol
    voisins.each do |vv|
      next if vv.object_id==self.object_id
      return true if (vv.value-value).abs > tol
    end
    #(0..2**(bbox.size)-1).each do |i|
    #	lvalue = error(bbox.corner(i))
    #	return true if (lvalue-value).abs > 0.5
    #end
    false
  end
  #
  # # Informations sur le nœud dans l'arbre
  #
  def is_root?
    if parent
      false
    else
      true
    end
  end
  def is_leaf?
    if children.size == 0
      true
    else
      false
    end
  end
  # Calcul de la hauteur du nœud (profondeur maxi de ses fils)
  def height
    depths = children.map {|child| child.depth}
    return 1 if depths.size == 0
    return depths.max + 1
  end
  #
  # # Recherche des voisins

  def intersects? other_node
    bbox.intersects? other_node.bbox
  end
  def find_children_intersecting other_node
    return nil unless self.intersects? other_node
    return self if is_leaf
    lst=[]
    children.each do |child|
      if child.object_id != other_node.object_id
        if child.intersects? other_node
          if child.is_leaf?
            lst << child
          else
            lst << child.find_children_intersecting(other_node)
          end
        end
        # #				new_neighbors = child.find_children_intersecting(other_node)
        # #				lst <<  new_neighbors if new_neighbors
      end
    end
    lst.delete(nil)
    lst.flatten
  end
  def root
    return self unless paren
    parent.root
  end
  def voisins
    siblings
    #root.find_children_intersecting self
  end
  #
  # # Gestion de la famille

  #
  # Jumeaux du nœud (fils du père à la même auteur)
  #
  def siblings
    return Array.new unless parent
    sibs = []
    parent.children.each do |child|
      next if child.object_id == self.object_id
      sibs << child
    end
    sibs
  end
  #
  # Tous les nœuds qui descendent du père (y compris descendants du nœud courant) - nœud courant
  #
  def full_family
    if parent
      fam = [parent] + parent.descendants
    else
      fam = descendants
    end
    fam.delete(self)
    fam
  end
  #
  # Tous les nœuds qui descendent du père et pas du nœud courant
  #
  def cousins
    return Array.new unless paren
    cousins= []
    parent.children.each do |child|
      next if child.id == self.id
      cousins << child
      cousins << child.descendant
    end
    cousins.flatten
  end
  #
  # Descendants du nœud
  #
  def descendants
    d = []
    children.each do |child|
      d << child
      d << child.descendants
    end
    d.flatten
  end
  #
  # # Feuilles accessibles à partir du nœud
  #
  def leaves
    outp = []
    children.each do |child|
      if child.is_leaf?
        outp << child
      else
        outp << child.leaves
      end
    end
    outp.flatten
  end
  #
  # # Affichage du nœud et de ses fils
  #
  def to_s
    ident=self.center.to_s + " (#{value})"
    if depth > 0
      outp = " #{(["    "] * (depth - 1)).join("|")}\\- #{ident}\n"
    else
      outp = "#{ident}\n"
    end
    children.each do |child|
      outp += child.to_s
    end
    outp
  end
  #
  # # Résolution maximale
  #
  def max_res
    ll=self.bbox.lengths
    self.leaves.each do |ff|
      ll=ll.zip(ff.bbox.lengths).map {|a,b| [a,b].min}
    end
    ll
  end
  #
  # # Tous les nœuds correspondants à l'arbre
  #
  def vertices
    vx=[]
    num_corners=bbox.num_corners
    if self.is_leaf?
      (0..num_corners).each do |i|
        vx << corner(i)
      end
    else
      (self.leaves).each do |child|
        (0..num_corners).each do |i|
          cc=child.corner(i)
          vx << cc unless vx.include?(cc)
        end
      end
    end
    vx
  end
  # Accesseurs
  attr_reader :parent, :value, :depth, :children, :bbox, :Eval_Clas
  #
  # # Ajout d'un fils
  #
  private
  def add_child(child)
    @children << child
  end
end

###########################################
#
# Grille adaptative
#
###########################################

class AdaptiveGrid
  def initialize(args={})
    bbox=BoundingBox.new(args.fetch(:bounds))
    @root=Node.new(domain: bbox, evaluator_class: args.fetch(:eval_class),tol: args.fetch(:tol))
    @root.subdivide
  end

  def to_s
    "#{root.height}\n"+root.to_s
  end

  def size
    root.descendants.size
  end

  def save_as_points(fname)
    File.open("#{fname}.vtk",File::CREAT | File::TRUNC | File::WRONLY) do |pfi|
      name=File.basename(fname)

      # On considère tous les descendants
      nodes=root.descendants

      # Création de l'entête
      pfi.puts "# vtk DataFile Version 3.0\n#{name}\nASCII\nDATASET UNSTRUCTURED_GRID"
      pfi.puts "POINTS #{nodes.size} float"

      # Coordonnées des nœuds
      nodes.each do |nn|
        if root.bbox.size == 2
          pfi.puts "#{nn.center[0]} #{nn.center[1]} 0"
        else
          pfi.puts "#{nn.center[0]} #{nn.center[1]} #{nn.center[2]}"
        end
      end

      # Valeurs des nœuds
      pfi.puts "POINT_DATA #{nodes.size}\nSCALARS #{name} float\nLOOKUP_TABLE default"
      nodes.each do  |nn|
        pfi.puts nn.value
      end
    end
  end

  def save_as_polydata(fname)
    File.open("#{fname}.vtk",File::CREAT | File::TRUNC | File::WRONLY) do |pfi|
      name=File.basename(fname)

      # On considère tous les descendants
      nodes=root.descendants
      vertices=root.vertices
      puts "Nombre de noeuds de la grille : #{vertices.size}"

      # Création de l'entête
      pfi.puts "# vtk DataFile Version 3.0\n#{name}\nASCII\nDATASET POLYDATA"
      pfi.puts "POINTS #{vertices.size} float"

      # Coordonnées des nœuds
      vertices.each do |vv|
        if root.bbox.size == 2
          pfi.puts "#{vv[0]} #{vv[1]} 0"
        else
          pfi.puts "#{vv[0]} #{vv[1]} #{vv[2]}"
        end
      end

      # Faces
      vert_per_cell=root.bbox.num_corners
      size_data=(vert_per_cell+1)*nodes.size
      pfi.puts "POLYGONS #{nodes.size} #{size_data}"
      nodes.each do |nn|
        str=vert_per_cell.to_s
        if root.bbox.size > 2
          (0..vert_per_cell-1).each do |i|
            str << " #{vertices.index(nn.corner(i))}"
          end
        else
          [0,1,3,2].each do |i|
            str << " #{vertices.index(nn.corner(i))}"
          end
        end
        pfi.puts str
      end

      # Valeur sur les faces
      pfi.puts "CELL_DATA #{nodes.size}\nSCALARS #{name} float\nLOOKUP_TABLE default"
      nodes.each do  |nn|
        pfi.puts nn.value
      end
    end
  end

  attr_reader :root
end
