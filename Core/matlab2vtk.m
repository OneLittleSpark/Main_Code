function matlab2vtk (filename,title, msh, elementType, scalar_point, vector_point, scalar_cell,dim,my_perm)

  output_unit = fopen(filename,'w+');
  
  flag = 0;
    
  switch lower(elementType)
      
      case 'line'
          
          element_order = 2;
          cell_type = 3;
          
      case 'line3'
          
          element_order = 3;
          cell_type = 21;
          
      case 'tri'
          
          element_order = 3;
          cell_type = 5;
          
      case 'tri6'
          
          element_order = 6;
          cell_type = 22;
          
      case 'quad'
          
          element_order = 4;
          cell_type = 9;
          
      case 'quad8'
          
          element_order = 8;
          cell_type = 23;
          
      case 'tet'
          
          element_order = 4; % Linear
          cell_type = 10;
          
      case 'tet10'
          
          element_order = 10;
          cell_type = 24;
          
      case 'wedg'
          
          element_order = 6;
          cell_type = 13;
          
      case 'pyr'
          
          element_order = 5;
          cell_type = 14;
                
      case 'hex'
          
          element_order = 8;
          cell_type = 12;
          
      case 'hex20'
          
          element_order = 20;
          cell_type = 25;
          
      case 'hex27'
          
          element_order = 27;
          cell_type = 29;
          flag = 1;
          
          
          
  end
  
  if (flag == 1 )
    perm = my_perm;
  else
    perm = 1 : element_order;
  end
  
%   [~,perm_inv] = sort(perm);
  
  
   
  fprintf ( output_unit, '# vtk DataFile Version 2.0\n' );
  fprintf ( output_unit, '%s\n', title );
  fprintf ( output_unit, 'ASCII\n' );
  fprintf ( output_unit, '\n' );
  fprintf ( output_unit, 'DATASET UNSTRUCTURED_GRID\n' );
  fprintf ( output_unit, 'POINTS %d double\n', msh.nnode );
  
  
  if (dim == 2)
      
      msh.coords(:,3) = zeros(msh.nnode,1);
      
  end

  for i = 1 : msh.nnode   
    fprintf ( output_unit, '  %f  %f  %f\n', msh.coords(i,:) );
  end

  fprintf ( output_unit, '\n' );
  fprintf ( output_unit, 'CELLS  %d  %d\n', msh.nelem, (element_order+1)*msh.nelem );
  for ie = 1 : msh.nelem
    fprintf ( output_unit, '  %d', element_order );
    for j = 1 : element_order
      fprintf ( output_unit, '  %d', msh.connectivity(ie,perm(j)) - 1 ); % '-1' due to 0 node numbering
    end
    fprintf ( output_unit, '\n' );
  end

  fprintf ( output_unit, '\n' );
  fprintf ( output_unit, 'CELL_TYPES %d\n', msh.nelem );

  
    for i = 1 : msh.nelem
      fprintf ( output_unit, '%d\n', cell_type);
    end
  
    
  if (isempty(scalar_point)==0) || (isempty(vector_point)==0)
      % POINT_DATA
      fprintf ( output_unit, '\n' );
      fprintf ( output_unit, 'POINT_DATA %d\n', msh.nnode );

      if isempty(scalar_point)==0
          % SCALAR
          fprintf ( output_unit, 'SCALARS %s double\n', scalar_point.name );
          fprintf ( output_unit, 'LOOKUP_TABLE default\n' );
          for i = 1 : msh.nnode
            fprintf ( output_unit, '  %f\n', scalar_point.data(i) );
          end
      end

      if isempty(vector_point)==0
          % VECTOR
          fprintf ( output_unit, 'VECTORS %s double\n', vector_point.name);
          % fprintf ( output_unit, 'LOOKUP_TABLE default\n' );
          for i = 1 : msh.nnode
              fprintf ( output_unit, '  %f  %f  %f\n',  vector_point.data(i,:));
          end
      end
  end

  % CELL_DATA
  if isempty(scalar_cell) == 0
      fprintf ( output_unit, '\n');
      fprintf ( output_unit, 'CELL_DATA %d\n', msh.nelem );
      fprintf ( output_unit, 'SCALARS %s float\n', scalar_cell.name);
      fprintf ( output_unit, 'LOOKUP_TABLE default\n');
      for i = 1 : msh.nelem
          fprintf ( output_unit, ' %d\n', scalar_cell.data(i) );
      end
  end
  
  
  return
end
