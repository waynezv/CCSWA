function [IDX] = EGS(MST_Edge, sup_num, par_k)

%% Main Algorithm of Efficient Graph-based Segmentation
display('Extract SST Using Efficient Graph-based Segmentation')
vertex_map = zeros(sup_num, 1);%�洢������ͨͼ��������
connection = zeros(sup_num, 1);%1�洢��������������ͨͼ���
Int_Matrix = zeros(sup_num, 1);%������������ͨͼ��Int Value
MST_Edge(:, 4) = 0;
MST_Edge(:, 3) = MST_Edge(:, 3).*100;
edge_num = size(MST_Edge, 1);
edge_ind = ones(edge_num, 1);
map_num = 0;
for edge_index = 1 : edge_num
    conn_class1 = connection(MST_Edge(edge_index, 1), 1);
    conn_class2 = connection(MST_Edge(edge_index, 2), 1);
    if conn_class1 == 0
        do1=1;
    else
        do1=0;
    end
    if conn_class2 == 0
        do2=1;
    else
        do2=0;
    end
    if do1 == 1 && do2 == 1
        if MST_Edge(edge_index, 3) <= par_k
            map_num = map_num + 1;
            connection(MST_Edge(edge_index, 1), 1) = map_num;
            connection(MST_Edge(edge_index, 2), 1) = map_num;
            Int_Matrix(map_num, 1) = MST_Edge(edge_index, 3);
            MST_Edge(edge_index, 4) = 1;%�ñ߼��������˵㹹��һ���µ���ͨͼ; This edge is a false predicate
            edge_ind(edge_index, 1) = 0;
            vertex_map(map_num, 1) = vertex_map(map_num, 1) + 2;
        else
            map_num = map_num + 2;
            connection(MST_Edge(edge_index, 1), 1) = map_num-1;
            connection(MST_Edge(edge_index, 2), 1) = map_num;
            Int_Matrix(map_num-1, 1) = 0;
            Int_Matrix(map_num, 1) = 0;
            MST_Edge(edge_index, 4) = 3;%This edge is a true predicate
            edge_ind(edge_index, 1) = 0;
            vertex_map(map_num-1, 1) = 1;
            vertex_map(map_num, 1) = 1;
        end
    elseif do1 == 0 && do2 == 1
        if MST_Edge(edge_index, 3) <= min(Int_Matrix(conn_class1, 1) + par_k/vertex_map(conn_class1, 1), par_k)
            connection(MST_Edge(edge_index, 2), 1) = conn_class1;
            Int_Matrix(conn_class1, 1) = MST_Edge(edge_index, 3);
            MST_Edge(edge_index, 4) = 1;%�ñ���չ��ĳ����ͨͼ; This edge is a false predicate
            edge_ind(edge_index, 1) = 0;
            vertex_map(conn_class1, 1) = vertex_map(conn_class1, 1) + 1;
        else
            map_num = map_num + 1;
            connection(MST_Edge(edge_index, 2), 1) = map_num;
            Int_Matrix(map_num, 1) = 0;
            MST_Edge(edge_index, 4) = 3;%This edge is a true predicate
            edge_ind(edge_index, 1) = 0;
            vertex_map(map_num, 1) = 1;
        end
    elseif do1 == 1 && do2 == 0
        if MST_Edge(edge_index, 3) <= min(par_k, Int_Matrix(conn_class2, 1) + par_k/vertex_map(conn_class2, 1))
            connection(MST_Edge(edge_index, 1), 1) = conn_class2;
            Int_Matrix(conn_class2, 1) = MST_Edge(edge_index, 3);
            MST_Edge(edge_index, 4) = 1;%�ñ���չ��ĳ����ͨͼ; This edge is a false predicate
            edge_ind(edge_index, 1) = 0;
            vertex_map(conn_class2, 1) = vertex_map(conn_class2, 1) + 1;
        else
            map_num = map_num + 1;
            connection(MST_Edge(edge_index, 1), 1) = map_num;
            Int_Matrix(map_num, 1) = 0;
            MST_Edge(edge_index, 4) = 3;%This edge is a true predicate
            edge_ind(edge_index, 1) = 0;
            vertex_map(map_num, 1) = 1;
        end
    elseif do1 == 0 && do2 == 0
        if connection(MST_Edge(edge_index, 2), 1) == connection(MST_Edge(edge_index, 1), 1)
            MST_Edge(edge_index, 4) = 2;%�ñ߹��ɻ�·
            edge_ind(edge_index, 1) = 0;
        else
            if MST_Edge(edge_index, 3) <= min(Int_Matrix(conn_class1, 1) + par_k/vertex_map(conn_class1, 1), Int_Matrix(conn_class2, 1) + par_k/vertex_map(conn_class2, 1))
                label_min = min(conn_class1, conn_class2);
                label_max = max(conn_class1, conn_class2);
                for i = 1 : sup_num
                    if connection(i, 1) == label_max
                        connection(i, 1) = label_min;
                    end
                end
                Int_Matrix(label_min, 1) = MST_Edge(edge_index, 3);
                Int_Matrix(label_max, 1) = 0;
                MST_Edge(edge_index, 4) = 1;%������ͨͼ�ɸñ����������һ����ͨͼ��labelѡ��ʹ�ý�С���Ǹ�
                edge_ind(edge_index, 1) = 0;
                vertex_map(label_min, 1) = vertex_map(label_min, 1) + vertex_map(label_max, 1);
                vertex_map(label_max, 1) = 0;
            else
                MST_Edge(edge_index, 4) = 3;%This edge is a true predicate
                edge_ind(edge_index, 1) = 0;
            end
        end
    end
end
IDX = zeros(sup_num, 1);
unique_set = unique(connection);
cluster_num = size(unique_set, 1);
for i=1:cluster_num
    idx = connection == unique_set(i);
    IDX(idx) = i;
end