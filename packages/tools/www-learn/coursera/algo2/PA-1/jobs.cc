#include <iostream>
#include <fstream>
#include <algorithm>
#include <vector>
#include <iterator>

using namespace std;


struct job_t {
    int weight;
    int length;
};

bool job_compare_diff(job_t j1, job_t j2) {
    int d1 = j1.weight - j1.length;
    int d2 = j2.weight - j2.length;
    if (d1 > d2)
        return true;
    else if (d1 < d2)
        return false;
    else if (j1.weight > j2.weight)
        return true;
    else
        return false;
}

bool job_compare_ratio(job_t j1, job_t j2) {
    return double(j1.weight)/double(j1.length) > double(j2.weight)/double(j2.length);
}

long weighted_sum(const vector<job_t>& jobs) {
    long sum=0, completion_time, prev_completion_time=0;
    vector<job_t>::const_iterator it = jobs.begin();
    vector<job_t>::const_iterator end = jobs.end();
    for(;it!=end;++it) {
        completion_time = prev_completion_time + it->length;
        sum += it->weight * completion_time;
        //cout << "sum=" << sum << " completion_time=" << completion_time << endl;
        prev_completion_time = completion_time;
    }
    return sum;
}

void print_jobs(const vector<job_t>& jobs) {
    cout << "--------------------------" << endl;
    for(typeof(jobs.begin()) it=jobs.begin(); it != jobs.end(); ++it) 
        cout << it->weight << " " << it->length << " " << double(it->weight)/double(it->length) << endl;
}

int main(int argc, const char **argv) {

    if (argc!=2) {
        cout << "Usage: " << argv[0] << " filename" << endl;
        return 1;
    }
    const char *filename = argv[1];

    cout << "filename=" << filename << endl;

    ifstream infile(filename);

    int n, i=0;
    infile >> n;
    vector<job_t> jobs;
    cout << "n=" << n << endl;
    while (i<n) {
        job_t job;
        infile >> job.weight >> job.length;
        jobs.push_back(job);
        i++;
    }
    cout << "i=" << i << endl;
    infile.close();

    sort(jobs.begin(),jobs.end(),job_compare_diff);
    cout << "weighted sum = " << weighted_sum(jobs) << endl;
    //print_jobs(jobs);

    sort(jobs.begin(),jobs.end(),job_compare_ratio);
    //print_jobs(jobs);
    cout << "weighted sum = " << weighted_sum(jobs) << endl;

    return 0;
}
