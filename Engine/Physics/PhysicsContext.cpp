#include "PhysicsContext.h"
#include "PhysicsObject.h"
#include <vector>
#include <map>

namespace
{

using namespace Physics;

const unsigned qtMax = 7;

typedef std::vector<Object*> NodeVector;

class Quadtree
{
private:
    void Descend ();
public:
    Quadtree ( vec2 lower_left, vec2 upper_right, Quadtree* _parent = NULL );
    ~Quadtree ();
    void InsertObject ( Object* obj );
    NodeVector ObjectsInCircle ( vec2 centre, float radius );
    vec2 llPosition;
    vec2 trPosition;
    Quadtree* parent;
    Quadtree* ll;
    Quadtree* lr;
    Quadtree* tl;
    Quadtree* tr;
    NodeVector nodes;
};

inline bool InRange ( float lower_bound, float upper_bound, float point )
{
    return point > lower_bound && point <= upper_bound;
}

inline bool CircleCollision ( vec2 circle1, float radius1, vec2 circle2, float radius2 )
{
    float maximumDistanceSquared = (radius1 + radius2) * (radius1 + radius2);
    float actualDistanceSquared = vec2::DistanceSquared(circle1, circle2);
    return actualDistanceSquared <= maximumDistanceSquared;
}

NodeVector Quadtree::ObjectsInCircle ( vec2 circle, float radius )
{
    NodeVector returnValue;
    // find objects stored in this quadtree
    for (NodeVector::iterator iter = nodes.begin(); iter != nodes.end(); iter++)
    {
        if (CircleCollision(circle, radius, (*iter)->position, (*iter)->collisionRadius))
        {
            returnValue.push_back(*iter);
        }
    }
    if (!ll) // if no subtrees, return this as-is
        return returnValue;
    // find objects stored in the child quadtrees
    float x, y;
    float left, right;
    float top, bottom;
    float midX, midY;
    x = circle.X();
    y = circle.Y();
    left = x - radius;
    right = x + radius;
    top = y + radius;
    bottom = y - radius;
    midX = (llPosition.X() + trPosition.X()) / 2.0f;
    midY = (llPosition.Y() + trPosition.Y()) / 2.0f;
    if (top > midY && left < midX)
    {
        // need to descend into top left quadtree
        NodeVector resultingVector = tl->ObjectsInCircle(circle, radius);
        returnValue.insert(returnValue.end(), resultingVector.begin(), resultingVector.end());
    }
    if (top > midY && right > midX)
    {
        // top right quadtree
        NodeVector resultingVector = tr->ObjectsInCircle(circle, radius);
        returnValue.insert(returnValue.end(), resultingVector.begin(), resultingVector.end());
    }
    if (bottom < midY && right > midX)
    {
        // lower right quadtree
        NodeVector resultingVector = lr->ObjectsInCircle(circle, radius);
        returnValue.insert(returnValue.end(), resultingVector.begin(), resultingVector.end());
    }
    if (bottom < midY && left < midX)
    {
        // lower left quadtree
        NodeVector resultingVector = ll->ObjectsInCircle(circle, radius);
        returnValue.insert(returnValue.end(), resultingVector.begin(), resultingVector.end());
    }
    return returnValue;
}

void Quadtree::Descend ()
{
    float leftX, rightX, midX, topY, bottomY, midY;
    leftX = llPosition.X();
    rightX = trPosition.X();
    topY = trPosition.Y();
    bottomY = llPosition.Y();
    midX = (leftX + rightX) / 2.0f;
    midY = (topY + bottomY) / 2.0f;
    ll = new Quadtree(vec2(leftX, bottomY), vec2(midX, midY), this);
    lr = new Quadtree(vec2(midX, bottomY), vec2(rightX, midY), this);
    tl = new Quadtree(vec2(leftX, midY), vec2(rightX, midY), this);
    tr = new Quadtree(vec2(midX, midY), vec2(rightX, topY), this);
    // distribute all current nodes
    NodeVector oldCopy = nodes;
    nodes.clear();
    for (NodeVector::iterator iter = oldCopy.begin(); iter != oldCopy.end(); iter++)
    {
        InsertObject(*iter);
    }
}

void Quadtree::InsertObject ( Object* obj )
{
    if (nodes.size() < qtMax)
    {
        nodes.push_back(obj);
    }
    else
    {
        if (!ll)
            Descend();
        // get relevant information for neatness checking
        float radius;
        float x, y;
        float left, right;
        float top, bottom;
        float midX, midY;
        x = obj->position.X();
        y = obj->position.Y();
        radius = obj->collisionRadius;
        left = x - radius;
        right = x + radius;
        top = y + radius;
        bottom = y - radius;
        midX = (llPosition.X() + trPosition.X()) / 2.0f;
        midY = (llPosition.Y() + trPosition.Y()) / 2.0f;
        // is it a nasty case, crossing the borderline?
        if (InRange(left, right, midX) ||
            InRange(top, bottom, midY))
        {
            // yes, it is :/
            nodes.push_back(obj);
        }
        else
        {
            if (!ll) // create the subquadrants
                Descend();
            // determine the quadrant
            if (x < midX && y < midY)
            {
                ll->InsertObject(obj);
            }
            else if (x > midX && y < midY)
            {
                lr->InsertObject(obj);
            }
            else if (x < midX && y > midY)
            {
                tl->InsertObject(obj);
            }
            else
            {
                tr->InsertObject(obj);
            }
        }
    }
}

Quadtree::Quadtree ( vec2 lower_left, vec2 upper_right, Quadtree* _parent )
 : llPosition(lower_left),
   trPosition(upper_right),
   parent(_parent),
   ll(NULL),
   lr(NULL),
   tl(NULL),
   tr(NULL)
{
}

Quadtree::~Quadtree ()
{
    if (ll)
    {
        delete ll;
        delete lr;
        delete tl;
        delete tr;
    }
}

}

