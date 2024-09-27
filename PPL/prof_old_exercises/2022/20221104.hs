data Point = Point Float Float deriving (Show, Eq)

pointx (Point x _) = x
pointy (Point _ y) = y

distance :: Point -> Point -> Float
distance (Point x1 y1) (Point x2 y2) = 
    let dx = x1 - x2
        dy = y1 - y2
    in sqrt $ dx^2 + dy^2 

data APoint = Apoint { apx, apy :: Float } deriving (Show, Eq)

type TPoint = (Float, Float)

distancet :: TPoint -> TPoint -> Float
distancet (x1,y1) (x2,y2) = 
    let dx = x1 - x2
        dy = y1 - y2
    in sqrt $ dx^2 + dy^2 

pointxt = fst
pointyt = snd

newtype NPoint = NPoint (Float, Float) -- we need a data constr. because they are different types
-- data NPoint = NPoint (Float, Float)

myFilter :: (a -> Bool) -> [a] -> [a]
myFilter _ [] = []
myFilter f (x:xs) 
    | f x = x : myFilter f xs
    | otherwise = myFilter f xs
-- = if f x then x .... else myFilter ...

-- zip  [1,2,3] [3,4,5]  [(1,2),(2,4),(3,5)]
myZip :: [a] -> [b] -> [(a,b)]
myZip [] _ = []
myZip _ [] = []
myZip (x:xs) (y:ys) = (x,y) : myZip xs ys

-- zipWith f [1,2] [3,4]  --->  [f 1 3, f 2 4]
-- myZipWith :: (a -> b -> c) -> [a] -> [b] -> [c]
myZipWith _ [] _ = []
myZipWith _ _ [] = []
myZipWith f (x:xs) (y:ys) = (f x y) : myZipWith f xs ys

-- sumf [1,2,3,4] ---> 1+2+3+4
sumf :: Num a => [a] -> a
sumf = foldr (+) 0

elemf x = foldr (\a b -> a == x || b) False
filterf p = foldr (\a b -> if p a then (a:b) else b) []

mapf f = foldr (\a b -> f a : b) []

-- (++) aka append
appf l1 l2 = foldr (:) l2 l1 


data BTree a = BEmpty | BNode a (BTree a) (BTree a) 

bleaf x = BNode x BEmpty BEmpty

instance Show a => Show (BTree a) where
    show BEmpty = ""
    show (BNode v x y) = "<" ++ show x ++ " " ++ show v ++ " " ++ show y ++ ">" 


t1 = BNode 1 (bleaf 2) (BNode 3 (bleaf 4) (bleaf 5))
t2 = BNode 1 (BNode 2 (bleaf 3) (bleaf 4)) (bleaf 5)

bToList :: (BTree a) -> [a]
bToList BEmpty = []
bToList (BNode v x y) = [v] ++ (bToList x) ++ (bToList y)

instance Eq a => Eq (BTree a) where
    x == y = (bToList x) == (bToList y) 

bmap f BEmpty = BEmpty
bmap f (BNode v x y) = BNode (f v) (bmap f x) (bmap f y)

-- infinite binary trees
-- binf :: Integer -> BTree Integer
binf x = 
    let t = binf (x+1)
    in BNode x t t 

