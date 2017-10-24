#include <complex>
#include <alps/gf/gf.hpp>
#include <alps/gf/mesh.hpp>

template<typename G>
void load_from_hdf5(G& gf, const std::string& file_name, const std::string& path) {
    alps::hdf5::archive iar(file_name, "r");
    gf.load(iar, path); 
}

template<typename G>
void save_to_hdf5(G& gf, const std::string& file_name, const std::string& path) {
    alps::hdf5::archive oar(file_name, "w");
    gf.save(oar, path); 
}

#ifdef SWIG
%feature("autodoc", "Do something ") do_something ;
#endif
inline void do_something() {
}
