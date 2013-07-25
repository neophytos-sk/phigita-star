#include "evaluator.h"

evaluator::evaluator() {
  reset();
}

void evaluator::reset() {
    inSum = 0; outSum = 0;
    inNum = 0; outNum = 0;
    inSqrSum = 0; outSqrSum = 0;
    low = 1; high = 0;
}

   
void evaluator::addIn(double distance) {
    inSum+= distance;
    inNum++;
    inSqrSum += distance*distance;
    add(distance);

}
   
void evaluator::addOut(double distance) {
    outSum+= distance;
    outNum++;
    outSqrSum += distance*distance;
    add(distance);
}

double evaluator::getInStdev() {
    return (inNum *inSqrSum - inSum*inSum)/(inNum * (inNum-1));
}

double evaluator::getOutStdev() {
    return (outNum *outSqrSum - outSum*outSum)/(outNum * (outNum-1));
}

double evaluator::getStdev() {      
    int Num = inNum + outNum;
    double Sum = inSum + outSum;
    double SqrSum = inSqrSum + outSqrSum;
    return (Num *SqrSum - Sum*Sum)/(Num * (Num-1));
}


double evaluator::getInSqrSum() {
  return inSqrSum;
}

double evaluator::getOutSqrSum() {
  return outSqrSum;
}

void evaluator::add(double distance) {
    if (distance < low) low = distance;
    if (distance > high) high = distance;
}

double evaluator::getLow() {
    return low;
}

double evaluator::getHigh() {
    return high;
}

double evaluator::getAverage() {
    return (inSum + outSum)/(inNum + outNum);
}

double evaluator::getInAvg() {
    return inSum/inNum;
}

double evaluator::getOutAvg() {
    return outSum/outNum;
}
