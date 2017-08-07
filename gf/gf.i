/* gf.i */
%module(package="alps") gf
%{
#define SWIG_FILE_WITH_INIT
#include <alps/gf/gf.hpp>
#include "gf_aux.hpp"
%}

%include "std_string.i"
%include "../common/swig/numpy.i"

%init %{
   import_array();
%}

/* These ignore directives must come before including header files */
%ignore alps::gf::operator<<;

%ignore alps::gf::one_index_gf::load;
%ignore alps::gf::two_index_gf::load;
%ignore alps::gf::three_index_gf::load;
%ignore alps::gf::four_index_gf::load;
%ignore alps::gf::five_index_gf::load;
%ignore alps::gf::seven_index_gf::load;

%ignore alps::gf::three_index_gf::data;
%ignore alps::gf::seven_index_gf::data;

%ignore alps::gf::three_index_gf::operator();

%pythoncode %{ 
import h5py

mesh_types = []
mesh_types.append(('alps::gf::legendre_mesh', 'LegendreMesh'))

def get_python_mesh_type(h5, path):
    kind = h5[path+'/kind'].value
    if kind == 'MATSUBARA':
        positive_only = h5[path+'/positive_only'].value
        if positive_only == 0:
            str = 'MatsubaraPN'
        elif positive_only == 1:
            str = 'MatsubaraP'
        else:
            raise RuntimeError("This mesh type is not supported by python wrapper: "+kind)
    elif kind == 'IMAGINARY_TIME':
        str = 'ImaginaryTime'
    elif kind == 'LEGENDRE':
        str = 'Legendre'
    elif kind == 'INDEX':
        str = 'Index'
    elif kind == 'NUMERICAL_MESH':
        str = 'Numerical'
    else:
        raise RuntimeError("Unsupported mesh type in python wrapper: "+kind)

    return str

def get_python_gf_type(h5, path):
    N = h5[path+'/mesh/N'].value

    type_name = 'ALPSGF'+str(N)
    if '__complex__' in h5[path+'/data'].attrs and h5[path+'/data'].attrs['__complex__'] == 1:
        type_name += 'Complex'
    else:
        type_name += 'Real'

    for im in range(N):
        type_name += get_python_mesh_type(h5, path+'/mesh/'+str(im+1))
    return type_name

#Very ad hoc implementation
def load_gf(file_name, path):
    with h5py.File(file_name, "r") as f:
        python_name = get_python_gf_type(f, path)
    gf = (globals()[python_name])()
    loader = globals()['load_'+python_name]
    loader(gf, file_name, path)
    return gf

def save_gf(gf, file_name, path):
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
    void _get_copy_buffer(VTYPE ** ARGOUTVIEWM_ARRAY3, int *DIM1, int *DIM2, int *DIM3) {
        const VTYPE* origin = $self->data().origin();
        int N = $self->data().num_elements();

        //make a copy
        VTYPE* p_copy_data = new VTYPE[N];
        std::copy(origin, origin+N, p_copy_data);

        *ARGOUTVIEWM_ARRAY3 = p_copy_data;
        *DIM1 = $self->data().shape()[0];
        *DIM2 = $self->data().shape()[1];
        *DIM3 = $self->data().shape()[2];
    }

    VTYPE _get_value(int i1, int i2, int i3) {
        return $self->operator()(MESH1::index_type(i1), MESH2::index_type(i2), MESH3::index_type(i3));
    }
}

%extend seven_index_gf {
    void _get_copy_buffer(VTYPE ** ARGOUTVIEWM_ARRAY1, int *DIM1) {
        const VTYPE* origin = $self->data().origin();
        int N = $self->data().num_elements();

        //make a copy
        VTYPE* p_copy_data = new VTYPE[N];
        std::copy(origin, origin+N, p_copy_data);

        *ARGOUTVIEWM_ARRAY1 = p_copy_data;
        *DIM1 = N;
    }

    VTYPE _get_value(int i1, int i2, int i3, int i4, int i5, int i6, int i7) {
        return $self->operator()(
            MESH1::index_type(i1),
            MESH2::index_type(i2),
            MESH3::index_type(i3),
            MESH4::index_type(i4),
            MESH5::index_type(i5),
            MESH6::index_type(i6),
            MESH7::index_type(i7)
        );
    }
}


}
}

