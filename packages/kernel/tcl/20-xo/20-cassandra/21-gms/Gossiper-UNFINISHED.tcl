# This module is responsible for Gossiping information for the local endpoint. This abstraction
# maintains the list of live and dead endpoints. Periodically i.e. every 1 second this module
# chooses a random node and initiates a round of Gossip with it. A round of Gossip involves 3
# rounds of messaging. For instance if node A wants to initiate a round of Gossip with node B
# it starts off by sending node B a GossipDigestSynMessage. Node B on receipt of this message
# sends node A a GossipDigestAckMessage. On receipt of this message node A sends node B a
# GossipDigestAck2Message which completes a round of Gossip. This module as and when it hears one
# of the three above mentioned messages updates the Failure Detector with the liveness information.
#


namespace eval ::xo::gms {;}

# GS - abbreviation for GOSSIPER_STAGE
set ::xo::gms::GOSSIP_STAGE "GS"
# GSV - abbreviation for GOSSIP-DIGEST-SYN-VERB
set ::xo::gms::JOIN_VERB_HANDLER "JVH"
# GSV - abbreviation for GOSSIP-DIGEST-SYN-VERB
set ::xo::gms::GOSSIP_DIGEST_SYN_VERB "GSV"
# GAV - abbreviation for GOSSIP-DIGEST-ACK-VERB
set ::xo::gms::GOSSIP_DIGEST_ACK_VERB "GAV"
# GA2V - abbreviation for GOSSIP-DIGEST-ACK2-VERB
set ::xo::gms::GOSSIP_DIGEST_ACK2_VERB "GA2V"
#private final static int intervalInMillis_ = 1000;



### implements IFailureDetectionEventListener, IEndPointStateChangePublisher, IComponentShutdown
Class create ::xo::gms::Gossiper

::xo::gms::Gossiper instproc init {args} {
    set __subscribers [list]
    set __live_endpoints [list]
    set __unreachable_endpoints [list]
    set __seeds [list]
    array set __endpoint_state_map [list]
}


::xo::gms::Gossiper instproc register {subscriber} {
    my instvar __subscribers
    set __subscribers($subscriber) ""
}

# IEndPointStateChangeSubscriber 
::xo::gms::Gossiper instproc unregister {subscriber} {
    my instvar __subscribers
    unset __subscribers($subscriber)
}



::xo::gms::Gossiper instproc getAllMembers {} {
    my instvar __live_endpoints __unreachable_endpoints
    return [concat $__live_endpoints $__unreachable_endpoints]
}

::xo::gms::Gossiper instproc getLiveMembers {} {
    my instvar __live_endpoints
    return $__live_endpoints
}

::xo::gms::Gossiper instproc getUnreachableMembers {} {
    my instvar __unreachable_endpoints
    return $__unreachable_endpoints
}
