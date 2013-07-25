#include "datapoint.h"
#include <iostream>
#include <set>

DataPoint::DataPoint(string Article, unsigned int Index,myset* removeSet) 
{
    article = Article;
    index = Index;
    parseArticle(removeSet);
}

void DataPoint::add(DataPoint* dp, double weight) {
   Sgi::hash_map<string,double>::iterator j = wordVector.begin();
   for(;j != wordVector.end();j++) {
       string key = (*j).first;
       double value = wordVector[key];
       wordVector[key] = value*weight/(weight+1);
     }

   Sgi::hash_map<string,double>::iterator i = dp->wordVector.begin();
   for(;i != dp->wordVector.end(); i++) {
       string key = (*i).first;
       double value = dp->wordVector[key];

       value = value/(weight+1);
       if (wordVector.count(key))
       {
           double value2 = wordVector[key];
           value += value2;
       }
       wordVector[key] = value;
   }
   normalize();
}

void DataPoint::add(DataPoint* dp) {
   add(dp, 1.0);
}

string DataPoint::getArticle()
{ 
    return article;
}

void DataPoint::overwriteArticle(string newArticle) {
   article = newArticle;
} 

void DataPoint::parseArticle(myset* removeSet)
{
    vector<string> tokens = getTokens(article);
    for (unsigned int i = 0; i < tokens.size(); i++)
    {
	string toInsert = toLower(tokens[i]);
	
	if (!removeSet->count(toInsert))
	    addNext(toInsert);
    }
    normalize();
}

void DataPoint::normalize() {
     Sgi::hash_map<string,double>::iterator i = wordVector.begin();
     double sum = 0;
     for (;i != wordVector.end(); i++) {
         sum  += pow(wordVector[(*i).first], 2);
     }
     sum = sqrt(sum);

     Sgi::hash_map<string,double>::iterator j = wordVector.begin();
     for (; j != wordVector.end(); j++ ) {
         string key = (*j).first;
         double value = wordVector[key];
         wordVector[key] = value/sum;
     }
}

void DataPoint::addNext(string word)
{
   if(wordVector.count(word)) {
       double value = wordVector[word];
       value = exp(log(value+1));
       wordVector[word] = value;
   }
   else wordVector[word]=1.0;
}

double DataPoint::cosineDistance(DataPoint* dp) {
     return cosineDistance(this, dp);
}

double DataPoint::cosineDistance(DataPoint* dp1, DataPoint* dp2) {
   double proximity = 0;
   Sgi::hash_map<string,double>::iterator i = dp1->wordVector.begin();
   int counter = 0;
   for (;i != dp1->wordVector.end(); i++)
   {
       string key = (*i).first;
       if(dp2->wordVector.count(key)) {
           proximity += dp1->wordVector[key] * dp2->wordVector[key];
	   counter++;
       }
   }
   return 1.0 - proximity;
}

string DataPoint::toString() {
   string result("");
   result += "----" + article + "----" + "\n";
   Sgi::hash_map<string,double>::iterator i = wordVector.begin();
   for (; i != wordVector.end(); i++)
       result += (*i).first + ",";
   return result;
}

Sgi::hash_map<string,double> DataPoint::getWordVector()
{
   return wordVector;
}

DataPoint::DataPoint()
{

}

unsigned int DataPoint::getIndex()
{
    return index;
}
