#ifndef __apollo_utilities_test_harness_h
#define __apollo_utilities_test_harness_h

/**
 * @file TestHarness.h
 * @brief An interface to the test harness
 */

#include <string>
#include <vector>

namespace TestHarness
{

/**
 * Invokes a given test.
 * @param testName The name of the test
 * @param testParameters A vector of parameters to the test
 * @return Whether the test succeeded or not
 */
bool InvokeTest ( const std::string& testName, const std::vector<std::string>& testParameters );

}

#endif