#include "my_class.hpp"
//#define BOOST_TEST_MODULE MyTest
#define BOOST_TEST_DYN_LINK
#define BOOST_TEST_MODULE Main
#include <boost/test/unit_test.hpp>

BOOST_AUTO_TEST_SUITE( my_test_suite )

BOOST_AUTO_TEST_CASE( my_test1 )
{
  my_class test_object("test"/* whatever you need to construct it right */);
  BOOST_CHECK( test_object.multiply_by_two(2) == 4 );
}


BOOST_AUTO_TEST_CASE( my_test2 )
{
  my_class test_object("test"/* whatever you need to construct it right */);
  BOOST_CHECK( test_object.multiply_by_two(3) == 4 );
}


BOOST_AUTO_TEST_SUITE_END()