namespace Physics
{

static unsigned nextObjectID;
typedef std::map<unsigned, Object*> ObjectMap;
static ObjectMap objects;
static std::vector<Collision> currentCollisions;
static float friction;
static Quadtree* currentTree = NULL;

void Open ( float _friction )
{
    nextObjectID = 1;
    friction = _friction;
}

void Close ()
{
    if (currentTree)
    {
        delete currentTree;
        currentTree = NULL;
    }
    currentCollisions.clear();
    for (ObjectMap::iterator iter = objects.begin(); iter != objects.end(); iter++)
    {
        delete iter->second;
    }
    objects.clear();
}

void Update ( float timestep )
{
    currentCollisions.clear();
    if (currentTree)
    {
        delete currentTree;
        currentTree = NULL;
    }
    // step physics and construct frame quadtree
    currentTree = new Quadtree ( vec2(-10000.0f, -10000.0f), vec2(10000.0f, 10000.0f) );
    for (ObjectMap::iterator iter = objects.begin(); iter != objects.end(); iter++)
    {
        Object* obj = iter->second;
        obj->Update(timestep, friction);
        currentTree->InsertObject(obj);
    }
    // handle collision detection
    for (ObjectMap::iterator iter = objects.begin(); iter != objects.end(); iter++)
    {
        Object* obj = iter->second;
        vec2 objPosition = obj->position;
        float objRadius = obj->collisionRadius;
        NodeVector otherObjects = currentTree->ObjectsInCircle(objPosition, objRadius);
        for (NodeVector::iterator iter = otherObjects.begin(); iter != otherObjects.end(); iter++)
        {
            Object* other = (*iter);
            if (obj != other)
            {
                // we have a collision
                currentCollisions.push_back(std::make_pair(obj, other));
            }
        }
    }
}

Object* NewObject ( float mass )
{
    if (mass <= 0.0f)
        return NULL;
    Object* theObject = new Object;
	theObject->mass = mass;
    unsigned id = nextObjectID++;
    theObject->objectID = id;
    objects[id] = theObject;
    return theObject;
}

void DestroyObject ( Object* object )
{
    assert(object);
    unsigned id = object->objectID;
    delete object;
    objects.erase(objects.find(id));
}

Object* ObjectWithID ( unsigned objID )
{
    return objects[objID];
}

std::vector<Collision> GetCollisions ()
{
    return currentCollisions;
}

}
