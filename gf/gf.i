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

/*
%include "../common/swig/multi_array.i"
%multi_array_typemaps(std::vector<double>);
%multi_array_typemaps(std::vector<std::complex<double> >); 

%multi_array_typemaps(Eigen::Matrix<double,Eigen::Dynamic,Eigen::Dynamic>);
%multi_array_typemaps(Eigen::Matrix<std::complex<double>,Eigen::Dynamic,Eigen::Dynamic>);

%multi_array_typemaps(boost::multi_array<double,2>); 
%multi_array_typemaps(boost::multi_array<double,3>); 
%multi_array_typemaps(boost::multi_array<double,4>); 
%multi_array_typemaps(boost::multi_array<double,5>); 
%multi_array_typemaps(boost::multi_array<double,6>); 
%multi_array_typemaps(boost::multi_array<double,7>); 

%multi_array_typemaps(boost::multi_array<std::complex<double>,2>); 
%multi_array_typemaps(boost::multi_array<std::complex<double>,3>); 
%multi_array_typemaps(boost::multi_array<std::complex<double>,4>); 
%multi_array_typemaps(boost::multi_array<std::complex<double>,5>); 
%multi_array_typemaps(boost::multi_array<std::complex<double>,6>); 
%multi_array_typemaps(boost::multi_array<std::complex<double>,7>); 

%multi_array_typemaps(Eigen::Tensor<double,2>);
%multi_array_typemaps(Eigen::Tensor<double,3>);
%multi_array_typemaps(Eigen::Tensor<double,4>);
%multi_array_typemaps(Eigen::Tensor<double,5>);
%multi_array_typemaps(Eigen::Tensor<double,6>);
%multi_array_typemaps(Eigen::Tensor<double,7>);

%multi_array_typemaps(Eigen::Tensor<std::complex<double>,2>);
%multi_array_typemaps(Eigen::Tensor<std::complex<double>,3>);
%multi_array_typemaps(Eigen::Tensor<std::complex<double>,4>);
%multi_array_typemaps(Eigen::Tensor<std::complex<double>,5>);
%multi_array_typemaps(Eigen::Tensor<std::complex<double>,6>);
%multi_array_typemaps(Eigen::Tensor<std::complex<double>,7>);
*/


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
import alps.hdf5

mesh_types = []
mesh_types.append(('alps::gf::legendre_mesh', 'LegendreMesh'))

def get_python_mesh_type(h5, path):
    kind = h5[path+'/kind']
    if kind == 'MATSUBARA':
        positive_only = h5[path+'/positive_only']
        if positive_only == 0:
            str = 'MatsubaraPN'
        elif positive_only == 1:
            str = 'MatsubaraP'
        else:
            raise RuntimeError("This mesh type is not supported by python wrapper: "+kind)
        #str += "F" if h5[path+'/statistics'] == 1 else "B"
    elif kind == 'IMAGINARY_TIME':
        str = 'ImaginaryTime'
        #str += "F" if h5[path+'/statistics'] == 1 else "B"
    elif kind == 'LEGENDRE':
        str = 'Legendre'
        #str += "F" if h5[path+'/statistics'] == 1 else "B"
    elif kind == 'INDEX':
        str = 'Index'
    elif kind == 'NUMERICAL_MESH':
        str = 'Numerical'
        #str += "F" if h5[path+'/statistics'] == 1 else "B"
    else:
        raise RuntimeError("Unsupported mesh type in python wrapper: "+kind)

    return str

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

}
}

%template(ALPSGF3ComplexMatsubaraPIndexIndex) alps::gf::three_index_gf<std::complex<double>, alps::gf::matsubara_mesh<mesh::POSITIVE_ONLY>, alps::gf::index_mesh, alps::gf::index_mesh>;
%template(load_ALPSGF3ComplexMatsubaraPIndexIndex) load_gf_cxx<alps::gf::three_index_gf<std::complex<double>, alps::gf::matsubara_mesh<mesh::POSITIVE_ONLY>, alps::gf::index_mesh, alps::gf::index_mesh> >;
%template(save_ALPSGF3ComplexMatsubaraPIndexIndex) save_gf_cxx<alps::gf::three_index_gf<std::complex<double>, alps::gf::matsubara_mesh<mesh::POSITIVE_ONLY>, alps::gf::index_mesh, alps::gf::index_mesh> >;

%template(ALPSGF7ComplexNumericalNumericalNumericalIndexIndexIndexIndex) alps::gf::seven_index_gf<std::complex<double>, alps::gf::numerical_mesh<double>, alps::gf::numerical_mesh<double>, alps::gf::numerical_mesh<double>, alps::gf::index_mesh, alps::gf::index_mesh, alps::gf::index_mesh, alps::gf::index_mesh>;
%template(load_ALPSGF7ComplexNumericalNumericalNumericalIndexIndexIndexIndex) load_gf_cxx<alps::gf::seven_index_gf<std::complex<double>, alps::gf::numerical_mesh<double>, alps::gf::numerical_mesh<double>, alps::gf::numerical_mesh<double>, alps::gf::index_mesh, alps::gf::index_mesh, alps::gf::index_mesh, alps::gf::index_mesh> >;
%template(save_ALPSGF7ComplexNumericalNumericalNumericalIndexIndexIndexIndex) save_gf_cxx<alps::gf::seven_index_gf<std::complex<double>, alps::gf::numerical_mesh<double>, alps::gf::numerical_mesh<double>, alps::gf::numerical_mesh<double>, alps::gf::index_mesh, alps::gf::index_mesh, alps::gf::index_mesh, alps::gf::index_mesh> >;

%template(real_numerical_mesh) alps::gf::numerical_mesh<double>;
%template(real_piecewise_polynomial) alps::gf::piecewise_polynomial<double>;
%template(matsubara_positive_mesh) alps::gf::matsubara_mesh<alps::gf::mesh::POSITIVE_ONLY>;
