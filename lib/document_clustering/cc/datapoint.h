#ifndef DATAPOINT_H
#define DATAPOINT_H

#include "common.h"
#include "document_distance.h"


class datapoint {
 public:
  datapoint();
  datapoint(int id, const word_list_t& word_list);

  datapoint(const datapoint& other);  // copy constructor
  datapoint& operator= (const datapoint& other);  // assignment operator

  double compute_sum() const;
  void add(const datapoint& other, double weight);
  int get_id() const;
  double cosine_distance_from(const datapoint& other) const;
  double vector_angle_from(const datapoint& other) const;

  datapoint& operator+= (const datapoint& other);
  datapoint& operator-= (const datapoint& other);
  datapoint& operator/= (double value);
  const datapoint operator/ (double value) const;


 private:
  
  void copyOther (const datapoint& other);
  void normalize();

  int id_;
  freq_map_t freq_map_;
  double sum_;

};

#endif
