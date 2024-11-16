/*
• The company TravelSpaces decides to help tourists visiting a city in
finding places that can keep their luggage for some time. The
company establishes agreements with small shops in various areas of
the city and acts as a mediator between these shops and the tourists
that need to leave their luggage in a safe place.

• To this end, the company wants to build a system, called
LuggageKeeper, that offers tourists the possibility to: look for luggage
keepers in a certain area; reserve a place for the luggage in the
selected place; pay for the service when they are at the luggage
keeper; and, optionally, rate the luggage keeper at the end of the
service.

Question 1
• Identify world and shared phenomena
• Define a use case diagram for this case
• Define a domain model in terms of a class diagram

Question 2
• Formalize through an Alloy model:
• The world and machine phenomena identified above.
• A predicate capturing the domain assumption D1 that a piece of luggage is
safe if, and only if, it is with its owner, or it is stored in a locker that has an
associated key, and the owner of the piece of luggage holds the key of the
locker.
• A predicate capturing the requirement R1 that a key opens only one locker.
• A predicate capturing the goal G1 that for each user all his/her luggage is safe.
• A predicate capturing the operation GenKey that, given a locker that is free,
associates with it a new electronic key.
• Remark: You are not required to write all requirements and
assumptions that make G1 hold, but only to formalize what is listed.

Q1

World phenomena
• Some users own various pieces of luggage.
• Some users carry around various pieces of luggage.
• Some pieces of luggage are safe
• Some pieces of luggage are unsafe.
• Small shops store the luggage in lockers.

Shared phenomena
• Some lockers are opened with an electronic key.
• Some users hold various electronic keys.
*/


abstract sig Status{}
one sig Safe extends Status{}
one sig Unsafe extends Status{}


sig Luggage{
    luggageStatus : one Status
}
sig EKey{}

sig User{
    owns : set Luggage,
    carries : set Luggage,
    hasKeys : set EKey
}
sig Locker{
    var hasKey : lone EKey,
    var storesLuggage : lone Luggage
}
sig Shop{
    lockers : some Locker
}


fact DAsafeLuggages {
    all lg : Luggage |
        lg.luggageStatus in Safe // a piece of luggage is safe if, and only if, it is with its owner, or it is stored in a locker that has an associated key, and the owner of the piece of luggage holds the key of the locker.
            iff
                all u : User | lg in u.owns
                    implies
                    ( lg in u.carries
                    or
                        some lk : Locker | lg in lk.storesLuggage and
                        lk.hasKey != none and
                        lk.hasKey in u.hasKeys )
}

fact requirement {
    all ek : EKey | no disj lk1, lk2: Locker | ek in lk1.hasKey // a key opens only one locker
    and
    ek in lk2.hasKey // 
}

pred goal {
    all u : User, lg : Luggage | lg in u.owns // for each user all his/her luggage is safe
    implies
    lg.luggageStatus in Safe
}

pred GenKey[lk : Locker] { // given a locker that is free, associates with it a new electronic key
    //precondition
    lk.hasKey = none
    //postcondition
    lk.storesLuggage' = lk.storesLuggage
    one ek : EKey | lk.hasKey' = ek
}


pred show{}
run show

