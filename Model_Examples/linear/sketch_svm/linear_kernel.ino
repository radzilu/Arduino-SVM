#ifndef VEC_DIM
#error 
#endif

#include <avr/pgmspace.h>

inline float linear_kernel(float* u, float* v){
  float result=0;
  for (int j=0; j<VEC_DIM; j++){
    result += pgm_read_float(u + j) * v[j];
  }
  return result;
}
