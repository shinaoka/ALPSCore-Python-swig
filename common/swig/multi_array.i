%{
#define SWIG_FILE_WITH_INIT
#include <vector>
%}

%include "typemaps.i"
%include "numpy.i"
%include "std_vector.i"

%init %{
  import_array();
%}

%fragment("Array_Fragments", "header", fragment="NumPy_Fragments")
%{
  template <typename T> int num_py_type() {return -1;};
  template<> int num_py_type<double>() {return NPY_DOUBLE;};
  template<> int num_py_type<std::complex<double> >() {return NPY_CDOUBLE;};
  template<> int num_py_type<int>() {return NPY_INT;};

  template <typename OBJ>
  struct CXXTypeTraits {
    typedef double scalar;
    static const int dim;
    static int size(const OBJ& obj, int i);
    static bool resize(OBJ& obj, const std::vector<int>& sizes);
    static void set_zero(OBJ& obj); 
    static scalar& element_at(OBJ& obj, const std::vector<int>& indices);
  };

  template <typename S>
  struct CXXTypeTraits<std::vector<S> > {
    typedef S scalar;
    typedef std::vector<S> obj_type;
    static const int dim = 1;
    static int size(const obj_type& obj, int i) {
      assert(i==0);
      return obj.size();
    }
    static bool resize(obj_type& obj, const std::vector<int>& sizes) {
      assert(sizes.size()==dim);
      obj.resize(sizes[0]);
      return true;
    }
    static void set_zero(obj_type& obj) {
      std::fill(obj.begin(), obj.end(), static_cast<S>(0.0));
    } 
    static scalar& element_at(obj_type& obj, const std::vector<int>& indices) {
      assert(indices.size()==1 && indices[0] < obj.size());
      return obj[indices[0]];
    }
  };

  /** Support for Eigen::Matrix */
  namespace Eigen {
    template<typename _Scalar, int _Rows, int _Cols, int _Options, int _MaxRows, int _MaxCols> class Matrix;
    int Dynamic;
  }
  template <typename S, int RowsAtCompileTime, int ColsAtCompileTime, int Options, int MaxRows, int MaxCols>
  struct CXXTypeTraits<Eigen::Matrix<S,RowsAtCompileTime,ColsAtCompileTime,Options,MaxRows,MaxCols> > {
    typedef S scalar;
    typedef Eigen::Matrix<S,RowsAtCompileTime,ColsAtCompileTime,Options,MaxRows,MaxCols> obj_type;
    static const int dim = 2;
    static int size(const obj_type& obj, int i) {
      assert(i<=1);
      if (i==0) {
        return obj.rows();
      } else {
        return obj.cols();
      }
    }
    static bool resize(obj_type& obj, const std::vector<int>& sizes) {
      assert(sizes.size()==dim);
      bool dynamic_row = RowsAtCompileTime == Eigen::Dynamic;
      bool dynamic_col = ColsAtCompileTime == Eigen::Dynamic;
      if (dynamic_row && dynamic_col) {
        //dynamic matrix
        obj.resize(sizes[0], size[1]);
      } else if (!dynamic_row && !dynamic_col) {
        if (RowsAtCompileTime == size[0] && ColsAtCompileTime == size[1]) {
          return true;
        }
        return false;
      } else {
        //FIXME: RESIZABLE?
        return false;
      }
      return true;
    }
    static void set_zero(obj_type& obj) {
      obj.setZero();
    } 
    static scalar& element_at(obj_type& obj, const std::vector<int>& indices) {
      assert(indices.size()==2);
      return obj(indices[0], indices[1]);
    }
  };

  /** Support for Eigen::Tensor */
  namespace Eigen {
    template<typename Scalar_, int NumIndices_, int Options_, typename IndexType_> class Tensor;
    template<class T, std::size_t N> class array;
  }
  template<typename Scalar_, int NumIndices_, int Options_, typename IndexType_> 
  struct CXXTypeTraits<Eigen::Tensor<Scalar_,NumIndices_,Options_,IndexType_> > {
    typedef Scalar_ scalar;
    typedef Eigen::Tensor<Scalar_,NumIndices_,Options_,IndexType_> obj_type;
    static const int dim = NumIndices_;
    static int size(const obj_type& obj, int i) {
      assert(i<NumIndices_);
      return obj.dimension(i);
    }
    static bool resize(obj_type& obj, const std::vector<int>& sizes) {
      assert(sizes.size()==dim);
      Eigen::array<int,dim> sizes_tmp;
      for (int i=0; i<dim; ++i) {
        sizes_tmp[i] = sizes[i];
      }
      obj.resize(sizes_tmp);
      return true;
    }
    static void set_zero(obj_type& obj) {
      obj.setZero();
    } 
    static scalar& element_at(obj_type& obj, const std::vector<int>& indices) {
      assert(indices.size()==dim);
      //FIXME: DO NOT COPY
      Eigen::array<long,dim> indices_tmp;
      for (int i=0; i<dim; ++i) {
        indices_tmp[i] = indices[i];
      }
      return obj(indices_tmp);
    }
  };

  /** Support for boost::multi_array */
  namespace boost {
    template<typename T, std::size_t NumDims, typename Allocator> class multi_array;
    template<typename T, std::size_t N> class array;
  }
  template <typename S, std::size_t NumDims,typename Allocator>
  struct CXXTypeTraits<boost::multi_array<S,NumDims,Allocator> > {
    typedef S scalar;
    typedef boost::multi_array<S,NumDims,Allocator> obj_type;
    static const int dim = NumDims;
    static int size(const obj_type& obj, int i) {
      assert(i<dim);
      return obj.shape()[i];
    }
    static bool resize(obj_type& obj, const std::vector<int>& sizes) {
      assert(sizes.size()==dim);
      boost::array<int,dim> extents;
      for (int i=0; i<dim; ++i) {
        extents[i] = sizes[i];
      }
      obj.resize(extents);
      return true;
    }
    static void set_zero(obj_type& obj) {
      std::fill(obj.origin(), obj.origin()+obj.num_elements(), static_cast<scalar>(0.0));
    } 
    static scalar& element_at(obj_type& obj, const std::vector<int>& indices) {
      assert(indices.size()==dim);
      //FIXME: DO NOT COPY
      boost::array<int,dim> indices_tmp;
      for (int i=0; i<dim; ++i) {
        indices_tmp[i] = indices[i];
      }
      return obj(indices_tmp);
    }
  };

  template<int DIM, typename S, typename T>
  struct copy_data_to_numpy_helper {
    static void invoke(std::vector<int>& data_size, S* out, T* in);
  };

  template<int DIM, typename S, typename T>
  struct copy_data_from_numpy_helper {
    static void invoke(std::vector<int>& data_size, S* in, T* out);
  };

  template <class A>
  bool ConvertFromNumpyToCXX(A* out, PyObject* in)
  {
    typedef CXXTypeTraits<A> traits;
    typedef typename traits::scalar scalar;
    const int dim = traits::dim;

    // Check object type
    if (!is_array(in))
    {
      PyErr_SetString(PyExc_ValueError, "Input is not as a numpy array or matrix.");
      return false;
    }

    // Check data type
    if (array_type(in) != num_py_type<scalar>())
    {
      PyErr_SetString(PyExc_ValueError, "Type mismatch between numpy and C++ objects.");
      return false;
    }

    // Check dimensions
    if (array_numdims(in) != traits::dim)
    {
      PyErr_SetString(PyExc_ValueError, "Dimension mismatch between numpy and C++ objects.");
      return false;
    }

    std::vector<int> data_size(dim);
    bool resize_required = false;
    for (int i=0; i<dim; ++i) {
      data_size[i] = array_size(in,i);
      resize_required = resize_required || (traits::size(*out,i) < data_size[i]);
    }

    if (resize_required) {
      if (!traits::resize(*out, data_size)) {
        PyErr_SetString(PyExc_ValueError, "Failed to resize C++ object.");
        return false;
      }
    }
    
    // Extract data
    int isNewObject = 0;
    PyArrayObject* temp = obj_to_array_contiguous_allow_conversion(in, array_type(in), &isNewObject);
    if (temp == NULL)
    {
      PyErr_SetString(PyExc_ValueError, "Impossible to convert the input into a Python array object.");
      return false;
    }

    traits::set_zero(*out);

    scalar* data = static_cast<scalar*>(PyArray_DATA(temp));

    copy_data_from_numpy_helper<dim,scalar,A>::invoke(data_size, data, out);

    return true;
  };

  // Copy elements in C++ object into an existing numpy object
  template <class A>
  bool CopyFromCXXToNumPyArray(PyObject* out, A* in)
  {
    typedef CXXTypeTraits<A> traits;
    typedef typename traits::scalar scalar;
    const int dim = traits::dim;

    // Check object type
    if (!is_array(out))
    {
      PyErr_SetString(PyExc_ValueError, "The given input is not known as a NumPy array or matrix.");
      return false;
    }

    // Check data type
    if (array_type(out) != num_py_type<scalar>())
    {
      PyErr_SetString(PyExc_ValueError, "Type mismatch between NumPy and C++ objects.");
      return false;
    }

    // Check dimensions
    if (array_numdims(out) != traits::dim)
    {
      PyErr_SetString(PyExc_ValueError, "Dimension mismatch between NumPy and C++ objects.");
      return false;
    }

    // Check sizes
    std::vector<int> data_size(dim);
    bool size_mismatch = false;
    for (int i=0; i<dim; ++i) {
      data_size[i] = array_size(out,i);
      size_mismatch = size_mismatch || (traits::size(*in,i) != data_size[i]);
    }
    if (size_mismatch) {
      PyErr_SetString(PyExc_ValueError, "Dimension mismatch between NumPy and C++ object (return argument).");
      return false;
    }

    // Extract data
    int isNewObject = 0;
    PyArrayObject* temp = obj_to_array_contiguous_allow_conversion(out, array_type(out), &isNewObject);
    //CORRECT?
    if (temp == NULL || isNewObject != 0) {
      PyErr_SetString(PyExc_ValueError, "Impossible to convert the input into a Python array object.");
      return false;
    }

    scalar* data = static_cast<scalar*>(PyArray_DATA(temp));

    copy_data_to_numpy_helper<dim,scalar,A>::invoke(data_size, data, in);

    return true;
  };

  template <class A>
  bool ConvertFromCXXToNumPyArray(PyObject** out, A* in)
  {
    typedef CXXTypeTraits<A> traits;
    typedef typename traits::scalar scalar;
    const int dim = traits::dim;

    std::vector<npy_intp> dims(dim);
    for (int i=0; i<dim; ++i) {
      dims[i] = traits::size(*in,i);
    }

    *out = PyArray_SimpleNew(dim, &dims[0], num_py_type<scalar>());
    if (!out) {
      return false;
    }
    scalar* data = static_cast<scalar*>(PyArray_DATA((PyArrayObject*) *out));


    std::vector<int> data_size(dim);
    for (int i=0; i<dim; ++i) {
      data_size[i] = traits::size(*in,i);
    }

    copy_data_to_numpy_helper<dim,scalar,A>::invoke(data_size, data, in);

    return true;
  };

  template<typename S, typename T> 
  struct copy_data_to_numpy_helper<1,S,T> { 
    static void invoke(std::vector<int>& data_size, S* out, T* in) { 
      typedef CXXTypeTraits<T> traits; 
      const int dim = 1; 

      int lin_idx = 0; 
      std::vector<int> indices(dim);
      for (int i0= 0; i0< data_size[0]; ++i0) { 
        indices[0] = i0;
        out[lin_idx] = traits::element_at(*in, indices);
        ++lin_idx;
      }

    } 
  };
    

  template<typename S, typename T> 
  struct copy_data_to_numpy_helper<2,S,T> { 
    static void invoke(std::vector<int>& data_size, S* out, T* in) { 
      typedef CXXTypeTraits<T> traits; 
      const int dim = 2; 

      int lin_idx = 0; 
      std::vector<int> indices(dim);
      for (int i0= 0; i0< data_size[0]; ++i0) { 
        indices[0] = i0;
        for (int i1= 0; i1< data_size[1]; ++i1) { 
          indices[1] = i1;
          out[lin_idx] = traits::element_at(*in, indices);
          ++lin_idx;
        }
      }

    } 
  };
    

  template<typename S, typename T> 
  struct copy_data_to_numpy_helper<3,S,T> { 
    static void invoke(std::vector<int>& data_size, S* out, T* in) { 
      typedef CXXTypeTraits<T> traits; 
      const int dim = 3; 

      int lin_idx = 0; 
      std::vector<int> indices(dim);
      for (int i0= 0; i0< data_size[0]; ++i0) { 
        indices[0] = i0;
        for (int i1= 0; i1< data_size[1]; ++i1) { 
          indices[1] = i1;
          for (int i2= 0; i2< data_size[2]; ++i2) { 
            indices[2] = i2;
            out[lin_idx] = traits::element_at(*in, indices);
            ++lin_idx;
          }
        }
      }

    } 
  };
    

  template<typename S, typename T> 
  struct copy_data_to_numpy_helper<4,S,T> { 
    static void invoke(std::vector<int>& data_size, S* out, T* in) { 
      typedef CXXTypeTraits<T> traits; 
      const int dim = 4; 

      int lin_idx = 0; 
      std::vector<int> indices(dim);
      for (int i0= 0; i0< data_size[0]; ++i0) { 
        indices[0] = i0;
        for (int i1= 0; i1< data_size[1]; ++i1) { 
          indices[1] = i1;
          for (int i2= 0; i2< data_size[2]; ++i2) { 
            indices[2] = i2;
            for (int i3= 0; i3< data_size[3]; ++i3) { 
              indices[3] = i3;
              out[lin_idx] = traits::element_at(*in, indices);
              ++lin_idx;
            }
          }
        }
      }

    } 
  };
    

  template<typename S, typename T> 
  struct copy_data_to_numpy_helper<5,S,T> { 
    static void invoke(std::vector<int>& data_size, S* out, T* in) { 
      typedef CXXTypeTraits<T> traits; 
      const int dim = 5; 

      int lin_idx = 0; 
      std::vector<int> indices(dim);
      for (int i0= 0; i0< data_size[0]; ++i0) { 
        indices[0] = i0;
        for (int i1= 0; i1< data_size[1]; ++i1) { 
          indices[1] = i1;
          for (int i2= 0; i2< data_size[2]; ++i2) { 
            indices[2] = i2;
            for (int i3= 0; i3< data_size[3]; ++i3) { 
              indices[3] = i3;
              for (int i4= 0; i4< data_size[4]; ++i4) { 
                indices[4] = i4;
                out[lin_idx] = traits::element_at(*in, indices);
                ++lin_idx;
              }
            }
          }
        }
      }

    } 
  };
    

  template<typename S, typename T> 
  struct copy_data_to_numpy_helper<6,S,T> { 
    static void invoke(std::vector<int>& data_size, S* out, T* in) { 
      typedef CXXTypeTraits<T> traits; 
      const int dim = 6; 

      int lin_idx = 0; 
      std::vector<int> indices(dim);
      for (int i0= 0; i0< data_size[0]; ++i0) { 
        indices[0] = i0;
        for (int i1= 0; i1< data_size[1]; ++i1) { 
          indices[1] = i1;
          for (int i2= 0; i2< data_size[2]; ++i2) { 
            indices[2] = i2;
            for (int i3= 0; i3< data_size[3]; ++i3) { 
              indices[3] = i3;
              for (int i4= 0; i4< data_size[4]; ++i4) { 
                indices[4] = i4;
                for (int i5= 0; i5< data_size[5]; ++i5) { 
                  indices[5] = i5;
                  out[lin_idx] = traits::element_at(*in, indices);
                  ++lin_idx;
                }
              }
            }
          }
        }
      }

    } 
  };
    

  template<typename S, typename T> 
  struct copy_data_to_numpy_helper<7,S,T> { 
    static void invoke(std::vector<int>& data_size, S* out, T* in) { 
      typedef CXXTypeTraits<T> traits; 
      const int dim = 7; 

      int lin_idx = 0; 
      std::vector<int> indices(dim);
      for (int i0= 0; i0< data_size[0]; ++i0) { 
        indices[0] = i0;
        for (int i1= 0; i1< data_size[1]; ++i1) { 
          indices[1] = i1;
          for (int i2= 0; i2< data_size[2]; ++i2) { 
            indices[2] = i2;
            for (int i3= 0; i3< data_size[3]; ++i3) { 
              indices[3] = i3;
              for (int i4= 0; i4< data_size[4]; ++i4) { 
                indices[4] = i4;
                for (int i5= 0; i5< data_size[5]; ++i5) { 
                  indices[5] = i5;
                  for (int i6= 0; i6< data_size[6]; ++i6) { 
                    indices[6] = i6;
                    out[lin_idx] = traits::element_at(*in, indices);
                    ++lin_idx;
                  }
                }
              }
            }
          }
        }
      }

    } 
  };
    
  template<typename S, typename T> 
  struct copy_data_from_numpy_helper<1,S,T> { 
    static void invoke(std::vector<int>& data_size, S* in, T* out) { 
      typedef CXXTypeTraits<T> traits; 
      const int dim = 1; 

      int lin_idx = 0; 
      std::vector<int> indices(dim);
      for (int i0= 0; i0< data_size[0]; ++i0) { 
        indices[0] = i0;
        traits::element_at(*out, indices) = in[lin_idx];
        ++lin_idx;
      }

    } 
  };
    

  template<typename S, typename T> 
  struct copy_data_from_numpy_helper<2,S,T> { 
    static void invoke(std::vector<int>& data_size, S* in, T* out) { 
      typedef CXXTypeTraits<T> traits; 
      const int dim = 2; 

      int lin_idx = 0; 
      std::vector<int> indices(dim);
      for (int i0= 0; i0< data_size[0]; ++i0) { 
        indices[0] = i0;
        for (int i1= 0; i1< data_size[1]; ++i1) { 
          indices[1] = i1;
          traits::element_at(*out, indices) = in[lin_idx];
          ++lin_idx;
        }
      }

    } 
  };
    

  template<typename S, typename T> 
  struct copy_data_from_numpy_helper<3,S,T> { 
    static void invoke(std::vector<int>& data_size, S* in, T* out) { 
      typedef CXXTypeTraits<T> traits; 
      const int dim = 3; 

      int lin_idx = 0; 
      std::vector<int> indices(dim);
      for (int i0= 0; i0< data_size[0]; ++i0) { 
        indices[0] = i0;
        for (int i1= 0; i1< data_size[1]; ++i1) { 
          indices[1] = i1;
          for (int i2= 0; i2< data_size[2]; ++i2) { 
            indices[2] = i2;
            traits::element_at(*out, indices) = in[lin_idx];
            ++lin_idx;
          }
        }
      }

    } 
  };
    

  template<typename S, typename T> 
  struct copy_data_from_numpy_helper<4,S,T> { 
    static void invoke(std::vector<int>& data_size, S* in, T* out) { 
      typedef CXXTypeTraits<T> traits; 
      const int dim = 4; 

      int lin_idx = 0; 
      std::vector<int> indices(dim);
      for (int i0= 0; i0< data_size[0]; ++i0) { 
        indices[0] = i0;
        for (int i1= 0; i1< data_size[1]; ++i1) { 
          indices[1] = i1;
          for (int i2= 0; i2< data_size[2]; ++i2) { 
            indices[2] = i2;
            for (int i3= 0; i3< data_size[3]; ++i3) { 
              indices[3] = i3;
              traits::element_at(*out, indices) = in[lin_idx];
              ++lin_idx;
            }
          }
        }
      }

    } 
  };
    

  template<typename S, typename T> 
  struct copy_data_from_numpy_helper<5,S,T> { 
    static void invoke(std::vector<int>& data_size, S* in, T* out) { 
      typedef CXXTypeTraits<T> traits; 
      const int dim = 5; 

      int lin_idx = 0; 
      std::vector<int> indices(dim);
      for (int i0= 0; i0< data_size[0]; ++i0) { 
        indices[0] = i0;
        for (int i1= 0; i1< data_size[1]; ++i1) { 
          indices[1] = i1;
          for (int i2= 0; i2< data_size[2]; ++i2) { 
            indices[2] = i2;
            for (int i3= 0; i3< data_size[3]; ++i3) { 
              indices[3] = i3;
              for (int i4= 0; i4< data_size[4]; ++i4) { 
                indices[4] = i4;
                traits::element_at(*out, indices) = in[lin_idx];
                ++lin_idx;
              }
            }
          }
        }
      }

    } 
  };
    

  template<typename S, typename T> 
  struct copy_data_from_numpy_helper<6,S,T> { 
    static void invoke(std::vector<int>& data_size, S* in, T* out) { 
      typedef CXXTypeTraits<T> traits; 
      const int dim = 6; 

      int lin_idx = 0; 
      std::vector<int> indices(dim);
      for (int i0= 0; i0< data_size[0]; ++i0) { 
        indices[0] = i0;
        for (int i1= 0; i1< data_size[1]; ++i1) { 
          indices[1] = i1;
          for (int i2= 0; i2< data_size[2]; ++i2) { 
            indices[2] = i2;
            for (int i3= 0; i3< data_size[3]; ++i3) { 
              indices[3] = i3;
              for (int i4= 0; i4< data_size[4]; ++i4) { 
                indices[4] = i4;
                for (int i5= 0; i5< data_size[5]; ++i5) { 
                  indices[5] = i5;
                  traits::element_at(*out, indices) = in[lin_idx];
                  ++lin_idx;
                }
              }
            }
          }
        }
      }

    } 
  };
    

  template<typename S, typename T> 
  struct copy_data_from_numpy_helper<7,S,T> { 
    static void invoke(std::vector<int>& data_size, S* in, T* out) { 
      typedef CXXTypeTraits<T> traits; 
      const int dim = 7; 

      int lin_idx = 0; 
      std::vector<int> indices(dim);
      for (int i0= 0; i0< data_size[0]; ++i0) { 
        indices[0] = i0;
        for (int i1= 0; i1< data_size[1]; ++i1) { 
          indices[1] = i1;
          for (int i2= 0; i2< data_size[2]; ++i2) { 
            indices[2] = i2;
            for (int i3= 0; i3< data_size[3]; ++i3) { 
              indices[3] = i3;
              for (int i4= 0; i4< data_size[4]; ++i4) { 
                indices[4] = i4;
                for (int i5= 0; i5< data_size[5]; ++i5) { 
                  indices[5] = i5;
                  for (int i6= 0; i6< data_size[6]; ++i6) { 
                    indices[6] = i6;
                    traits::element_at(*out, indices) = in[lin_idx];
                    ++lin_idx;
                  }
                }
              }
            }
          }
        }
      }

    } 
  };
    

%}

%define %multi_array_typemaps(CLASS...)
// In: (nothing: no constness)
%typemap(in, fragment="Array_Fragments") CLASS (CLASS temp)
{
  if (!ConvertFromNumpyToCXX<CLASS >(&temp, $input))
    SWIG_fail;
  $1 = temp;
}

// In: const&
%typemap(in, fragment="Array_Fragments") CLASS const& (CLASS temp)
{
  // In: const&
  if (!ConvertFromNumpyToCXX<CLASS >(&temp, $input))
    SWIG_fail;
  $1 = &temp;
}

// Out: (nothing: no constness)
%typemap(out, fragment="Array_Fragments") CLASS
{
  if (!ConvertFromCXXToNumPyArray<CLASS >(&$result, &$1))
    SWIG_fail;
}

%enddef