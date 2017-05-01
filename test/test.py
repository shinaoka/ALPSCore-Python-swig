import alps.hdf5
import alps.gf
import alps.gf_extension
a = alps.gf_extension.fermionic_ir_basis(1000.0, 10)
print(a.dim())
print(a(0))
