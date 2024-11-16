/*
Question 1: Model in Alloy the concept of cube and the piling constraints defined
above.

Question 2: Model also the predicate canPileUp that, given two cubes, is true
if the first can be piled on top of the second and false otherwise.

Question 3: Consider now the possibility of finishing towers with a top
component having a shape that prevents further piling, for instance, a pyramidal
or semispherical shape. This top component can only be the last one of a tower,
in other words, it cannot have any other component piled on it.
Rework your model to include also this component. You do not need to consider
a specific shape for it, but only its property of not allowing further piling on its
top. Modify also the canPileUp predicate so that it can work both with cubes
and top components.
*/


abstract sig Size{} // abstract class for size

one sig Large extends Size{}
one sig Medium extends Size{}
one sig Small extends Size{}

abstract sig Block {}

sig Top extends Block {}
sig Cube extends Block {
	size: Size,
	cubeUp: lone Block
	}{ cubeUp != this }

// no circular piling
fact noCircularPiling {
	no c: Cube | c in c.^cubeUp // no cube is in its own transitive closure
}

// the following fact is not necessary
fact pilingUpRules {
all c1, c2: Cube |
	c1.cubeUp = c2
	implies
	( c1.size = Large or
	c1.size = Medium and (c2.size = Medium or c2.size = Small) or
	c1.size = Small and c2.size = Small )
}
// it is still possible for a cube to be on top of two different cubes
// this is not explicitly ruled out by the specification

// canPileUp predicate
pred canPileUp[cUp: Cube, cDown: Cube] {
	cDown != cUp // a cube cannot be on top of itself
	and
	( cDown.size = Large // the cube on top must be larger
	or
	cDown.size = Medium and (cUp.size = Medium or cUp.size = Small)
	or
	cDown.size = Small and cUp.size = Small )
}

// canPileUp predicate for Top
pred canPileUp[bUp: Block, bDown: Block] {
	bDown != bUp and
	bDown in Cube and
	( bUp in Top
	or
	bDown.size = Large
	or
	bDown.size = Medium and (bUp.size = Medium or bUp.size = Small)
	or
	bDown.size = Small and bUp.size = Small )
	}

pred show{}
run show 
