

/* Singleton should be considered only if all three of the following criteria
 * are satisfied:
 * - Ownership of the single instance cannot be reasonably assigned
 * - Lazy initialization is desirable
 * - Global access is not otherwise provided for
 */

class Singleton {
public:
  static Singleton& getInstance();

private:
  Singleton();  // Clients cannot call this function; it's private
  ~Singleton(); // ... nor can they call this one

  static Singleton instance; // ... but they can be used here because
                             // instance is part of the class.
};

Singleton Singleton::instance;


Singleton& Singleton::getInstance()
{
  if (!instance) {
    // Do "lazy initialization" in the accesor function
    // if (type == "xxx") 
    instance = new Singleton();
    // else
    // instance = new OtherClass();
  }

  return instance;
}
