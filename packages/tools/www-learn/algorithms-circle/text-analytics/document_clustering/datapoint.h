#ifndef DATAPOINT_H
#define DATAPOINT_H

#include "common.h"
#include "document_distance.h"

class datapoint {
 public:
  datapoint();
  datapoint(int id, const word_list_t& word_list);
  void add(const datapoint& other, double weight);
  int get_id() const;
  double cosine_distance_from(const datapoint& other) const;
  double vector_angle_from(const datapoint& other);
 private:
  void normalize();
  int id_;
  freq_map_t freq_map_;
};

#endif
