

module TreeMethods
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

  #
  # Jumeaux du nœud (fils du père à la même hauteur)
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

  def root
    return self unless parent
    parent.root
  end

end

