/* gf_extension.i */
%module(package="alps") gf_extension
%{
#define SWIG_FILE_WITH_INIT
#include <alps/gf_extension/ir_basis.hpp>
%}

%include "std_string.i"
%include "std_vector.i"
%include "../common/swig/multi_array.i"

%init %{
   import_array();
%}

%multi_array_typemaps(std::vector<int>);
%multi_array_typemaps(std::vector<long>);
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

%ignore alps::gf_extension::fermionic_kernel::clone;
%ignore alps::gf_extension::bosonic_kernel::clone;
%ignore dgesvd_;
%ignore dgesdd_;

%include <alps/gf_extension/ir_basis.hpp>
%include <alps/gf_extension/detail/ir_basis.ipp>

%inline %{
  template<typename T>
  Eigen::Tensor<std::complex<double>,2>
  compute_Tnl(const alps::gf::numerical_mesh<double>& mesh, const std::vector<long>& n) {
    Eigen::Tensor<std::complex<double>,2> Tnl;
    std::vector<alps::gf::piecewise_polynomial<T> > bf;
    for (int i=0; i < mesh.extent(); ++i) {
      bf.push_back(mesh.basis_function(i));
    }
    alps::gf_extension::compute_transformation_matrix_to_matsubara(n, mesh.statistics(), bf, Tnl);
    return Tnl;
  }
%}

%template(compute_Tnl) compute_Tnl<double>;
