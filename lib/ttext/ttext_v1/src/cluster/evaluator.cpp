#include "evaluator.h"

Evaluator::Evaluator() {
    inSum = 0; outSum = 0;
    inNum = 0; outNum = 0;
    inSqrSum = 0; outSqrSum = 0;
    low = 1; high = 0;
}
   
void Evaluator::addIn(double distance) {
    inSum+= distance;
    inNum++;
    inSqrSum += distance*distance;
    add(distance);

}
   
void Evaluator::addOut(double distance) {
    outSum+= distance;
    outNum++;
    outSqrSum += distance*distance;
    add(distance);
}

double Evaluator::getInStdev() {
    return (inNum *inSqrSum - inSum*inSum)/(inNum * (inNum-1));
}

double Evaluator::getOutStdev() {
    return (outNum *outSqrSum - outSum*outSum)/(outNum * (outNum-1));
}

double Evaluator::getStdev() {      
    int Num = inNum + outNum;
    double Sum = inSum + outSum;
    double SqrSum = inSqrSum + outSqrSum;
    return (Num *SqrSum - Sum*Sum)/(Num * (Num-1));
}

void Evaluator::add(double distance) {
    if (distance < low) low = distance;
    if (distance > high) high = distance;
}

double Evaluator::getLow() {
    return low;
}

double Evaluator::getHigh() {
    return high;
}

double Evaluator::getAverage() {
    return (inSum + outSum)/(inNum + outNum);
}

double Evaluator::getInAvg() {
    return inSum/inNum;
}

double Evaluator::getOutAvg() {
    return outSum/outNum;
}
