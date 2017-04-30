/* gf_extension.i */
%module(package="alps") gf_extension
%{
#define SWIG_FILE_WITH_INIT
#include <alps/gf_extension/ir_basis.hpp>
%}

%include "std_string.i"
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

%ignore alps::gf_extension::fermionic_kernel::clone;
%ignore alps::gf_extension::bosonic_kernel::clone;
%ignore dgesvd_;
%ignore dgesdd_;

%include <alps/gf_extension/ir_basis.hpp>

%include <alps/gf_extension/detail/ir_basis.ipp>
