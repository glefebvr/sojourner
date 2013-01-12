#encoding: utf-8

module DiskWriter
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

    def save_as_1D fname
      File.open("#{fname}.txt",File::CREAT | File::TRUNC | File::WRONLY) do |pfi|
        leaves.each do |nn|
          pfi.puts "#{nn.center[0]}\t#{nn.value}"
        end
      end
    end

    def save_as_unstructured_grid(fname)

      return save_as_1D(fname) if root.bbox.size==1

      File.open("#{fname}.vtk",File::CREAT | File::TRUNC | File::WRONLY) do |pfi|
        name=File.basename(fname)

        # On considère les feuilles
        nodes=leaves

        # Création de l'entête
        pfi.puts "# vtk DataFile Version 3.0\n#{name}\nASCII\nDATASET UNSTRUCTURED_GRID"
        pfi.puts "POINTS #{vertices.size} float"

        # Coordonnées des nœuds
        vertices.each do |vv|
          if root.bbox.size == 2
            pfi.puts "#{vv[0]} #{vv[1]} 0"
          else
            pfi.puts "#{vv[0]} #{vv[1]} #{vv[2]}"
          end
        end

        # Cellules
        size_data=(root.bbox.size ==2) ? nodes.size*5 : nodes.size*9
        vert_per_cell=root.bbox.num_corners
        pfi.puts "CELLS #{nodes.size} #{size_data}"
        nodes.each do |nn|
          str =  (root.bbox.size==2 ? 4 : 8).to_s
          nn.corners.each do |corner|
                str << " #{vertices.index(corner)}"
          end
          pfi.puts str
        end

        # Cell types
        pfi.puts "CELL_TYPES #{nodes.size}"
        nodes.size.times do
          pfi.puts ((root.bbox.size ==2) ? 8 : 11)
        end

        # Valeur sur les faces
        pfi.puts "CELL_DATA #{nodes.size}\nSCALARS #{name} float\nLOOKUP_TABLE default"
        nodes.each do  |nn|
          pfi.puts nn.value
        end
      end
    end
end
