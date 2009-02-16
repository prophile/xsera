#ifdef WIN32
#include <malloc.h>
#endif
#include "neural-network.h"
#include <stdlib.h>
#include <math.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>

#define SQUARE(x) ((x)*(x))

static inline float ActivationFunction ( NeuralNetworkActivationModel model, float v )
{
    switch (model)
    {
        case NN_ACTIVATION_PIECEWISE_LINEAR:
            if (v >= 0.5f)
                return 1.0f;
            else if (v <= -0.5f)
                return -1.0f;
            else
                return v + 0.5f;
            break;
        case NN_ACTIVATION_THRESHOLD:
            if (v >= 0.0f)
                return 1.0f;
            else
                return 0.0f;
            break;
        case NN_ACTIVATION_SIGMOID:
            return 1.0f / (1.0f + expf(-v));
            break;
        case NN_ACTIVATION_HYPERBOLIC_TANGENT:
            return tanhf(v / 2.0f);
            break;
    }
    return 0.0f;
}

inline static float RandomInitialWeight ()
{
    float uniform = rand() / (float)RAND_MAX;
    uniform *= 0.1f;
    uniform -= 0.05f;
    return uniform; // this gives a weight in the range -2..2
}

NeuralNetwork* NN_Create ( unsigned long layerCount, const unsigned long* layers, float initialLearningRate, NeuralNetworkActivationModel model )
{
    assert(layerCount >= 2);
    assert(layers);
    unsigned long totalSize = sizeof(NeuralNetwork);
    totalSize += sizeof(NeuralNetworkLayer) * layerCount; // add space for each layer
    for (unsigned long i = 0; i < layerCount; i++)
    {
        totalSize += sizeof(NeuralNetworkNode) * layers[i]; // add space for the nodes...
        if (i < (layerCount - 1))
        {
            totalSize += sizeof(float) * layers[i + 1]; // add space for the weights
        }
    }
    printf("Created neural network, space used: %u bytes\n", totalSize);
    // get the actual block
    #ifdef __MACH__
    unsigned char* block = valloc(totalSize);
    #else
		#ifdef WIN32
		unsigned char* block = (unsigned char*)malloc(totalSize);
		#else
		unsigned char* block = malloc(totalSize);
		#endif
    #endif
	assert(block);
    // first, set up the actual NeuralNetwork* structure
    NeuralNetwork* nn = (NeuralNetwork*)block;
    nn->memoryUsage = totalSize;
    block += sizeof(NeuralNetwork);
    nn->learningRate = initialLearningRate;
    nn->model = model;
    nn->layerCount = layerCount;
    nn->layers = (NeuralNetworkLayer*)block;
    // now, set up the array of layers, without filling in node blocks
    block += sizeof(NeuralNetworkLayer) * layerCount;
    for (unsigned long i = 0; i < layerCount; i++)
    {
        nn->layers[i].nodeCount = layers[i];
        nn->layers[i].nodes = (NeuralNetworkNode*)block;
        block += sizeof(NeuralNetworkNode) * layers[i];
    }
    // and now deal with the array of nodes in all but the output layer
    for (unsigned long i = 0; i < (layerCount - 1); i++)
    {
        for (unsigned long j = 0; j < layers[i]; j++)
        {
            nn->layers[i].nodes[j].value = 0.0f;
            nn->layers[i].nodes[j].delta = 0.0f;
            nn->layers[i].nodes[j].weightCount = layers[i + 1];
            nn->layers[i].nodes[j].weights = (float*)block;
            block += sizeof(float) * layers[i + 1];
            for (unsigned long k = 0; k < layers[i + 1]; k++)
            {
                nn->layers[i].nodes[j].weights[k] = RandomInitialWeight();
            }
        }
    }
    // and now deal with the output layer
    for (unsigned long i = 0; i < layers[layerCount - 1]; i++)
    {
        nn->layers[layerCount - 1].nodes[i].value = 0.0f;
        nn->layers[layerCount - 1].nodes[i].weightCount = 0;
        nn->layers[layerCount - 1].nodes[i].weights = NULL;
    }
    return nn;
}

