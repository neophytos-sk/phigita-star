
class evaluator
{
    double inSum;
    double outSum;
    double inSqrSum;
    double outSqrSum;
    int inNum;
    int outNum;
    double low;
    double high;

 public:
    evaluator();
    void reset();
    void addIn(double distance);
    void addOut(double distance);
    double getInStdev();
    double getOutStdev();
    double getStdev();
    void add(double distance);
    double getLow();
    double getHigh();
    double getAverage();
    double getInAvg();
    double getOutAvg();
    double getInSqrSum();
    double getOutSqrSum();
    
};
