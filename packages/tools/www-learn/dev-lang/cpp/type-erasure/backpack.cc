/* Let's take an RPG game as an example. The game has different kinds of items:
 * weapons of various types, armor of various types, helmets of various types,
 * scrolls, magic potions, etc, etc. I was to be able to store all of these in my 
 * backpack. Immediately an STL container comes to mind - perhaps a deque.
 * But that means that either I must make one class called Item that is a superset
 * of attributes of all the different kinds of items, or I must make Item a base class
 * of all those types. But then, once I've stored the item in the backpack, I've lost
 * its real type. If I want to prevent the player from, say, wieldin a scroll as a
 * weapon or donning  a flashlight for armor, I must resort to downcasts to check if
 * the item is really the right type.
 *
 * But there is an alternative:
 */
 
#include<iostream>
#include<string>
#include<typeinfo>
#include<vector>
 
// enum {SWORD,CHAIN_MAIL,HEALING,SLEEP};

/*
class Weapon {};
class Armor {};
class Helmet {};
class Scroll {};
class Potion {};
*/

struct Weapon {
   bool can_attack() const { return true; } // All weapons can do damage
};

struct Armor {
   bool can_attack() const { return false; } // Cannot attack with armor...
};

struct Helmet {
   bool can_attack() const { return false; } // Cannot attack with helmet...
};

struct Scroll {
   bool can_attack() const { return false; }
};

struct FireScroll {
   bool can_attack() const { return true; }
};

struct Potion {
   bool can_attack() const { return false; }  
};


struct PoisonPotion {
   bool can_attack() const { return true; }
};


class Object {
   struct ObjectConcept {   
       virtual ~ObjectConcept() {}
       virtual bool has_attack_concept() const = 0;
       virtual std::string name() const = 0;
   };

   template< typename T > struct ObjectModel : ObjectConcept {
       ObjectModel( const T& t ) : object( t ) {}
       virtual ~ObjectModel() {}
       virtual bool has_attack_concept() const
           { return object.can_attack(); }
       virtual std::string name() const
           {  return typeid( object ).name; }
     private:
       T object;
   };

   //boost::shared_ptr<ObjectConcept> object;
   ObjectConcept *object;

  public:
   template< typename T > Object( const T& obj ) :
      object( new ObjectModel<T>( obj ) ) {}

   std::string name() const
      { return object->name(); }

   bool has_attack_concept() const
      { return object->has_attack_concept(); }
};


int main() {
	typedef std::vector< Object >    Backpack;
	typedef Backpack::const_iterator BackpackIter;

	Backpack backpack;

	backpack.push_back(Object(Weapon( /* SWORD */ )));
	backpack.push_back(Object(Armor( /* CHAIN_MAIL */ )));
	backpack.push_back(Object(Potion( /* HEALING */ )));
	backpack.push_back(Object(Scroll( /* SLEEP */ )));

	
	BackpackIter it = backpack.begin();
	const BackpackIter end = backpack.end();
	std::cout << "Items I can attack with:" << std::endl;
	for(;it!=end;++it) {
		if( it->has_attack_concept() )
			std::cout << it->name();
	}
	
/*	
	backpack.push_back(Object(Weapon(SWORD)));
	backpack.push_back(Object(Armor(CHAIN_MAIL)));
	backpack.push_back(Object(Potion(HEALING)));
	backpack.push_back(Object(Scroll(SLEEP)));
*/	
	return 0;
};