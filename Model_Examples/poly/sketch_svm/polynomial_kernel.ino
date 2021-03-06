#ifndef VEC_DIM
#error
#endif

#ifndef GAMMA
#error
#endif

#ifndef COEF0
#error
#endif

#ifndef DEGREE
#error
#endif

#include <avr/pgmspace.h>

inline float polynomial_kernel(float* u, float* v){
  float result=0;

  for (int j=0; j<VEC_DIM; j++){
    result += pgm_read_float(u + j) * v[j];
  }

  return pow((GAMMA * result + COEF0),DEGREE);
}
