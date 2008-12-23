#ifndef __included_neural_network_h
#define __included_neural_network_h

#include <stdlib.h>

#ifdef __cplusplus
extern "C"
{
#endif

typedef enum
{
    NN_ACTIVATION_THRESHOLD = 0,
    NN_ACTIVATION_PIECEWISE_LINEAR = 1,
    NN_ACTIVATION_SIGMOID = 2,
    NN_ACTIVATION_HYPERBOLIC_TANGENT = 3,
} NeuralNetworkActivationModel;

typedef struct
{
    float value;
    float delta;
    unsigned long weightCount;
    float* weights;
} NeuralNetworkNode;

typedef struct
{
    unsigned long nodeCount;
    NeuralNetworkNode* nodes;
} NeuralNetworkLayer;

typedef struct
{
    unsigned long memoryUsage;
    float learningRate;
    NeuralNetworkActivationModel model;
    unsigned long layerCount;
    NeuralNetworkLayer* layers;
} NeuralNetwork;

NeuralNetwork* NN_Create ( unsigned long layerCount, const unsigned long* layers, float initialLearningRate, NeuralNetworkActivationModel model );
void NN_Destroy ( NeuralNetwork* nn );
void* NN_Serialise ( NeuralNetwork* nn, size_t* len, int fast );
NeuralNetwork* NN_Deserialise ( const void* data, size_t len, int fast );

void NN_Train ( NeuralNetwork* nn, unsigned long numInputs, const float* inputs, unsigned long numOutputs, const float* outputs );
void NN_Solve ( NeuralNetwork* nn, unsigned long numInputs, const float* inputs, unsigned long numOutputs, float* outputs );

void NN_Debug_DumpNetwork ( NeuralNetwork* nn, int deltas );

#ifdef __cplusplus
}
#endif

#endif
