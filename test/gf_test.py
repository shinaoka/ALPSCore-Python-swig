import numpy as np

import gf
#import alps.gf_extension


#Create an gf object (with positive-only Matsubara mesh, index mesh, index mesh)
#Assignment of a value to gf is not supported yet
mp_mesh = gf.matsubara_positive_mesh(10.0, 1000)
idx_mesh = gf.index_mesh(6)
#g = gf.ALPSGF3ComplexMatsubaraPIndexIndex(mp_mesh, idx_mesh, idx_mesh)

g = gf.gf()

g.load('data.h5', 'gf')
g.save('tmp.h5', 'gf')

g2 = gf.gf()
g2.load('tmp.h5', 'gf')

#print g.mesh(0)
#print g2.mesh(0)
assert g == g2
#print(help(gf.gf))
#print(help(gf))

#Load a gf from data.h5
#g1 = gf.load_gf('data.h5', 'gf')
#print g1.to_array()
#print g1.mesh1()
#print g1.mesh2()

#gf.save_gf(g1, 'tmp.h5', 'gf')

