# A space-efficient probabilistic set for membership test, false positives
# are possible, but false negatives are not.

namespace eval ::bloom_filter {

    namespace ensemble create -subcommands {init insert may_contain}

    # An estimated number of items that will be inserted
    variable items_estimate

    # The probability for false positives
    variable false_positive_prob

    # Average bits per item
    variable bits_per_item

    # Number of hash functions for the filter
    variable num_hashes

    # Actual number of items
    variable items_actual

    # Number of bits
    variable length

}

proc ::bloom_filter::init {args} {
}

proc ::bloom_filter::insert {args} {
}

proc ::bloom_filter::may_contain {args} {
}


