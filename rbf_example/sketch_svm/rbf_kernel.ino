#ifndef VEC_DIM
#error "must define the dimension of vectors."
#endif

#ifndef GAMMA
#error "must define gamma for rbf kernel."
#endif

#include <avr/pgmspace.h>
/*
 * \param u a vector in program memory
 * \param v a vector in main memory
 *
 * \pre the CPP-constant VEC_DIM defines the dimension of support vectors and sensors.
 */
inline float rbf_kernel(float* u, float* v){
  float result=0;
  // calculate squared norm
  for (int j=0; j<VEC_DIM; j++){
    float temp = pgm_read_float(u + j) - v[j];
    result += temp * temp;
  }
  return exp(-GAMMA * result);
}