void NN_Destroy ( NeuralNetwork* nn )
{
    free((void*)nn);
}

void* NN_Serialise ( NeuralNetwork* nn, size_t* len, int fast )
{
    if (fast) // the fast option does make it very fast :)
    {
        *len = nn->memoryUsage;
        return nn;
    }
    else
    {
        const char* modelName;
        switch (nn->model)
        {
            case NN_ACTIVATION_HYPERBOLIC_TANGENT:
                modelName = "tanh";
                break;
            case NN_ACTIVATION_PIECEWISE_LINEAR:
                modelName = "pwl";
                break;
            case NN_ACTIVATION_SIGMOID:
                modelName = "sigmoid";
                break;
            case NN_ACTIVATION_THRESHOLD:
                modelName = "bool";
                break;
            default:
                modelName = "unknown";
                break;
        }
        char* buffer = (char*)malloc(1024 * 32); // 32kb of storage space
        unsigned lineIndex = 0;
        lineIndex += sprintf(buffer + lineIndex, "model:%s learnRate:%f layers:%u\n", modelName, nn->learningRate, nn->layerCount);
        for (unsigned long i = 0; i < nn->layerCount; i++)
        {
            lineIndex += sprintf(buffer + lineIndex, "layer:%u nodeCount:%u\n", i, nn->layers[i].nodeCount);
            for (unsigned long j = 0; j < nn->layers[i].nodeCount; j++)
            {
                char weights[1024];
                unsigned long weightIndex = 0;
                for (unsigned long k = 0; k < nn->layers[i].nodes[j].weightCount; k++)
                {
                    weightIndex += sprintf(weights + weightIndex, "%f ", nn->layers[i].nodes[j].weights[k]);
                }
                if (weightIndex > 0)
                    weights[weightIndex - 1] = 0;
                lineIndex += sprintf(buffer + lineIndex, "\t%s\n", weights);
            }
        }
        *len = lineIndex;
        return buffer;
    }
}

NeuralNetwork* NN_Deserialise ( const void* data, size_t len, int fast )
{
    if (fast)
    {
		#ifdef __MACH__
        unsigned char* mem = valloc(len);
		#else
			#ifdef WIN32
			unsigned char* mem = (unsigned char*)malloc(len);
			#else
			unsigned char* mem = malloc(len);
			#endif
		#endif
        memcpy(mem, data, len);
        NeuralNetwork* nn = (NeuralNetwork*)mem;
        // now fix all the pointers
        nn->layers = (NeuralNetworkLayer*)(mem + sizeof(NeuralNetwork));
        unsigned char* nodememory = mem + sizeof(NeuralNetwork) + (sizeof(NeuralNetworkLayer) * nn->layerCount);
        for (unsigned long i = 0; i < nn->layerCount; i++)
        {
            nn->layers[i].nodes = (NeuralNetworkNode*)nodememory;
            nodememory += sizeof(NeuralNetworkNode) * nn->layers[i].nodeCount;
        }
        for (unsigned long i = 0; i < nn->layerCount; i++)
        {
            for (unsigned long j = 0; j < nn->layerCount; j++)
            {
                nn->layers[i].nodes[j].weights = (float*)nodememory;
                nodememory += sizeof(float) * nn->layers[i].nodes[j].weightCount;
            }
        }
        return nn;
    }
    else
    {
        return NULL;
    }
}

static void ClearNN ( NeuralNetwork* nn )
{
    for (unsigned long i = 0; i < nn->layerCount; i++)
    {
        for (unsigned long j = 0; j < nn->layers[i].nodeCount; j++)
        {
            nn->layers[i].nodes[j].value = 0.0f;
        }
    }
}

// assume squared errors

