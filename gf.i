/* gf.i */
%module gf
%{
#define SWIG_FILE_WITH_INIT
#include <alps/gf/gf.hpp>
#include "gf_aux.hpp"
%}

%include "std_string.i"
%include "numpy.i"

/* This ignore directive must come before including header files */
%ignore alps::gf::operator<<;
%ignore alps::gf::one_index_gf::load;
%ignore alps::gf::two_index_gf::load;
%ignore alps::gf::three_index_gf::load;
%ignore alps::gf::four_index_gf::load;
%ignore alps::gf::five_index_gf::load;

%ignore alps::gf::three_index_gf::data;

%pythoncode %{ 
import alps.hdf5

mesh_types = []
mesh_types.append(('alps::gf::legendre_mesh', 'LegendreMesh'))

def get_python_mesh_type(h5, path):
    kind = h5[path+'/kind']
    if kind == 'MATSUBARA':
        positive_only = h5[path+'/positive_only']
        if positive_only == 0:
            return 'MatsubaraPN'
        elif positive_only == 1:
            return 'MatsubaraP'
        else:
            raise RuntimeError("This mesh type is not supported by python wrapper: "+kind)
    elif kind == 'IMAGINARY_TIME':
        return 'ImaginaryTime'
    elif kind == 'LEGENDRE':
        return 'Legendre'
    elif kind == 'INDEX':
        return 'Index'
    elif kind == 'NUMERICAL':
        return 'Numerical'
    else:
        raise RuntimeError("Unsupported mesh type in python wrapper: "+kind)

def get_python_gf_type(h5, path):
    N = h5[path+'/mesh/N']

    type_name = 'ALPSGF'+str(N)
    if h5[path+'/data@__complex__']:
        type_name += 'Complex'
    else:
        type_name += 'Real'

    for im in range(N):
        type_name += get_python_mesh_type(h5, path+'/mesh/'+str(im+1))
    return type_name

#Very ad hoc implementation
def load_gf(file_name, path):
    f = alps.hdf5.archive(file_name, 'r')
    python_name = get_python_gf_type(f, path)
    gf = (globals()[python_name])()
    loader = globals()['load_'+python_name]
    loader(gf, file_name, path)
    return gf

def save_gf(gf, file_name, path):
    f = alps.hdf5.archive(file_name, 'w')
    saver = globals()['save_'+ gf.__class__.__name__]
    saver(gf, file_name, path)
%}

%include <alps/gf/gf.hpp>
%include <alps/gf/mesh.hpp>
%include <alps/gf/piecewise_polynomial.hpp>
%include "gf_aux.hpp"

namespace alps {
namespace gf {
%extend three_index_gf {
    void _get_data_buffer(VTYPE ** ARGOUT_CARRAY3, int *DIM1, int *DIM2, int *DIM3) {
        const VTYPE* origin = $self->data().origin();
        int N = $self->data().num_elements();

        //make a copy
        VTYPE* p_copy_data = new VTYPE[N];
        std::copy(origin, origin+N, p_copy_data);

        *ARGOUT_CARRAY3 = p_copy_data;
        *DIM1 = $self->data().shape()[0];
        *DIM2 = $self->data().shape()[1];
        *DIM3 = $self->data().shape()[2];
    }
}

}
}

namespace alps {
namespace gf {

%extend three_index_gf {
    %pythoncode %{ 
        def data():
            return self._get_data_buffer()
    %}
}

}
}

/*
%template(legendre_gf) alps::gf::one_index_gf< std::complex<double>, alps::gf::legendre_mesh >;
%template(omega_gf) alps::gf::one_index_gf<std::complex<double>, alps::gf::matsubara_mesh<alps::gf::mesh::POSITIVE_ONLY> >;
*/

%template(ALPSComplexGF3MatsubaraPIndexIndex) alps::gf::three_index_gf<std::complex<double>, alps::gf::matsubara_mesh<mesh::POSITIVE_ONLY>, alps::gf::index_mesh, alps::gf::index_mesh>;
%template(load_ALPSComplexGF3MatsubaraPIndexIndex) load_gf_cxx<std::complex<double>, alps::gf::matsubara_mesh<mesh::POSITIVE_ONLY>, alps::gf::index_mesh, alps::gf::index_mesh>;
%template(save_ALPSComplexGF3MatsubaraPIndexIndex) save_gf_cxx<std::complex<double>, alps::gf::matsubara_mesh<mesh::POSITIVE_ONLY>, alps::gf::index_mesh, alps::gf::index_mesh>;

%template(real_numerical_mesh) alps::gf::numerical_mesh<double>;
%template(real_piecewise_polynomial) alps::gf::piecewise_polynomial<double>;
%template(matsubara_positive_mesh) alps::gf::matsubara_mesh<alps::gf::mesh::POSITIVE_ONLY>;
