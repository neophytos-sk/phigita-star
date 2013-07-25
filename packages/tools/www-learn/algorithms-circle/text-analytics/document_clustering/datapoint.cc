#include "datapoint.h"

datapoint::datapoint() : id_(-1) {}

datapoint::datapoint(int id, const word_list_t& word_list) : id_(id) {
  count_frequency(word_list, freq_map_);
  normalize();
}


void datapoint::add(const datapoint& other, double weight) {
  freq_map_t::const_iterator iter = freq_map_.begin();
  const freq_map_t::const_iterator stop = freq_map_.end();

  const double value = weight/(weight+1);
  for(;iter != stop; ++iter)
    freq_map_[iter->first] *= value;

  //printf("freq_map_.size before = %zd \n",freq_map_.size());

  freq_map_t::const_iterator other_iter = other.freq_map_.begin();
  const freq_map_t::const_iterator other_stop = other.freq_map_.end();
  for(; other_iter != other_stop; ++other_iter)
    freq_map_[other_iter->first] += other_iter->second / (weight+1);

  //printf("freq_map_.size after = %zd \n",freq_map_.size());

  //normalize(); // we don't need to normalize again - not sure but think so (??)

}


int datapoint::get_id() const { return id_; }

// normalize the freq_map_ by dividing with the denominator of the cosine equation
void datapoint::normalize() {
  const double denominator = sqrt(inner_product(freq_map_,freq_map_));
  freq_map_t::iterator map_iter = freq_map_.begin();
  const freq_map_t::const_iterator map_iter_stop = freq_map_.end();
  for(; map_iter != map_iter_stop; ++map_iter)
    map_iter->second /= denominator;
}



// linguistic similarity using the cosine equation 
// BUT since we are handling normalized vectors, 
// we only need the numerator of the equation.
// 
double datapoint::cosine_distance_from(const datapoint& other) const {
  //printf("this.size=%zd other.size=%zd ",this->freq_map_.size(),other.freq_map_.size());
  return 1.0 - inner_product(this->freq_map_, other.freq_map_);
}

// Equivalent to vector_angle. Note that:
//   angle = acos(1.0-distance)
//   distance = 1.0-cos(angle)
double datapoint::vector_angle_from(const datapoint& other) {
  return acos(inner_product(this->freq_map_, other.freq_map_));
}
