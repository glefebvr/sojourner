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
end