void NN_Train ( NeuralNetwork* nn, unsigned long numInputs, const float* inputs, unsigned long numOutputs, const float* outputs )
{
    // run a solution
	#ifdef WIN32
	float* givenOutputs = (float*)_alloca(sizeof(float) * numOutputs);
	#else
	float* givenOutputs = (float*)alloca(sizeof(float) * numOutputs);
	#endif
    NN_Solve(nn, numInputs, inputs, numOutputs, givenOutputs);
    float learningRate = nn->learningRate;
    // update all deltas to the errors in the output layer
    NeuralNetworkLayer* outputLayer = nn->layers + (nn->layerCount - 1);
    for (unsigned long i = 0; i < numOutputs; i++)
    {
        float out = givenOutputs[i];
        outputLayer->nodes[i].delta = out * (1.0f - out) * (outputs[i] - out);
    }
    // update all deltas to the errors in the other layers
    for (unsigned long i = nn->layerCount - 2; i != ~0UL; i--)
    {
        for (unsigned long j = 0; j < nn->layers[i].nodeCount; j++)
        {
            float val = nn->layers[i].nodes[j].value;
            float downstreamSum = 0.0f;
            for (unsigned long k = 0; k < nn->layers[i].nodes[j].weightCount; k++)
            {
                float weight = nn->layers[i].nodes[j].weights[k];
                float downstreamDelta  = nn->layers[i + 1].nodes[k].delta;
                downstreamSum += (weight * downstreamDelta);
            }
            nn->layers[i].nodes[j].delta = val * (1.0f - val) * downstreamSum;
        }
    }
    // adjust all weights
    for (unsigned long i = 0; i < nn->layerCount - 1; i++)
    {
        for (unsigned long j = 0; j < nn->layers[i].nodeCount; j++)
        {
            float value = nn->layers[i].nodes[j].value;
            for (unsigned long k = 0; k < nn->layers[i].nodes[j].weightCount; k++)
            {
                float weightDelta = nn->layers[i].nodes[k].delta * value * learningRate;
                nn->layers[i].nodes[j].weights[k] += weightDelta;
            }
        }
    }
    //NN_Debug_DumpNetwork(nn, 1);
}

void NN_Solve ( NeuralNetwork* nn, unsigned long numInputs, const float* inputs, unsigned long numOutputs, float* outputs )
{
    ClearNN(nn);
    // set the input values
    for (unsigned long i = 0; i < numInputs; i++)
    {
        nn->layers[0].nodes[i].value = inputs[i];
    }
    // propagate forward
    for (unsigned long i = 0; i < (nn->layerCount - 1); i++)
    {
        // use the weights to move the values forward
        for (unsigned long j = 0; j < nn->layers[i].nodeCount; j++)
        {
            for (unsigned long k = 0; k < nn->layers[i].nodes[j].weightCount; k++)
            {
                nn->layers[i + 1].nodes[k].value += nn->layers[i].nodes[j].value * nn->layers[i].nodes[j].weights[k];
            }
        }
        // then activate
        for (unsigned long j = 0; j < nn->layers[i + 1].nodeCount; j++)
        {
            nn->layers[i + 1].nodes[j].value = ActivationFunction(nn->model, nn->layers[i + 1].nodes[j].value);
        }
    }
    // write the output values
    for (unsigned long i = 0; i < numOutputs; i++)
    {
        outputs[i] = nn->layers[nn->layerCount - 1].nodes[i].value;
    }
}

void NN_Debug_DumpNetwork ( NeuralNetwork* nn, int deltas )
{
    puts("--------------------------------------------------------");
    for (unsigned int i = 0; i < nn->layerCount; i++)
    {
        for (unsigned int j = 0; j < nn->layers[i].nodeCount; j++)
        {
            printf(" | %1.3f | ", deltas ? nn->layers[i].nodes[j].delta : nn->layers[i].nodes[j].value );
        }
        puts("");
    }
    puts("--------------------------------------------------------");
}
