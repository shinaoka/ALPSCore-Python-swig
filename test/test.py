import numpy as np

import alps.gf
import alps.gf_extension


#Create an gf object (with positive-only Matsubara mesh, index mesh, index mesh)
#Assignment of a value to gf is not supported yet
mp_mesh = alps.gf.matsubara_positive_mesh(10.0, 1000)
idx_mesh = alps.gf.index_mesh(6)
g = alps.gf.ALPSGF3ComplexMatsubaraPIndexIndex(mp_mesh, idx_mesh, idx_mesh)

#Load a gf from data.h5
g1 = alps.gf.load_gf('data.h5', 'gf')
print g1.to_array()
alps.gf.save_gf(g1, 'tmp.h5', 'gf')

#Contruct an IR basis and compute a transformation matrix to Matsubara freq.
a = alps.gf_extension.fermionic_ir_basis(100.0, 40, 1e-10)
print("dim ", a.dim())
print(a(0).compute_value(0.1))

#Tnl = np.zeros((4,4), dtype=complex)
niw = 1000
Tnl = a.compute_Tnl(np.arange(niw))

#print np.sum(np.abs(Tnl))
dim = a.dim()

#print Tnl.shape
#for i in xrange(niw):
  #print i, Tnl[i,0].real, Tnl[i,0].imag

Tbar_ol = alps.gf_extension.interpolate_Tbar_ol(a)

log_points = np.linspace(0, np.log(1E+10), 1000)
ovec = [int(np.exp(l)) for l in log_points]

for o in ovec:
  z = Tbar_ol(o, dim-1)
  print o, z.real, z.imag
