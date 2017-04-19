#include "mq.h"

#include <grpc++/grpc++.h>
#include <iostream>
#include <unordered_map>

using std::unordered_map;

namespace mq {

grpc::Status MessageQueue::put(std::string topic, std::string message) {
    std::lock_guard<std::mutex> lk(_m);
    _mq[topic] = message;
    return grpc::Status::OK;
}

grpc::Status MessageQueue::get(std::string topic, std::string *message) {
    std::lock_guard<std::mutex> lk(_m);
    *message = _mq[topic];
    _mq.erase(topic);
    return grpc::Status::OK;
}

}


