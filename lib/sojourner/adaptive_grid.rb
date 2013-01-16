#encoding: utf-8
require 'forwardable'
###########################################
#
# Grille adaptative
#
###########################################

class AdaptiveGrid
  include DiskWriter
  extend Forwardable

  def initialize(args={})
    bbox=BoundingBox.new(args.fetch(:bounds))
    @root=Node.new(domain: bbox, evaluator_class: args.fetch(:eval_class))
    @root.subdivide
    @cached_leaves=@root.leaves
    @max_depth=args.fetch(:max_depth) { 10 }
  end

    attr_reader :root, :max_depth

  def leaves
    @cached_leaves
  end

  def vertices
    vx=[]

    leaves.each do |lf|
      vx << lf.corners
    end
    vx.flatten.uniq
  end

  def to_s
    "#{root.height}\n"+root.to_s
  end

  def size
    root.descendants.size
  end

  def refine_with_tolerance tol
    new_leaves=[]
    @cached_leaves.sort{|a,b| a.bbox.volume <=>b.bbox.volume}.reverse.each do |lf|
      if (lf.is_critical? tol ) && (lf.depth< max_depth)
        lf.subdivide
        lf.children.each { |c| new_leaves << c}
      else
        new_leaves << lf
      end
    end
    @cached_leaves=new_leaves
  end

  def refine_until_tolerance tol
    critical_leaves=@cached_leaves.select { |lf| (lf.is_critical? tol)&& (lf.depth< max_depth)}

    until critical_leaves.empty?
      puts "Refinement : #{critical_leaves.size} leaves left."
      refine_with_tolerance tol

      critical_leaves=@cached_leaves.select { |lf| (lf.is_critical? tol)&& (lf.depth< max_depth)}
    end

  end

end
