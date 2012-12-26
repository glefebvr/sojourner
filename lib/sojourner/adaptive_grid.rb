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
  end

  def leaves
    @cached_leaves
  end

  def to_s
    "#{root.height}\n"+root.to_s
  end

  def size
    root.descendants.size
  end

  def refine_with_tolerance tol
    new_leaves=[]
    @cached_leaves.shuffle.each do |lf|
      if lf.is_critical? tol
        lf.subdivide
        lf.children.each { |c| new_leaves << c}
      else
        new_leaves << lf
      end
    end
    @cached_leaves=new_leaves
  end

  def refine_until_tolerance tol
    critical_leaves=@cached_leaves.select { |lf| lf.is_critical? tol}

    until critical_leaves.empty?
      refine_with_tolerance tol

      critical_leaves=@cached_leaves.select { |lf| lf.is_critical? tol}
    end

  end

  attr_reader :root
end
