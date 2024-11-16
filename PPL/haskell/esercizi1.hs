module Example1 where

-- in cli: ghci
--        :l esercizi1.hs

hello = "Hello, World!"

y = x + 1 -- y = 4

x = 3

greet name = "Hello, " ++ name ++ "!"

listOfNumbers = [1 .. 5]

data Food = Fruit | Dairy | Fish | Meat -- kinda like an enum

dish = Fruit

-- left hand side is the type (type constructor), right hand side is the value (data constructor)
data Point2d a = P2D a a

p1 = P2D 0 0

p2 = P2D 4 5

manhattanDist :: Num a => Point2d a -> Point2d a -> a
manhattanDist
  (P2D x0 y0)
  (P2D x1 y1) = abs (x0 - x1) + abs (y0 - y1)

data Point3D a = Point3D
  { pointX :: a,
    pointY :: a,
    pointZ :: a
  }

p3 = Point3D 1 2 3

getX (Point3D x _ _) = x

getY (Point3D _ y _) = y

getZ (Point3D _ _ z) = z

--TREES

data BinTree a = Leaf a | Branch (BinTree a) (BinTree a)

mytree = Branch (Leaf 'a') (Branch (Leaf 'b') (Leaf 'c'))

--sum :: Int -> Int -> Int

add1 = (1 +)

-- = \x -> 1 + x

-- in cli: map add1 listOfNumbers

cylinderArea r h =
  let sideArea = 2 * pi * r * h
      topArea = pi * r ^ 2
   in sideArea + 2 * topArea

cylinderArea' r h = sideArea + 2 * topArea
  where
    sideArea = 2 * pi * r * h
    topArea = pi * r ^ 2

myInfinityListOfNums = [1 ..]

--in cli: take 10 myInfinityListOfNums

myInfinityListOfEvenNums = [x * 2 | x <- [0, 1 ..]]

pythagTriples = 
    [(a, b, c) | c <- [1 ..], 
                b <- [1 .. c], 
                a <- [1 .. b], 
                a ^ 2 + b ^ 2 == c ^ 2
                ]

myInfinityListOfEvenNumsMod4 = [x * 2 | x <- [0, 1 ..], x `mod` 4 == 0]

mult x y = x * y

