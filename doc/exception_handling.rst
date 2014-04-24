.. toctree::
   :maxdepth: 2

==================
Exception Handling
==================

This evolved from a discussion with Marcus on exactly what is best practice for
exception handling in python. This is a good question, and though
there are probably different camps, another good question is to decide how we'll
do it throughout rocon to maintain some readable consistency in the code.

Overview
========

This document is written from the perspective of a library/module developer. Some common guidelines:

1. Gracefully handle errors you know how to handle.
2. Do not silence exceptions that you cannot handle or do not know.
3. If necessary, use a global exception handler (at the highest level) to (hopefully) gracefully handle unexpected errors.


Recommendations
===============

Use Exceptions for 1% Situations
--------------------------------

A try/except block is extremely efficient if no exceptions are raised. Actually catching an exception is expensive. An example:

.. code-block:: python

   try:
       value = mydict[key]
   except KeyError:
       mydict[key] = getvalue(key)
       value = mydict[key]

This only makes sense when you expect the dict to have the key almost all the time. If that wasn’t the case, you code it like this:
   
.. code-block:: python

   if key in mydict:
       value = mydict[key]
   else:
       value = mydict[key] = getvalue(key)

.. note:: Note In Python 2.0 and higher, you can do even better and code this as value = mydict.setdefault(key, getvalue(key)).

Refining Exceptions
-------------------

There are often times when a lower level library you import throws exceptions
that you don't actually wish to handle. You simply want to pass them up the tree.

An example, urllib throws a ``socket.error``. One very useful way of passing this
up the tree is to **refine the exception**. e.g.

.. code-block:: python

   try:
      # some code doing authentication for rocon interactions
      # it uses some urllib functions which throw socket.errors
   catch socket.error as e:
      raise InteractionsAuthenticationError("some msg....")

This makes it more readable and provides more flexibility for the user of your library.

Other Unhandled Exceptions
--------------------------

Again, what to do with lower level exceptions that are thrown, but you don't want to handle. How do
you make it nice and easy for your library user to know that he's got to handle these exceptions
that are coming his way? 

**Good Documentation** 

.. code-block:: python

    def foo():
        '''
        :raises: :exc:`urllib.error.ContentTooShortError` if download content-length error occurred.
        '''

Quite often this is all a user sees of your module. e.g.
I almost never looking into *rospy* code, but I'm constantly hitting Ken's well written rospy api
documentation looking for what arg types there are and what exceptions are getting raised.

**Re-Raising Exceptions**

The following could potentially assist readability in code:

.. code-block:: python

   try:
      # something
   catch SomeLowerLevelException:
      raise

However, catching exceptions is said to be very expensive. *I do not know* if the above is more expensive
than just letting it float up, so I am avoiding it for now.

Don't Hide Exceptions
---------------------

In the python world, **hiding**, or masking exceptions is considered very bad practice because
you take control away from your users. Even if you're writing a module for an executable
(e.g. rapp manager) don't be surprised if someone links and uses one of your package's classes,
or modules one day...thus becoming your library user (I do this all the time with Ken's python code,
half of which have comments about not recommending its use).

A DONT DO THIS example - *hiding known exceptions*:

.. code-block:: python

    try:
        self._publishers['app_list'].publish(rapp_list)
    except KeyError:  
        pass

I just spent 20mins hunting a bug in the rapp manager because this should have been 'rapp_list' not 'app_list'.

Be Scared of the Mother of All Exceptions
-----------------------------------------

The Mother of All Exceptions, ``Exception`` should not be used directly, use one from the standard exception heirarchy
<https://docs.python.org/2/library/exceptions.html#exception-hierarchy> or customise your own. The key problems here
are that you are handling something that may not be what you expect, or you are hiding it from user's above.

A DONT DO THIS example - *hiding the MOTHER OF ALL exceptions*:

.. code-block:: python

    try:
        yourapi.call_me()
    except APIKnownError as e:
        report(e)
    except Exception:
        pass

If you don't know what's floating up, the worst possible thing to do is hide it. 

Another DONT DO THIS example - *handling the MOTHER OF ALL exceptions*:

.. code-block:: python

    try:
        foo = opne("file") # misspelled "open"
    except Exception as e:
        sys.exit("could not open file!")

Here it's hard to know that it was a programming error that raised a ``NameError`` and not
related to opening the file, i.e. a ``IOError``.

Unknown Exceptions
------------------

Ok, so we don't hide unknown exceptions and since we don't know what they are, we can't handle them so
you can probably safely conclude that your *program is now rogue and likely soon to be fubar* no matter
what you're thinking of doing. So I typically transfer the problem to optimising how quickly we can
identify what is getting thrown and then fix it.

While in *development*, for most programs I prefer to let **unknown exceptions float up and crash the program**. Why?

* A crash will startle your co-developers and they'll feel the need to do something.
* The alternative is to catch and log errors, which has a tendency to be missed, ignored if it doesn't affect their module.

I'd much rather them jump up and down, come and annoy me, or have a rant on a github issue so the problem immediately
comes into focus. Fixing these issues quickly is important because python makes it hard to catch every conceivable problem
at compile time.

For a *product* or a critical program that needs the best chance to exit gracefully (e.g. a powerful manipulator)
there are of course other considerations that might be important enough to change this philosophy.


