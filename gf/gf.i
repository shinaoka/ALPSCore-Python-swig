/* gf.i */
%module(package="alps") gf
%{
#define SWIG_FILE_WITH_INIT
#include <alps/gf/mesh.hpp>
#include "gf_aux.hpp"
%}

%include "std_string.i"
%include "../common/swig/numpy.i"

%init %{
   import_array();
%}

/* These ignore directives must come before including header files */
%ignore alps::gf::operator<<;

%pythoncode %{ 
import h5py
import numpy

def load_gf_data(f, path, dtype=float):
    dtype = float
    if '__complex__' in f[path].attrs and f[path].attrs['__complex__'] == 1:
        dtype = complex

    if dtype==float:
        return f[path].value
    elif dtype==complex:
        raw_data = f[path].value
        s = raw_data.shape
        array_2d = raw_data.reshape((int(raw_data.size/2), 2))
        return (array_2d[:,0] + 1J*array_2d[:,1]).reshape(s[:-1])
    else:
        raise RuntimeError("Unknown type : "+dtype)

def save_gf_data(f, path, data):
    if data.dtype == float:
        f[path] = data
    elif data.dtype == complex:
        s = data.shape
        a = numpy.zeros((data.size, 2), dtype=float)
        a[:,0] = data.flatten().real
        a[:,1] = data.flatten().imag
        f[path] = a.reshape(data.shape+(2,))
        f[path].attrs['__complex__'] = 1
    else:
        raise RuntimeError("Unknown type : "+dtype)

def load_mesh(file_name, path):
    with h5py.File(file_name, 'r') as f:
        kind = f[path+'/kind'].value
        if kind == 'MATSUBARA':
            positive_only = f[path+'/positive_only'].value
            if positive_only == 0:
                py_name = 'matsubara_positive_negative_mesh'
            elif positive_only == 1:
                py_name = 'matsubara_positive_mesh'
            else:
                raise RuntimeError("This mesh type is not supported by python wrapper: "+kind)
        elif kind == 'IMAGINARY_TIME':
            py_name = 'imaginary_time_mesh'
        elif kind == 'LEGENDRE':
            py_name = 'legendre_mesh'
        elif kind == 'INDEX':
            py_name = 'index_mesh'
        elif kind == 'NUMERICAL_MESH':
            py_name = 'numerical_mesh'
        else:
            raise RuntimeError("Unsupported mesh type in python wrapper: "+kind)

    loader = globals()['load_'+py_name]
    mesh_obj = (globals()[py_name])()
    loader(mesh_obj, file_name, path)
    return mesh_obj

def save_mesh(mesh, file_name, path):
    saver = globals()['save_'+ mesh.__class__.__name__]
    saver(mesh, file_name, path)

class gf(object):
    def __init__(self):
        self._meshes = []

        # Data (numpy array)
        self._data = None

    def mesh(self, idx):
        assert idx >= 0 and idx < len(self._meshes)
        return self._meshes[idx]

    def load(self, file_name, path):
        with h5py.File(file_name, 'r') as f:
            self._data = load_gf_data(f, path+'/data')
            n_mesh = f[path+'/mesh/N'].value

            self._version_major = f[path+'/version/major'].value
            self._version_minor = f[path+'/version/minor'].value
            self._version_originator = f[path+'/version/originator'].value
            self._version_reference = f[path+'/version/reference'].value

        self._meshes = []
        for im in range(n_mesh):
            self._meshes.append(load_mesh(file_name, path+'/mesh/'+str(im+1)))

    def save(self, file_name, path):
        with h5py.File(file_name, 'w') as f:
            save_gf_data(f, path+'/data', self._data)
            f[path+'/version/major'] = self._version_major
            f[path+'/version/minor'] = self._version_minor
            f[path+'/version/originator'] = self._version_originator
            f[path+'/version/reference'] = self._version_reference
            f[path+'/mesh/N'] = len(self._meshes)

        # save meshes
        im = 1
        for mesh in self._meshes:
            save_mesh(mesh, file_name, path+'/mesh/'+str(im))
            im += 1

    @property
    def data(self):
        return self._data

    def __eq__(self, other):
        eq_r = True
        for k in self.__dict__:
            #print(k, self.__dict__[k] == other.__dict__[k])
            if self.__dict__[k].__class__.__name__ == 'ndarray':
                eq_r = eq_r and (self.__dict__[k] == other.__dict__[k]).all()
            else:
                eq_r = eq_r and self.__dict__[k] == other.__dict__[k]
        return eq_r

%}

%include <alps/gf/mesh.hpp>
%include <alps/gf/piecewise_polynomial.hpp>
%include "gf_aux.hpp"

%define MESH_LOAD_SAVE_WITH_INSTANTIATION(py_name, cxx_name)
%template(py_name) cxx_name ;
%template(load_ ## py_name) load_from_hdf5<cxx_name >;
%template(save_ ## py_name) save_to_hdf5<cxx_name >;
%enddef

%define MESH_LOAD_SAVE(py_name, cxx_name)
%template(load_ ## py_name) load_from_hdf5<cxx_name >;
%template(save_ ## py_name) save_to_hdf5<cxx_name >;
%enddef

MESH_LOAD_SAVE_WITH_INSTANTIATION(matsubara_positive_mesh, alps::gf::matsubara_mesh<alps::gf::mesh::POSITIVE_ONLY>)
MESH_LOAD_SAVE_WITH_INSTANTIATION(real_numerical_mesh, alps::gf::numerical_mesh<double>)

MESH_LOAD_SAVE(index_mesh, alps::gf::index_mesh)
MESH_LOAD_SAVE(legendre_mesh, alps::gf::legendre_mesh)

%template(real_piecewise_polynomial) alps::gf::piecewise_polynomial<double>;
