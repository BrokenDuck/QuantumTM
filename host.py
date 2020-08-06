import qsharp

from GraphColoring import graphColoringMain

vertices = 7
edges = [(0, 1), (0, 2), (0, 3), (0, 4), (1, 2), (1, 3), (1, 4), (3, 5), (2, 6), (5, 6), (4, 6)]

coloring = graphColoringMain.simulate(V = vertices, edges = edges)

print(coloring)
