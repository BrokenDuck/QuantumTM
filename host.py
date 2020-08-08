import qsharp
import networkx as nx
import matplotlib.pyplot as plt
from GraphColoring import graphColoringMain

def draw_graph(vertices, edges, coloring):
    G = nx.Graph()
    G.add_nodes_from(list(range(vertices)))
    G.add_edges_from(edges)
    pos = nx.spring_layout(G)
    options = {"node_size": 500, "alpha": 0.8}
    nx.draw_networkx_nodes(G, pos, nodelist=[i for i, x in enumerate(coloring) if x == 0], node_color="r", **options)
    nx.draw_networkx_nodes(G, pos, nodelist=[i for i, x in enumerate(coloring) if x == 1], node_color="b", **options)
    nx.draw_networkx_nodes(G, pos, nodelist=[i for i, x in enumerate(coloring) if x == 2], node_color="y", **options)
    nx.draw_networkx_nodes(G, pos, nodelist=[i for i, x in enumerate(coloring) if x == 3], node_color="g", **options)
    nx.draw_networkx_edges(G, pos, edgelist=edges, width=1.0, alpha=0.5)
    plt.axis("off")
    plt.show()

    
vertices = 5
edges = [(0, 1), (0, 2), (0, 3), (0, 4), (1, 2), (1, 3), (1, 4)]

check_array = []
for (a, b) in edges :
    if not a in check_array:
        check_array.append(a)
    if not b in check_array:
        check_array.append(b)
    if a == b:
        raise Exception("Edges is connected to the same vertex")

if len(check_array) != vertices:
    raise Exception("Number of vertices given does not correspond to the number of vertices in edges") 

coloring = graphColoringMain.simulate(V = vertices, edges = edges)

print(coloring)

draw_graph(vertices, edges, coloring)