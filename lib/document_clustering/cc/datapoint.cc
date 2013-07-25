#include "datapoint.h"
#include <iostream>

datapoint::datapoint() : id_(-1) {}

datapoint::datapoint(int id, const word_list_t& word_list) : id_(id) {
  count_frequency(word_list, freq_map_);
  sum_ = compute_sum();
  normalize();
}

double datapoint::compute_sum() const {
  double sum=0;
  freq_map_t::const_iterator map_iter = freq_map_.begin();
  const freq_map_t::const_iterator map_iter_stop = freq_map_.end();
  for(; map_iter != map_iter_stop; ++map_iter)
    sum += map_iter->second;

  return sum;
}

datapoint::datapoint(const datapoint& other) {
  copyOther(other);
}



void datapoint::copyOther (const datapoint& other) {
  id_ = other.get_id();

    freq_map_t::const_iterator other_iter = other.freq_map_.begin();
    const freq_map_t::const_iterator other_end = other.freq_map_.end();
    for(; other_iter != other_end; ++other_iter) {
      freq_map_[other_iter->first] = other_iter->second;
    }
}

datapoint& datapoint::operator= (const datapoint& other) {

  if (this != &other) {
    copyOther(other);
  }
  return *this;

}

datapoint& datapoint::operator+= (const datapoint& other) {

  freq_map_t::const_iterator other_iter = other.freq_map_.begin();
  const freq_map_t::const_iterator other_end = other.freq_map_.end();
  for(; other_iter != other_end; ++other_iter) {
    freq_map_[other_iter->first] += other_iter->second;
  }
  return *this;
}

datapoint& datapoint::operator-= (const datapoint& other) {

  freq_map_t::const_iterator other_iter = other.freq_map_.begin();
  const freq_map_t::const_iterator other_end = other.freq_map_.end();
  for(; other_iter != other_end; ++other_iter) {
    freq_map_[other_iter->first] -= other_iter->second;
  }
  return *this;
}

datapoint& datapoint::operator/= (double value) {

  freq_map_t::const_iterator iter = freq_map_.begin();
  const freq_map_t::const_iterator end = freq_map_.end();

  for(;iter != end; ++iter)
    freq_map_[iter->first] /= value;

  return *this;

}

const datapoint datapoint::operator/ (double value) const {

  datapoint result = *this; // Make a deep copy of this datapoint.
  result /= value;
  return result;
}


void datapoint::add(const datapoint& other, double weight) {
  freq_map_t::const_iterator iter = freq_map_.begin();
  const freq_map_t::const_iterator end = freq_map_.end();

  const double value = weight/(weight+1.0);
  for(;iter != end; ++iter)
    freq_map_[iter->first] *= value;

  //printf("freq_map_.size before = %zd \n",freq_map_.size());

  freq_map_t::const_iterator other_iter = other.freq_map_.begin();
  const freq_map_t::const_iterator other_end = other.freq_map_.end();
  for(; other_iter != other_end; ++other_iter)
    freq_map_[other_iter->first] += other_iter->second / (weight+1.0);

  //printf("freq_map_.size after = %zd \n",freq_map_.size());

  normalize();

}


int datapoint::get_id() const { return id_; }

void datapoint::normalize() {

  const double denominator = sum_;
  freq_map_t::iterator map_iter = freq_map_.begin();
  const freq_map_t::const_iterator map_iter_stop = freq_map_.end();
  for(; map_iter != map_iter_stop; ++map_iter)
    map_iter->second /= denominator;

}



/* linguistic similarity using the cosine equation 
 * BUT since we are handling normalized vectors, 
 * we only need the numerator of the equation.
 *
 * Cosine Distance:
 *
 *     d(X,Y) = 1 - inner_product(X,Y)/sum(X)*sum(Y)
 *
 * Probabilities sum up to 1 and thus:
 *
 *     d(X,Y) = 1 - inner_product(X,Y)
 * 
 */ 
double datapoint::cosine_distance_from(const datapoint& other) const {
  return 1.0 - inner_product(freq_map_, other.freq_map_);
}

// Equivalent to vector_angle. Note that:
//   angle = acos(1.0-distance)
//   distance = 1.0-cos(angle)
double datapoint::vector_angle_from(const datapoint& other) const {
  return acos(inner_product(freq_map_, other.freq_map_));
}