namespace alps {
namespace gf {

%extend three_index_gf {
    %pythoncode %{ 
        def to_array(self):
            return self._get_copy_buffer()

        def __call__(self, i1, i2, i3):
            return self._get_value(i1, i2, i3)
    %}
}

%extend seven_index_gf {
    %pythoncode %{ 
        def to_array(self):
            return self._get_copy_buffer().reshape(self.mesh1().extent(), self.mesh2().extent(), self.mesh3().extent(), self.mesh4().extent(), self.mesh5().extent(), self.mesh6().extent(), self.mesh7().extent())

        def __call__(self, i1, i2, i3, i4, i5, i6, i7):
            return self._get_value(i1, i2, i3, i4, i5, i6, i7)
    %}
}

}
}

/*
%typemap(in) alps::gf::numerical_mesh<double>::index_type
{
  $1 = alps::gf::numerical_mesh<double>::index_type(static_cast<int>(PyInt_AsLong($input)));
}
*/


%template(ALPSGF3ComplexMatsubaraPIndexIndex) alps::gf::three_index_gf<std::complex<double>, alps::gf::matsubara_mesh<mesh::POSITIVE_ONLY>, alps::gf::index_mesh, alps::gf::index_mesh>;
%template(load_ALPSGF3ComplexMatsubaraPIndexIndex) load_gf_cxx<alps::gf::three_index_gf<std::complex<double>, alps::gf::matsubara_mesh<mesh::POSITIVE_ONLY>, alps::gf::index_mesh, alps::gf::index_mesh> >;
%template(save_ALPSGF3ComplexMatsubaraPIndexIndex) save_gf_cxx<alps::gf::three_index_gf<std::complex<double>, alps::gf::matsubara_mesh<mesh::POSITIVE_ONLY>, alps::gf::index_mesh, alps::gf::index_mesh> >;

%template(ALPSGF3ComplexNumericalIndexIndex) alps::gf::three_index_gf<std::complex<double>, alps::gf::numerical_mesh<double>, alps::gf::index_mesh, alps::gf::index_mesh>;
%template(load_ALPSGF3ComplexNumericalIndexIndex) load_gf_cxx<alps::gf::three_index_gf<std::complex<double>, alps::gf::numerical_mesh<double>, alps::gf::index_mesh, alps::gf::index_mesh> >;
%template(save_ALPSGF3ComplexNumericalIndexIndex) save_gf_cxx<alps::gf::three_index_gf<std::complex<double>, alps::gf::numerical_mesh<double>, alps::gf::index_mesh, alps::gf::index_mesh> >;

%template(ALPSGF7ComplexNumericalNumericalNumericalIndexIndexIndexIndex) alps::gf::seven_index_gf<std::complex<double>, alps::gf::numerical_mesh<double>, alps::gf::numerical_mesh<double>, alps::gf::numerical_mesh<double>, alps::gf::index_mesh, alps::gf::index_mesh, alps::gf::index_mesh, alps::gf::index_mesh>;
%template(load_ALPSGF7ComplexNumericalNumericalNumericalIndexIndexIndexIndex) load_gf_cxx<alps::gf::seven_index_gf<std::complex<double>, alps::gf::numerical_mesh<double>, alps::gf::numerical_mesh<double>, alps::gf::numerical_mesh<double>, alps::gf::index_mesh, alps::gf::index_mesh, alps::gf::index_mesh, alps::gf::index_mesh> >;
%template(save_ALPSGF7ComplexNumericalNumericalNumericalIndexIndexIndexIndex) save_gf_cxx<alps::gf::seven_index_gf<std::complex<double>, alps::gf::numerical_mesh<double>, alps::gf::numerical_mesh<double>, alps::gf::numerical_mesh<double>, alps::gf::index_mesh, alps::gf::index_mesh, alps::gf::index_mesh, alps::gf::index_mesh> >;

%template(real_numerical_mesh) alps::gf::numerical_mesh<double>;
%template(real_piecewise_polynomial) alps::gf::piecewise_polynomial<double>;
%template(matsubara_positive_mesh) alps::gf::matsubara_mesh<alps::gf::mesh::POSITIVE_ONLY>;
